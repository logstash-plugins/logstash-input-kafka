Gem::Specification.new do |s|

  s.name            = 'logstash-input-kafka'
  s.version         = '0.1.0'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = 'This input will read events from a Kafka topic. It uses the high level consumer API provided by Kafka to read messages from the broker'
  s.description     = 'This input will read events from a Kafka topic. It uses the high level consumer API provided by Kafka to read messages from the broker'
  s.authors         = ['Elasticsearch']
  s.email           = 'richard.pijnenburg@elasticsearch.com'
  s.homepage        = 'http://logstash.net/'
  s.require_paths = ['lib']

  # Files
  s.files = `git ls-files`.split($\)

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'group' => 'input'}

  # Jar dependencies
  s.requirements << "jar 'org.apache.kafka:kafka_2.9.2', '0.8.1.1'"
  s.requirements << "jar 'log4j:log4j', '1.2.14'"

  # Gem dependencies
  s.add_runtime_dependency 'jar-dependencies', ['~> 0.1.0']

  s.add_runtime_dependency 'jruby-kafka', ['>=0.2.1']

  s.add_runtime_dependency 'logstash', '>= 1.4.0', '< 2.0.0'
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'logstash-codec-json'
end

