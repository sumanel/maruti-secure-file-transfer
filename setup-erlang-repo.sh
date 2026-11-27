#!/usr/bin/env bash
set -Eeuo pipefail

# Configure the official RabbitMQ Erlang RPM repository on Amazon Linux 2023 x86_64.
# Run: sudo bash setup-erlang-repo.sh

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run this script with sudo: sudo bash setup-erlang-repo.sh" >&2
  exit 1
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR: This repository supports x86_64 only. Detected: $(uname -m)" >&2
  exit 1
fi

KEY_URL="https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key"
REPO_FILE="/etc/yum.repos.d/rabbitmq-erlang.repo"

echo "[1/4] Importing RabbitMQ Erlang signing key..."
rpm --import "$KEY_URL"

echo "[2/4] Writing Amazon Linux 2023 Erlang repository configuration..."
cat > "$REPO_FILE" <<'EOF'
[modern-erlang]
name=RabbitMQ Erlang Repository for Amazon Linux 2023
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
name=RabbitMQ Erlang Noarch Repository for Amazon Linux 2023
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

echo "[3/4] Displaying configured repository URLs..."
grep -E '^\[|^baseurl=' "$REPO_FILE"

echo "[4/4] Refreshing repository metadata..."
dnf clean metadata
dnf makecache --refresh --disablerepo='*' --enablerepo=modern-erlang,modern-erlang-noarch

echo
echo "SUCCESS: RabbitMQ Erlang repository metadata downloaded."
echo "Next step: install Erlang after confirming this script completes successfully."
