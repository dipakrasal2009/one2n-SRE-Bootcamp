#!/bin/bash
set -e

echo "=============================="
echo "STEP 1: Create Namespaces"
echo "=============================="

kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace student-api --dry-run=client -o yaml | kubectl apply -f -

echo "=============================="
echo "STEP 2: Install External Secrets Operator (CRDs + Controller)"
echo "=============================="

# Install ESO using official manifest (includes CRDs)
kubectl apply -f https://raw.githubusercontent.com/external-secrets/external-secrets/main/deploy/crds/bundle.yaml

kubectl apply -f external-secrets/eso.yml

echo "Waiting for ESO controller to be ready..."
kubectl rollout status deployment/external-secrets -n external-secrets

echo "=============================="
echo "STEP 3: Deploy Vault"
echo "=============================="

kubectl apply -f vault/vault.yml
kubectl apply -f vault/vault-backend.yaml
kubectl apply -f vault/eso-vault-sa.yaml
kubectl apply -f vault/vault-secretstore.yaml

echo "Waiting for Vault pod..."
kubectl rollout status deployment/vault -n vault

echo "=============================="
echo "STEP 4: Apply Final Secret Configuration"
echo "=============================="

kubectl apply -f final/cluster-vault-secretstore.yml
kubectl apply -f final/cluster-external-secret-db.yml
kubectl apply -f final/external-secret-db.yaml

echo "=============================="
echo "STEP 5: Deploy Database"
echo "=============================="

kubectl apply -f final/database.yml

echo "=============================="
echo "STEP 6: Deploy Application"
echo "=============================="

kubectl apply -f final/application.yml

echo "=============================="
echo "DEPLOYMENT COMPLETED SUCCESSFULLY 🚀"
echo "=============================="

