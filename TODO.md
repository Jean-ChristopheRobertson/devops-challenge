# Production Hardening TODOs

The original containerization and Minikube deployment tasks are complete. This list tracks the next production-readiness improvements in delivery order.

## 1. Replace plaintext Kubernetes secrets

- **Status:** Complete.
- **Current state:** the plaintext Minikube Secret manifest was removed and replaced with a strict namespace/name-bound encrypted `SealedSecret`.
- **Delivered:** Bitnami Sealed Secrets controller is provisioned through Terraform; Argo CD tracks the `SealedSecret`; the database credential was rotated during migration.
- **Operational requirement:** back up controller sealing keys securely, rotate underlying credentials regularly, and reseal values whenever they change. A `SealedSecret` is cluster-specific unless sealing keys are deliberately shared.

## 2. Move production PostgreSQL to a managed service

- **Status:** Not started.
- **Done when:** production configuration targets a managed PostgreSQL service with private networking, backup/PITR, encryption, monitoring, rotation, and a documented migration/cutover plan. The in-cluster PostgreSQL workload remains explicitly local-demo only.

## 3. Add production DNS and TLS

- **Status:** Not started.
- **Done when:** ingress uses a real managed DNS name, cert-manager issues and renews TLS certificates, HTTP redirects to HTTPS, and certificate/ingress readiness are verified.

## 4. Add observability and alerting

- **Status:** Complete.
- **Delivered:** Prometheus, Grafana, Alertmanager, blackbox probing, PostgreSQL exporter, application dashboard, and Prometheus alert rules.
- **Validated:** Prometheus collects PostgreSQL connections, blackbox web availability, and Deployment replica metrics; Grafana discovers the labeled dashboard; alert groups load successfully; the application smoke test passes.
- **Operational notes:** Kubernetes container logs remain available through `kubectl logs`; add centralized long-term log storage and an external alert receiver when selecting a production platform.
- **Done when:** application, Kubernetes, database, and ingress signals are collected; dashboards and actionable alerts cover availability, latency, errors, saturation, deployment failures, and database health.

## 5. Publish the operational runbook

- **Status:** Not started.
- **Done when:** README documents the exact Minikube profile, addon setup, Terragrunt bootstrap, tunnel lifecycle, ingress URL, verification commands, rollback, and troubleshooting.

## 6. Add disposable-cluster Kubernetes integration CI

- **Status:** Not started.
- **Done when:** a scheduled and manually triggerable workflow provisions an ephemeral cluster, deploys the GitOps stack, waits for Argo/PostgreSQL/migrations/web/HPA, runs `scripts/smoke.mjs`, captures diagnostics, and tears down safely.
