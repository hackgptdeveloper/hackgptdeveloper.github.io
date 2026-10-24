# Runbook: Create Project Namespace and Baseline Resources

## Metadata

| Field | Value |
|---|---|
| Runbook ID | RB-K8S-CREATE-PROJECT-NS-001 |
| Operation | create |
| Resource type | Kubernetes namespace and baseline policy resources |
| Owner | Platform Engineering |
| On-call | `#platform-oncall` |
| Risk | Medium |
| Environments | `dev`, `staging`, `prod` |
| Required approval | Platform Engineering lead for `prod`; team lead for `dev`/`staging` |
| Source of truth | `platform-infra/k8s/project-namespace` |
| Review cadence | Quarterly |
| Last reviewed | 2026-10-22 |

## Purpose

Create an isolated project namespace with baseline resource governance, access control, workload security policy, and network isolation.

This runbook creates:

- `Namespace`
- `ResourceQuota`
- `LimitRange`
- Namespace-scoped `Role` and `RoleBinding`
- Pod Security Admission labels
- Default-deny `NetworkPolicy`
- Standard ownership and cost-allocation labels

A namespace is not a complete security boundary by itself; isolation requires namespace-scoped RBAC, network policy, admission controls, and resource governance. [kubernetes](https://kubernetes.io/docs/concepts/policy/resource-quotas/)

## Preconditions

Before starting, confirm all items:

- [ ] Approved request exists in Jira/ServiceNow.
- [ ] Request includes project ID, owning team, environment, cost center, data classification, and resource requirements.
- [ ] Operator is authenticated to the correct cluster.
- [ ] Operator has `platform-provisioner` permissions in the target environment.
- [ ] Namespace name is available and follows naming convention.
- [ ] Resource quota values are approved by the requesting team and Platform Engineering.
- [ ] For `prod`, change approval is recorded.
- [ ] No existing namespace uses the requested name.

## Inputs

| Variable | Required | Example | Validation |
|---|---:|---|---|
| `PROJECT_ID` | Yes | `payments` | Lowercase DNS label: `^[a-z0-9]([-a-z0-9]*[a-z0-9])?$`, max 63 characters |
| `ENVIRONMENT` | Yes | `prod` | `dev`, `staging`, or `prod` |
| `TEAM` | Yes | `payments-team` | Existing team/group name |
| `COST_CENTER` | Yes | `cc-4821` | Valid finance cost center |
| `DATA_CLASSIFICATION` | Yes | `confidential` | `internal`, `confidential`, or `restricted` |
| `CPU_REQUEST` | Yes | `4` | Positive Kubernetes CPU quantity |
| `CPU_LIMIT` | Yes | `8` | Greater than or equal to `CPU_REQUEST` |
| `MEMORY_REQUEST` | Yes | `8Gi` | Positive Kubernetes memory quantity |
| `MEMORY_LIMIT` | Yes | `16Gi` | Greater than or equal to `MEMORY_REQUEST` |
| `MAX_PODS` | Yes | `40` | Positive integer |
| `NAMESPACE` | Generated | `payments-prod` | `$PROJECT_ID-$ENVIRONMENT` |

## Naming and labeling standards

Namespace name:

```text
<project-id>-<environment>
```

Required namespace labels:

```yaml
app.kubernetes.io/part-of: <PROJECT_ID>
environment: <ENVIRONMENT>
owner: <TEAM>
cost-center: <COST_CENTER>
data-classification: <DATA_CLASSIFICATION>
managed-by: platform-engineering
network-policy: default-deny
```

Use consistent labels for ownership, environment, cost allocation, and policy selection. [github](https://github.com/lukemurraynz/hve-agent-skills/blob/main/skills/aks-cluster-architecture/bundles/production-workload-controls/guide.md)

## Procedure

### 1. Verify target cluster

```bash
kubectl config current-context
kubectl auth can-i create namespaces
kubectl auth can-i create resourcequotas
kubectl auth can-i create limitranges
kubectl auth can-i create roles
kubectl auth can-i create rolebindings
kubectl auth can-i create networkpolicies
```

**Verify:** The current context is the approved cluster, and every permission check returns `yes`.

**If failed:** Stop. Request access through Platform Engineering. Do not use a broader identity or `cluster-admin`.

### 2. Confirm namespace does not exist

```bash
NAMESPACE="<PROJECT_ID>-<ENVIRONMENT>"

kubectl get namespace "${NAMESPACE}" \
  -o name 2>/dev/null || echo "NAMESPACE_AVAILABLE"
```

**Verify:** Output is `NAMESPACE_AVAILABLE`.

**If failed:** Stop. Investigate ownership, labels, and workloads before proceeding. Do not reuse or modify an existing namespace without a separate modification runbook.

### 3. Create the namespace

Save as `namespace.yaml`:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: <PROJECT_ID>-<ENVIRONMENT>
  labels:
    app.kubernetes.io/part-of: <PROJECT_ID>
    environment: <ENVIRONMENT>
    owner: <TEAM>
    cost-center: <COST_CENTER>
    data-classification: <DATA_CLASSIFICATION>
    managed-by: platform-engineering
    network-policy: default-deny
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

Apply it:

```bash
kubectl apply -f namespace.yaml
```

**Verify:**

```bash
kubectl get namespace "${NAMESPACE}" \
  --show-labels
```

**Verify:**

- Namespace exists.
- All required labels are present.
- Pod Security Admission labels are `restricted` for `prod`; `baseline` may be used in non-production only with a documented exception.

Pod Security Admission enforces the restricted standard through the `pod-security.kubernetes.io/*` namespace labels. [kubernetes](https://kubernetes.io/docs/concepts/security/pod-security-admission/)

### 4. Create resource quota

Save as `resource-quota.yaml`:

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: project-baseline-quota
  namespace: <PROJECT_ID>-<ENVIRONMENT>
spec:
  hard:
    requests.cpu: "<CPU_REQUEST>"
    requests.memory: "<MEMORY_REQUEST>"
    limits.cpu: "<CPU_LIMIT>"
    limits.memory: "<MEMORY_LIMIT>"
    pods: "<MAX_PODS>"
    persistentvolumeclaims: "10"
    services.loadbalancers: "1"
```

Apply it:

```bash
kubectl apply -f resource-quota.yaml
```

**Verify:**

```bash
kubectl describe resourcequota project-baseline-quota \
  --namespace "${NAMESPACE}"
```

**Verify:**

- CPU, memory, pod, PVC, and LoadBalancer limits match the approved request.
- `Used` values are zero or expected.
- No warning indicates the quota was rejected.

`ResourceQuota` constrains aggregate namespace consumption and can also cap object counts such as pods and services. [kubernetes](https://kubernetes.recipes/recipes/configuration/namespace-management/)

### 5. Create limit range

Save as `limit-range.yaml`:

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: project-baseline-limits
  namespace: <PROJECT_ID>-<ENVIRONMENT>
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 100m
        memory: 128Mi
      default:
        cpu: 500m
        memory: 512Mi
      min:
        cpu: 50m
        memory: 64Mi
      max:
        cpu: "2"
        memory: 2Gi
    - type: PersistentVolumeClaim
      min:
        storage: 1Gi
      max:
        storage: 50Gi
```

Apply it:

```bash
kubectl apply -f limit-range.yaml
```

**Verify:**

```bash
kubectl describe limitrange project-baseline-limits \
  --namespace "${NAMESPACE}"
```

**Verify:**

- Default requests and limits are present.
- Maximum per-container values are within the approved project quota.
- PVC bounds match storage policy.

`LimitRange` supplies defaults for containers that omit requests or limits and enforces minimum and maximum resource values. [deepwiki](https://deepwiki.com/learnk8s/kubernetes-production-best-practices/3.1-namespace-limits)

### 6. Create namespace-scoped RBAC

Save as `rbac.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: project-developer
  namespace: <PROJECT_ID>-<ENVIRONMENT>
rules:
  - apiGroups: ["", "apps", "batch"]
    resources:
      - pods
      - pods/log
      - services
      - configmaps
      - deployments
      - replicasets
      - statefulsets
      - jobs
      - cronjobs
    verbs:
      - get
      - list
      - watch
      - create
      - update
      - patch
      - delete

  - apiGroups: [""]
    resources:
      - secrets
    verbs:
      - get
      - list
      - watch

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: project-developer-binding
  namespace: <PROJECT_ID>-<ENVIRONMENT>
subjects:
  - kind: Group
    name: <TEAM>
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: project-developer
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```bash
kubectl apply -f rbac.yaml
```

**Verify:**

```bash
kubectl auth can-i list pods \
  --as=system:group:<TEAM> \
  --namespace "${NAMESPACE}"

kubectl auth can-i delete namespaces \
  --as=system:group:<TEAM> \
  --namespace "${NAMESPACE}"
```

**Verify:**

- First command returns `yes`.
- Second command returns `no`.
- No `ClusterRoleBinding` is created for the project team.

Use namespace-scoped `Role` and `RoleBinding`, and avoid broad or cluster-admin access for project teams. [nirgeier.github](https://nirgeier.github.io/KubernetesLabs/37-ResourceQuotas/)

### 7. Create default-deny network policy

Save as `network-policy.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: <PROJECT_ID>-<ENVIRONMENT>
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```

Apply it:

```bash
kubectl apply -f network-policy.yaml
```

**Verify:**

```bash
kubectl get networkpolicy default-deny-all \
  --namespace "${NAMESPACE}" \
  -o yaml
```

**Verify:**

- `policyTypes` contains both `Ingress` and `Egress`.
- No ingress or egress rules are present in the default-deny policy.
- Any required exceptions are added through separate, reviewed network policies.

A default-deny policy blocks ingress and egress unless explicitly allowed by another policy. [atmosly](https://atmosly.com/blog/kubernetes-namespace-management-best-practices-2025)

### 8. Validate baseline resources

```bash
kubectl get namespace,resourcequota,limitrange,role,rolebinding,networkpolicy \
  --namespace "${NAMESPACE}"
```

Expected result:

```text
NAME                                      STATUS   AGE
namespace/<PROJECT_ID>-<ENVIRONMENT>      Active   ...

NAME                                                  AGE
resourcequota/project-baseline-quota                  ...

NAME                                      CREATED AT
limitrange/project-baseline-limits        ...

NAME                                      CREATED AT
role/project-developer                    ...

NAME                                      ROLE              AGE
rolebinding/project-developer-binding     Role/project-developer ...

NAME                                      POD-SELECTOR   AGE
networkpolicy/default-deny-all            <none>         ...
```

Run an end-to-end smoke test:

```bash
kubectl run baseline-smoke-test \
  --namespace "${NAMESPACE}" \
  --image=registry.k8s.io/pause:3.10 \
  --restart=Never

kubectl get pod baseline-smoke-test \
  --namespace "${NAMESPACE}" \
  -o jsonpath='{.spec.containers.resources}'

kubectl delete pod baseline-smoke-test \
  --namespace "${NAMESPACE}"
```

**Verify:**

- Test pod is created.
- It receives default CPU and memory requests/limits from the `LimitRange`.
- It is deleted after validation.

### 9. Record completion

Update the original request with:

- Namespace name.
- Cluster and environment.
- Approved quota values.
- Owner group.
- Cost center.
- Data classification.
- Links to applied manifests or Git commit.
- Operator name and completion timestamp.

Notify the requesting team:

```text
Project namespace <NAMESPACE> has been created in <CLUSTER>.
Owner: <TEAM>
Resource quota: CPU request <CPU_REQUEST>, CPU limit <CPU_LIMIT>,
memory request <MEMORY_REQUEST>, memory limit <MEMORY_LIMIT>, max pods <MAX_PODS>.
Network access is default-deny; submit a network-policy change request for required exceptions.
```

## Rollback

Use this only if creation failed, was approved in error, or the namespace contains no workloads or persistent data.

```bash
NAMESPACE="<PROJECT_ID>-<ENVIRONMENT>"

kubectl get all,pvc,secret,configmap \
  --namespace "${NAMESPACE}"

kubectl delete namespace "${NAMESPACE}"
```

**Verify:**

```bash
kubectl get namespace "${NAMESPACE}" 2>/dev/null \
  || echo "NAMESPACE_REMOVED"
```

**Warning:** Deleting the namespace deletes all resources inside it, including workloads, configuration, secrets, PVCs, and namespace-scoped RBAC. Do not run rollback if the namespace contains production data or active workloads.

If resources must be retained, remove only the newly created baseline objects instead:

```bash
kubectl delete resourcequota project-baseline-quota --namespace "${NAMESPACE}"
kubectl delete limitrange project-baseline-limits --namespace "${NAMESPACE}"
kubectl delete role project-developer --namespace "${NAMESPACE}"
kubectl delete rolebinding project-developer-binding --namespace "${NAMESPACE}"
kubectl delete networkpolicy default-deny-all --namespace "${NAMESPACE}"
```

## Failure handling

| Symptom | Likely cause | Action | Escalation |
|---|---|---|---|
| `kubectl auth can-i` returns `no` | Missing RBAC permissions | Stop; request `platform-provisioner` access | Platform on-call |
| Namespace already exists | Name collision or duplicate request | Identify owner and existing workload | Platform Engineering lead |
| `ResourceQuota` rejected | Invalid quantity or exceeds cluster policy | Correct approved values; reapply | Capacity owner |
| Pod cannot schedule | Quota, node capacity, taints, or admission policy | Inspect events and quota usage | Platform on-call |
| Pod fails admission | Pod violates restricted Pod Security Standard | Remediate workload manifest or document exception | Security Engineering |
| Required external access fails | Default-deny network policy | Add narrowly scoped ingress/egress policy through review | Network/Security team |
| Team cannot access namespace | Incorrect group name or role binding | Verify identity provider group and `RoleBinding` | Identity/Platform team |

## Change control

- Any change to quota values requires a new approved request.
- Any relaxation of Pod Security, RBAC, or network policy requires security review.
- Do not grant namespace teams permission to modify or delete `ResourceQuota`, `LimitRange`, or baseline network policies.
- Protect baseline objects through admission policy or GitOps-controlled manifests; Kubernetes recommends restricting update/delete access to quotas to preserve enforcement. [kubernetes](https://kubernetes.recipes/recipes/configuration/namespace-management/)
