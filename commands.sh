#!/bin/bash
set -euo pipefail

log() {
  echo -e "\n\033[1;34m$1\033[0m"
}

log "STEP 1: Create Namespaces"

for ns in vault external-secrets student-api; do
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -
done

log "STEP 2: Install External Secrets Operator (CRDs + Controller)"

kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/crds/bundle.yaml

kubectl apply -f external-secrets/eso.yml

log "Waiting for ESO controller to be ready..."
kubectl wait --for=condition=Available deployment/external-secrets \
  -n external-secrets --timeout=120s || true

log "STEP 3: Deploy Vault"

kubectl apply -f vault/vault.yml
kubectl apply -f vault/vault-backend.yaml
kubectl apply -f vault/eso-vault-sa.yaml
kubectl apply -f vault/vault-secretstore.yaml

log "Waiting for Vault pod..."
kubectl wait --for=condition=Available deployment/vault \
  -n vault --timeout=120s || true

log "STEP 4: Apply Final Secret Configuration"

kubectl apply -f final/cluster-vault-secretstore.yml
kubectl apply -f final/cluster-external-secret-db.yml
kubectl apply -f final/external-secret-db.yaml

log "STEP 5: Deploy Database"

kubectl apply -f final/database.yml

log "STEP 6: Deploy Application"

kubectl apply -f final/application.yml

log "DEPLOYMENT COMPLETED SUCCESSFULLY 🚀"

