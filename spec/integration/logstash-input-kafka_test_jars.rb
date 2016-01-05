# encoding: utf-8
require 'logstash/environment'

root_dir = File.expand_path(File.join(File.dirname(__FILE__), "../.."))
LogStash::Environment.load_test_jars! File.join(root_dir, "vendor")
