#!/usr/bin/env bash

set -euo pipefail

APP_DIR=/opt/flask-app

if command -v dnf >/dev/null 2>&1; then
  dnf install -y python3 python3-pip
else
  yum install -y python3 python3-pip
fi

python3 -m venv "$APP_DIR/venv"
"$APP_DIR/venv/bin/pip" install --upgrade pip -q
"$APP_DIR/venv/bin/pip" install -r "$APP_DIR/requirements.txt" -q
