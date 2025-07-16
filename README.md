# 🚀 Azure VM Baseline Architecture with Terraform

This repository contains a fully modular, production-ready implementation of Microsoft's Azure VM baseline architecture—built entirely with Terraform and designed for real-world scalability, security, and automation.

## 📦 Modules Included

| Module         | Description                                                  |
|----------------|--------------------------------------------------------------|
| `resource_group` | Creates the project-level resource group with tagging       |
| `network`        | Deploys VNet and delegated subnets (frontend, backend, bastion) |
| `security`       | Sets up Key Vault with secrets-as-code using User Assigned Identity |
| `lb_public`      | Configures zone-redundant public Load Balancer with probes and rules |
| `lb_internal`    | Deploys private internal Load Balancer for backend services |
| `app_gateway`    | Sets up Application Gateway WAF_v2 with diagnostics and routing |
| `vmss`           | Creates VM Scale Sets with cloud-init bootstrap and identity injection |
| `monitoring`     | Log Analytics Workspace and Application Insights for telemetry |

---
<img width="1335" height="1163" alt="image" src="https://github.com/user-attachments/assets/1c4d87d9-25b4-4ec0-a197-a3c2be043357" />

https://learn.microsoft.com/en-us/azure/architecture/virtual-machines/baseline

## 🧱 Architecture Highlights



- 🔐 **Secrets-as-Code**: Key Vault + User Assigned Managed Identity
- ⚙️ **VMSS Frontend & Backend**: Zone-aware, cloud-init ready, modular
- 🚧 **NSG Enforcement**: Per subnet, with tightly scoped ingress rules
- 🧭 **App Gateway WAF_v2**: Preconfigured diagnostics streamed to Log Analytics
- 🛰️ **Load Balancers**: Standard SKU, with health probes and custom routing
- 📊 **Monitoring**: Centralized logs & metrics via LAW and App Insights

---

## 🛠️ Deploy This Architecture

1. Clone the repo:
   ```bash
   git clone [https://github.com/<your-username>/vm-baseline-azure.git](https://github.com/kale-swapnil/azure_vm_baseline_architecture.git)
   ``

2. Authenticate to Azure:
   ```bash
   az login
   ```

3. Initialize Terraform:
   ```bash
   terraform init
   ```

4. Plan and apply:
   ```bash
   terraform plan
   terraform apply
   ```

---

## 🧪 Development Features

- Designed for CI/CD pipelines via GitHub Actions
- Cloud-init templates auto-configure VMSS instances securely
- Parameterised inputs using `variables.tf` for region, zones, instance sizing, and module control
- Diagnostic settings integrated at App Gateway for real-time visibility

---

## 📮 Feedback & Contributions

Open to collaboration, improvements, or issue reports. Feel free to fork and extend. If you’re using this in production or adapting it for internal teams, drop a star and share how you made it your own.
