# Automated Observability Stack on Azure

This project deploys a complete, containerized observability stack (Grafana, Loki, Prometheus, Traefik) onto a single Azure Virtual Machine. The entire lifecycle of the infrastructure and its configuration is managed through a fully automated, GitOps-centric workflow using Terraform, Ansible, and GitHub Actions.

## Core Technologies

This project uses a curated selection of industry-standard tools to achieve end-to-end automation:

* **Terraform**: Manages the infrastructure as code (IaC), provisioning all Azure resources in a modular and reusable fashion.
* **Ansible**: Handles configuration management, preparing the provisioned VM and deploying the application stack.
* **Docker**: Provides the containerization platform for the observability applications, ensuring consistency and isolation.
* **GitHub Actions**: Serves as the CI/CD engine, automating the entire workflow from code commit to active deployment.
* **Trivy**: Integrated into the CI/CD pipeline for automated security scanning of the Terraform code.

## Architecture and Workflow

The architecture is designed around a GitOps model where the `main` branch is the single source of truth.

1.  **Pull Request (Validation)**: When a pull request is opened against the `main` branch, the `validate.yml` workflow is triggered. This workflow performs several checks:
    * Formats and validates the Terraform code.
    * Runs a Trivy security scan on the IaC to detect potential misconfigurations.
    * Generates a `terraform plan` and posts the output as a comment on the pull request for peer review.

2.  **Merge to `main` (Deployment)**: Once the pull request is approved and merged, the `deploy.yml` workflow is triggered. This workflow executes the deployment:
    * Provisions or updates the Azure infrastructure by running `terraform apply`.
    * Retrieves the public IP address of the newly created VM.
    * Runs the Ansible playbook to configure the VM, install Docker, and deploy the observability stack using Docker Compose.

## Prerequisites

Before using this project, you will need the following:

* An Azure subscription.
* An Azure DNS Zone for managing the application's domain name.
* Terraform Cloud account for state management.
* The following tools installed locally:
    * Azure CLI
    * Git
    * Terraform

## Setup and Configuration

To use this repository, you must first configure the necessary secrets for the GitHub Actions workflows.

1.  **Create an Azure Service Principal**: Follow the official Microsoft documentation to create a service principal with `Contributor` rights scoped to your Azure subscription. This will provide the credentials for the CI/CD pipeline to authenticate with Azure.

2.  **Configure GitHub Secrets**: In your repository, navigate to `Settings > Secrets and variables > Actions` and create the following secrets:

| Secret Name | Value |
| :--- | :--- |
| `ARM_CLIENT_ID` | The `appId` from your service principal output. |
| `ARM_CLIENT_SECRET` | The `password` from your service principal output. |
| `ARM_SUBSCRIPTION_ID` | Your Azure Subscription ID. |
| `ARM_TENANT_ID` | The `tenant` from your service principal output. |
| `TF_API_TOKEN` | Your Terraform Cloud API token. |
| `SSH_PUBLIC_KEY` | The **public** key of an SSH key pair dedicated to the pipeline. |
| `SSH_PRIVATE_KEY` | The **private** key of the same SSH key pair. |
| `HOME_DDNS_HOSTNAME`| Your DDNS hostname for SSH access from your local machine. |

3.  **Update Terraform Variables**: In the `variables.tf` file, update the default values for `dns_zone_name` and `dns_resource_group_name` to match your Azure environment.

## How to Use

This repository is designed to be used with a feature-branch Git workflow.

1.  **Create a Feature Branch**:
    ```bash
    git checkout -b feature/my-new-change
    ```
2.  **Make Changes**: Modify the Terraform or Ansible code as needed.
3.  **Commit and Push**:
    ```bash
    git add .
    git commit -m "feat: Describe your new feature"
    git push origin feature/my-new-change
    ```
4.  **Create a Pull Request**: Open a pull request in GitHub to merge your feature branch into `main`.
5.  **Review and Merge**: The `validate` workflow will run, posting a plan and security scan results to the PR. After reviewing and approving, merge the PR.
6.  **Deployment**: Upon merging, the `deploy` workflow will automatically provision and configure your resources. The URLs for the deployed services will be available in the Terraform outputs.

## Project Structure

The project is organized into logical, modular components:

```
.
├── .github/workflows/     # Contains the CI/CD pipeline definitions
│   ├── deploy.yml
│   └── validate.yml
├── ansible/
│   ├── roles/             # Contains reusable Ansible roles
│   │   ├── docker/
│   │   └── observability_stack/
│   └── playbook.yml       # The main Ansible playbook
└── modules/               # Contains reusable Terraform modules
    ├── compute/
    ├── network/
    └── security/
```
