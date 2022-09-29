#!/bin/bash

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y boundary

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat << EOF > /etc/config.hcl
disable_mlock = true

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
  address     = "$${PRIVATE_IP}:9201"
  purpose     = "cluster"
  tls_disable = true
}

listener "tcp" {
  address     = "$${PRIVATE_IP}:9203"
  purpose     = "ops"
  tls_disable = true
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

events {
  audit_enabled        = true
  observations_enabled = true
  sysevents_enabled    = true

  sink "stderr" {
    name        = "all-events"
    description = "All events sent to stderr"
    event_types = ["*"]
    format      = "cloudevents-json"
  }

  sink {
    name        = "controller-audit-sink"
    description = "Audit sent to a file"
    event_types = ["audit"]
    format      = "cloudevents-json"

    file {
      path      = "${boundary_sink_file_path}"
      file_name = "${boundary_sink_file_name}"
    }
  }
}
EOF

cat << EOF > /etc/systemd/system/boundary.service
[Unit]
Description=Boundary Controller
[Service]
ExecStart=/usr/bin/boundary server -config /etc/config.hcl
User=boundary
Group=boundary
LimitMEMLOCK=infinity
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
[Install]
WantedBy=multi-user.target
EOF

adduser --system --group boundary || true
chown boundary:boundary /etc/config.hcl
chown boundary:boundary /usr/bin/boundary

mkfs -t xfs /dev/nvme1n1
mkdir -p ${boundary_sink_file_path}
mount /dev/nvme1n1 ${boundary_sink_file_path}

chgrp boundary ${boundary_sink_file_path}
chmod g+rwx ${boundary_sink_file_path}

boundary database init -skip-auth-method-creation -skip-host-resources-creation -skip-scopes-creation -skip-target-creation -config /etc/config.hcl || true

chmod 664 /etc/systemd/system/boundary.service
systemctl daemon-reload
systemctl enable boundary
systemctl start boundary

%{ if datadog_api_key != null }
DD_INSTALL_ONLY=true DD_AGENT_MAJOR_VERSION=7 DD_API_KEY=${datadog_api_key} DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

cat << EOF > /etc/datadog-agent/datadog.yaml
api_key: "${datadog_api_key}"

site: datadoghq.com

tags:
  - team:${name}
  - component:boundary-controller

cloud_provider_metadata:
  - "aws"

## @param logs_enabled - boolean - optional - default: false
## Enable Datadog Agent log collection by setting logs_enabled to true.
logs_enabled: true
EOF

cat << EOF > /etc/datadog-agent/conf.d/boundary.d/conf.yaml
logs:
  - type: file
    path: "${boundary_sink_file_path}/${boundary_sink_file_name}"
    service: "boundary-controller"
    source: "boundary-audit"

init_config:
    service: boundary-controller

instances:
  - health_endpoint: http://$${PRIVATE_IP}:9203/health
    openmetrics_endpoint: http://$${PRIVATE_IP}:9203/metrics
EOF

usermod -a -G boundary dd-agent
chmod g+rwx ${boundary_sink_file_path}/${boundary_sink_file_name}

systemctl daemon-reload
systemctl enable datadog-agent
systemctl start datadog-agent
%{ endif }