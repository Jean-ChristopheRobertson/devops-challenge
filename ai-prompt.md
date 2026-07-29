# Production-Grade Task 2 Prompt (Minikube + Argo CD + Terragrunt)

You are an expert DevOps engineer. Execute a full, production-grade Task 2 proof for this repository on a CLEAN Minikube cluster.

## Objective

Prove the app is deployed and reachable via GitOps, with operational health gates verified end-to-end:

1. Bootstrap Argo CD through Terragrunt entrypoint.
2. Confirm Argo CD application sync + health.
3. Confirm PostgreSQL readiness.
4. Confirm migration Job completion.
5. Confirm web Deployment rollout success.
6. Confirm HPA is present and serving metrics.
7. Run scripts/smoke.mjs and capture HTTP response evidence containing both:
   - LatestPrices
   - Recent Currencies

## Strict requirements

- Use Minikube profile name: devops-clean.
- Use Kubernetes context: devops-clean.
- Keep all commands non-interactive.
- Fail fast on errors.
- Output exact command transcript and key outputs.
- Preserve existing repo files and changes unless a fix is explicitly required.
- Production-grade emphasis:
  - deterministic and idempotent commands
  - explicit waits/timeouts
  - no hidden manual UI actions
  - security- and operations-aware checks

## Required execution plan

### 1) Clean cluster bootstrap

- Delete profile if it exists.
- Start Minikube with Docker driver.
- Enable ingress and metrics-server addons.
- Verify node Ready.

Commands (PowerShell):

```powershell
minikube delete -p devops-clean
minikube start -p devops-clean --driver=docker
minikube addons enable ingress -p devops-clean
minikube addons enable metrics-server -p devops-clean
kubectl config use-context devops-clean
kubectl wait --for=condition=Ready node --all --timeout=180s
```

### 2) Terragrunt bootstrap (Argo CD + Application)

- Use infra/environments/minikube as the Terragrunt entrypoint.
- Set KUBECONFIG and KUBE_CONTEXT explicitly.
- Run init/apply and capture outputs.

```powershell
$env:KUBE_CONTEXT = 'devops-clean'
$env:KUBECONFIG = "$HOME/.kube/config"
Set-Location infra/environments/minikube
terragrunt init
terragrunt apply -auto-approve
Set-Location ../..
```

### 3) Argo CD operational checks

- Confirm Argo CD namespace resources are healthy.
- Confirm devops-challenge Application exists and reaches Synced + Healthy.

```powershell
kubectl -n argocd get pods
kubectl -n argocd wait --for=condition=Ready pod --all --timeout=300s
kubectl -n argocd get application devops-challenge -o yaml
```

Expected gate:

- status.sync.status == Synced
- status.health.status == Healthy

If not ready immediately, poll every 10s for up to 10 minutes and fail with diagnostics.

### 4) Workload gates in devops-challenge namespace

PostgreSQL:

```powershell
kubectl -n devops-challenge get pods -l app=postgres -o wide
kubectl -n devops-challenge wait --for=condition=Ready pod -l app=postgres --timeout=300s
```

Migration Job:

```powershell
kubectl -n devops-challenge get jobs
kubectl -n devops-challenge wait --for=condition=Complete job/prisma-migrate --timeout=600s
kubectl -n devops-challenge logs job/prisma-migrate --tail=200
```

Deployment rollout:

```powershell
kubectl -n devops-challenge rollout status deployment/web --timeout=300s
kubectl -n devops-challenge get pods -l app=web -o wide
kubectl -n devops-challenge get svc web
kubectl -n devops-challenge get ingress web
```

HPA + metrics:

```powershell
kubectl -n devops-challenge get hpa web -o wide
kubectl top pods -n devops-challenge
kubectl top nodes
```

Expected gate:

- HPA exists and reports targets (not "unknown" for CPU metrics after metrics-server warm-up).

### 5) Reachability + smoke proof

- Start Minikube tunnel in a separate terminal/session if required for ingress reachability.
- Run smoke test script from repo root.
- Capture both script output and raw HTTP response sample.

```powershell
Set-Location .
node scripts/smoke.mjs
```

Also capture:

```powershell
curl.exe -sS http://devops-challenge.127.0.0.1.nip.io | Select-String -Pattern 'LatestPrices|Recent Currencies'
```

Expected gate:

- smoke.mjs exits 0
- HTTP response contains both LatestPrices and Recent Currencies

### 6) Final proof report format

Return a concise report with:

1. Cluster bootstrap status.
2. Terragrunt apply status.
3. Argo CD app sync/health status.
4. PostgreSQL readiness evidence.
5. Migration completion evidence.
6. Deployment rollout evidence.
7. HPA metrics evidence.
8. Smoke test output.
9. HTTP content evidence containing LatestPrices and Recent Currencies.
10. Any deviations/fixes applied.

If any gate fails, stop and include:

- failing command
- exact error
- targeted remediation command
- rerun result.
