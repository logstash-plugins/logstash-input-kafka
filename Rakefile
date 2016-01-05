require "logstash/devutils/rake"

task :default do
  system('rake -T')
end

desc "Get jars"
task :vendor do
  home_dir = Dir.pwd
  jar_target = "vendor/jar-dependencies"
  runtime_jar_target = "#{jar_target}/runtime-jars"
  test_jar_target = "#{jar_target}/test-jars"
  kafka_version = "0.9.0.0"
  scala_version = "2.11.7"
  kafka_url = "http://central.maven.org/maven2/org/apache/kafka/kafka_2.11/#{kafka_version}/kafka_2.11-#{kafka_version}.jar"
  kafka_clients_url = "http://central.maven.org/maven2/org/apache/kafka/kafka-clients/#{kafka_version}/kafka-clients-#{kafka_version}.jar"
  log4j_version = "1.2.17"
  log4j_url = "http://central.maven.org/maven2/log4j/log4j/#{log4j_version}/log4j-#{log4j_version}.jar"
  slf4j_version = "1.7.13"
  slf4j_url = "http://central.maven.org/maven2/org/slf4j/slf4j-api/#{slf4j_version}/slf4j-api-#{slf4j_version}.jar"
  slf4j_nop_url = "http://central.maven.org/maven2/org/slf4j/slf4j-nop/#{slf4j_version}/slf4j-nop-#{slf4j_version}.jar"
  scala_url = "http://central.maven.org/maven2/org/scala-lang/scala-library/#{scala_version}/scala-library-#{scala_version}.jar"
  zk_url = "http://central.maven.org/maven2/com/101tec/zkclient/0.7/zkclient-0.7.jar"
  scala_parsers_url = "http://central.maven.org/maven2/org/scala-lang/modules/scala-parser-combinators_2.11/1.0.4/scala-parser-combinators_2.11-1.0.4.jar"
  zookeeper_version = "3.4.6"
  zookeeper_url = "https://repo1.maven.org/maven2/org/apache/zookeeper/zookeeper/#{zookeeper_version}/zookeeper-#{zookeeper_version}.jar"

  puts "Will get jars for version #{kafka_version}"
  puts "Removing current jars"
  `rm -rf #{jar_target}`
  `mkdir -p #{runtime_jar_target}`
  `mkdir -p #{test_jar_target}`

  Dir.chdir runtime_jar_target
  puts "Will download #{kafka_clients_url}"
  `curl #{kafka_clients_url} -o kafka-clients-#{kafka_version}.jar`
  puts "Will download #{slf4j_url}"
  `curl #{slf4j_url} -o slf4j-api-#{slf4j_version}.jar`
  puts "Will download #{slf4j_nop_url}"
  `curl #{slf4j_nop_url} -o slf4j-noop-#{slf4j_version}.jar`

  Dir.chdir home_dir

  Dir.chdir test_jar_target
  puts "Will download #{kafka_url}"
  `curl #{kafka_url} -o kafka-#{kafka_version}.jar`
  puts "Will download #{scala_url}"
  `curl #{scala_url} -o scala-#{scala_version}.jar`
  puts "Will download #{zk_url}"
  `curl #{zk_url} -o zk.jar`
  puts "Will download #{scala_parsers_url}"
  `curl #{scala_parsers_url} -o scala-parsers.jar`
  puts "Will download #{log4j_url}"
  `curl #{log4j_url} -o log4j-#{log4j_version}.jar`
  puts "Will download #{zookeeper_url}"
  `curl #{zookeeper_url} -o zookeeper-#{zookeeper_version}.jar`
end
