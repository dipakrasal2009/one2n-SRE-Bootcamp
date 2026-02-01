#!/bin/bash

# Set variables for namespace and helm release
NAMESPACE="vault"
RELEASE_NAME="vault"

# Step 1: Create Vault namespace
echo "Creating namespace '$NAMESPACE'..."
kubectl create namespace $NAMESPACE

# Step 2: Add HashiCorp Helm repository
echo "Adding HashiCorp Helm repository..."
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

# Step 3: Install Vault in dev mode with UI enabled
echo "Installing Vault in dev mode with UI..."
helm upgrade --install $RELEASE_NAME hashicorp/vault \
  --set="server.dev.enabled=true" \
  --set="ui.enabled=true" \
  --set="ui.serviceType=NodePort" \
  --namespace $NAMESPACE --create-namespace

# Wait for Vault pod to be ready
echo "Waiting for Vault pod to be ready..."
kubectl rollout status statefulset/$RELEASE_NAME -n $NAMESPACE

# Step 4: Get Vault pod name
VAULT_POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=vault -o jsonpath="{.items[0].metadata.name}")

# Step 5: Enter Vault pod shell
echo "Entering Vault pod '$VAULT_POD'..."
kubectl exec -it $VAULT_POD -n $NAMESPACE -- /bin/sh -- -c "

# Inside Vault pod

# Step 6: Create read policy
cat <<EOF > /root/read-policy.hcl
path \"secret/*\" {
  capabilities = [\"read\"]
}
EOF
echo \"Policy 'read-policy' created.\"

# Step 7: Write the policy to Vault
vault policy write read-policy /root/read-policy.hcl
echo \"Policy 'read-policy' written.\"

# Step 8: Enable Kubernetes auth
vault auth enable kubernetes
echo \"Kubernetes auth enabled.\"

# Step 9: Configure Vault with Kubernetes API details
# Note: Kubernetes environment variables are available inside the container
 vault write auth/kubernetes/config \\
   token_reviewer_jwt=\"$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)\" \\
   kubernetes_host=\"https://${KUBERNETES_PORT_443_TCP_ADDR}:443\" \\
   kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# Step 10: Create a role binding policy to service account in 'vault' namespace
vault write auth/kubernetes/role/vault-role \\
   bound_service_account_names=vault-serviceaccount \\
   bound_service_account_namespaces=vault \\
   policies=read-policy \\
   ttl=1h

# Step 11: Store a test secret
vault kv put secret/db-credentials username=user password password
echo \"Secret 'clisecret' created in Vault.\"

# Step 12: List secrets to verify
vault kv list secret/
"
# End of script

