#!/bin/bash

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y boundary

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat << EOF > /etc/config.hcl
disable_mlock = true

telemetry {
  prometheus_retention_time = "24h"
  disable_hostname          = true
}

controller {
  name        = "${name}-controller-${index}"
  description = "A controller for a demo!"

  database {
    url = "postgresql://${db_username}:${db_password}@${db_endpoint}/boundary"
  }
}

listener "tcp" {
  address              = "$${PRIVATE_IP}:9200"
  purpose              = "api"
  tls_disable          = true
  cors_enabled         = true
  cors_allowed_origins = ["*"]
}

listener "tcp" {
  address              = "$${PRIVATE_IP}:9201"
  purpose              = "cluster"
  tls_disable          = true
}

kms "awskms" {
  purpose    = "root"
  key_id     = "global_root"
  kms_key_id = "${kms_root_key_id}"
}

kms "awskms" {
  purpose    = "worker-auth"
  key_id     = "global_worker_auth"
  kms_key_id = "${kms_worker_auth_key_id}"
}

kms "awskms" {
  purpose    = "recovery"
  key_id     = "global_recovery"
  kms_key_id = "${kms_recovery_key_id}"
}
EOF

cat << EOF > /etc/systemd/system/boundary-controller.service
[Unit]
Description=Boundary Controller
[Service]
ExecStart=/usr/bin/boundary server -config /etc/config.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
[Install]
WantedBy=multi-user.target
EOF

adduser --system --group boundary || true
chown boundary:boundary /etc/config.hcl
chown boundary:boundary /usr/bin/boundary

boundary database init -skip-auth-method-creation -skip-host-resources-creation -skip-scopes-creation -skip-target-creation -config /etc/config.hcl || true

chmod 664 /etc/systemd/system/boundary-controller.service
systemctl daemon-reload
systemctl enable boundary-controller
systemctl start boundary-controller