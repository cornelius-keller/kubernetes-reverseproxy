#!/bin/bash

. /var/run/secrets/hetzner

KUBE_TOKEN=$(</var/run/secrets/kubernetes.io/serviceaccount/token)
HOST_IP=$(curl -sSk -H "Authorization: Bearer $KUBE_TOKEN" \
   https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_PORT_443_TCP_PORT/api/v1/namespaces/default/pods/$HOSTNAME \
   | grep hostIP | awk '{ print $2 }' | tr -d  ',"')
ETCD=https://$HOST_IP:2379

echo "setting Failover IP:  $FAILOVER_IP to Server IP:  $HOST_IP"

curl -u $HETZNER_USER:$HETZNER_PASS https://robot-ws.your-server.de/failover/$FAILOVER_IP -d active_server_ip=$HOST_IP
