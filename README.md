<div align="center">

# 🔐 DevSecOps E-Commerce Pipeline

### Secure CI/CD Pipeline · Spring Boot + React + MySQL · Minikube Kubernetes · Security-First

[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD-D24939?style=for-the-badge&logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![Docker](https://img.shields.io/badge/Docker-Container-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Minikube-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://minikube.sigs.k8s.io/)
[![SonarQube](https://img.shields.io/badge/SonarQube-SAST-4E9BCD?style=for-the-badge&logo=sonarqube&logoColor=white)](https://www.sonarqube.org/)
[![Trivy](https://img.shields.io/badge/Trivy-Image%20Scan-1904DA?style=for-the-badge&logo=aqua&logoColor=white)](https://trivy.dev/)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-Dashboard-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)
[![Falco](https://img.shields.io/badge/Falco-Runtime%20IDS-00AEF0?style=for-the-badge&logo=falco&logoColor=white)](https://falco.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

<br/>

> A **production-grade DevSecOps pipeline** that builds, scans, and deploys a Java Spring Boot + React e-commerce application on a local **Minikube** Kubernetes cluster — with security embedded at every layer: code, container, runtime, and host.

<br/>

**[📖 Setup Guide](#-phase-by-phase-setup-guide) · [🏗️ Architecture](#-system-architecture) · [🔒 Security Controls](#-security-controls-matrix) · [🧪 Security Tests](#-security-testing-scenarios)**

</div>

---

## 📌 Table of Contents

- [🌟 Project Overview](#-project-overview)
- [🏗️ System Architecture](#-system-architecture)
- [📁 Project Structure](#-project-structure)
- [🔄 CI/CD Pipeline Stages](#-cicd-pipeline-stages)
- [🔒 Security Controls Matrix](#-security-controls-matrix)
- [⚙️ Tech Stack](#-tech-stack)
- [🚀 Phase-by-Phase Setup Guide](#-phase-by-phase-setup-guide)
  - [Phase 1 — System Requirements & Linux Preparation](#phase-1--system-requirements--linux-preparation)
  - [Phase 2 — Install Core Tools](#phase-2--install-core-tools)
  - [Phase 3 — Start Minikube Cluster](#phase-3--start-minikube-cluster)
  - [Phase 4 — Install & Configure Jenkins](#phase-4--install--configure-jenkins)
  - [Phase 5 — Set Up SonarQube](#phase-5--set-up-sonarqube)
  - [Phase 6 — Deploy Kubernetes Resources](#phase-6--deploy-kubernetes-resources)
  - [Phase 7 — Prometheus & Grafana Monitoring](#phase-7--prometheus--grafana-monitoring)
  - [Phase 8 — Falco Runtime Security](#phase-8--falco-runtime-security)
  - [Phase 9 — Run the Jenkins Pipeline](#phase-9--run-the-jenkins-pipeline)
  - [Phase 10 — Linux Hardening](#phase-10--linux-hardening)
- [🧪 Security Testing Scenarios](#-security-testing-scenarios)
- [📊 Monitoring & Alerting](#-monitoring--alerting)
- [🛠️ Useful Commands](#-useful-commands)
- [❓ Troubleshooting](#-troubleshooting)

---

## 🌟 Project Overview

This project implements a **complete DevSecOps pipeline** for a full-stack e-commerce application, migrated from AWS EKS to a **local Minikube** cluster — zero cloud cost.

### What Makes This a DevSecOps Pipeline?

Security is not a final gate — it is **integrated into every stage**:

| Stage | What Happens | Security Tool |
|-------|-------------|---------------|
| Code commit | Static analysis on Java source | SonarQube SAST |
| Before build | Dependency CVE check | OWASP Dependency-Check |
| Build | Filesystem vulnerability scan | Trivy FS |
| Docker build | Image layer CVE scan | Trivy Image |
| Deploy | Non-root containers, RBAC, Secrets | Kubernetes Security Contexts |
| Runtime | Intrusion detection on syscalls | Falco |
| Host | Firewall, audit logs, SSH hardening | UFW, auditd, fail2ban |
| Metrics | Live dashboards + alerts | Prometheus + Grafana |

---

## 🏗️ System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        LINUX HOST (Ubuntu 22.04)                            │
│                   UFW Firewall · auditd · fail2ban · SSH:2222               │
│                                                                             │
│  ┌─────────────────┐      ┌──────────────────┐    ┌────────────────────┐    │
│  │   Developer     │      │   GitHub Repo    │    │   DockerHub        │    │
│  │   git push ─────┼─────▶│  main branch     │   │  sandesh300/       │    │
│  └─────────────────┘      └────────┬─────────┘    │  ecommerce-backend │    │
│                                    │ webhook/poll │  ecommerce-frontend│    │
│                           ┌────────▼─────────┐    └────────▲───────────┘    │
│                           │                   │             │ docker push   │
│                           │  JENKINS :8080    │─────────────┘               │
│                           │                   │                             │
│                           │  14-Stage Pipeline│                             │
│                           │  ┌─────────────┐  │                             │
│                           │  │ 1.Checkout   │  │                            │
│                           │  │ 2.Unit Tests │  │    ┌───────────────────┐   │
│                           │  │ 3.SonarQube ─┼──┼───▶│  SONARQUBE :9000 │   │
│                           │  │ 4.QualityGate│  │    │  MySQL DB         │  │
│                           │  │ 5.OWASP DC  │  │     └───────────────────┘  │
│                           │  │ 6.Trivy FS  │  │                             │
│                           │  │ 7.Bld Back  │  │                             │
│                           │  │ 8.Bld Front │  │                             │
│                           │  │ 9.Trivy Img │  │                             │
│                           │  │ 10.Push Hub │  │                             │
│                           │  │ 11.Update K8│  │                             │
│                           │  │ 12.Deploy   │  │                             │
│                           │  │ 13.SmokeTest│  │                             │
│                           │  └─────────────┘  │                             │
│                           └────────┬──────────┘                             │
│                                    │ kubectl apply                          │
│  ┌─────────────────────────────────▼───────────────────────────────────┐    │
│  │              MINIKUBE KUBERNETES CLUSTER                            │    │
│  │                                                                     │    │
│  │  ┌──────────────────── Namespace: ecommerce ─────────────────────┐  │    │
│  │  │                                                               │  │   │
│  │  │  ┌──────────────────────────────────────────────────────────┐ │  │   │
│  │  │  │  RBAC + NetworkPolicy + PodSecurityContext + Secrets     │ │  │   │
│  │  │  └──────────────────────────────────────────────────────────┘ │  │   │
│  │  │                                                               │  │   │
│  │  │  ┌─────────────┐    ┌──────────────────┐    ┌──────────────┐  │  │   │
│  │  │  │  FRONTEND   │    │    BACKEND       │    │    MYSQL     │  │  │   │
│  │  │  │  (2 pods)   │───▶│    (2 pods)      │───▶│ StatefulSet │  │  │   │
│  │  │  │  nginx:101  │    │    JVM:1001      │    │  PVC: 5Gi    │  │  │   │
│  │  │  │  NodePort   │    │    Actuator      │    │ ClusterIP    │  │  │   │
│  │  │  │  :30090     │    │    :30080        │    │ :3306        │  │  │   │
│  │  │  └─────────────┘    └──────────────────┘    └──────────────┘  │  │   │
│  │  │       │                      │                                │  │   │
│  │  │  ┌────▼──────────────────────▼──────────────────────────────┐ │  │   │
│  │  │  │  Ingress (ecommerce.local) — nginx ingress controller    │ │  │   │
│  │  │  └──────────────────────────────────────────────────────────┘ │  │   │
│  │  └───────────────────────────────────────────────────────────────┘  │   │
│  │                                                                     │   │
│  │  ┌────── Namespace: monitoring ──┐  ┌───── Namespace: falco ─────┐  │   │
│  │  │  Prometheus   Grafana         │  │  Falco eBPF agent          │  │   │
│  │  │  AlertManager Node-Exporter   │  │  Custom ecommerce rules    │  │   │
│  │  │  kube-state-metrics           │  │  Syscall intrusion detect  │  │   │
│  │  └───────────────────────────────┘  └────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└────────────────────────────────────────────────────────────────────────────┘
```

### Network Flow & Security Boundaries

```
External User
     │
     ▼
[UFW Firewall] ── blocks all except :2222, :8080, :9000, :30000-32767
     │
     ▼
[Minikube Ingress — ecommerce.local]
     │
     ▼
[ecommerce-frontend-svc :80]          NetworkPolicy:
     │  ← frontend can reach backend   frontend → backend ✅
     ▼                                 frontend → mysql   ❌ BLOCKED
[ecommerce-backend-svc :8080]         backend  → mysql   ✅
     │  ← backend can reach mysql      anything → other   ❌ BLOCKED
     ▼
[mysql-svc :3306]
     │
     ▼
[mysql-pvc — hostPath on Minikube node]
```

---

## 📁 Project Structure

```
DevSecOps-ECommerce/
│
├── 📄 Jenkinsfile                          # 14-stage CI/CD pipeline definition
│
├── 🐳 backend/
│   ├── Dockerfile                          # Multi-stage: maven builder → jre-alpine runtime
│   ├── pom.xml                             # Maven dependencies (scanned by OWASP)
│   └── src/
│       ├── main/java/com/ecommerce/        # Spring Boot application source
│       │   ├── controller/                 # REST API endpoints
│       │   ├── service/                    # Business logic
│       │   ├── model/                      # JPA entities (MySQL)
│       │   ├── repository/                 # Spring Data JPA repos
│       │   ├── config/                     # Security, DB, CORS config
│       │   └── dto/                        # Data Transfer Objects
│       └── test/                           # JUnit unit tests (run in pipeline)
│
├── 🐳 frontend/
│   ├── Dockerfile                          # Multi-stage: node builder → nginx runtime
│   ├── nginx.conf                          # Hardened nginx: security headers, SPA routing
│   ├── package.json
│   └── src/
│       ├── components/                     # React components
│       ├── pages/                          # Page-level views
│       ├── services/                       # Axios API calls to backend
│       └── App.js
│
├── ☸️ kubernetes/
│   ├── namespace.yaml                      # ecommerce namespace + PodSecurity labels
│   │
│   ├── rbac/
│   │   └── rbac.yaml                       # ServiceAccounts + Roles + RoleBindings
│   │
│   ├── mysql/
│   │   ├── secret.yaml                     # DB credentials (base64 encoded)
│   │   ├── pvc.yaml                        # 5Gi PersistentVolumeClaim (standard SC)
│   │   ├── statefulset.yaml                # MySQL 8.0 StatefulSet + hardened ConfigMap
│   │   └── service.yaml                    # ClusterIP + Headless service
│   │
│   ├── backend/
│   │   ├── configmap.yaml                  # Spring Boot env vars (non-sensitive)
│   │   ├── deployment.yaml                 # 2 replicas, rolling update, init container
│   │   └── service.yaml                    # NodePort :30080
│   │
│   ├── frontend/
│   │   ├── deployment.yaml                 # 2 replicas, non-root nginx
│   │   └── service-ingress.yaml            # NodePort :30090 + Ingress
│   │
│   ├── network-policy/
│   │   └── networkpolicy.yaml              # Default-deny-all + targeted allowlist
│   │
│   └── monitoring/
│       ├── prometheus-stack-values.yaml    # Helm values for kube-prometheus-stack
│       └── servicemonitor.yaml             # Prometheus scrape config for Spring Boot
│
├── 🔒 security/
│   └── falco/
│       └── falco-custom-rules.yaml         # 6 custom runtime detection rules
│
└── 📜 scripts/
    └── linux-harden.sh                     # Full Linux hardening (12 sections)
```

---

## 🔄 CI/CD Pipeline Stages

```
 Git Push
    │
    ▼
┌───────────────────────────────────────────────────────────────────┐ 
│  JENKINS PIPELINE  (Triggered on commit to main)                  │
│                                                                   │
│  Stage 1  ──▶  Clean Workspace                                   │
│                 cleanWs() — fresh state every run                 │
│                                                                   │
│  Stage 2  ──▶  Code Checkout                                      │
│                 git clone from GitHub (credentialsId: github-creds)│
│                                                                   │
│  Stage 3  ──▶  Unit Tests                           🧪           │
│                 mvn test → JUnit XML report published             │
│                                                                   │
│  Stage 4  ──▶  SonarQube SAST Analysis              🔍           │
│                 sonar-scanner → reports bugs, vulnerabilities,    │
│                 code smells, security hotspots                    │
│                                                                   │
│  Stage 5  ──▶  SonarQube Quality Gate               🚦           │
│                 Pipeline ABORTS if gate fails                     │
│                                                                   │
│  Stage 6  ──▶  OWASP Dependency-Check               🛡️           │
│                 Scans backend/pom.xml for CVEs                    │
│                 Fails on CVSS >= 7.0                              │
│                                                                   │
│  Stage 7  ──▶  Trivy Filesystem Scan                🔎           │
│                 Scans repo for HIGH/CRITICAL secrets & CVEs       │
│                                                                   │
│  Stage 8  ──▶  Docker Build — Backend               🐳           │
│                 Multi-stage: maven:3.9.6 → eclipse-temurin:17-jre │
│                                                                   │
│  Stage 9  ──▶  Docker Build — Frontend              🐳           │
│                 Multi-stage: node:20-alpine → nginx:1.25-alpine   │
│                                                                   │
│  Stage 10 ──▶  Trivy Image Vulnerability Scan       🔬           │
│                 Scans both built images for CVEs                  │
│                 Reports HIGH & CRITICAL findings                  │
│                                                                   │
│  Stage 11 ──▶  Push to DockerHub                    📤           │
│                 Authenticates via Jenkins credentials             │
│                 Pushes :IMAGE_TAG and :latest                     │
│                                                                   │
│  Stage 12 ──▶  Update Kubernetes Manifests          📝           │
│                 sed replaces image tag in YAML files              │
│                 Git commit + push [skip ci]                       │
│                                                                   │
│  Stage 13 ──▶  Deploy to Minikube                   🚀           │
│                 kubectl apply all manifests                       │
│                 kubectl set image → rolling update                │
│                 Waits for rollout to complete                     │
│                                                                   │
│  Stage 14 ──▶  Smoke Test                           ✅           │
│                 curl /actuator/health — 10 retries                │
│                 Fails pipeline if backend unhealthy               │
│                                                                   │
│  POST ────▶  Email notification (success/failure)   📧           │
│             Docker cleanup (system prune)                         │
└───────────────────────────────────────────────────────────────────┘
```

---

## 🔒 Security Controls Matrix

| Security Layer | Control Implemented | Tool/Method | Where Configured |
|---------------|--------------------|-----------|--------------------|
| **Code** | Static Application Security Testing | SonarQube | `Jenkinsfile` Stage 4-5 |
| **Code** | Secret detection in source | SonarQube (S2068) | SonarQube rules |
| **Dependencies** | CVE scan of Java libraries | OWASP Dependency-Check | `Jenkinsfile` Stage 6 |
| **Filesystem** | CVE scan of repo files | Trivy FS | `Jenkinsfile` Stage 7 |
| **Container** | Image layer CVE scanning | Trivy Image | `Jenkinsfile` Stage 10 |
| **Container** | Non-root user (UID 1001) | Dockerfile `USER appuser` | `backend/Dockerfile` |
| **Container** | Non-root nginx (UID 101) | Dockerfile `USER nginxuser` | `frontend/Dockerfile` |
| **Container** | No new privileges | SecurityContext | `kubernetes/backend/deployment.yaml` |
| **Container** | Read-only root filesystem | SecurityContext | All deployments |
| **Container** | Drop ALL capabilities | SecurityContext | All deployments |
| **Container** | Seccomp RuntimeDefault | SecurityContext | All deployments |
| **Kubernetes** | RBAC — least privilege | ServiceAccount + Role | `kubernetes/rbac/rbac.yaml` |
| **Kubernetes** | No automount SA token | `automountServiceAccountToken: false` | All deployments |
| **Kubernetes** | Secrets for credentials | Kubernetes Secret | `kubernetes/mysql/secret.yaml` |
| **Kubernetes** | Pod Security Standards | Namespace labels | `kubernetes/namespace.yaml` |
| **Kubernetes** | Zero-trust networking | NetworkPolicy | `kubernetes/network-policy/` |
| **Kubernetes** | MySQL isolated (deny-all) | NetworkPolicy | `networkpolicy.yaml` |
| **Runtime** | Shell spawn detection | Falco rule | `falco-custom-rules.yaml` |
| **Runtime** | Unexpected outbound connections | Falco rule | `falco-custom-rules.yaml` |
| **Runtime** | Sensitive file reads | Falco rule | `falco-custom-rules.yaml` |
| **Runtime** | Privilege escalation | Falco rule | `falco-custom-rules.yaml` |
| **Runtime** | Crypto mining detection | Falco rule | `falco-custom-rules.yaml` |
| **Host** | Firewall (default deny) | UFW | `scripts/linux-harden.sh` |
| **Host** | Kernel hardening (ASLR, etc.) | sysctl | `scripts/linux-harden.sh` |
| **Host** | Audit logging | auditd | `scripts/linux-harden.sh` |
| **Host** | Brute-force protection | fail2ban | `scripts/linux-harden.sh` |
| **Host** | SSH hardening (port 2222, keys only) | sshd_config | `scripts/linux-harden.sh` |
| **Host** | Password aging policy | login.defs + PAM | `scripts/linux-harden.sh` |
| **Monitoring** | Metrics + alerting | Prometheus + Grafana | `kubernetes/monitoring/` |
| **Monitoring** | JVM metrics (Spring Boot) | Actuator + ServiceMonitor | `kubernetes/monitoring/servicemonitor.yaml` |

---

## ⚙️ Tech Stack

| Category | Technology | Version | Role |
|----------|-----------|---------|------|
| **Backend** | Spring Boot | 3.x | REST API, JPA, Actuator |
| **Frontend** | React | 18.x | SPA served by Nginx |
| **Database** | MySQL | 8.0 | Persistent storage (StatefulSet) |
| **Build** | Maven | 3.9.6 | Java dependency & build tool |
| **Container** | Docker | 24.x | Image build & runtime |
| **Orchestration** | Minikube / Kubernetes | 1.28 | Local K8s cluster |
| **CI/CD** | Jenkins | LTS | 14-stage pipeline automation |
| **SAST** | SonarQube | 10 Community | Static code analysis |
| **Image Scan** | Trivy | Latest | Container & FS CVE scanning |
| **Dep Scan** | OWASP Dependency-Check | Latest | Java library CVE check |
| **Monitoring** | Prometheus | 2.x | Metrics collection |
| **Dashboard** | Grafana | 10.x | Visualization & alerting |
| **Runtime IDS** | Falco | Latest | eBPF-based intrusion detection |
| **Ingress** | Nginx Ingress Controller | Minikube addon | HTTP routing |
| **Package Mgr** | Helm | 3.x | K8s chart management |
| **Host OS** | Ubuntu | 22.04 LTS | Linux base environment |

---

## 🚀 Phase-by-Phase Setup Guide

### Prerequisites — Minimum System Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| OS | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| CPU | 4 cores | 8 cores |
| RAM | 12 GB | 16 GB |
| Disk | 40 GB free | 60 GB free |
| Network | Internet access | Internet access |

---

### Phase 1 — System Requirements & Linux Preparation

#### Step 1.1 — Fresh system update

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y \
  curl wget git unzip zip jq tree \
  net-tools htop lsof \
  ca-certificates gnupg lsb-release \
  apt-transport-https software-properties-common \
  build-essential
```

#### Step 1.2 — Clone the project repository

```bash
git clone https://github.com/sandesh300/Automated-Deployment-of-a-Scalable-E-commerce.git
cd Automated-Deployment-of-a-Scalable-E-commerce
```

#### Step 1.3 — Run the Linux hardening script

> ⚠️ **Before running**: Make sure your SSH public key is already in `~/.ssh/authorized_keys`. The script disables password auth and moves SSH to port 2222.

```bash
# Run as root
sudo bash scripts/linux-harden.sh

# After completion, verify SSH still works on port 2222
ssh -p 2222 your-user@your-host
```

The script applies 12 hardening sections:
1. Automatic security updates
2. User/password aging policies
3. SSH hardening (port 2222, keys-only, modern ciphers)
4. UFW firewall (default-deny + allowlist)
5. Kernel sysctl hardening (ASLR, martian logging, SYN cookies)
6. auditd rules (tracks Docker, Jenkins, kubectl, SSH)
7. fail2ban (brute-force protection)
8. Disable unused services (avahi, bluetooth, cups, rpcbind)
9. File permission hardening (/etc/shadow, /etc/passwd, etc.)
10. Security tools (rkhunter, lynis, aide, clamav)
11. Docker daemon hardening (no-new-privileges, icc=false)
12. Logrotate for pipeline logs

---

### Phase 2 — Install Core Tools

#### Step 2.1 — Install Java 17

```bash
sudo apt-get install -y openjdk-17-jdk

# Verify
java -version
# Expected: openjdk version "17.x.x"

# Set JAVA_HOME permanently
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' | sudo tee -a /etc/environment
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
source ~/.bashrc
```

#### Step 2.2 — Install Maven

```bash
sudo apt-get install -y maven
mvn -version
# Expected: Apache Maven 3.x.x
```

#### Step 2.3 — Install Docker

```bash
# Add Docker's GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin

# Add your user and jenkins to the docker group
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins  # run after Jenkins is installed

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# IMPORTANT: Log out and log back in for group membership to take effect
# or run: newgrp docker

# Verify
docker --version
docker run hello-world
```

#### Step 2.4 — Install kubectl

```bash
# Download the latest stable version
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Validate checksum
curl -LO "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
```

#### Step 2.5 — Install Minikube

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

minikube version
```

#### Step 2.6 — Install Helm

```bash
curl https://baltocdn.com/helm/signing.asc | \
  gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] \
  https://baltocdn.com/helm/stable/debian/ all main" | \
  sudo tee /etc/apt/sources.list.d/helm-stable-debian.list

sudo apt-get update && sudo apt-get install -y helm
helm version
```

#### Step 2.7 — Install Trivy

```bash
sudo apt-get install -y wget apt-transport-https gnupg

wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | \
  gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] \
  https://aquasecurity.github.io/trivy-repo/deb generic main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list

sudo apt-get update && sudo apt-get install -y trivy

# Update vulnerability database
trivy image --download-db-only
trivy --version
```

---

### Phase 3 — Start Minikube Cluster

#### Step 3.1 — Increase vm.max_map_count (required for SonarQube + Elasticsearch)

```bash
sudo sysctl -w vm.max_map_count=524288
echo 'vm.max_map_count=524288' | sudo tee /etc/sysctl.d/99-minikube.conf
```

#### Step 3.2 — Start Minikube with sufficient resources

```bash
minikube start \
  --driver=docker \
  --cpus=4 \
  --memory=8192 \
  --disk-size=30g \
  --kubernetes-version=v1.28.0

# Check status
minikube status
kubectl get nodes
# Expected: Ready
```

#### Step 3.3 — Enable required Minikube addons

```bash
minikube addons enable ingress          # Nginx ingress controller
minikube addons enable metrics-server   # kubectl top + HPA
minikube addons enable coredns          # Internal DNS
minikube addons enable storage-provisioner  # Dynamic PVC provisioning

# Verify
minikube addons list | grep -E "enabled"
```

#### Step 3.4 — Configure /etc/hosts for local domain

```bash
# Get Minikube cluster IP
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

# Add to /etc/hosts
echo "$MINIKUBE_IP  ecommerce.local" | sudo tee -a /etc/hosts

# Test
ping -c 2 ecommerce.local
```

---

### Phase 4 — Install & Configure Jenkins

#### Step 4.1 — Install Jenkins

```bash
# Add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
  sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update && sudo apt-get install -y jenkins

# Start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins  # Should show: active (running)
```

#### Step 4.2 — Unlock Jenkins

```bash
# Get the initial admin password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

1. Open browser: `http://localhost:8080`
2. Paste the password
3. Select **Install Suggested Plugins** and wait for completion
4. Create your admin user
5. Set Jenkins URL: `http://localhost:8080`

#### Step 4.3 — Install Required Jenkins Plugins

Navigate to **Manage Jenkins → Plugins → Available plugins** and install:

| Plugin Name | Purpose |
|-------------|---------|
| `Pipeline` | Core Groovy pipeline |
| `Git` | Source code checkout |
| `SonarQube Scanner` | SAST integration |
| `OWASP Dependency-Check` | CVE dependency scanning |
| `Docker Pipeline` | Docker build/push in pipeline |
| `Kubernetes CLI` | kubectl commands in pipeline |
| `Email Extension` | Rich HTML build notifications |
| `JUnit` | Test result publishing |
| `AnsiColor` | Colored terminal output |
| `Credentials Binding` | Safe secret injection |
| `Pipeline Utility Steps` | Extra pipeline functions |

Restart Jenkins after installation.

#### Step 4.4 — Add Jenkins Credentials

Go to: **Manage Jenkins → Credentials → System → Global → Add Credential**

| Credential ID | Kind | Values |
|---------------|------|--------|
| `github-creds` | Username with password | GitHub username + Personal Access Token |
| `dockerHub` | Username with password | DockerHub username + password |
| `sonarqube-token` | Secret text | Token from SonarQube (see Phase 5.3) |

To create a GitHub PAT: GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token → check: `repo`, `read:org`

#### Step 4.5 — Configure Global Tools

**Manage Jenkins → Global Tool Configuration**:

**SonarQube Scanner:**
- Click **Add SonarQube Scanner**
- Name: `Sonar`
- ✅ Install automatically → latest version

**OWASP Dependency-Check:**
- Click **Add Dependency-Check**
- Name: `OWASP`
- ✅ Install automatically → latest version

**Maven:**
- Click **Add Maven**
- Name: `Maven`
- ✅ Install automatically → 3.9.x

#### Step 4.6 — Configure SonarQube Server in Jenkins

**Manage Jenkins → Configure System → SonarQube servers**:
- ✅ Enable injection of SonarQube server configuration as build environment variables
- Click **Add SonarQube**
- Name: `Sonar`
- Server URL: `http://localhost:9000`
- Server authentication token: select `sonarqube-token`

#### Step 4.7 — Give Jenkins access to Docker and Minikube

```bash
# Add jenkins to docker group
sudo usermod -aG docker jenkins

# Create kube config directory for jenkins
sudo mkdir -p /var/lib/jenkins/.kube

# Copy your Minikube config to jenkins home
sudo cp ~/.kube/config /var/lib/jenkins/.kube/config
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube/
sudo chmod 600 /var/lib/jenkins/.kube/config

# Update the kubeconfig server address to use Minikube IP
# (Minikube uses 127.0.0.1 by default; Jenkins may need the actual IP)
MINIKUBE_IP=$(minikube ip)
sudo sed -i "s|https://127.0.0.1:|https://${MINIKUBE_IP}:|g" /var/lib/jenkins/.kube/config

# Restart Jenkins for group changes to take effect
sudo systemctl restart jenkins

# Verify Jenkins can reach kubectl
sudo -u jenkins kubectl get nodes
```

---

### Phase 5 — Set Up SonarQube

#### Step 5.1 — Run SonarQube with Docker Compose

```bash
# Create a dedicated network
docker network create sonarnet

# Run PostgreSQL backend for SonarQube
docker run -d \
  --name sonarqube-db \
  --network sonarnet \
  -e POSTGRES_USER=sonar \
  -e POSTGRES_PASSWORD=sonar_pass_123 \
  -e POSTGRES_DB=sonarqube \
  -v sonarqube_db_data:/var/lib/postgresql/data \
  --restart unless-stopped \
  postgres:15-alpine

# Run SonarQube Community Edition
docker run -d \
  --name sonarqube \
  --network sonarnet \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=jdbc:postgresql://sonarqube-db:5432/sonarqube \
  -e SONAR_JDBC_USERNAME=sonar \
  -e SONAR_JDBC_PASSWORD=sonar_pass_123 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  --restart unless-stopped \
  sonarqube:10-community

# Wait ~2 minutes for startup, then check logs
docker logs -f sonarqube
```

#### Step 5.2 — Initial SonarQube Setup

1. Open: `http://localhost:9000`
2. Login: `admin` / `admin`
3. **Change the default password immediately**
4. Navigate to **Administration → Security → Force user authentication** → Enable

#### Step 5.3 — Generate SonarQube Token

1. Click your avatar (top right) → **My Account → Security**
2. Under **Generate Tokens**: Name = `jenkins-token`, Type = **Global Analysis Token**
3. Click **Generate** — copy the token immediately (shown only once)
4. Go to Jenkins → Credentials → add as **Secret text** with ID: `sonarqube-token`

#### Step 5.4 — Create SonarQube Project

1. **Projects → Create Project → Manually**
2. Project key: `ecommerce-backend`
3. Display name: `ecommerce-backend`
4. Main branch: `main`

#### Step 5.5 — Configure Quality Gate

1. **Quality Gates → Create** (or use the default Sonar Way)
2. Ensure these conditions are set:
   - Coverage < 80% → Fail
   - Security Rating worse than A → Fail
   - Reliability Rating worse than A → Fail
   - New Vulnerabilities > 0 → Fail

---

### Phase 6 — Deploy Kubernetes Resources

#### Step 6.1 — Prepare MySQL Secrets

Generate your own base64-encoded passwords:

```bash
# Replace the example passwords with your own strong passwords
echo -n 'ecommerce_db'     | base64    # Database name
echo -n 'ecommerce_user'   | base64    # DB username
echo -n 'YourStrongPass@1' | base64    # DB password  ← change this
echo -n 'YourRootPass@2'   | base64    # Root password ← change this
```

Edit `kubernetes/mysql/secret.yaml` and replace the 4 placeholder base64 values.

#### Step 6.2 — Apply all Kubernetes manifests in order

```bash
# 1. Namespace and RBAC (must be first)
kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/rbac/rbac.yaml

# 2. MySQL (database must come before backend)
kubectl apply -f kubernetes/mysql/secret.yaml
kubectl apply -f kubernetes/mysql/pvc.yaml
kubectl apply -f kubernetes/mysql/statefulset.yaml
kubectl apply -f kubernetes/mysql/service.yaml

# 3. Wait for MySQL to be Ready before continuing
kubectl rollout status statefulset/mysql -n ecommerce --timeout=120s

# 4. Backend
kubectl apply -f kubernetes/backend/configmap.yaml
kubectl apply -f kubernetes/backend/deployment.yaml
kubectl apply -f kubernetes/backend/service.yaml

# 5. Frontend
kubectl apply -f kubernetes/frontend/deployment.yaml
kubectl apply -f kubernetes/frontend/service-ingress.yaml

# 6. Network Policies (apply last so all pods exist first)
kubectl apply -f kubernetes/network-policy/networkpolicy.yaml
```

#### Step 6.3 — Verify all pods are running

```bash
# Watch pods come up (Ctrl+C when all are Running)
kubectl get pods -n ecommerce -w

# Expected final state:
# NAME                                    READY   STATUS    RESTARTS   AGE
# mysql-0                                 1/1     Running   0          3m
# ecommerce-backend-xxxx-xxxxx            1/1     Running   0          2m
# ecommerce-backend-xxxx-xxxxx            1/1     Running   0          2m
# ecommerce-frontend-xxxx-xxxxx           1/1     Running   0          1m
# ecommerce-frontend-xxxx-xxxxx           1/1     Running   0          1m

# Full resource overview
kubectl get all -n ecommerce
kubectl get pvc -n ecommerce
kubectl get networkpolicies -n ecommerce
```

#### Step 6.4 — Access the application

```bash
# Method 1 — NodePort (direct port access)
MINIKUBE_IP=$(minikube ip)
echo "Frontend: http://${MINIKUBE_IP}:30090"
echo "Backend:  http://${MINIKUBE_IP}:30080/actuator/health"

# Method 2 — Minikube service tunnel (opens browser automatically)
minikube service ecommerce-frontend-svc -n ecommerce
minikube service ecommerce-backend-svc -n ecommerce

# Method 3 — Via Ingress (if ecommerce.local is in /etc/hosts)
curl http://ecommerce.local
```

---

### Phase 7 — Prometheus & Grafana Monitoring

#### Step 7.1 — Add Helm chart repositories

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

#### Step 7.2 — Install kube-prometheus-stack

```bash
# Create monitoring namespace
kubectl create namespace monitoring

# Install with custom values (Minikube-tuned resources + NodePort access)
helm install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring \
  -f kubernetes/monitoring/prometheus-stack-values.yaml \
  --wait \
  --timeout 10m

# Verify all monitoring pods are running
kubectl get pods -n monitoring
```

#### Step 7.3 — Apply ServiceMonitor for Spring Boot scraping

```bash
# This tells Prometheus to scrape /actuator/prometheus from backend pods
kubectl apply -f kubernetes/monitoring/servicemonitor.yaml

# Verify it was created
kubectl get servicemonitor -n monitoring
```

#### Step 7.4 — Access Grafana dashboard

```bash
# Get the Grafana NodePort
kubectl get svc -n monitoring monitoring-grafana

# Access via Minikube (opens in browser)
minikube service monitoring-grafana -n monitoring

# Or port-forward to localhost
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 &
# Open: http://localhost:3000
# Login: admin / GrafanaAdmin@123
```

#### Step 7.5 — Import dashboards

In Grafana → **Dashboards → Import**, use these dashboard IDs:

| Dashboard | ID | What You See |
|-----------|----|-------------|
| Kubernetes Cluster Overview | `315` | Node CPU/RAM, pod health |
| JVM Micrometer (Spring Boot) | `4701` | Heap, GC, threads, HTTP |
| Node Exporter Full | `1860` | Host CPU, disk, network |
| MySQL Overview | `7362` | Query rate, connections, InnoDB |

---

### Phase 8 — Falco Runtime Security

#### Step 8.1 — Add Falco Helm repository

```bash
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update
```

#### Step 8.2 — Install Falco with custom rules

```bash
kubectl create namespace falco

helm install falco falcosecurity/falco \
  -n falco \
  --set driver.kind=ebpf \
  --set falco.json_output=true \
  --set falco.log_level=info \
  --set-file customRules."custom-rules\.yaml"=security/falco/falco-custom-rules.yaml \
  --wait

# Verify Falco is running on each node
kubectl get pods -n falco -o wide
```

#### Step 8.3 — Custom rules overview

The `falco-custom-rules.yaml` contains 6 rules specific to this application:

| Rule | Trigger | Severity |
|------|---------|---------|
| Shell Spawned in Ecommerce Container | `bash/sh` exec in app pods | WARNING |
| Unexpected Outbound Connection | Backend connects to non-MySQL IP | ERROR |
| Sensitive File Read | Reads `/etc/shadow`, `/root/.ssh/*` | CRITICAL |
| Privilege Escalation Attempt | SUID binary execution | CRITICAL |
| Unexpected Write to Filesystem | Frontend writes outside `/tmp`, cache | WARNING |
| Crypto Mining Detection | Known mining process names | CRITICAL |

#### Step 8.4 — Monitor Falco alerts live

```bash
# Stream live security events
kubectl logs -n falco -l app.kubernetes.io/name=falco -f --tail=100

# Filter only CRITICAL/ERROR events
kubectl logs -n falco -l app.kubernetes.io/name=falco -f | \
  grep -E "(CRITICAL|ERROR|WARNING)"
```

---

### Phase 9 — Run the Jenkins Pipeline

#### Step 9.1 — Create the Pipeline Job

1. Jenkins Dashboard → **New Item**
2. Name: `ecommerce-devsecops-pipeline`
3. Type: **Pipeline** → OK
4. Under **Build Triggers**:
   - ✅ Poll SCM: `H/5 * * * *` (checks every 5 minutes) or configure a GitHub webhook
5. Under **Pipeline → Definition**: `Pipeline script from SCM`
6. SCM: **Git**
7. Repository URL: `https://github.com/sandesh300/Automated-Deployment-of-a-Scalable-E-commerce.git`
8. Credentials: `github-creds`
9. Branch: `*/main`
10. Script Path: `jenkins/Jenkinsfile`
11. **Save**

#### Step 9.2 — Run the pipeline

1. Click **Build with Parameters**
2. `IMAGE_TAG`: `v1.0`
3. Click **Build**

#### Step 9.3 — Monitor the pipeline

- Watch **Stage View** in Jenkins for each stage status
- Click on any stage for detailed logs
- Security reports appear as build artifacts:
  - `trivy-fs-report.txt`
  - `trivy-backend-image-report.txt`
  - `trivy-frontend-image-report.txt`
  - `dependency-check-report.html`

#### Step 9.4 — Verify successful deployment

```bash
# All 5 pods should be Running
kubectl get pods -n ecommerce

# Check rollout history
kubectl rollout history deployment/ecommerce-backend -n ecommerce
kubectl rollout history deployment/ecommerce-frontend -n ecommerce

# Test the application
curl http://$(minikube ip):30080/actuator/health
# Expected: {"status":"UP"}
```

---

### Phase 10 — Linux Hardening

The hardening script (`scripts/linux-harden.sh`) is designed to run once after initial server setup. Key actions:

```bash
# Review the script before running
cat scripts/linux-harden.sh

# Run as root (ensure SSH key is in authorized_keys first)
sudo bash scripts/linux-harden.sh

# Post-hardening security audit
sudo lynis audit system

# Check firewall rules
sudo ufw status verbose

# Verify auditd is capturing Docker events
sudo ausearch -k docker | tail -20

# Verify fail2ban is running
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

---

## 🧪 Security Testing Scenarios

### Test 1 — Simulate a vulnerable Java dependency (OWASP)

```bash
# Add this to backend/pom.xml (Log4Shell vulnerability)
# <dependency>
#   <groupId>org.apache.logging.log4j</groupId>
#   <artifactId>log4j-core</artifactId>
#   <version>2.14.1</version>  ← CVE-2021-44228
# </dependency>

# Trigger pipeline → OWASP stage should FAIL with HIGH CVE alert
```

### Test 2 — Trigger SonarQube Quality Gate failure

```bash
# Add a hardcoded credential to any Java file:
# String apiKey = "hardcoded_api_key_do_not_use";  // Triggers S2068

# Commit and push → SonarQube Quality Gate stage FAILS and aborts pipeline
```

### Test 3 — Test Falco intrusion detection

```bash
# Exec into running backend pod (triggers Shell Spawned rule)
kubectl exec -it -n ecommerce deployment/ecommerce-backend -- sh

# In a separate terminal, watch Falco alerts:
kubectl logs -n falco -l app.kubernetes.io/name=falco -f

# Expected alert:
# WARNING Shell spawned in ecommerce container
# (user=root cmd=sh container=ecommerce-backend image=sandesh300/ecommerce-backend)
```

### Test 4 — Test NetworkPolicy enforcement

```bash
# Frontend → MySQL should be BLOCKED
kubectl exec -it -n ecommerce deployment/ecommerce-frontend -- \
  nc -zv mysql-svc 3306 -w 3
# Expected: Connection timed out (NetworkPolicy blocking)

# Backend → MySQL should SUCCEED
kubectl exec -it -n ecommerce deployment/ecommerce-backend -- \
  nc -zv mysql-svc 3306 -w 3
# Expected: Connection succeeded
```

### Test 5 — Test RBAC (least privilege)

```bash
# Verify ecommerce-sa cannot create/delete deployments
kubectl auth can-i delete deployments -n ecommerce \
  --as=system:serviceaccount:ecommerce:ecommerce-sa
# Expected: no

# Verify ecommerce-sa CAN read configmaps (allowed by Role)
kubectl auth can-i get configmaps -n ecommerce \
  --as=system:serviceaccount:ecommerce:ecommerce-sa
# Expected: yes
```

### Test 6 — Compare image vulnerability counts

```bash
# Scan an old, unpatched image
trivy image nginx:1.18 --severity HIGH,CRITICAL

# Scan your hardened image — should show significantly fewer CVEs
trivy image sandesh300/ecommerce-frontend:v1.0 --severity HIGH,CRITICAL
```

---

## 📊 Monitoring & Alerting

### Key Metrics to Watch in Grafana

| Metric | Query | Alert Threshold |
|--------|-------|----------------|
| Backend availability | `up{job="ecommerce-backend"}` | < 1 |
| HTTP error rate | `rate(http_server_requests_seconds_count{status=~"5.."}[5m])` | > 0.1 |
| JVM Heap usage | `jvm_memory_used_bytes{area="heap"}` | > 80% of max |
| MySQL connections | `mysql_global_status_threads_connected` | > 80 |
| Pod restart rate | `kube_pod_container_status_restarts_total` | > 3 in 10min |
| Node CPU | `100 - (avg by(instance)(rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)` | > 85% |

### AlertManager Email Notifications

Alerts are configured in `prometheus-stack-values.yaml`. Update the SMTP settings:

```yaml
alertmanager:
  config:
    receivers:
      - name: 'email-alerts'
        email_configs:
          - to: 'your-email@gmail.com'
            auth_password: 'your-gmail-app-password'  # Not your main password
```

To create a Gmail App Password: Google Account → Security → 2-Step Verification → App Passwords

---

## 🛠️ Useful Commands

### Kubernetes — Daily Operations

```bash
# Get all resources in ecommerce namespace
kubectl get all -n ecommerce

# Watch pods in real time
kubectl get pods -n ecommerce -w

# View backend application logs (last 100 lines)
kubectl logs -n ecommerce deployment/ecommerce-backend --tail=100 -f

# View MySQL logs
kubectl logs -n ecommerce statefulset/mysql --tail=50

# Describe a pod (for troubleshooting events)
kubectl describe pod -n ecommerce <pod-name>

# Open a shell in backend pod (triggers Falco alert!)
kubectl exec -it -n ecommerce deployment/ecommerce-backend -- /bin/sh

# Manual rolling update (without Jenkins)
kubectl set image deployment/ecommerce-backend \
  ecommerce-backend=sandesh300/ecommerce-backend:v1.1 \
  -n ecommerce

# Rollback deployment
kubectl rollout undo deployment/ecommerce-backend -n ecommerce

# Check rollout history
kubectl rollout history deployment/ecommerce-backend -n ecommerce

# Scale deployment manually
kubectl scale deployment/ecommerce-backend --replicas=3 -n ecommerce

# View resource usage
kubectl top pods -n ecommerce
kubectl top nodes
```

### Security — Audit & Verification

```bash
# View auditd events for Docker
sudo ausearch -k docker | tail -20

# View auditd events for kubectl
sudo ausearch -k kubectl | tail -20

# View UFW logs
sudo tail -50 /var/log/ufw.log

# Check fail2ban jail status
sudo fail2ban-client status sshd

# Run a security audit
sudo lynis audit system --quick

# Check for rootkits
sudo rkhunter --check --skip-keypress

# View Falco alerts
kubectl logs -n falco -l app.kubernetes.io/name=falco -f

# Trivy scan on demand
trivy image sandesh300/ecommerce-backend:v1.0 --severity CRITICAL
```

### Minikube — Cluster Management

```bash
# Start/stop/status
minikube start
minikube stop
minikube status

# Get service URLs
minikube service list -n ecommerce

# SSH into Minikube node
minikube ssh

# View Minikube dashboard in browser
minikube dashboard

# View logs
minikube logs

# Reset everything (nuclear option)
minikube delete --all
```

---

## ❓ Troubleshooting

### MySQL pod not starting

```bash
# Check if the StatefulSet pod was created
kubectl describe statefulset mysql -n ecommerce

# Check events in the namespace
kubectl get events -n ecommerce --sort-by='.lastTimestamp'

# Check PVC is bound
kubectl get pvc -n ecommerce

# Verify the secret exists
kubectl get secret mysql-secret -n ecommerce -o yaml

# Delete and recreate StatefulSet (keeps PVC data)
kubectl delete statefulset mysql -n ecommerce
kubectl apply -f kubernetes/mysql/statefulset.yaml
```

### Backend pods stuck in Init:0/1

```bash
# Backend waits for MySQL — check if MySQL is actually ready
kubectl get pods -n ecommerce -l app=mysql

# Check init container logs
kubectl logs -n ecommerce <backend-pod-name> -c wait-for-mysql

# Force restart
kubectl rollout restart deployment/ecommerce-backend -n ecommerce
```

### Frontend ImagePullBackOff

```bash
# Verify the image exists on DockerHub
docker pull sandesh300/ecommerce-frontend:v1.0

# Check if imagePullPolicy is Always but image doesn't exist remotely
kubectl describe pod -n ecommerce <frontend-pod-name> | grep -A5 Events

# For local development, use Minikube's Docker daemon
eval $(minikube docker-env)
docker build -t sandesh300/ecommerce-frontend:v1.0 ./frontend
# Then set imagePullPolicy: Never in the deployment
```

### Jenkins cannot connect to Minikube

```bash
# Verify kubeconfig is accessible by jenkins user
sudo -u jenkins kubectl get nodes

# Check if the server address is correct
cat /var/lib/jenkins/.kube/config | grep server

# Minikube IP may change after restart — update kubeconfig
MINIKUBE_IP=$(minikube ip)
sudo sed -i "s|https://[0-9.]*:|https://${MINIKUBE_IP}:|g" \
  /var/lib/jenkins/.kube/config
```

### SonarQube Quality Gate timeout

```bash
# Check SonarQube is running
docker ps | grep sonarqube
curl http://localhost:9000/api/system/status

# Restart if needed
docker restart sonarqube

# Increase Quality Gate timeout in Jenkinsfile (default 10 min)
timeout(time: 20, unit: 'MINUTES') {
  waitForQualityGate abortPipeline: true
}
```

### Falco not detecting events

```bash
# Check Falco is running
kubectl get pods -n falco

# Check if eBPF is supported on your kernel
uname -r  # Should be 4.14+

# Try module driver instead of eBPF
helm upgrade falco falcosecurity/falco -n falco \
  --set driver.kind=module
```

<div align="center">

Security is not a feature — it's a foundation.

⭐ Star this repo if it helped you!

</div>
