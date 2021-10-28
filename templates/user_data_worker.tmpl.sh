#!/bin/bash

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update && apt-get install -y boundary

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

cat << EOF > /etc/config.hcl
listener "tcp" {
  address              = "$${PRIVATE_IP}:9202"
  purpose              = "proxy"
  tls_disable          = true
}

worker {
  name = "${name}-worker-${index}"
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
EOF

cat << EOF > /etc/systemd/system/boundary-worker.service
[Unit]
Description=Boundary Worker
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

chmod 664 /etc/systemd/system/boundary-worker.service
systemctl daemon-reload
systemctl enable boundary-worker
systemctl start boundary-worker