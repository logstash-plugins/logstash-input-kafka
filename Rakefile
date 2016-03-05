require "logstash/devutils/rake"

task :default do
  system('rake -T')
end

desc "Get jars"
task :vendor do
  jar_target = "vendor/jar-dependencies/runtime-jars"
  kafka_version = "0.9.0.1"
  kafka_url = "http://central.maven.org/maven2/org/apache/kafka/kafka-clients/#{kafka_version}/kafka-clients-#{kafka_version}.jar"
  slf4j_version = "1.7.13"
  slf4j_url = "http://central.maven.org/maven2/org/slf4j/slf4j-api/#{slf4j_version}/slf4j-api-#{slf4j_version}.jar"
  slf4j_nop_url = "http://central.maven.org/maven2/org/slf4j/slf4j-nop/#{slf4j_version}/slf4j-nop-#{slf4j_version}.jar"

  puts "Will get jars for version #{kafka_version}"
  puts "Removing current jars"
  `rm -rf #{jar_target}`
  `mkdir -p #{jar_target}`
  Dir.chdir jar_target
  puts "Will download #{kafka_url}"
  `curl #{kafka_url} -o kafka-clients-#{kafka_version}.jar`
  puts "Will download #{slf4j_url}"
  `curl #{slf4j_url} -o slf4j-api-#{slf4j_version}.jar`
  puts "Will download #{slf4j_nop_url}"
  `curl #{slf4j_nop_url} -o slf4j-noop-#{slf4j_version}.jar`
end

