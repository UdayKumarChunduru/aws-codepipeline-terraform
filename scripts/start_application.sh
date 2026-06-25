#!/usr/bin/env bash

set -euo pipefail

APP_DIR=/opt/flask-app
UNIT=/etc/systemd/system/flask-app.service

cat > "$UNIT" <<EOF
[Unit]
Description=Flask sample app deployed by CodeDeploy
After=network.target

[Service]
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/venv/bin/gunicorn --bind 0.0.0.0:80 --workers 2 app:app
Restart=always
Environment=APP_ENV=production

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable flask-app
systemctl restart flask-app
