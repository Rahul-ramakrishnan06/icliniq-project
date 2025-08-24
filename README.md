# iCliniq_Assesment

This repository contains the **iCliniq Project**, a Node.js-based backend deployed on **Google Cloud Run** using **Docker**, **Terraform**, and **GitHub Actions** for automated CI/CD. The project also integrates monitoring, alerting, and secret management for secure and reliable operations.

## Setup & Deployment Steps

### **1. Prerequisites**
- Node.js **v18+**
- Docker installed and configured
- Terraform **v1.13+**
- A **Google Cloud Platform (GCP)** project
- Enable the following GCP APIs:
  - Cloud Run
  - Artifact Registry
  - Secret Manager
  - Cloud Monitoring

### **2. Local Setup**
```bash
#Configure the following environment variables with your local database values:
DB_HOST
DB_USER
DB_PASSWORD
DB_NAME
PORT #optional
```
```bash
# Clone the repository
git clone https://github.com/Rahul-ramakrishnan06/icliniq-project.git
cd icliniq-project/app

# Install dependencies
npm install

# Run the app locally
npm run dev
```
Note: The schema will be automatically created at startup.

The app will start on **http://localhost:8080**.

### **3. Build & Push Docker Image**
```bash
docker build -t gcr.io/<PROJECT_ID>/icliniq-node-app:latest ./app
docker push gcr.io/<PROJECT_ID>/icliniq-node-app:latest
```

### **4. Deploy Infrastructure (Terraform)**

Note: GCP bucket need to be provisioned manualy for storing terraform state files.

```bash
cd ../gcp

# Initialize Terraform
terraform init   

# Validate and apply infrastructure
terraform fmt -recursive
terraform validate
terraform plan
terraform apply -auto-approve
```

Terraform provisions:
- Cloud Run service
- Artifact Registry
- VPC & Firewalls
- Postgres Cloud SQL Database
- Secret Manager
- Monitoring & Alerts

### **5. CI/CD Deployment**
This project uses **GitHub Actions** workflows:

- `deploy.yml` → Builds, scans, and deploys the Node.js app to Cloud Run.
- `infra-setup.yaml` → Manages Terraform provisioning and security scans.

Automatic deployment triggers:
```bash
branch: master only 
  on: push,merge,manual trigger
```

---

## Security Measures Taken

| Area                 | Implementation |
|----------------------|----------------|
| **Secrets**         | Stored securely in **GCP Secret Manager** and injected at runtime. |
| **CI/CD Security**  | Uses **service account** to interact with GCP services. |
| **Docker Scans**    | Integrated **Trivy** to scan for vulnerabilities during CI/CD. |
| **IAM Policies**    | Terraform sets **least privilege** IAM roles for services. |
| **Transport Security** | Cloud Run automatically provisions HTTPS. |
| **Static Code Analysis** | Uses `npm audit`, `tfsec`, and `tflint` for app & infra scanning. |

---

## Assumptions

- The application is **designed for GCP Cloud Run** and is not tested on other environments.
- Deployment is assumed for **single-region architecture**.
- Cloud Monitoring and alerting are set up for **CPU utilization and error metrics only**.
- Secrets are managed through GCP Secret Manager and never committed to source control.
- Sufficient GCP quota and IAM permissions are assumed to be configured.


## Explanation of Alerting Setup

Alerting is configured in **gcp/monitoring.tf** using **Google Cloud Monitoring**.

### **1. Metrics Monitored**
- **CPU Utilization** on the Cloud Run service
- **Application Errors** from Cloud Logging

### **2. Alert Types**
| Alert Type      | Threshold | Notification Channel |
|-----------------|-----------|----------------------|
| **Warning**    | CPU > 70% | Slack |
| **Critical**   | CPU > 80% | Email |
| **Error Logs** | High app error count | Email + Slack |

### **3. Slack Integration**
- Uses a **Slack Bot OAuth Token** (`var.slack_token`) [can be stored in repository secrets when automating terraform provisioning].
- Sends proactive alerts to a dedicated Slack channel.

### **4. Email Alerts**
- Configured via `google_monitoring_notification_channel`.
- Sends critical alerts to predefined email recipients.

### **5. Log-Based Metrics**
- Custom error-based metrics track **Cloud Run ERROR logs**.
- Alerts are triggered if errors exceed defined thresholds.

---

## Tech Stack
- **Backend** → Node.js (Express)
- **Infrastructure** → Terraform
- **Deployment** → Google Cloud Run
- **Container Registry** → Google Artifact Registry
- **Monitoring** → Google Cloud Monitoring + Slack + Email
- **CI/CD** → GitHub Actions
- **Security Scanning** → Trivy, npm audit, tfsec

---

## Folder Structure
```
icliniq-project/
├── app/                   # Node.js backend app
│   ├── Dockerfile         # Multi-stage Dockerfile
│   ├── package.json       # Dependencies & scripts
│   └── src/               # API source code
├── gcp/                   # Terraform infrastructure configs
│   ├── main.tf            # Cloud Run setup
│   ├── monitoring.tf      # Monitoring + Alerting
│   ├── secrets.tf         # Secret Manager integration
│   └── db.tf              # Cloud SQL DB
└── .github/workflows/     # CI/CD workflows
    ├── deploy.yml          # Build & Deploy app
    └── infra-setup.yaml   # Infra provisioning
```

---

## Summary

This project demonstrates:
- **infrastructure provisioning** using Terraform.
- **Secure CI/CD pipelines** using GitHub Actions.
- **Scalable deployment** via Cloud Run.
- Proactive **monitoring and alerting** for app health and performance.
