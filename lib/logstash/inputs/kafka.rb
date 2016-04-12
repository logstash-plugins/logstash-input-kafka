require 'logstash/namespace'
require 'logstash/inputs/base'
require 'jruby-kafka'
require 'stud/interval'

# This input will read events from a Kafka topic. It uses the high level consumer API provided
# by Kafka to read messages from the broker. It also maintains the state of what has been
# consumed using Zookeeper. The default input codec is json
#
# You must configure `topic_id`, `white_list` or `black_list`. By default it will connect to a
# Zookeeper running on localhost. All the broker information is read from Zookeeper state
#
# Ideally you should have as many threads as the number of partitions for a perfect balance --
# more threads than partitions means that some threads will be idle
#
# For more information see http://kafka.apache.org/documentation.html#theconsumer
#
# Kafka consumer configuration: http://kafka.apache.org/documentation.html#consumerconfigs
#
class LogStash::Inputs::Kafka < LogStash::Inputs::Base
  config_name 'kafka'

  default :codec, 'json'

  # Specifies the ZooKeeper connection string in the form hostname:port where host and port are
  # the host and port of a ZooKeeper server. You can also specify multiple hosts in the form
  # `hostname1:port1,hostname2:port2,hostname3:port3`.
  #
  # The server may also have a ZooKeeper chroot path as part of it's ZooKeeper connection string
  # which puts its data under some path in the global ZooKeeper namespace. If so the consumer
  # should use the same chroot path in its connection string. For example to give a chroot path of
  # `/chroot/path` you would give the connection string as
  # `hostname1:port1,hostname2:port2,hostname3:port3/chroot/path`.
  config :zk_connect, :validate => :string, :default => 'localhost:2181'
  # A string that uniquely identifies the group of consumer processes to which this consumer
  # belongs. By setting the same group id multiple processes indicate that they are all part of
  # the same consumer group.
  config :group_id, :validate => :string, :default => 'logstash'
  # The topic to consume messages from
  config :topic_id, :validate => :string, :default => nil
  # Whitelist of topics to include for consumption.
  config :white_list, :validate => :string, :default => nil
  # Blacklist of topics to exclude from consumption.
  config :black_list, :validate => :string, :default => nil
  # Reset the consumer group to start at the earliest message present in the log by clearing any
  # offsets for the group stored in Zookeeper. This is destructive! Must be used in conjunction
  # with auto_offset_reset => 'smallest'
  config :reset_beginning, :validate => :boolean, :default => false
  # `smallest` or `largest` - (optional, default `largest`) If the consumer does not already
  # have an established offset or offset is invalid, start with the earliest message present in the
  # log (`smallest`) or after the last message in the log (`largest`).
  config :auto_offset_reset, :validate => %w( largest smallest ), :default => 'largest'
  # The frequency in ms that the consumer offsets are committed to zookeeper.
  config :auto_commit_interval_ms, :validate => :number, :default => 1000
  # Number of threads to read from the partitions. Ideally you should have as many threads as the
  # number of partitions for a perfect balance. More threads than partitions means that some
  # threads will be idle. Less threads means a single thread could be consuming from more than
  # one partition
  config :consumer_threads, :validate => :number, :default => 1
  # Internal Logstash queue size used to hold events in memory after it has been read from Kafka
  config :queue_size, :validate => :number, :default => 20
  # When a new consumer joins a consumer group the set of consumers attempt to "rebalance" the
  # load to assign partitions to each consumer. If the set of consumers changes while this
  # assignment is taking place the rebalance will fail and retry. This setting controls the
  # maximum number of attempts before giving up.
  config :rebalance_max_retries, :validate => :number, :default => 4
  # Backoff time between retries during rebalance.
  config :rebalance_backoff_ms, :validate => :number, :default => 2000
  # Throw a timeout exception to the consumer if no message is available for consumption after
  # the specified interval
  config :consumer_timeout_ms, :validate => :number, :default => -1
  # Option to restart the consumer loop on error
  config :consumer_restart_on_error, :validate => :boolean, :default => true
  # Time in millis to wait for consumer to restart after an error
  config :consumer_restart_sleep_ms, :validate => :number, :default => 0
  # Option to add Kafka metadata like topic, message size to the event.
  # This will add a field named `kafka` to the logstash event containing the following attributes:
  #   `msg_size`: The complete serialized size of this message in bytes (including crc, header attributes, etc)
  #   `topic`: The topic this message is associated with
  #   `consumer_group`: The consumer group used to read in this event
  #   `partition`: The partition this message is associated with
  #   `offset`: The offset from the partition this message is associated with
  #   `key`: A ByteBuffer containing the message key
  config :decorate_events, :validate => :boolean, :default => false
  # A unique id for the consumer; generated automatically if not set.
  config :consumer_id, :validate => :string, :default => nil
  # The number of byes of messages to attempt to fetch for each topic-partition in each fetch
  # request. These bytes will be read into memory for each partition, so this helps control
  # the memory used by the consumer. The fetch request size must be at least as large as the
  # maximum message size the server allows or else it is possible for the producer to send
  # messages larger than the consumer can fetch.
  config :fetch_message_max_bytes, :validate => :number, :default => 1048576
  # The serializer class for messages. The default decoder takes a byte[] and returns the same byte[]
  config :decoder_class, :validate => :string, :default => 'kafka.serializer.DefaultDecoder'
  # The serializer class for keys (defaults to the same default as for messages)
  config :key_decoder_class, :validate => :string, :default => 'kafka.serializer.DefaultDecoder'

  class KafkaShutdownEvent; end
  KAFKA_SHUTDOWN_EVENT = KafkaShutdownEvent.new

  public
  def register
    LogStash::Logger.setup_log4j(@logger)
    @stream_threads = []
    options = {
        :zookeeper_connect => @zk_connect,
        :group_id => @group_id,
        :topic => @topic_id,
        :auto_offset_reset => @auto_offset_reset,
        :auto_commit_interval_ms => @auto_commit_interval_ms,
        :rebalance_max_retries => @rebalance_max_retries,
        :rebalance_backoff_ms => @rebalance_backoff_ms,
        :consumer_timeout_ms => @consumer_timeout_ms,
        :consumer_id => @consumer_id,
        :fetch_message_max_bytes => @fetch_message_max_bytes,
        :include_topics => @white_list,
        :exclude_topics => @black_list,
        :msg_decoder => @decoder_class,
        :key_decoder => @key_decoder_class,
        :num_streams => @consumer_threads
    }
    if @reset_beginning
      options[:reset_beginning] = 'from-beginning'
    end # if :reset_beginning
    topic_or_filter = [@topic_id, @white_list, @black_list].compact
    if topic_or_filter.count == 0
      raise LogStash::ConfigurationError, 'topic_id, white_list or black_list required.'
    elsif topic_or_filter.count > 1
      raise LogStash::ConfigurationError, 'Invalid combination of topic_id, white_list or black_list. Use only one.'
    end
    @consumer = create_consumer(options)
  end # def register

  public
  def run(logstash_queue)
    # noinspection JRubyStringImportInspection
    java_import 'kafka.common.ConsumerRebalanceFailedException'
    java_import 'kafka.consumer.ConsumerTimeoutException'
    begin
      @logger.info('Running kafka', :group_id => @group_id, :topic => @topic_id, :zookeeper_connect => @zk_connect)
      streams = @consumer.message_streams
      @stream_threads = streams.map {
          |stream| Thread.new {
          consume_stream stream, logstash_queue
        }
      }
      @stream_threads.each { |t| t.join }
    rescue => e
      if !stop? and @consumer_restart_on_error
        @consumer.shutdown
        @logger.warn('kafka client threw exception, restarting',
                     :exception => e)
        Stud.stoppable_sleep(Float(@consumer_restart_sleep_ms) * 1 / 1000) { stop? }
        @logger.debug('joining Kafka streams to rescue ')
        @stream_threads.each { |t| t.join }
        retry
      else
        @logger.error('kafka client threw exception: ',
                     :exception => e)
        raise e
      end # if
    end # begin
  end # def run

  public
  def stop
    @consumer.shutdown
    @stream_threads.each { |t| t.join }
  end

  private
  def create_consumer(options)
    @consumer = Kafka::Consumer.new(options)
  end

  private
  def consume_stream(stream, logstash_queue)
    it = stream.iterator
    begin
      while it.hasNext
        message_and_metadata = it.next
        begin
          @codec.decode("#{message_and_metadata.message}") do |event|
            decorate(event)
            if @decorate_events
              mm_key = message_and_metadata.key
              kafka_key = mm_key.nil? ? nil : "#{mm_key}"
              event['kafka'] = {'msg_size' => message_and_metadata.message.size,
                                'topic' => message_and_metadata.topic,
                                'consumer_group' => @group_id,
                                'partition' => message_and_metadata.partition,
                                'offset' => message_and_metadata.offset,
                                'key' => kafka_key}
            end
            logstash_queue << event
          end # @codec.decode
        rescue => e # parse or event creation error
          @logger.error('Failed to create event', :message => "#{message_and_metadata.message}", :exception => e,
                        :backtrace => e.backtrace)
        end # begin
      end # while
    rescue Exception => e
      @logger.error("#{self.class.name} caught exception: #{e.class.name}")
      @logger.error(e.message) if e.message != ''
      raise e
    end # begin
  end # def consume_stream
end #class LogStash::Inputs::Kafka
