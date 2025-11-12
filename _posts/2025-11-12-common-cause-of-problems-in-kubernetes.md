---
title: "Common Kubernetes LoadBalancer problems and it causes"
tags:
  - kubernetes
  - loadbalancer
---

Here’s a detailed breakdown of the **common root causes** behind Kubernetes LoadBalancer problems — organized by **layer of the system**, from infrastructure to application. Each category maps back to the issues from the previous list.

---

## 🏗️ 1. **Infrastructure & Cloud Provider Causes**

| Cause                                | Explanation                                                                                                                                 |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **Cloud API limits**                 | Each provider (AWS, GCP, Azure) enforces quotas for active load balancers or public IPs. Hitting limits leaves services in `Pending` state. |
| **IAM permission gaps**              | The Kubernetes Cloud Controller Manager (CCM) can’t call APIs like `CreateLoadBalancer`, causing silent or retry-loop failures.             |
| **Incorrect cloud tags**             | Nodes missing `kubernetes.io/cluster/<name>=owned` tag → CCM fails to attach backends.                                                      |
| **Regional vs zonal LB mismatch**    | Nodes deployed in different zones than the LB region prevent registration.                                                                  |
| **Unmanaged network routes**         | Provider VPC routing tables not updated for the service subnet.                                                                             |
| **Cloud controller crashes**         | Outdated or mismatched `cloud-controller-manager` images lead to reconciliation bugs.                                                       |
| **Security group misconfigurations** | Missing inbound rules for NodePorts, blocking health checks or client connections.                                                          |

---

## 🌐 2. **Network Stack & CNI-Level Causes**

| Cause                            | Explanation                                                                                      |
| -------------------------------- | ------------------------------------------------------------------------------------------------ |
| **Overlay/underlay mismatch**    | VXLAN or Calico encapsulation conflicts with external routes; packets drop at the host boundary. |
| **MTU inconsistencies**          | Large packets fragmented or dropped across overlay networks.                                     |
| **ARP/NDP suppression**          | MetalLB can’t announce VIPs because kernel ARP settings block them.                              |
| **conntrack saturation**         | Stateful connections overflow Linux conntrack tables → random drops and “stuck” TCP sessions.    |
| **Reverse path filtering**       | Kernel `rp_filter=1` drops return traffic that appears asymmetric.                               |
| **BGP session flapping**         | In MetalLB, unstable BGP peer state due to router misconfig or missing keepalives.               |
| **No masquerade for pod egress** | External LBs can’t reach pod IPs directly when masquerading disabled.                            |
| **Unreachable node IPs**         | Nodes behind NAT or private subnets cannot receive LB health checks.                             |

---

## ⚙️ 3. **Service & kube-proxy Causes**

| Cause                                       | Explanation                                                                          |
| ------------------------------------------- | ------------------------------------------------------------------------------------ |
| **kube-proxy mode mismatch**                | IPVS, iptables, or userspace modes behave differently; inconsistent conntrack rules. |
| **Stale iptables rules**                    | kube-proxy crashed or desynced from API state → packets misrouted.                   |
| **ExternalTrafficPolicy misused**           | `Local` skips SNAT but drops traffic if no pod on that node → partial reachability.  |
| **NodePort range firewall blocked**         | External firewalls not opened for 30000–32767.                                       |
| **Service CIDR overlap**                    | Overlapping with cluster or VPC CIDR → routing ambiguity.                            |
| **Multiple services sharing same selector** | LBs front unintended pods due to selector collision.                                 |

---

## 🧱 4. **Configuration & Annotation Causes**

| Cause                                   | Explanation                                                                                                        |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| **Missing annotations**                 | Cloud-specific options (`service.beta.kubernetes.io/aws-load-balancer-type`) required for correct LB provisioning. |
| **Wrong health check port/path**        | LB fails health probes, marking backends unhealthy.                                                                |
| **Invalid SSL cert references**         | Ingress or LB configured with missing `Secret` → SSL handshake errors.                                             |
| **Session affinity misused**            | Sticky sessions overloading a single node.                                                                         |
| **Typo in `loadBalancerClass`**         | Cluster ignores Service spec, falls back to default controller.                                                    |
| **Default backend missing**             | Ingress with unmatched host/path sends traffic nowhere.                                                            |
| **Improper `loadBalancerSourceRanges`** | Restrictive IP filters block clients unexpectedly.                                                                 |
| **Incorrect subnet pool**               | Assigned static IP not available in the network.                                                                   |

---

## 🧩 5. **Ingress & Application Layer Causes**

| Cause                              | Explanation                                                       |
| ---------------------------------- | ----------------------------------------------------------------- |
| **IngressClass not defined**       | Controller doesn’t reconcile objects without class label.         |
| **Path rewrite misrules**          | Traefik/NGINX rewriting causes wrong upstream URLs.               |
| **TLS secret rotation**            | cert-manager updates secret but ingress controller not reloaded.  |
| **Redirect loops (HTTP↔HTTPS)**    | Both app and ingress enforcing redirection.                       |
| **Hostname mismatch**              | Client requests `www.app.com`, but cert CN=app.com → TLS failure. |
| **Backend readiness issues**       | Liveness/readiness probes fail before pod is healthy.             |
| **Timeout configuration mismatch** | App idle timeout < LB keep-alive timeout → premature disconnects. |
| **Ingress sync delay**             | Controller’s sync interval too long; stale config in NGINX pods.  |

---

## 🧠 6. **Operational & Maintenance Causes**

| Cause                                   | Explanation                                                                                    |
| --------------------------------------- | ---------------------------------------------------------------------------------------------- |
| **Version drift**                       | Kubelet, kube-proxy, and CCM running mismatched versions.                                      |
| **Stale endpoints**                     | Pods deleted, but endpoint objects not updated → blackhole traffic.                            |
| **Resource pressure**                   | Nodes OOM-killing kube-proxy or metallb-speaker pods.                                          |
| **Misleading “Pending” state**          | CCM waiting on async API callback but users interpret it as crash.                             |
| **CrashLoopBackOff in controller pods** | Missing RBAC roles to patch Service status.                                                    |
| **Improper node taints**                | LB avoids nodes labeled “NoSchedule” or “NoExecute”.                                           |
| **DNS propagation delays**              | External IP allocated but DNS record still stale.                                              |
| **Static IP reuse conflicts**           | Multiple LBs trying to claim same external IP.                                                 |
| **Metrics ignored**                     | No Prometheus alerting on `kube_service_created_seconds`, leading to unnoticed slow creations. |
| **Load test misconfiguration**          | Synthetic clients reuse connections, hiding LB routing bugs.                                   |

---

## 🧰 7. **Root Software Causes (Source-Level)**

These issues stem from how Kubernetes components internally reconcile and manage services:

| Component                                                             | Source Code Responsibility                                                                          |
| --------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| **`pkg/controller/service/service_controller.go`**                    | Cloud load balancer reconciliation logic; errors here often show as “pending” services.             |
| **`pkg/proxy/ipvs/proxier.go` & `iptables/proxier.go`**               | Handles kube-proxy rule sync; bugs or latency here break traffic paths.                             |
| **`pkg/cloudprovider/providers/*`**                                   | Provider-specific code paths (AWS, Azure, GCP) managing LB creation/deletion.                       |
| **`pkg/apis/core/v1/types.go`**                                       | Defines `ServiceTypeLoadBalancer` behavior; certain defaults cause unexpected changes when omitted. |
| **`pkg/controller/endpointslice`**                                    | Endpoints not updating → traffic to terminated pods.                                                |
| **MetalLB** (`internal/speaker/arp.go`, `internal/bgp_controller.go`) | ARP/NDP or BGP advertisement bugs cause “flapping IPs.”                                             |

---

## ⚡ 8. **Human & Process Causes**

| Cause                                         | Explanation                                                          |
| --------------------------------------------- | -------------------------------------------------------------------- |
| **No understanding of cloud controller flow** | Teams skip studying how CCM provisions cloud LBs → blame kube-proxy. |
| **No resource cleanup**                       | Deleted namespaces leave orphan LBs consuming IPs.                   |
| **Unclear team boundaries**                   | NetOps vs DevOps → firewall rules never updated.                     |
| **Manual edits to cloud infra**               | External modifications to LB rules fight with CCM reconciliation.    |
| **Ignoring warning events**                   | `kubectl describe svc` emits useful clues often overlooked.          |
| **No observability**                          | Missing metrics for LB provision latency or failure rates.           |
| **Skipping provider documentation**           | AWS ALB vs NLB vs ELB differences misapplied.                        |
| **Testing only with localhost clients**       | Never testing from external internet path.                           |
| **Improper CI/CD teardown**                   | Automated tests leave residual load balancers.                       |
| **No version pinning**                        | Helm or CCM upgrades break annotation compatibility.                 |

---

### 🔍 Summary of Common Root Themes

1. **Network misalignment** between cluster overlay and underlay (CNI, routes, NAT).
2. **Cloud controller integration** issues (permissions, API limits, tags).
3. **Configuration drift** in service annotations or ingress manifests.
4. **Health check failures** due to port/path mismatch or readiness delay.
5. **Operational neglect** — ignoring events, metrics, and cleanup.
6. **Lack of end-to-end visibility** — no tracing from LB → node → pod.

---
