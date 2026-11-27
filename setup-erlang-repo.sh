#!/usr/bin/env bash
set -euo pipefail

# RabbitMQ Erlang repository setup for Amazon Linux 2023 (x86_64).
# Run: sudo bash setup-erlang-repo.sh

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR: This script expects x86_64. Detected: $(uname -m)" >&2
  exit 1
fi

KEY_URL="https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key"
REPO_FILE="/etc/yum.repos.d/rabbitmq-erlang.repo"

echo "[1/3] Importing RabbitMQ Erlang signing key..."
rpm --import "$KEY_URL"

echo "[2/3] Configuring RabbitMQ Erlang repository..."
cat > "$REPO_FILE" <<'EOF'
[modern-erlang]
name=RabbitMQ Erlang Repository
baseurl=https://yum1.rabbitmq.com/erlang/el/9/$basearch
        https://yum2.rabbitmq.com/erlang/el/9/$basearch
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
type=rpm-md

[modern-erlang-noarch]
name=RabbitMQ Erlang Noarch Repository
baseurl=https://yum1.rabbitmq.com/erlang/el/9/noarch
        https://yum2.rabbitmq.com/erlang/el/9/noarch
repo_gpgcheck=1
enabled=1
gpgkey=https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key
gpgcheck=1
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
pkg_gpgcheck=1
type=rpm-md
EOF

echo "[3/3] Refreshing DNF metadata..."
dnf makecache

echo
echo "Erlang repository configured successfully."
echo "Next: install a RabbitMQ-supported Erlang version."
