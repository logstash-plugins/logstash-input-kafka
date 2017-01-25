Gem::Specification.new do |s|
  s.name            = 'logstash-input-kafka'
  s.version         = '5.1.6'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = 'This input will read events from a Kafka topic. It uses the high level consumer API provided by Kafka to read messages from the broker'
  s.description     = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.authors         = ['Elasticsearch']
  s.email           = 'info@elastic.co'
  s.homepage        = "http://www.elastic.co/guide/en/logstash/current/index.html"
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*.rb','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { 'logstash_plugin' => 'true', 'group' => 'input'}

  s.requirements << "jar 'org.apache.kafka:kafka-clients', '0.10.0.1'"
  s.requirements << "jar 'org.slf4j:slf4j-log4j12', '1.7.21'"

  s.add_development_dependency 'jar-dependencies', '~> 0.3.2'

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency 'logstash-codec-json'
  s.add_runtime_dependency 'logstash-codec-plain'
  s.add_runtime_dependency 'stud', '>= 0.0.22', '< 0.1.0'

  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency 'rspec-wait'
end

