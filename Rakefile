
# encoding: utf-8
require "logstash/devutils/rake"
require "jars/installer"
require "fileutils"

task :default do
  system('rake -vT')
end

task :vendor do
  exit(1) unless system './gradlew vendor'
end

task :clean do
  ["vendor/jar-dependencies", "Gemfile.lock"].each do |p|
    FileUtils.rm_rf(p)
  end
end

