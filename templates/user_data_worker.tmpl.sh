#!/bin/bash

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y boundary

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

cat << EOF > /etc/config.hcl
listener "tcp" {
  address     = "$${PRIVATE_IP}:9202"
  purpose     = "proxy"
  tls_disable = true
}

worker {
  name        = "${name}-worker-${index}"
  public_addr = "$${PUBLIC_IP}"
  description = "A default worker created for demonstration"
  controllers = [
  %{ for ip in controller_ips ~}
    "${ip}",
  %{ endfor ~}
  ]
}

kms "awskms" {
  purpose    = "worker-auth"
  key_id     = "global_root"
  kms_key_id = "${kms_worker_auth_key_id}"
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
    name        = "worker-audit-sink"
    description = "All events sent to a file"
    event_types = ["*"]
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
Description=Boundary Worker
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

chmod 664 /etc/systemd/system/boundary.service
systemctl daemon-reload
systemctl enable boundary
systemctl start boundary