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

  config :auto_commit_interval_ms, :validate => :string, :default => "10"
  config :auto_commit_reset, :validate => :string, :default => "true"
  config :bootstrap_servers, :validate => :string, :default => "localhost:9092"
  config :check_crcs, :validate => :string
  config :client_id, :validate => :string, :default => "logstash"
  config :connections_max_idle_ms, :validate => :string
  config :enable_auto_commit, :validate => :string, :default => "true"
  config :fetch_max_wait_ms, :validate => :string
  config :fetch_min_bytes, :validate => :string
  config :group_id, :validate => :string, :default => "ll"
  config :heartbeat_interval_ms, :validate => :string
  config :key_deserializer, :validate => :string, :default => "org.apache.kafka.common.serialization.StringDeserializer"
  config :max_partition_fetch_bytes, :validate => :string
  config :metadata_max_age_ms, :validate => :string
  config :metric_reporters, :validate => :string
  config :metrics_num_samples, :validate => :string
  config :metrics_sample_window_ms, :validate => :string
  config :partition_assignment_strategy, :validate => :string
  config :receive_buffer_bytes, :validate => :string
  config :reconnect_backoff_ms, :validate => :string
  config :request_timeout_ms, :validate => :string
  config :retry_backoff_ms, :validate => :string
  config :send_buffer_bytes, :validate => :string
  config :session_timeout_ms, :validate => :string, :default => "30000"
  config :value_deserializer, :validate => :string, :default => "org.apache.kafka.common.serialization.StringDeserializer"
  config :num_threads, :validate => :number, :default => 1
  config :topics, :validate => :array, :required => true
  config :timeout_ms, :validate => :number, :default => 100
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
          records = consumer.poll(timeout_ms);
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
