DeepSeek’s DualPath paper argues that agentic LLM serving is increasingly limited by **KV-cache storage bandwidth**, not raw GPU compute, and proposes a system that uses two cache-loading routes instead of one. The core idea is to turn the idle storage bandwidth on decode engines into a second path, so KV-cache can flow storage → decode → prefill over RDMA when direct storage → prefill would bottleneck. [arxiv](https://arxiv.org/html/2602.21548v1)

## What problem it targets

The paper focuses on multi-turn, tool-using workloads where most of the context is reused across turns, so the KV-cache hit rate is very high and cache reloads dominate performance. In their traces, agentic sessions average 157 turns, around 32.7k context tokens, and only about 429 new tokens per turn, which makes the workload heavily I/O-bound. The result is that prefill engines’ storage NICs saturate while decode engines’ storage NICs sit underused. [arxiv](https://arxiv.org/html/2602.21548v1)

## How DualPath works

DualPath adds a second loading path: instead of always reading KV-cache directly into prefill engines, it can read into decode engines and then transfer the cache to prefill engines over the compute network using RDMA. The system also uses a CNIC-centric traffic manager so KV-cache traffic stays isolated from latency-sensitive model communication traffic. On top of that, a global scheduler decides which path each request should take and tries to balance load across both prefill and decode engines. [arxiv](https://arxiv.org/html/2602.21548v1)

## Why this is interesting

The paper’s systems insight is that bandwidth, queueing, and traffic balance can matter more than FLOPs in agentic inference. That is a very infrastructure-heavy framing, which fits your background: it is basically a cluster-level resource pooling problem with NIC asymmetry, QoS isolation, and online scheduling all interacting. The design is notable because it claims to improve throughput without changing the model itself or adding new hardware. [arxiv](https://arxiv.org/html/2602.21548v1)

## Reported results

The paper reports up to 1.87x offline throughput improvement and 1.96x average online serving throughput without violating SLOs. Those gains come from better utilization of the storage network and better load balancing across the cluster, rather than from model compression or kernel-level acceleration. In other words, it is an infrastructure optimization paper disguised as an AI paper. [arxiv](https://arxiv.org/html/2602.21548v1)

## Practical takeaway

If you run long-context agents, the important lesson is that the bottleneck may move from GPU math to cache movement and network contention. DualPath’s broader implication is that disaggregated serving stacks should treat storage bandwidth as a pooled cluster resource, not a per-engine bottleneck. For production systems, the most relevant questions are whether your interconnect QoS is strong enough, whether decode-side NICs are actually idle, and whether your scheduler can exploit that slack safely. [arxiv](https://arxiv.org/html/2602.21548v1)

## One-line summary

DeepSeek’s DualPath is a serving-system paper that boosts agentic LLM throughput by rerouting KV-cache loading through underused decode-node bandwidth, then controlling traffic and scheduling so the added path does not interfere with inference. [arxiv](https://arxiv.org/html/2602.21548v1)

Would you like a deeper breakdown of the architecture, the scheduler, or the bottleneck analysis math?
