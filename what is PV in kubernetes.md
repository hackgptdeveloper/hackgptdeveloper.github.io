<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# what is PV in kubernetes

A PV (PersistentVolume) in Kubernetes is a cluster‑level object that represents a real piece of storage (disk, NFS, cloud volume, etc.) that the cluster can mount into Pods, with its own lifecycle independent of any Pod.[^1]

## Core idea

- A PV is “provisioned storage” in the cluster, similar to how a Node is “provisioned compute.”[^1]
- It abstracts the underlying storage implementation (EBS, GCE PD, NFS, iSCSI, CSI driver, etc.) so workloads just see “a volume” rather than provider‑specific details.[^2][^1]


## Relationship to PVC

- A PersistentVolumeClaim (PVC) is a request for storage from a Pod (size, access modes, StorageClass), while the PV is the actual volume that satisfies that request.[^3][^1][^4]
- The control plane watches for PVCs and binds each one to a matching PV (either pre‑created or dynamically provisioned via a StorageClass).[^1][^5][^6]


## Lifecycle and behavior

- PVs can be created statically by an admin, or dynamically when a PVC uses a StorageClass that supports provisioning.[^1][^6][^7]
- Once bound to a PVC, a PV is “owned” by that claim until released; its lifecycle outlives any single Pod that mounts it, which is what makes data persistent across Pod reschedules.[^6][^2][^1]
- A reclaim policy (Retain, Delete, Recycle – though Recycle is deprecated) controls what happens to the underlying storage when the claim is deleted.[^2][^1]


## Why it matters

- PVs are the foundation for stateful workloads on Kubernetes (databases, queues, file stores), allowing Pods to be ephemeral while data persists.[^1][^2]
- They enable decoupling: app teams work with PVCs, while platform teams manage PV/StorageClass characteristics (performance tiers, backup integration, encryption, etc.).[^3][^4][^1]

Do you want a short YAML example next (PV+PVC for, say, an RWO SSD volume on a cloud provider), or are you more interested in the scheduling/binding semantics for multi‑tenant clusters?
<span style="display:none">[^10][^8][^9]</span>

<div align="center">⁂</div>

[^1]: https://kubernetes.io/docs/concepts/storage/persistent-volumes/

[^2]: https://www.geeksforgeeks.org/devops/kubernetes-volumes/

[^3]: https://www.baeldung.com/ops/kubernetes-pv-vs-pvc

[^4]: https://www.kubermatic.com/blog/keeping-the-state-of-apps-4-persistentvolumes-and-persistentvolum/

[^5]: https://portworx.com/tutorial-kubernetes-persistent-volumes/

[^6]: https://kubernetes.io/ja/docs/concepts/storage/persistent-volumes/

[^7]: https://medium.com/google-cloud/kubernetes-storage-overview-of-pv-and-pvc-fe47d5a8a625

[^8]: https://medium.com/cloudnloud/pv-and-pvc-explained-kubernetes-2cde1feb4a05

[^9]: https://stackoverflow.com/questions/48956049/what-is-the-difference-between-persistent-volume-pv-and-persistent-volume-clai

[^10]: https://kubernetes.io/ko/docs/concepts/storage/persistent-volumes/

