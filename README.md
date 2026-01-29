# Student REST API

Simple REST API for managing students.

## Endpoints

- `GET /api/v1/student`
- `POST /api/v1/student`
- `GET /api/v1/student/<id>`
- `PUT /api/v1/student/<id>`
- `DELETE /api/v1/student/<id>`
- `GET /healthcheck`

## How to Run

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python run.py

---

## Kubernetes Deployment (student-api)

All manifests are under `k8s-manifests/`:

- Application (namespace, ConfigMap, Deployment with initContainer, Service): `k8s-manifests/final/application.yml`
- Database (namespace, ConfigMap, Deployment, Service): `k8s-manifests/final/database.yml`
- External Secrets Operator: `k8s-manifests/external-secrets/eso.yml`
- Vault (secret store backend): `k8s-manifests/vault/vault.yml`, `k8s-manifests/vault/vault-backend.yaml`
- Vault-backed secret store + ExternalSecret for DB credentials:
  - `k8s-manifests/final/cluster-vault-secretstore.yml`
  - `k8s-manifests/final/cluster-external-secret-db.yml`

### Steps

1. Label nodes (example):
   - `kubectl label node <app-node> type=application`
   - `kubectl label node <db-node> type=dependent_services`
2. Deploy Vault and ESO:
   - `kubectl apply -f k8s-manifests/vault/vault.yml`
   - `kubectl apply -f k8s-manifests/vault/vault-backend.yaml`
   - `kubectl apply -f k8s-manifests/external-secrets/eso.yml`
3. Configure Vault with a `db-credentials` secret (username/password) under the `secret/` path.
4. Deploy SecretStore and ExternalSecret:
   - `kubectl apply -f k8s-manifests/final/cluster-vault-secretstore.yml`
   - `kubectl apply -f k8s-manifests/final/cluster-external-secret-db.yml`
5. Deploy database and API:
   - `kubectl apply -f k8s-manifests/final/database.yml`
   - `kubectl apply -f k8s-manifests/final/application.yml`
6. Test the API (NodePort service `student-api` on port 80):
   - `curl http://<node-ip>:<nodePort>/api/v1/student`



---

### ✅ 11. Add Logging (optional but recommended)

In `routes.py`, you can add logs like:

```python
import logging
logging.basicConfig(level=logging.INFO)

# inside route
logging.info("Student created: %s", new_student.name)

# SRE_Bootcamp

# Student API (Flask)

## 🐳 Docker

Build Docker Image:

```bash
make build

Run the container with environment variables:
```
make run
```
Tag and push:
```
make tag-latest
make push
```
🧪 Healthcheck
```
curl http://localhost:5000/healthcheck
```

🧬 Image Info
Multi-stage build

Small image size (~40MB)

Tags: student-api:v1.0.0 (no latest tag)


—

✅ Summary

You now have:

- ✅ Multi-stage Dockerfile
- ✅ Minimal image size
- ✅ Environment variable support
- ✅ SemVer tagging
- ✅ Automated Makefile
- ✅ Clean README instructions

Let me know if you want to Docker Compose this or deploy to AWS/GCP next.

