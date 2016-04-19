# 2.0.7
 - Update to jruby-kafka 1.6 which includes Kafka 0.8.2.2 enabling LZ4 decompression.
 
# 2.0.6
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash

# 2.0.5
  - New dependency requirements for logstash-core for the 5.0 release

## 2.0.4
 - Fix safe shutdown while plugin waits on Kafka for new events
 - Expose auto_commit_interval_ms to control offset commit frequency

## 2.0.3
 - Fix infinite loop when no new messages are found in Kafka

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

