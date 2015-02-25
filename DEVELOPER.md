logstash-input-kafka
====================

Apache Kafka input for Logstash. This input will consume messages from a Kafka topic using the high level consumer API exposed by Kafka. 

For more information about Kafka, refer to this [documentation](http://kafka.apache.org/documentation.html) 

Information about high level consumer API can be found [here](http://kafka.apache.org/documentation.html#highlevelconsumerapi)

Logstash Configuration
====================

See http://kafka.apache.org/documentation.html#consumerconfigs for details about the Kafka consumer options.

    input {
        kafka {
            topic_id => ... # string (optional), default: nil, The topic to consume messages from. Can be a java regular expression for whitelist of topics.
            white_list => ... # string (optional), default: nil, Blacklist of topics to exclude from consumption.
            black_list => ... # string (optional), default: nil, Whitelist of topics to include for consumption.
            zk_connect => ... # string (optional), default: "localhost:2181", Specifies the ZooKeeper connection string in the form hostname:port
            group_id => ... # string (optional), default: "logstash", A string that uniquely identifies the group of consumer processes
            reset_beginning => ... # boolean (optional), default: false, Specify whether to jump to beginning of the queue when there is no initial offset in ZK
            auto_offset_reset => ... # string (optional), one of [ "largest", "smallest"] default => 'largest', Where consumer should start if group does not already have an established offset or offset is invalid
            consumer_threads => ... # number (optional), default: 1, Number of threads to read from the partitions
            queue_size => ... # number (optional), default: 20, Internal Logstash queue size used to hold events in memory 
            rebalance_max_retries => ... # number (optional), default: 4
            rebalance_backoff_ms => ... # number (optional), default:  2000
            consumer_timeout_ms => ... # number (optional), default: -1
            consumer_restart_on_error => ... # boolean (optional), default: true
            consumer_restart_sleep_ms => ... # number (optional), default: 0
            decorate_events => ... # boolean (optional), default: false, Option to add Kafka metadata like topic, message size to the event
            consumer_id => ... # string (optional), default: nil
            fetch_message_max_bytes => ... # number (optional), default: 1048576
        }
    }

The default codec is json

Dependencies
====================

* Apache Kafka version 0.8.1.1
* jruby-kafka library
