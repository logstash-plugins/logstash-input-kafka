require 'logstash/namespace'
require 'logstash/inputs/base'
require 'stud/interval'
require 'java'
require 'logstash-input-kafka_jars.rb'

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

  default :codec, 'plain'

  # The frequency in milliseconds that the consumer offsets are committed to Kafka.
  config :auto_commit_interval_ms, :validate => :string, :default => "10"
  # What to do when there is no initial offset in Kafka or if an offset is out of range:
  #
  # * smallest: automatically reset the offset to the smallest offset
  # * largest: automatically reset the offset to the largest offset
  # * disable: throw exception to the consumer if no previous offset is found for the consumer's group
  # * anything else: throw exception to the consumer.
  config :auto_commit_reset, :validate => :string, :default => "true"
  # A list of URLs to use for establishing the initial connection to the cluster. 
  # This list should be in the form of `host1:port1,host2:port2` These urls are just used 
  # for the initial connection to discover the full cluster membership (which may change dynamically) 
  # so this list need not contain the full set of servers (you may want more than one, though, in 
  # case a server is down).
  config :bootstrap_servers, :validate => :string, :default => "localhost:9092"
  # Automatically check the CRC32 of the records consumed. This ensures no on-the-wire or on-disk 
  # corruption to the messages occurred. This check adds some overhead, so it may be 
  # disabled in cases seeking extreme performance.
  config :check_crcs, :validate => :string
  # The id string to pass to the server when making requests. The purpose of this 
  # is to be able to track the source of requests beyond just ip/port by allowing 
  # a logical application name to be included.
  config :client_id, :validate => :string, :default => "logstash"
  # Close idle connections after the number of milliseconds specified by this config.
  config :connections_max_idle_ms, :validate => :string
  # If true, periodically commit to Kafka the offsets of messages already returned by the consumer. 
  # This committed offset will be used when the process fails as the position from 
  # which the consumption will begin.
  config :enable_auto_commit, :validate => :string, :default => "true"
  # The maximum amount of time the server will block before answering the fetch request if 
  # there isn't sufficient data to immediately satisfy `fetch_min_bytes`. This 
  # should be less than or equal to the timeout used in `poll_timeout_ms`
  config :fetch_max_wait_ms, :validate => :string
  # The minimum amount of data the server should return for a fetch request. If insufficient 
  # data is available the request will wait for that much data to accumulate
  # before answering the request.
  config :fetch_min_bytes, :validate => :string
  # The identifier of the group this consumer belongs to. Consumer group is a single logical subscriber 
  # that happens to be made up of multiple processors. Messages in a topic will be distributed to all 
  # Logstash instances with the same `group_id`
  config :group_id, :validate => :string, :default => "logstash"
  # The expected time between heartbeats to the consumer coordinator. Heartbeats are used to ensure 
  # that the consumer's session stays active and to facilitate rebalancing when new
  # consumers join or leave the group. The value must be set lower than 
  # `session.timeout.ms`, but typically should be set no higher than 1/3 of that value. 
  # It can be adjusted even lower to control the expected time for normal rebalances.
  config :heartbeat_interval_ms, :validate => :string
  # Java Class used to deserialize the record's key
  config :key_deserializer, :validate => :string, :default => "org.apache.kafka.common.serialization.StringDeserializer"
  # The maximum amount of data per-partition the server will return. The maximum total memory used for a 
  # request will be <code>#partitions * max.partition.fetch.bytes</code>. This size must be at least 
  # as large as the maximum message size the server allows or else it is possible for the producer to 
  # send messages larger than the consumer can fetch. If that happens, the consumer can get stuck trying 
  # to fetch a large message on a certain partition.
  config :max_partition_fetch_bytes, :validate => :string
  # The class name of the partition assignment strategy that the client will use to distribute 
  # partition ownership amongst consumer instances
  config :partition_assignment_strategy, :validate => :string
  # The size of the TCP receive buffer (SO_RCVBUF) to use when reading data.
  config :receive_buffer_bytes, :validate => :string
  # The amount of time to wait before attempting to reconnect to a given host. 
  # This avoids repeatedly connecting to a host in a tight loop. 
  # This backoff applies to all requests sent by the consumer to the broker.
  config :reconnect_backoff_ms, :validate => :string
  # The configuration controls the maximum amount of time the client will wait 
  # for the response of a request. If the response is not received before the timeout 
  # elapses the client will resend the request if necessary or fail the request if 
  # retries are exhausted.
  config :request_timeout_ms, :validate => :string
  # The amount of time to wait before attempting to retry a failed fetch request 
  # to a given topic partition. This avoids repeated fetching-and-failing in a tight loop.
  config :retry_backoff_ms, :validate => :string
  # The timeout after which, if the `poll_timeout_ms` is not invoked, the consumer is marked dead 
  # and a rebalance operation is triggered for the group identified by `group_id`
  config :session_timeout_ms, :validate => :string, :default => "30000"
  # Java Class used to deserialize the record's value
  config :value_deserializer, :validate => :string, :default => "org.apache.kafka.common.serialization.StringDeserializer"
  # Ideally you should have as many threads as the number of partitions for a perfect 
  # balance — more threads than partitions means that some threads will be idle
  config :num_threads, :validate => :number, :default => 1
  # A list of topics to subscribe to.
  config :topics, :validate => :array, :required => true
  # Time kafka consumer will wait to receive new messages from topics
  config :poll_timeout_ms, :validate => :number, :default => 100
  config :max_messages, :validate => :number

  public
  def register
    @message_count = 0
    @runner_threads = []
  end # def register

  public
  def run(logstash_queue)
    @runner_consumers = num_threads.times.map { || new_consumer }
    @runner_threads = @runner_consumers.map { |consumer| thread_runner(logstash_queue, consumer) }
    @runner_threads.each { |t| t.join }
  end # def run

  public
  def stop
    @runner_consumers.each { |c| c.wakeup }
  end

  private
  def thread_runner(logstash_queue, consumer)
    Thread.new do
      begin
        consumer.subscribe(topics);
        while !stop?
          records = consumer.poll(poll_timeout_ms);
          for record in records do
            break if !max_messages.nil? && @message_count >= max_messages
            @message_count = @message_count.next
            @codec.decode(record.value.to_s) do |event|
              logstash_queue << event
            end
          end
        end
      rescue org.apache.kafka.common.errors.WakeupException => e
        raise e if !stop?
      ensure
        consumer.close
      end
    end
  end

  private
  def new_consumer 
    props = java.util.Properties.new
    props.put("bootstrap.servers", bootstrap_servers)
    props.put("group.id", group_id);
    props.put("enable.auto.commit", enable_auto_commit);
    props.put("auto.commit.interval.ms", auto_commit_interval_ms);
    props.put("session.timeout.ms", session_timeout_ms);
    props.put("key.deserializer", key_deserializer);
    props.put("value.deserializer", value_deserializer);
    org.apache.kafka.clients.consumer.KafkaConsumer.new(props);
  end
end #class LogStash::Inputs::Kafka
