## 8.0.4
  - Upgrade Kafka client to version 1.0.0

## 8.0.3
  - Update gemspec summary

## 8.0.2
  - Fix some documentation issues

## 8.0.1
  - Fixed an issue that prevented setting a custom `metadata_max_age_ms` value

## 8.0.0
  - Breaking: mark deprecated `ssl` option as obsolete

## 7.0.0
  - Breaking: Nest the decorated fields under `@metadata` field to avoid mapping conflicts with beats.
    Fixes #198, #180

## 6.3.4
  - Fix an issue that led to random failures in decoding messages when using more than one input thread

## 6.3.3
  - Upgrade Kafka client to version 0.11.0.0

## 6.3.1
  - fix: Added record timestamp in event decoration

## 6.3.0
  - Upgrade Kafka client to version 0.10.2.1

## 6.2.7
  - Fix NPE when SASL_SSL+PLAIN (no Kerberos) is specified.

## 6.2.6
  - fix: Client ID is no longer reused across multiple Kafka consumer instances

## 6.2.5
  - Fix a bug where consumer was not correctly setup when `SASL_SSL` option was specified. 

## 6.2.4
  - Make error reporting more clear when connection fails 

## 6.2.3
  - Docs: Update Kafka compatibility matrix
  
## 6.2.2
  - update kafka-clients dependency to 0.10.1.1

## 6.2.1
  - Docs: Clarify compatibility matrix and remove it from the changelog to avoid duplication.
  
## 6.2.0
  - Expose config `max_poll_interval_ms` to allow consumer to send heartbeats from a background thread
  - Expose config `fetch_max_bytes` to control client's fetch response size limit

## 6.1.0
  - Add Kerberos authentication support.

## 6.0.1
  - default `poll_timeout_ms` to 100ms

## 6.0.0
  - Breaking: Support for Kafka 0.10.1.0. Only supports brokers 0.10.1.x or later.

## 5.0.5
  - place setup_log4j for logging registration behind version check

## 5.0.4
  - Update to Kafka version 0.10.0.1 for bug fixes

## 5.0.3
  - Internal: gem cleanup

## 5.0.2
  - Release a new version of the gem that includes jars

## 5.0.1
  - Relax constraint on logstash-core-plugin-api to >= 1.60 <= 2.99

## 5.0.0
  - Support for Kafka 0.10 which is not backward compatible with 0.9 broker.

## 4.0.0
  - Republish all the gems under jruby.
  - Update the plugin to the version 2.0 of the plugin api, this change is required for Logstash 5.0 compatibility. See https://github.com/elastic/logstash/issues/5141
  - Support for Kafka 0.9 for LS 5.x

## 3.0.0.beta7
 - Fix Log4j warnings by setting up the logger

## 3.0.0.beta5 and 3.0.0.beta6
 - Internal: Use jar dependency
 - Fixed issue with snappy compression

## 3.0.0.beta3 and 3.0.0.beta4
 - Internal: Update gemspec dependency

## 3.0.0.beta2
 - internal: Use jar dependencies library instead of manually downloading jars
 - Fixes "java.lang.ClassNotFoundException: org.xerial.snappy.SnappyOutputStream" issue (#50)

## 3.0.0.beta2
 - Added SSL/TLS connection support to Kafka
 - Breaking: Changed default codec to plain instead of SSL. Json codec is really slow when used 
   with inputs because inputs by default are single threaded. This makes it a bad
   first user experience. Plain codec is a much better default.

## 3.0.0.beta1
 - Refactor to use new Java based consumer, bypassing jruby-kafka
 - Breaking: Change configuration to match Kafka's configuration. This version is not backward compatible

## 2.0.7
 - Update to jruby-kafka 1.6 which includes Kafka 0.8.2.2 enabling LZ4 decompression.
 
## 2.0.6
  - Depend on logstash-core-plugin-api instead of logstash-core, removing the need to mass update plugins on major releases of logstash

## 2.0.5
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
