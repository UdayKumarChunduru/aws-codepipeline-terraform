#!/usr/bin/env bash
set -euo pipefail

REGION="${region}"

dnf update -y
dnf install -y ruby wget

cd /home/ec2-user
wget "https://aws-codedeploy-$REGION.s3.$REGION.amazonaws.com/latest/install"
chmod +x ./install
./install auto

systemctl enable codedeploy-agent
systemctl start codedeploy-agent
