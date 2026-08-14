#!/bin/bash

env

set -ex

if [ "${INTEGRATION}" = "true" ]; then
  trap './kafka_test_teardown.sh' EXIT
  ./kafka_test_setup.sh
  bundle exec rspec --tag integration
else
  bundle exec rake test
fi
