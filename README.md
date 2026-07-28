# :rocket: DevOps Challenge

:wave: Hello and welcome to the DevOps Challenge! https://github.com/moonpay/devops-challenge

We're excited to see what you can do! This take-home exercise is your time to **show off your technical skills and aptitude**. We want to understand how you think, how you solve problems, and how you apply DevOps principles to real-world scenarios.

This exercise uses a simple Next.js application, but our focus is on your DevOps expertise—working with Containers, CI/CD, and Infrastructure as Code (IaC).

> **Note:** For development setup, scripts, and project structure details, see [DEVELOPMENT.md](DEVELOPMENT.md).

## :dart: Goal

Deploy the provided Next.js application in a **production-ready** manner.

## :clipboard: Requirements

You should be comfortable with:

1.  **Docker**: Building and running containers.
2.  **CI/CD & IaC**: Tools like GitHub Actions, Terraform, etc.
3.  **Orchestration**: Kubernetes (GKE or local).
4.  **Git**: Version control.

## :wrench: Tasks

### Task 1: Containerize the Application :package:

1.  Write a `Dockerfile` to containerize the application. :whale:
    - Ensure it follows best practices for a Next.js application.
2.  Build and run the container locally to verify it works. :hammer_and_wrench:

### Task 2: Deploy the Application :rocket:

1.  Deploy the application to **Kubernetes** (GKE or a local cluster such as kind, minikube, or Docker Desktop).
2.  Ensure the solution is **as close to production-ready as possible**. Consider aspects like:
    - Security
    - Scalability
    - Reliability
3.  Demonstrate that the application is reachable and returns the _Latest Crypto Prices_. :globe_with_meridians:

## :hourglass_flowing_sand: Time & Expectations

This is a take-home exercise — complete it on your own time and submit when you're ready. We want to see your best work! Be prepared to walk us through your solution and decision-making during the interview.

## :robot: AI Usage

If you use AI tools to assist with this challenge, please bring the prompts you used to the interview. The interviewers would like to understand how you arrived at your solution.

## :shipit: Option B Skeleton (Minikube + Terraform/Terragrunt + GitOps)

This repository now includes a deployment skeleton based on:

1. Minikube as the Kubernetes target.
2. Terraform modules orchestrated by Terragrunt.
3. Argo CD for GitOps reconciliation.
4. GitHub Actions for CI and GitOps release automation.

### Included Structure

- `Dockerfile`: multi-stage Next.js production image plus a dedicated Prisma migration target.
- `k8s/base`: app manifests (deployment, service, ingress, hpa, pdb, network policy, local postgres, migration job).
- `k8s/overlays/minikube`: Minikube-specific kustomize overlay.
- `argocd/applications/devops-challenge.yaml`: Argo CD Application definition.
- `infra/terraform`: Terraform modules and minikube environment.
- `infra/environments/minikube/terragrunt.hcl`: Terragrunt entrypoint.
- `.github/workflows/ci.yml`: build and publish container image to GHCR on `main`.
- `.github/workflows/gitops-release.yml`: updates image tag in kustomize overlay after successful CI on `main`.

### Local Bootstrap (Skeleton)

```bash
# 1) Start minikube and enable ingress
minikube start
minikube addons enable ingress

# 2) Bootstrap Argo CD + app definition with terragrunt
cd infra/environments/minikube
terragrunt init
terragrunt apply

# 3) Access app
minikube tunnel
# Then browse host configured in k8s/overlays/minikube/kustomization.yaml
```

### Local Pipeline Commands

Use these commands to mirror a Jenkins-style flow locally while keeping the CI/CD boundary explicit:

```bash
pnpm ci        # verify -> build -> application and migration images
pnpm ci:verify # lint, typecheck, unit tests, audit
pnpm ci:build  # Next.js production build
pnpm ci:image  # docker build of the app and Prisma migration images
pnpm cd        # deploy -> smoke
pnpm cd:deploy # load image into Minikube and apply manifests
pnpm cd:smoke  # HTTP smoke test against the Minikube ingress
pnpm ci:all    # verify -> build -> application and migration images
pnpm cd:all    # deploy -> smoke
pnpm pipeline:all # verify -> build -> image -> deploy -> smoke
```

### Important Notes

1. Argo CD reconciles the public fork at `https://github.com/Jean-ChristopheRobertson/devops-challenge.git`.
2. `k8s/overlays/minikube/secret.yaml` is intentionally plaintext for local demo only. Replace with sealed/external secret management for real production.
3. CI publishes public `ghcr.io/jean-christopherrobertson/devops-challenge` and `ghcr.io/jean-christopherrobertson/devops-challenge-migrate` images. Public images need no Kubernetes image-pull secret; set each package visibility to public after its first successful release.
4. The Prisma migration job is enabled as an Argo CD `Sync` hook. It waits for the local PostgreSQL Service, runs `prisma migrate deploy` from the dedicated migration image, and completes before the web Deployment sync wave.

Good luck! :four_leaf_clover:
