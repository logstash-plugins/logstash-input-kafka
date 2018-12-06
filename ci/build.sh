#!/bin/bash
# version: 1
########################################################
#
# AUTOMATICALLY GENERATED! DO NOT EDIT
#
########################################################
set -e

./ci/setup.sh

export KAFKA_VERSION=2.1.0
./kafka_test_setup.sh
bundle install
bundle exec rake vendor
