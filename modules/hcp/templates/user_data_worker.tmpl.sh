#!/bin/bash

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - ;\
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" ;\
apt-get update && sudo apt-get install boundary-worker-hcp -y

PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

mkdir -p /etc/boundary/worker

cat << EOF > /etc/boundary/config.hcl
disable_mlock = true

hcp_boundary_cluster_id = "${boundary_cluster_id}"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  public_addr = "$${PUBLIC_IP}"
%{ if initial_upstreams != null }
  initial_upstreams = ${initial_upstreams}
%{ endif }
  auth_storage_path = "/etc/boundary/worker"
  controller_generated_activation_token = "${controller_generated_activation_token}
  tags {
    type = ${worker_tags}
  }
}
EOF

cat << EOF > /etc/systemd/system/boundary.service
[Unit]
Description=Boundary Worker
[Service]
ExecStart=/usr/bin/boundary-worker server -config="/etc/boundary/config.hcl"
User=boundary
Group=boundary
[Install]
WantedBy=multi-user.target
EOF

adduser --system --group boundary || true
chown boundary:boundary -R /etc/boundary
chown boundary:boundary /usr/bin/boundary

chmod 664 /etc/systemd/system/boundary.service
systemctl daemon-reload
systemctl enable boundary
systemctl start boundary