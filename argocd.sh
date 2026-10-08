# Script for update-kubeconfig, argocd port-forwd and get secret. Run after applying the terraform conf
#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="argocd"
PORT=8080

aws eks update-kubeconfig --region us-east-1 --name citadel-cluster

echo "==> Fetching and decoding initial Argo CD admin password..."
if kubectl get secret argocd-initial-admin-secret -n "$NAMESPACE" &>/dev/null; then
    PASS=$(kubectl get secret argocd-initial-admin-secret -n "$NAMESPACE" -o jsonpath="{.data.password}" | base64 --decode)
    echo "--------------------------------------------------------"
    echo "Username: admin"
    echo "Password: $PASS"
    echo "--------------------------------------------------------"
else
    echo "Warning: 'argocd-initial-admin-secret' not found in namespace '$NAMESPACE'."
    echo "The initial secret may have been deleted after the password was changed."
fi

if lsof -ti:"$PORT" &>/dev/null; then
    echo "==> Cleaning up existing process listening on port $PORT..."
    kill -9 $(lsof -ti:"$PORT") 2>/dev/null || true
fi

echo "==> Port-forwarding argo-server to http://0.0.0.0:$PORT..."
echo "Press Ctrl+C to stop."

kubectl port-forward svc/argocd-server -n "$NAMESPACE" --address 0.0.0.0 "$PORT":443
