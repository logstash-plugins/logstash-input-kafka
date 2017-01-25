## 5.1.6
  - fix: Client ID is no longer reused across multiple Kafka consumer instances

## 5.1.5
  - Fix a bug where consumer was not correctly setup when `SASL_SSL` option was specified. 

## 5.1.4
  - Fix log4j bootstrapping for 2.4

## 5.1.3
  - Make error reporting clearer when connection fails
  - set kerberos only when using GSSAPI

## 5.1.2
  - Docs: Move info about security features out of the compatibility matrix and into the main text.
 
## 5.1.1
  - Docs: Clarify compatibility matrix and remove it from the changelog to avoid duplication.
  
## 5.1.0
  - Add Kerberos authentication support.

## 5.0.6
  - default `poll_timeout_ms` to 100ms

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
