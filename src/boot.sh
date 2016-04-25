#!/bin/bash

# Fail hard and fast
set -eo pipefail

if [ ! -z "$ETCD" ]; then
	_ETCD=" -node $ETCD"
fi

if [ ! -z "$ETCD_CLEINT_CERT" ]; then
	_ETCD_CLEINT_CERT=" -client-cert $ETCD_CLEINT_CERT"
fi

if [ ! -z "$ETCD_CLEINT_KEY" ]; then
	_ETCD_CLEINT_KEY=" -client-key $ETCD_CLEINT_KEY"
fi

if [ ! -z "$ETCD_CLEINT_CA" ]; then
	_ETCD_CLEINT_CA=" -client-ca-keys $ETCD_CLEINT_CA"
fi

echo "[nginx] booting container. ETCD: $ETCD ETCD_CLEINT_CERT: $ETCD_CLEINT_CERT ETCD_CLEINT_KEY: $ETCD_CLEINT_KEY ETCD_CLEINT_CA: $ETCD_CLEINT_CA"

# Loop until confd has updated the nginx config
until confd -onetime $_ETCD $_ETCD_CLEINT_KEY $_ETCD_CLEINT_CA  -config-file /etc/confd/confd.toml; do
  echo "[nginx] waiting for confd to refresh nginx.conf"
  sleep 5
done

# Run confd in the background to watch the upstream servers
confd -interval 10 -node $ETCD -config-file /etc/confd/confd.toml &
echo "[nginx] confd is listening for changes on etcd..."

# Start nginx
echo "[nginx] starting nginx service..."
service nginx start
