#!/bin/bash

set -ex

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

if [ "${INTEGRATION}" = "true" ]; then
  trap "${REPO_ROOT}/kafka_test_teardown.sh" EXIT
  "${REPO_ROOT}/kafka_test_setup.sh"
  bundle exec rspec --tag integration
else
  bundle exec rake test
fi
