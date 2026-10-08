#!/bin/bash
set -euo pipefail
umask 022

# Install software.
dnf install -y python3 python3-pip git nginx
command -v aws

# Create a dedicated application user.
id three-tier-app >/dev/null 2>&1 ||
    useradd --system --home-dir /opt/three-tier-app \
        --shell /sbin/nologin three-tier-app

# Download the application.
git clone https://github.com/Dileesha001/aws-3tier-ha.git \
    /opt/three-tier-app

# Create the Python environment.
python3 -m venv /opt/three-tier-app/.venv
/opt/three-tier-app/.venv/bin/python -m pip install \
    -r /opt/three-tier-app/app/requirements.txt

# Create the startup script. No password is saved here.
cat >/usr/local/bin/three-tier-start.py <<'PY'
import json
import os
import subprocess
import sys

try:
    result = subprocess.run(
        [
            "aws", "secretsmanager", "get-secret-value",
            "--secret-id", os.environ["DB_SECRET_ARN"],
            "--region", "ap-southeast-2",
            "--query", "SecretString",
            "--output", "text",
        ],
        check=True,
        capture_output=True,
        text=True,
        timeout=60,
    )
    secret = json.loads(result.stdout)
    os.environ["DB_USER"] = secret["username"]
    os.environ["DB_PASSWORD"] = secret["password"]
except Exception:
    print("Unable to retrieve database credentials", file=sys.stderr)
    sys.exit(1)

os.execv(
    sys.executable,
    [
        sys.executable, "-m", "gunicorn",
        "--bind", "127.0.0.1:8000",
        "--workers", "2",
        "--access-logfile", "-",
        "--error-logfile", "-",
        "app:app",
    ],
)
PY

# Configure the persistent application service.
cat >/etc/systemd/system/three-tier-app.service <<'UNIT'
[Unit]
Description=Three-tier Flask application
Wants=network-online.target
After=network-online.target

[Service]
User=three-tier-app
WorkingDirectory=/opt/three-tier-app/app
Environment="PATH=/usr/local/bin:/usr/bin:/bin"
Environment="AWS_DEFAULT_REGION=ap-southeast-2"
Environment="DB_HOST=database-1.cns2acaayarh.ap-southeast-2.rds.amazonaws.com"
Environment="DB_PORT=5432"
Environment="DB_NAME=portfolio_app"
Environment="DB_SECRET_ARN=arn:aws:secretsmanager:ap-southeast-2:802823597623:secret:rds!db-2907a3a1-63d5-4a1d-aabd-6eec73d8fa38-HZslER"
ExecStart=/opt/three-tier-app/.venv/bin/python /usr/local/bin/three-tier-start.py
Restart=on-failure
RestartSec=10
UMask=0077
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
UNIT

# Configure Nginx to forward port 80 to Gunicorn.
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.original

cat >/etc/nginx/nginx.conf <<'NGINX'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    access_log /var/log/nginx/access.log;
    sendfile on;

    server {
        listen 80 default_server;
        server_name _;
        client_max_body_size 16k;

        location / {
            proxy_pass http://127.0.0.1:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
NGINX

nginx -t

# Start services and enable them after reboot.
systemctl daemon-reload
systemctl enable --now three-tier-app
systemctl enable --now nginx
systemctl enable --now amazon-ssm-agent

# Centralized Nginx logs for every replacement instance.
dnf install -y amazon-cloudwatch-agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CWCONFIG'
{
  "agent": {"region": "ap-southeast-2", "run_as_user": "root"},
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {"file_path": "/var/log/nginx/access.log", "log_group_name": "/three-tier/nginx/access", "log_stream_name": "{instance_id}"},
          {"file_path": "/var/log/nginx/error.log", "log_group_name": "/three-tier/nginx/error", "log_stream_name": "{instance_id}"}
        ]
      }
    }
  }
}
CWCONFIG
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
systemctl enable amazon-cloudwatch-agent
