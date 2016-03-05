# 3.0.0.beta2
 - Added SSL/TLS connection support to Kafka
 - Breaking: Changed default codec to plain instead of SSL. Json codec is really slow when used 
   with inputs because inputs by default are single threaded. This makes it a bad
   first user experience. Plain codec is a much better default.

# 3.0.0.beta1
 - Refactor to use new Java based consumer, bypassing jruby-kafka
 - Breaking: Change configuration to match Kafka's configuration. This version is not backward compatible

## 2.0.0
 - Plugins were updated to follow the new shutdown semantic, this mainly allows Logstash to instruct input plugins to terminate gracefully, 
   instead of using Thread.raise on the plugins' threads. Ref: https://github.com/elastic/logstash/pull/3895
 - Dependency on logstash-core update to 2.0

