list down all the steps for migrating from one cloud provider to another (or even from node to another node in the same provider)
[https://intl.cloud.tencent.com/techpedia/148238?lang=en](https://intl.cloud.tencent.com/techpedia/148238?lang=en)


The complete migration workflow is:

Inventory → assess compatibility → choose migration method → design the target → prepare networking and security → provision the target → back up → copy and synchronize data → deploy applications → test → rehearse → freeze writes → perform final synchronization → cut over → validate → retain rollback capability → decommission the source.

This applies both to migrations between cloud providers and to moving a workload between two VMs or nodes in the same provider. The difference is how much infrastructure, identity, networking, and storage you can reuse.

The Tencent article describes five high-level phases—provision, replicate, validate, cut over, and decommission. Below is a more complete operational checklist expanding those phases, with additional safeguards around data consistency and rollback. [intl.cloud.tencent](https://intl.cloud.tencent.com/techpedia/148238?lang=en)

## 1. Define exactly what is being migrated

1. Identify the source and destination:
   - Provider and account/project/subscription.
   - Region and availability zone.
   - VPC/network and subnet.
   - VM, physical node, Docker host, or Kubernetes node/cluster.

2. Define the migration scope:
   - Entire VM, including OS.
   - Applications and configuration only.
   - Containers and persistent volumes.
   - Databases.
   - File shares or object storage.
   - Complete application stack, including supporting managed services.

3. Identify what will remain unchanged:
   - External database.
   - DNS provider.
   - Identity provider.
   - Container registry.
   - Monitoring platform.
   - External integrations.

4. Define success criteria:
   - Acceptable downtime.
   - Recovery point objective: acceptable data loss.
   - Recovery time objective: acceptable recovery duration.
   - Performance and availability targets.
   - Security and compliance requirements.

5. Assign an owner for the migration, application validation, networking, databases, and rollback decisions.

6. Define a maintenance window, communications plan, approval process, and escalation contacts.

7. Write the initial cutover and rollback runbooks before implementing the migration.

Exit condition: Everyone agrees on what moves, what does not, how success is measured, and who can authorize cutover or rollback. AWS recommends a documented cutover plan, contingency procedures, and rehearsals before production migration. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/best-practices-migration-cutover/pre-cutover-stage.html)

## 2. Inventory the source and its dependencies

8. Inventory compute and OS requirements:
   - CPU architecture: x86-64 versus ARM.
   - CPU, RAM, GPU, and accelerators.
   - OS distribution/version and kernel.
   - Boot mode, partition layout, and disk encryption.
   - Installed packages, drivers, and licenses.

9. Inventory every running workload:
   - System services.
   - Docker containers and Compose projects.
   - Kubernetes workloads.
   - Reverse proxies.
   - Background workers.
   - Scheduled jobs, cron jobs, and systemd timers.

10. Inventory application artifacts and configuration:
    - Application versions.
    - Container image references and digests.
    - Deployment manifests.
    - Environment variables.
    - Configuration files.
    - Startup commands and service dependencies.

11. Inventory persistent state:
    - Databases and transaction logs.
    - Docker named volumes.
    - Bind-mounted directories.
    - Uploaded files.
    - Shared filesystems.
    - Object storage.
    - Message queues.
    - Session stores and caches that contain non-disposable state.

12. Map connectivity and dependencies:
    - Incoming ports and endpoints.
    - Outgoing APIs and databases.
    - Internal DNS names.
    - Service discovery.
    - Hardcoded IP addresses.
    - Webhooks, callbacks, and partner allowlists.

13. Inventory security and identity:
    - Cloud IAM roles and service identities.
    - Application credentials.
    - TLS certificates and private keys.
    - Encryption keys.
    - Secret-store access.
    - SSH and administrative access.

14. Record operational dependencies:
    - Monitoring, logging, and alerting.
    - Backup schedules and retention.
    - CI/CD pipelines.
    - Infrastructure-as-code state.
    - Resource tags, ownership, and billing attribution.

15. Capture baseline measurements:
    - Request rate and error rate.
    - p50/p95/p99 latency.
    - CPU and memory consumption.
    - Storage capacity, IOPS, throughput, and latency.
    - Database connections and transaction rate.
    - Network throughput.

Output: A dependency map and migration manifest. This expands the workload inventory and target mapping prerequisites in the Tencent guide. [intl.cloud.tencent](https://intl.cloud.tencent.com/techpedia/148238?lang=en)

## 3. Choose a migration method for each component

Do not assume every component should use the same migration mechanism.

| Component or scenario | Candidate approach | Main consideration |
|---|---|---|
| Stateless application | Redeploy the same application artifact or container image | Configuration and dependencies still need migration |
| Whole VM | Supported image/snapshot workflow or server-migration tooling | Guest OS, boot, disk, and target-platform compatibility |
| Small stateful service with downtime allowed | Stop writes, take a consistent backup, restore, restart | Restore duration determines much of the outage |
| Large database with low downtime | Initial load plus native replication or change-data capture | Final consistency and writer handover |
| Files or uploads | Initial copy plus incremental synchronization | Handle changes, deletions, permissions, and final write freeze |
| Docker persistent volumes | Consistent backup/restore or application-aware replication | Container images do not contain volume data |
| Kubernetes node in the same cluster | Prepare replacement capacity and safely drain the old node | Scheduling and persistent-storage constraints |

Tencent documents server migration tooling separately from database migration tooling; its database procedures distinguish full migration from full-plus-incremental synchronization. Docker likewise documents volumes as a separate backup and migration concern. [intl.cloud.tencent](https://intl.cloud.tencent.com/ind/document/product/1036/72276)

16. Select the method for every stateful component.

17. Decide whether to retain the current OS/runtime or change it.

18. Avoid combining migration with unrelated application, OS, database, or schema upgrades unless necessary and tested.

19. Define migration waves and dependency order:
    - Pilot a low-risk workload.
    - Establish target dependencies.
    - Migrate a tightly coupled application group together where appropriate.
    - Schedule writer handover explicitly.

20. Document expected downtime and rollback options for each component.

## 4. Design the destination environment

21. Map source resources to destination resources:
    - Compute type and architecture.
    - Storage capacity and performance.
    - Network topology.
    - Load balancers.
    - Databases.
    - Object storage.
    - Identity and key management.

22. Verify quotas, regional availability, capacity, and licensing.

23. Size the target against measured workload demand—not just matching vCPU and RAM labels.

24. Design resilience:
    - Replica count.
    - Availability-zone placement.
    - Health checks.
    - Restart and recovery behavior.

25. Design addressing and routing:
    - CIDR ranges.
    - Subnets and routes.
    - Private DNS.
    - Ingress and egress.
    - Stable service endpoints.

26. Plan how clients will discover the new destination:
    - Existing load balancer.
    - New load balancer.
    - Reverse proxy.
    - DNS record changes.
    - Service discovery changes.

27. Estimate migration and steady-state costs:
    - Source egress.
    - Temporary duplicate infrastructure.
    - Replication traffic.
    - Storage and snapshots.
    - Connectivity and tooling.

The Tencent article emphasizes instance/region mapping and network preparation; its provider-family examples should be treated as starting points for evaluation, not proof of performance equivalence. [intl.cloud.tencent](https://intl.cloud.tencent.com/techpedia/148238?lang=en)

## 5. Prepare connectivity, security, and access

28. Establish a secure transfer path:
    - Private routing where available.
    - VPN or dedicated connectivity when justified.
    - Encrypted public-network transfer where appropriate.

29. Check routing and address overlap.

30. Verify connectivity for the actual migration protocols and ports.

31. Test throughput, latency, DNS resolution, and large transfers.

32. Configure destination firewall rules, security groups, and access controls.

33. Recreate workload identities and least-privilege permissions.

34. Make required secrets available securely at the destination.

35. Verify access to encryption keys, certificate chains, and registries.

36. Update external allowlists:
    - Database access rules.
    - Partner APIs.
    - SMTP relays.
    - Corporate firewalls.
    - Webhook sources and destinations.

37. Establish administrative and emergency access.

38. Enable audit logging before production cutover.

The transfer path must be ready before replication begins. Tencent explicitly identifies network throughput as a potential bottleneck for the initial full copy. [intl.cloud.tencent](https://intl.cloud.tencent.com/techpedia/148238?lang=en)

## 6. Provision and prepare the target

39. Create destination networking, compute, storage, and supporting services.

40. Install and configure the OS, runtime, Docker, or Kubernetes components as applicable.

41. Apply security baselines and patching.

42. Configure disks and mounts:
    - Filesystem and mount options.
    - Capacity and performance.
    - Ownership and permissions.
    - Persistent mounting after reboot.

43. Install operational agents:
    - Monitoring.
    - Logging.
    - Security monitoring.
    - Backup agents where used.

44. Configure application deployment automation and registry access.

45. Create application configuration with destination-specific endpoints.

46. Keep target schedulers, workers, and write-capable processes disabled until the migration plan explicitly enables them.

47. Verify target boot, administrative access, network access, runtime readiness, and storage availability.

Exit condition: The destination is ready to receive the workload, but cannot accidentally process production writes. Target provisioning and readiness verification are the first operational phase in the Tencent workflow. [intl.cloud.tencent](https://intl.cloud.tencent.com/techpedia/148238?lang=en)

## 7. Create and verify recoverable backups

48. Take backups of:
    - Databases.
    - Persistent application files.
    - Docker volumes.
    - Deployment configuration.
    - Relevant infrastructure definitions.

49. Use application-consistent backups for stateful software.

50. Verify backup integrity and access to required decryption keys.

51. Test a restore into an isolated environment.

52. Record the backup timestamp and any associated database recovery position.

53. Measure restore duration against the recovery objective.

For Docker volumes, use a controlled backup/restore process. A raw archive of a live database volume should not be assumed to be a valid database backup; Docker’s volume-backup example stops attached containers to avoid corruption. [docs.docker](https://docs.docker.com/engine/storage/volumes/)

## 8. Perform the initial data transfer and ongoing synchronization

54. Transfer the initial dataset.

55. Preserve required file attributes:
    - Ownership and numeric UID/GID.
    - Permissions and ACLs.
    - Symlinks.
    - Extended attributes, where required.

56. Restore database backups or initialize replicas.

57. Enable incremental synchronization where the chosen method supports it.

58. Monitor:
    - Replication failures.
    - Replication lag or recovery positions.
    - Transfer throughput.
    - Target storage growth.
    - Source performance impact.

59. Verify data:
    - File counts and checksums where appropriate.
    - Database schema.
    - Row counts and application-specific consistency checks.
    - Object metadata and access rules.

60. Confirm that synchronization includes required changes and deletions.

61. Keep the source authoritative until the planned handover.

Tencent’s database migration guide explicitly separates full data loading from ongoing incremental synchronization and requires checking synchronization readiness before completion. [intl.cloud.tencent](https://intl.cloud.tencent.com/document/product/571/63302)

## 9. Deploy and validate the application on the target

62. Deploy the intended application version.

63. Connect it to the correct target dependencies.

64. Keep tests isolated from production side effects:
    - Do not send real emails, payments, or customer notifications unintentionally.
    - Do not let duplicate schedulers or workers consume production work.
    - Do not replay write requests into production systems without controls.

65. Test:
    - Startup and readiness.
    - Authentication and authorization.
    - Core read and write workflows.
    - Uploads and downloads.
    - Background processing.
    - External integrations.
    - TLS and redirects.

66. Compare functionality with the source.

67. Run representative load tests.

68. Compare latency, errors, resource usage, and storage behavior against the baseline.

69. Verify logging, dashboards, alerts, and backup operation.

70. Verify recovery after a restart or reboot.

71. Obtain technical and business acceptance.

The article recommends application-level parity checks before routing production traffic to the destination. A successful HTTP health response alone is not equivalent to functional acceptance. [intl.cloud.tencent](https://intl.cloud.tencent.com/techpedia/148238?lang=en)

## 10. Rehearse and approve the cutover

72. Run the cutover procedure in a test environment.

73. Measure:
    - Write-freeze duration.
    - Final synchronization time.
    - Application startup time.
    - Routing-change time.
    - Rollback duration.

74. Define go/no-go criteria and rollback thresholds.

75. Identify the person authorized to make the final decision.

76. Prepare exact commands or automation steps.

77. Prepare traffic-switching and connection-draining procedures.

78. If DNS is involved, lower the TTL sufficiently ahead of the maintenance window for the previous TTL to expire.

79. Confirm staffing and communications.

80. Freeze unrelated application and infrastructure changes.

81. Obtain final approval.

AWS recommends rehearsing the cutover and explicitly documenting contingencies and rollback procedures. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/best-practices-migration-cutover/pre-cutover-stage.html)

## 11. Execute the production cutover

For a stateful workload, the critical sequence is:

```text
Stop new source writes
        ↓
Drain or finish in-flight work
        ↓
Complete final synchronization
        ↓
Verify the destination is current and consistent
        ↓
Fence the old writer
        ↓
Promote or enable the destination writer
        ↓
Switch traffic
        ↓
Validate production behavior
```

82. Announce the maintenance window.

83. Pause all relevant write sources:
    - User-facing write requests.
    - Scheduled jobs.
    - Queue consumers.
    - Import pipelines.
    - External ingestion.

84. Drain in-flight transactions and requests as required.

85. Take the planned final backup or recovery checkpoint.

86. Complete final data synchronization.

87. Verify the final data position and consistency checks.

88. Stop, fence, or otherwise prevent the old application/database from accepting writes.

89. Promote or enable the destination as the authoritative writer.

90. Start destination application services and workers in the planned order.

91. Switch the load balancer, reverse proxy, DNS, or service-discovery endpoint.

92. Verify real traffic reaches the destination.

93. Run production smoke tests.

94. Re-enable paused integrations, ingestion, schedules, and workers exactly once.

95. Monitor closely and apply the agreed go/no-go thresholds.

Write freeze and final synchronization are explicit steps in AWS’s cutover guidance. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/best-practices-migration-cutover/cutover-stage.html)

### Important correction to the linked article

The article uses “replica lag < 60 seconds” as a readiness check. That is not enough by itself to establish a lossless final cutover. For a migration intended to preserve all committed writes, stop source writes and verify that all required changes have reached the destination before handing over write ownership. Also, switching DNS alone does not provide a data-safe rollback. [intl.cloud.tencent](https://intl.cloud.tencent.com/techpedia/148238?lang=en)

## 12. Stabilize and preserve rollback capability

96. Compare production metrics with the source baseline.

97. Check:
    - Error rate and latency.
    - Database consistency.
    - Queue backlogs.
    - Scheduled jobs.
    - Authentication.
    - External callbacks.
    - Backup success.
    - Security alerts.

98. Keep the old environment isolated from production writes during the agreed rollback window.

99. Decide whether to fix forward or roll back using the preapproved thresholds.

100. Handle rollback according to whether new data exists:

| Situation | Rollback requirement |
|---|---|
| Destination has not accepted new writes | Returning traffic to the unchanged source may be sufficient |
| Destination has accepted new writes | Preserve those writes through tested reverse synchronization, restore/replay, or another reconciliation process before returning |
| Data is split between environments | Establish one authoritative writer and reconcile state before reopening writes |

101. Test destination backups and restore capability.

102. Obtain application-owner and operational sign-off.

**Rollback** is a data-recovery problem once the destination accepts writes—not merely a routing change. AWS explicitly warns that the source can become stale after cutover and describes the need to restore or replicate destination changes before returning to it. [docs.aws.amazon](https://docs.aws.amazon.com/prescriptive-guidance/latest/best-practices-migration-cutover/cutover-stage.html)

## 13. Decommission and close the migration

103. Confirm that the rollback window and retention requirements have been satisfied.

104. Confirm no remaining traffic, integrations, or jobs depend on the source.

105. Archive the required backups, logs, and migration evidence.

106. Remove migration agents and temporary replication infrastructure.

107. Revoke temporary credentials and remove temporary firewall rules.

108. Remove obsolete DNS records, routes, load-balancer targets, and allowlist entries.

109. Delete or retire old compute, disks, snapshots, IP allocations, and other unused resources according to policy.

110. Update:
     - Inventory and CMDB.
     - IaC definitions and state.
     - CI/CD targets.
     - Monitoring and dashboards.
     - Ownership and billing tags.
     - Runbooks and architecture diagrams.

111. Verify source billing has stopped for resources intended to be removed.

112. Review actual costs and target sizing.

113. Record lessons learned and close the migration.

Decommissioning belongs after validation and the rollback window, not immediately after the traffic switch. This is also the final phase of the Tencent workflow. [intl.cloud.tencent](https://intl.cloud.tencent.com/techpedia/148238?lang=en)

## What changes for particular migration scenarios?

### Docker host → another Docker host

Use the same overall lifecycle, but organize the workload around four separately tracked items:

| Item | What must be reproduced or transferred |
|---|---|
| Images | Exact application image versions, ideally pinned references |
| Configuration | Compose files, runtime settings, networks, ports, and environment configuration |
| Secrets | Securely provisioned credentials and certificates |
| State | Named volumes, bind mounts, databases, uploads, and other persistent files |

Recreating a container does not recreate the contents of its persistent volumes. Docker documents volume backup and restoration into another container or host as a separate operation. [docs.docker](https://docs.docker.com/engine/storage/volumes/)

### Kubernetes node → another node in the same cluster

A same-cluster move can be much shorter:

1. Add or prepare replacement node capacity.
2. Verify node readiness and required networking/storage components.
3. Check resource capacity, scheduling constraints, and disruption budgets.
4. Verify how each workload’s persistent storage will become available on the replacement node.
5. Drain the old node using the supported procedure.
6. Verify evicted workloads are healthy on the replacement capacity.
7. Complete validation before retiring the old node.

For example:

```bash
kubectl drain OLD_NODE --ignore-daemonsets
```

Treat this as a controlled eviction operation, not a general data-copy command. Kubernetes documents that drain skips DaemonSet-managed pods when this flag is used; those pods remain on the old node until it is removed. Review any drain blockers rather than bypassing them blindly. [kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/safely-drain-node/)

### VM → another VM in the same provider

The same checklist still applies, but target networking, identity, or supporting services may already exist. First determine whether you are:

- Replacing only application compute while retaining external state.
- Moving compute and attached persistent state.
- Moving across availability zones, networks, accounts, or regions.
- Rebuilding from application artifacts rather than cloning the OS.

The governing question is not just “same provider or different provider?” It is “which state, dependencies, endpoints, and write ownership are changing?” The provision–replicate–validate–cutover–decommission lifecycle remains the same. [intl.cloud.tencent](https://intl.cloud.tencent.com/techpedia/148238?lang=en)
