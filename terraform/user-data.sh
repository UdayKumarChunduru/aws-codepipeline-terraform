#!/usr/bin/env bash

set -euo pipefail

dnf update -y
dnf install -y ruby wget

cd /home/ec2-user
wget "https://aws-codedeploy-${region}.s3.${region}.amazonaws.com/latest/install"
chmod +x ./install
./install auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent
