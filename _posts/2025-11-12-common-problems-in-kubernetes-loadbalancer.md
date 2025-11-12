---
title: "*100 common problems in Kubernetes LoadBalancer implementations**"
tags:
  - loadbalancer
  - kubernetes
---

Here’s a comprehensive list of **100 common problems in Kubernetes LoadBalancer implementations**, organized by categories (architecture, networking, configuration, DNS, health checks, cloud provider issues, etc.) with brief technical explanations:

---

## 🧩 1. Architectural and Design-Level Issues

1. Misunderstanding Layer 4 vs. Layer 7 load balancing.
2. Using `LoadBalancer` type on bare-metal clusters without MetalLB or similar.
3. Multiple LoadBalancers per service causing excessive cloud resource usage.
4. No external IP assigned due to pending load balancer provisioning.
5. Failure to expose internal services (wrong external/internal annotation).
6. Inconsistent behavior across cloud providers (AWS vs GCP vs Azure).
7. Exceeding the limit of allowed load balancers per cloud project.
8. Misaligned CIDR ranges between cluster and external network.
9. Overlapping service CIDRs causing routing conflicts.
10. Using external load balancers without proper NAT handling.
11. Ignoring idle connection timeouts in cloud LB (common in AWS ELB).
12. Lack of HA strategy for single load balancer dependency.
13. Not accounting for failover between multiple zones.
14. LoadBalancer fronting another LoadBalancer (double LB hop).
15. Insufficient throughput capacity for expected workloads.
16. Using NodePort underneath without firewall rules for nodes.
17. Load balancer not resilient to node restarts or scaling.
18. Using wrong protocol type (`TCP` vs `UDP` vs `HTTP`).
19. Exposing control plane components accidentally.
20. Traffic not routed through kube-proxy (bypassing service rules).

---

## 🌐 2. Networking and Connectivity Problems

21. Misconfigured CNI plugin blocking external traffic.
22. LoadBalancer not accessible due to missing external routes.
23. NetworkPolicy blocking health check probes.
24. Cloud firewall rules missing for NodePort ranges (30000–32767).
25. Incorrect MTU leading to packet fragmentation/loss.
26. Node IP not reachable from LB due to NAT misconfig.
27. LoadBalancer health checks hitting wrong port or path.
28. Source IP preserved incorrectly, breaking backend logic.
29. Reverse path filtering causing dropped packets.
30. Connection tracking issues (conntrack table overflow).
31. Node local routing bypassing kube-proxy IPVS tables.
32. Multiple NICs confusing the load balancer routing.
33. BGP peering instability (in MetalLB setups).
34. ARP/NDP conflicts between MetalLB speakers.
35. VXLAN overlay interfering with external routes.
36. Routing table overflow (too many routes).
37. SNAT masking client IPs (breaking access logs).
38. Kubernetes IPVS not syncing with kernel conntrack.
39. Proxy ARP disabled on nodes (MetalLB issue).
40. Incorrect egress IP or masquerade setup.

---

## ⚙️ 3. Configuration and Annotation Errors

41. Missing cloud-specific annotations (e.g., AWS ALB ingress annotations).
42. Wrong load balancer class (`loadBalancerClass` field not set).
43. Misconfigured health check path annotation.
44. Backend protocol mismatch (`HTTP` vs `HTTPS`).
45. Missing SSL certificate reference.
46. Incorrect security group annotations.
47. Service selector not matching any pods.
48. Missing externalTrafficPolicy configuration.
49. Misusing `sessionAffinity` settings.
50. Wrong `loadBalancerIP` specified (not in pool).
51. Missing `loadBalancerSourceRanges`.
52. Disabled cross-zone load balancing by mistake.
53. Using unsupported annotations in managed clusters.
54. Forgetting to delete dangling LB when service is removed.
55. Overly aggressive `externalTrafficPolicy=Local` causing node starvation.
56. Conflicting annotations between multiple ingress controllers.
57. Cloud provider ignoring unrecognized annotation.
58. Unintentionally setting `loadBalancerSourceRanges: 0.0.0.0/0`.
59. Auto-assigned IP not in allowed subnet range.
60. Health probe ports mismatched with container ports.

---

## 🧱 4. Ingress Controller Integration Problems

61. Ingress controller using same ports as LoadBalancer.
62. Duplicate ingress rules sending traffic to wrong backend.
63. Path rewrite rules conflicting with app routes.
64. TLS secret not found by ingress controller.
65. Default backend misconfigured or missing.
66. Ingress not picking up annotations from Service.
67. Conflicts between Traefik and NGINX ingress controllers.
68. Cert-manager not updating ingress TLS cert.
69. Hostname mismatch causing SSL handshake failure.
70. Ingress controller pod crashlooping due to invalid config.
71. Load balancer health checks failing due to HTTP 301/302 redirects.
72. Misconfigured ingress class (IngressClassName not set).
73. Missing `X-Forwarded-For` header propagation.
74. HTTP → HTTPS redirection loop.
75. Wildcard hostnames not resolving properly.
76. Static IP not associated with ingress LB.
77. Overlapping host rules across namespaces.
78. Backend timeout lower than LB idle timeout.
79. Unsupported path type (`Exact` vs `Prefix` mismatch).
80. Controller RBAC not allowing status updates.

---

## ☁️ 5. Cloud Provider and Infrastructure Problems

81. Cloud provider API quota exhausted (cannot create LB).
82. Service stuck in “pending” due to missing IAM permissions.
83. Firewall rules not auto-created by cloud controller.
84. Cloud controller not running in cluster.
85. Using private subnet for LoadBalancer IPs unintentionally.
86. Cloud LB not supporting IPv6 while cluster does.
87. Static IP reservation expired or released.
88. Using custom network tags that block LB provisioning.
89. Cloud load balancer name too long for provider limit.
90. Cloud provider API latency causing update delays.
91. Regional vs. zonal LB mismatch.
92. Load balancer nodes not detected due to tag mismatch.
93. Cloud controller manager version incompatible with cluster.
94. IAM policy missing `elasticloadbalancing:*` permissions.
95. Cloud load balancer doesn’t support UDP (e.g., AWS Classic ELB).
96. Load balancer node pool scaled down automatically.
97. Backend instance registration failing silently.
98. Security group dependency cycles (common in AWS).
99. Subnet exhaustion—no available IPs for new LBs.
100. Provider rate limits hit due to frequent service updates.

---

## 🔍 Reference Source Chains

Many of these issues can be traced through:

* **Kubernetes source**:
  `pkg/cloudprovider/providers/*`
  `pkg/proxy/ipvs/`, `pkg/proxy/iptables/`, `pkg/proxy/topology.go`
* **Cloud Controller Manager logic**:
  [kubernetes/cloud-provider](https://github.com/kubernetes/cloud-provider)
  `controller/service/service_controller.go`
* **MetalLB internals**:
  [metallb/metallb](https://github.com/metallb/metallb/tree/main/internal) → `speaker/arp.go`, `bgp_controller.go`
* **Ingress controllers**:
  [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx),
  [traefik/traefik](https://github.com/traefik/traefik)

---
