export KAFKA_VERSION=0.10.2.1
./kafka_test_setup.sh
bundle exec rake vendor
bundle exec rspec && bundle exec rspec --tag integration
./kafka_test_teardown.sh
