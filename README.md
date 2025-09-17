# Automated Observability Stack on Azure

This project deploys a complete, production-ready observability stack (Grafana, Loki, Prometheus, Traefik) onto a single Azure Virtual Machine with enterprise-grade authentication through Microsoft Entra ID (Azure AD). The entire lifecycle—from infrastructure provisioning to application deployment—is managed through a fully automated, GitOps-centric workflow using Terraform, Ansible, and GitHub Actions.

## 🏗️ Architecture Overview

The solution deploys a containerized observability stack with the following components:

- **Traefik**: Reverse proxy with automatic Let's Encrypt SSL certificates and SSO integration
- **Grafana**: Data visualization and dashboarding with Entra ID OAuth integration
- **Prometheus**: Metrics collection and storage with node-exporter and cAdvisor
- **Loki**: Log aggregation with Promtail for log collection
- **Forward Auth**: SSO middleware for securing services behind Entra ID authentication

All services are secured with SSL certificates, protected by Microsoft Entra ID authentication, and accessible via subdomains (e.g., `grafana.your-domain.com`, `prometheus.your-domain.com`).

## 🚀 Core Technologies

- **Terraform**: Infrastructure as Code for Azure resource provisioning
- **Ansible**: Configuration management and application deployment
- **Docker & Docker Compose**: Container orchestration
- **GitHub Actions**: CI/CD pipeline automation
- **Traefik**: Reverse proxy and SSL termination
- **Microsoft Entra ID**: Enterprise authentication and authorization
- **Azure DNS**: Domain name management
- **Let's Encrypt**: Automated SSL certificate management

## 📋 Prerequisites

Before using this project, ensure you have the following:

### Required Accounts and Services
1. **Azure Subscription** with sufficient permissions to create resources
2. **Azure DNS Zone** for your domain (e.g., `example.com`)
3. **Microsoft Entra ID Tenant** (comes with Azure subscription)
4. **Terraform Cloud Account** for remote state management
5. **GitHub Repository** (fork or clone this repository)

### Required Tools (for local development)
- Azure CLI
- Terraform CLI
- Git

## 🔧 Setup Instructions

### Step 1: Azure DNS Zone Setup

1. Create an Azure DNS Zone for your domain:
   ```bash
   az group create --name rgDns --location "East US"
   az network dns zone create --resource-group rgDns --name "yourdomain.com"
   ```

2. Configure your domain registrar to use Azure's name servers (found in the DNS zone overview).

### Step 2: Azure Service Principal Creation

Create a service principal for the GitHub Actions pipeline:

```bash
# Create service principal with Contributor role
az ad sp create-for-rbac --name "github-actions-observability" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --sdk-auth
```

Save the output - you'll need these values for GitHub secrets:
- `appId` → `ARM_CLIENT_ID`
- `password` → `ARM_CLIENT_SECRET`
- `tenant` → `ARM_TENANT_ID`
- Your subscription ID → `ARM_SUBSCRIPTION_ID`

### Step 3: Terraform Cloud Configuration

1. Create a [Terraform Cloud account](https://app.terraform.io/)
2. Create an organization (e.g., `your-org-name`)
3. Generate an API token: User Settings → Tokens → Create an API token
4. The workspaces will be created automatically based on the `tags` in `main.tf`

### Step 4: Microsoft Entra ID App Registration

You need to create **one** app registration in Entra ID with **two** client secrets:

#### Create the App Registration

1. Navigate to Azure Portal → Entra ID → App registrations → New registration
2. Configure:
   - **Name**: `observability-stack`
   - **Supported account types**: Accounts in this organizational directory only
   - **Redirect URIs**: Add:
      - `https://auth.YOUR-DOMAIN.COM/_oauth` for Forward Auth
      - `https://grafana.YOUR-DOMAIN.COM/login/generic_oauth` for Grafana
      - `https://prometheus.YOUR-DOMAIN.COM/_oauth` for Prometheus
3. After creation, note the **Application (client) ID** and **Directory (tenant) ID**

#### Create Client Secrets

1. Go to "Certificates & secrets" → "Client secrets"
2. Create **two** client secrets:
   - **Secret 1**: `forward-auth-secret` → Save the **secret value** for `ENTRA_CLIENT_SECRET`
   - **Secret 2**: `grafana-oauth-secret` → Save the **secret value** for `GRAFANA_OAUTH_CLIENT_SECRET`

#### Entra ID Group for Grafana Admins (Optional but Recommended)

1. Go to Entra ID → Groups → New group
2. Create a security group (e.g., `Grafana-Admins`)
3. Add users who should have admin access to Grafana
4. Note the **Object ID** of the group

#### Token Configuration

Configure the Auth token to include security group membership.

1. Go to "Token Configuration"
2. Click "Add groups claim"
   - Select "Security groups"
   - "ID" > "Group ID"
   - Click "Add"

### Step 5: SSH Key Pair Generation

Generate an SSH key pair for VM access:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_actions_runner -C "github-actions"
```

This creates:
- `~/.ssh/github_actions_runner` (private key)
- `~/.ssh/github_actions_runner.pub` (public key)

### Step 6: GitHub Repository Configuration

#### Fork or Clone Repository

Fork this repository or clone it to your own GitHub account.

#### Configure Repository Secrets

Go to your repository → Settings → Secrets and variables → Actions → New repository secret

Create the following secrets:

| Secret Name | Description | Example/Notes |
|-------------|-------------|---------------|
| `ARM_CLIENT_ID` | Service Principal App ID | From Step 2 output |
| `ARM_CLIENT_SECRET` | Service Principal Password | From Step 2 output |
| `ARM_SUBSCRIPTION_ID` | Your Azure Subscription ID | `12345678-1234-1234-1234-123456789012` |
| `ARM_TENANT_ID` | Your Entra ID Tenant ID | From Step 2 output |
| `TF_API_TOKEN` | Terraform Cloud API Token | From Step 3 |
| `SSH_PUBLIC_KEY` | Public SSH key content | Content of `~/.ssh/github_actions_runner.pub` |
| `SSH_PRIVATE_KEY` | Private SSH key content | Content of `~/.ssh/github_actions_runner` |
| `HOME_DDNS_HOSTNAME` | Your home DDNS hostname | `home.ddns.net` (for SSH access) |
| `ENTRA_TENANT_ID` | Entra ID Tenant ID | Same as `ARM_TENANT_ID` |
| `ENTRA_CLIENT_ID` | Forward Auth App Client ID | From App Registration |
| `ENTRA_CLIENT_SECRET` | Forward Auth App Secret | First client secret from App Registration |
| `FORWARD_AUTH_SECRET` | Random secret for Forward Auth | Generate: `openssl rand -base64 32` |
| `ALLOWED_USERS` | Comma-separated list of allowed emails | `user1@domain.com,user2@domain.com` |
| `GRAFANA_OAUTH_CLIENT_SECRET` | Grafana App Secret | Second client secret from App Registration |
| `GRAFANA_OAUTH_ADMIN_GROUP_ID` | Grafana Admin Group Object ID | From Step 4 (optional) |

### Step 7: Update Terraform Variables

Edit `variables.tf` to match your environment:

```hcl
variable "dns_zone_name" {
  description = "The name of the existing Azure DNS Zone."
  type        = string
  default     = "yourdomain.com"  # ← Update this
}

variable "dns_resource_group_name" {
  description = "The name of the resource group where the DNS zone is located."
  type        = string
  default     = "rgDns"  # ← Update this if different
}
```

Update the Terraform Cloud organization in `main.tf`:

```hcl
cloud {
  organization = "your-org-name"  # ← Update this
  workspaces {
    tags = { project = "grafana" }
  }
}
```

## 🚦 Usage Workflow

This project follows a GitOps workflow where the `main` branch represents the desired state of your infrastructure.

### Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/add-new-monitoring
   ```

2. **Make your changes** to Terraform configurations or Ansible playbooks

3. **Commit and push**:
   ```bash
   git add .
   git commit -m "feat: Add new monitoring configuration"
   git push origin feature/add-new-monitoring
   ```

4. **Create a Pull Request** against the `main` branch

5. **Review the automated plan**: The `validate.yml` workflow will:
   - Run Terraform format checks
   - Perform security scanning with Trivy
   - Generate and post a Terraform plan as a PR comment
   - Validate all configurations

6. **Merge the PR**: After review and approval, merge the PR to `main`

7. **Automatic deployment**: The `deploy.yml` workflow will:
   - Provision/update Azure infrastructure
   - Configure the VM with Ansible
   - Deploy the observability stack
   - Provide access URLs in the workflow output

### Manual Deployment Trigger

You can also trigger deployments manually:
- Go to Actions → Deploy to Production → Run workflow

## 🌐 Accessing Your Services

After successful deployment, your services will be available at:

- **Grafana**: `https://grafana.YOUR-DOMAIN.COM`
- **Prometheus**: `https://prometheus.YOUR-DOMAIN.COM` 
- **Traefik Dashboard**: `https://traefik.YOUR-DOMAIN.COM`

All services are protected by Microsoft Entra ID authentication. Users must be in your `ALLOWED_USERS` list to access the services.

### Default Data Sources

Grafana comes pre-configured with:
- **Prometheus**: Default data source for metrics
- **Loki**: Data source for logs

## 📁 Project Structure

```
.
├── .github/workflows/          # CI/CD pipeline definitions
│   ├── deploy.yml             # Production deployment workflow
│   └── validate.yml           # PR validation workflow
├── ansible/                   # Configuration management
│   ├── roles/
│   │   ├── docker/           # Docker installation and setup
│   │   └── observability_stack/  # Stack deployment and config
│   ├── ansible.cfg           # Ansible configuration
│   ├── playbook.yml          # Main Ansible playbook
│   └── requirements.yml      # Ansible dependencies
├── modules/                   # Terraform modules
│   ├── compute/              # Virtual machine resources
│   ├── network/              # Networking resources  
│   └── security/             # Security group rules
├── dns.tf                    # DNS record management
├── main.tf                   # Main Terraform configuration
├── outputs.tf                # Terraform outputs
├── variables.tf              # Terraform variables
└── README.md                 # This file
```

## 🔒 Security Features

- **SSL/TLS**: Automatic Let's Encrypt certificates for all services
- **Authentication**: Microsoft Entra ID SSO integration
- **Authorization**: Role-based access control in Grafana
- **Network Security**: Azure NSG rules limiting access
- **Infrastructure Scanning**: Automated security scanning with Trivy
- **Secret Management**: All sensitive data stored in GitHub Secrets

## 🐛 Troubleshooting

### Common Issues

#### 1. DNS Resolution Problems
- Ensure your domain's nameservers point to Azure DNS
- Verify the DNS zone is correctly configured
- Check that the A and CNAME records are created properly

#### 2. SSL Certificate Issues
- Let's Encrypt requires ports 80 and 443 to be accessible
- Ensure your domain resolves to the correct IP address
- Check Traefik logs: `docker logs traefik`

#### 3. Authentication Failures
- Verify Entra ID app registrations have correct redirect URIs
- Ensure "Token Configuration" includes Security Groups, and that the user has the proper group membership.
- Check that both client secrets are valid and correctly configured in GitHub secrets
- Check that user emails are in the `ALLOWED_USERS` list

#### 4. Deployment Failures
- Check GitHub Actions workflow logs for specific errors
- Verify all secrets are correctly configured
- Ensure service principal has sufficient permissions

### Accessing VM for Debugging

SSH into the VM using:
```bash
ssh -i ~/.ssh/github_actions_runner azureuser@VM_PUBLIC_IP
```

View container logs (from VM):
```bash
docker logs grafana
docker logs traefik
docker logs prometheus
```

Check service status (from VM):
```bash
docker ps
docker compose ps
```

## 🔄 Updates and Maintenance

### Updating the Stack
1. Create a feature branch
2. Update Docker image tags in `docker-compose.yml`
3. Test changes in development environment
4. Create PR and review changes
5. Merge to trigger deployment

### Monitoring Resources
- Monitor Azure costs in the Azure portal
- Check VM resource utilization in Grafana
- Review logs in Loki for any issues

### Backup Considerations
- Grafana dashboards and settings are stored in Docker volumes
- Consider implementing backup strategies for persistent data
- Terraform state is managed by Terraform Cloud

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Create a pull request with detailed description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
