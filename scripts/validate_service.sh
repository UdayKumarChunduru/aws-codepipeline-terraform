#!/usr/bin/env bash

set -uo pipefail

for i in $(seq 1 12); do
  if curl -sf http://localhost/health >/dev/null; then
    echo "Service healthy after $((i * 5)) seconds"
    exit 0
  fi
  sleep 5
done

echo "Service failed health validation"
exit 1
