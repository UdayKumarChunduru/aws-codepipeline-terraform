#!/usr/bin/env bash

set -uo pipefail

if systemctl list-unit-files | grep -q flask-app.service; then
  systemctl stop flask-app || true
fi
exit 0
