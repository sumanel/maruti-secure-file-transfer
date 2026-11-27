#!/usr/bin/env bash
set -Eeuo pipefail

# RabbitMQ installation on Amazon Linux 2023 x86_64
# Installs Erlang 27.3.4.19 and RabbitMQ Server 4.4.1.
# Run: sudo bash install-rabbitmq-step1-6.sh

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run with sudo: sudo bash install-rabbitmq-step1-6.sh" >&2
  exit 1
fi

if [[ -r /etc/os-release ]]; then
  . /etc/os-release
  if [[ "${ID:-}" != "amzn" || "${VERSION_ID:-}" != "2023" ]]; then
    echo "ERROR: This script is intended for Amazon Linux 2023." >&2
    exit 1
  fi
fi

if [[ "$(uname -m)" != "x86_64" ]]; then
  echo "ERROR: This script requires x86_64. Detected: $(uname -m)" >&2
  exit 1
fi

ERLANG_VERSION="27.3.4.19"
RABBITMQ_VERSION="4.4.1"
WORKDIR="/tmp/rabbitmq-install"

ERLANG_RPM="erlang-${ERLANG_VERSION}-1.amzn2023.x86_64.rpm"
RABBITMQ_RPM="rabbitmq-server-${RABBITMQ_VERSION}-1.el8.noarch.rpm"

ERLANG_URL="https://github.com/rabbitmq/erlang-rpm/releases/download/v${ERLANG_VERSION}/${ERLANG_RPM}"
RABBITMQ_URL="https://github.com/rabbitmq/rabbitmq-server/releases/download/v${RABBITMQ_VERSION}/${RABBITMQ_RPM}"

echo "[1/6] Preparing installation directory..."
mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

echo "[2/6] Importing official package signing keys..."
rpm --import "https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key"
rpm --import "https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc"

echo "[3/6] Downloading Erlang ${ERLANG_VERSION} RPM..."
curl --fail --location --retry 3 --output "${ERLANG_RPM}" "${ERLANG_URL}"

echo "[4/6] Downloading RabbitMQ ${RABBITMQ_VERSION} RPM..."
curl --fail --location --retry 3 --output "${RABBITMQ_RPM}" "${RABBITMQ_URL}"

echo "[5/6] Verifying RPM signatures..."
rpm --checksig --verbose "${ERLANG_RPM}"
rpm --checksig --verbose "${RABBITMQ_RPM}"

echo "[6/6] Installing dependencies, Erlang and RabbitMQ..."
dnf install -y logrotate
dnf install -y "./${ERLANG_RPM}" "./${RABBITMQ_RPM}"

echo
echo "Installation completed."
echo "Erlang version:"
erl -version
echo
echo "RabbitMQ package:"
rpm -q rabbitmq-server
echo
echo "Next: enable/start RabbitMQ and configure its users, permissions and network access."
