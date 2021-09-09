#!/bin/bash
# Interpreter identifier

# Exit on fail
set -e

rm -f $RAILS_ROOT/tmp/pids/server.pid
rm -f $RAILS_ROOT/tmp/pids/sidekiq.pid

exec "$@"
