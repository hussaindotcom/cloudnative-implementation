# Forked To-Do Application Deployment For Emumba

This repository contains the complete deployment configuration  To-Do application on Kubernetes using Minikube cluster.

## Index

- [Architecture Overview](#architecture-overview)
- [Structure](#project-structure)
- [Part 1: Manual Deployment](#part-1-manual-deployment)
  - [Step 1: Clone the Repository](#step-1-clone-the-repository)
  - [Step 2: Setup Minikube Cluster](#step-2-setup-minikube-cluster)
  - [Step 3: GitHub Actions CI/CD](#step-3-github-actions-cicd)
  - [Step 4: Apply Kubernetes Manifests](#step-4-apply-kubernetes-manifests)
  - [Step 5: Verify Deployment](#step-5-verify-deployment)
- [Part 2: Terraform Deployment](#part-2-terraform-deployment)
  - [Terraform Files Overview](#terraform-files-overview)
  - [Deploy with Terraform](#deploy-with-terraform)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Minikube                                │
│                                                             │
│  ┌──────────────┐     ┌──────────────┐     ┌────────────┐   │
│  │   Frontend   │────▶│     API      │────▶│  MongoDB   │   │
│  │   (client)   │     │  (Backend)   │     │            │   │
│  └──────────────┘     └──────────────┘     └────────────┘   │
│                                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Components

| Component | Technology | Description |
|-----------|------------|-------------|
| Frontend  | React + Nginx | UI for the To-Do app |
| API | Go  | APIs |
| Database | MongoDB | Persistent storage |
| 
---

## Tools Required

- **Docker**
- **Minikube**
- **kubectl** 
- **Terraform** 
- **Git**: as SCM
- **Docker Hub Account**: as container resgistery

### Install Prereqs (macOS)

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Docker Desktop

# Install Minikube
brew install minikube

# Install kubectl
brew install kubectl

# Install Terraform
brew install terraform
```

---

## Project Structure

```
cloudnative-implementation (root)/
├── .github/
│   └── workflows/
│       ├── frontend-ci.yml      # Frontend CI pipeline (image versioning with build number)
│       └── api-ci.yml           # API CI pipeline (image versioning with build number)
├── k8s/
│   └── manifests/
│       ├── namespace.yaml      # k8s namespace for todo app
│       ├── configmap.yaml      # configmaps
│       ├── secrets.yaml        # secrets
│       ├── mongodb.yaml        # mongo sts (bitnamilegacy/mongodb:4.4.1 -- compose was usig bitnami/mongodb:4.4.1), and svc
│       ├── api.yaml            # backend/api deployment and svc resource
│       ├── frontend.yaml       # fronytend and svc resource
│       └── network-policy.yaml # network policy as per required in assessment
├── terraform/
│   ├── providers.tf             # Terraform providers
│   ├── main.tf                  # k8s resources
│   └── provision.tf             # Minikube provisioning plus k8s manifest apply
├── client/                      # React frontend source with on push CI trigger
├── server/                      # API source with on push CI trigger
└── README.md                    # This file
```

---

## Part 1: Manual Deployment

### Step 1: Clone the Repository

1. Clone repository:

```bash
git clone https://github.com/hussaindotcom/cloudnative-implementation.git
cd cloudnative-implementation
```

### Step 2: Setup Minikube Cluster

1. **Start Minikube** with Docker driver:

```bash
minikube start --driver=docker --cpus=2 --memory=2048
```

2. **Verify Minikube is running**:

```bash
minikube status
```

3. **Enable minikube addons**:

```bash
# Enable ingress controller (to access frontend)
minikube addons enable ingress

```

4. **Get Minikube IP**:

```bash
minikube ip
```

### Step 3: GitHub Actions CI/CD

The repository includes two GitHub Actions workflows:

#### Frontend CI (`.github/workflows/frontend-ci.yml`)
- **Trigger**: Push to `master` branch PR changes in `./client/` directory
- **Steps**:
  1. Checkout code
  2. Set up Docker Buildx
  3. Login to Docker Hub
  4. Build and push frontend image with build number as tag

#### API CI (`.github/workflows/api-ci.yml`)
- **Trigger**: Push to `master` branch  PR changes in `./server/` directory
- **Steps**:
  1. Checkout code
  2. Set up Docker Buildx
  3. Login to Docker Hub
  4. Build and push API image with build number as tag

#### Setup GitHub Actions:

1. **Add Docker Hub secrets**:
   - Go to your repository -> Settings -> Secrets and variables -> Actions
   - Add two new repository secrets:
     - `DOCKER_USERNAME`:  Docker Hub username
     - `DOCKER_PASSWORD`:  Docker Hub password or access token

2. **Update image names**:
   Edit the workflow files to use your desired image name:
   
   ```yaml
   env:
     DOCKER_IMAGE: ${{ secrets.DOCKER_USERNAME }}/tod-frontend
   ```

3. **Push changes** to trigger CI:
   
```bash
git add .
git commit -m "Add GitHub Actions CI workflows"
git push origin master
```

4. **Verify CI runs**:
   - Go to repository -> Actions tab
   - You should see the workflows running

### Step 4: Apply Kubernetes Manifests

1. **Navigate to manifests directory**:

```bash
cd k8s/manifests
```

2. **Apply all manifests in order**:



```bash
kubectl apply -f .
```

### Step 5: Verify Deployment

1. **Check pod status**:

```bash
kubectl get pods -n todo
```

Expected output:
```
NAME              READY   STATUS    RESTARTS   AGE
api-xxxxx-xxxxx   1/1     Running   0          4m
frontend-xxxxx    1/1     Running   0          4m
mongodb-0        1/1     Running   0          5m
```

2. **Check services**:

```bash
kubectl get svc -n todo
```


3. **Check logs**:

```bash
# Frontend logs
kubectl logs -n todo -l app=frontend

# API logs
kubectl logs -n todo -l app=api

# MongoDB logs
kubectl logs -n todo -l app=mongodb
```
4. **Access the application**:

```bash
# Using NodePort
minikube service frontend -n todo
```

---

## Part 2: Terraform Deployment

### Terraform Files Overview

| File | Purpose |
|------|---------|
| `providers.tf` | Defines required providers (kubernetes, local, null) |
| `main.tf` | Defines Variables, and Output |
| `provision.tf` | Minikube cluster provisioning and manifest application |

### Deploy with Terraform
1. **Starts Minikube**:

```bash
minikube start --driver=docker --cpus=2 --memory=2048
```

2. **Initialize Terraform**:

```bash
cd terraform
terraform init
```

3. **Plan the provision**:

```bash
terraform plan
```

4. **Apply the configuration**:

```bash
terraform apply
```

5. **Confirm** when prompted:
   - Type `yes` and press Enter

6. **Access the application**:

```bash
# access the application
minikube service frontend -n todo

# or check via Terraform output
terraform output
```

### What Terraform Provisions

1. **Starts Minikube Cluster** (via provision.tf):
   - Starts Minikube if not running

2. **Kubernetes Resources** (via main.tf):
   - Namespace `todo`
   - ConfigMaps for frontend and API
   - Secret for database credentials
   - MongoDB StatefulSet (1 replica)
   - MongoDB Service
   - API Deployment (1 replicas)
   - API ClusterIP Service
   - Frontend Deployment (1 replicas)
   - Frontend NodePort Service
   - Network Policies

---

## Network Policies

The network policies in `network-policy.yaml` implement the following restrictions (as required in assessment):

| Policy | Ingress Rules | Egress Rules |
|--------|---------------|---------------|
| **MongoDB** | Only API pod(s) can connect on port 27017 | DNS only |
| **API** | Only Frontend pod(s) can connect on port 8080 | Only to MongoDB and DNS |
| **Frontend** | traffic allowed | Only to API and DNS |

### Apply Network Policies

```bash
kubectl apply -f k8s/manifests/network-policy.yaml
```
---

## Components Description

### Kubernetes Manifests

#### namespace.yaml
Spawns the `todo` namespace for all todo app resources.

#### configmap.yaml
- **frontend-config**: Store `REACT_APP_API_ENDPOINT` pointing to API service (as mentioned in .env.example)
- **api-config**: Store mongodb connection settings

#### secrets.yaml
Stores sensitive data:
- Database username and password
- MongoDB root password
- Database name

#### mongodb.yaml
- **StatefulSet**: MongoDB with persistent storage of 1Gi
- **Service**: For pod discovery
- **Volume Claim**: 1Gi persistent storage

#### api.yaml
- **Deployment**: 1 replicas of API
- **ClusterIP Service**: Internal access on port 8080
- **Probes**: Liveness and readiness probes

#### frontend.yaml
- **Deployment**: 1 replicas of  frontend
- **NodePort Service**: External access on port 80->8080

#### network-policy.yaml
Implements pod-to-pod communication restrictions .

---

### Delete Kubernetes Resources

```bash
# Delete all resources in the todo namespace
kubectl delete namespace todo

# Or delete individual resources
kubectl delete -f k8s/manifests/
```

### Stop Minikube

```bash
minikube stop
```

### Delete Minikube Cluster

```bash
minikube delete
```

### Remove Terraform State

```bash
cd terraform
terraform destroy
rm -rf .terraform/
```

---

## Additional Information

### Image Names

The manifests reference these images (update as needed):
- Frontend: `husen22/emumba:latest`
- API: `husen22/emumba-api:latest`
- MongoDB: `bitnamilegacy/mongodb:4.4.1`

### Port Mappings

| Service | Type | Port | Target |
|---------|------|------|--------|
| Frontend | NodePort | 80 | 8080 |
| API | ClusterIP | 8080 | 8080 |
| MongoDB | Headless | 27017 | 27017 |
