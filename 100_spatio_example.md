
Spatiotemporal composability is a way to design dynamic systems so components remain correct across both **time** and **structure**: every change a component makes has a clean inverse (temporal), and every dependency is declared and reactively handled when providers appear, disappear, or change (spatial). In short: *install safely, adapt to dependency changes, and remove without residue.* [github](https://github.com/cordiverse/paper)

## Reading the examples

Each example uses this compact pattern:

- **Temporal:** What must be undone when the component is removed, rolled back, or replaced?
- **Spatial:** What dependencies or relationships must react if the environment changes?
- **Problem-solving payoff:** How this framing avoids a specific failure mode.

## Application and platform examples

1. **HTTP route plugin** — Temporal: unregister `/reports`; Spatial: activate only when auth and report services exist; Payoff: hot-disable reporting without dead routes.

2. **Middleware module** — Temporal: remove its middleware from the ordered chain; Spatial: recompose when upstream identity or rate-limit middleware changes; Payoff: prevents stale ordering and duplicate execution.

3. **Feature flag rollout** — Temporal: remove flag-created jobs, routes, and cache keys; Spatial: respond to flag service/config changes; Payoff: safe rollout and rollback without restart.

4. **A/B testing component** — Temporal: unregister experiment assignment and metrics hooks; Spatial: require an experiment registry and analytics sink; Payoff: avoids logging to a removed experiment.

5. **Authentication provider** — Temporal: deregister login routes, token validators, and session hooks; Spatial: react to an identity-provider replacement; Payoff: permits SSO migration while services stay online.

6. **Authorization policy plugin** — Temporal: withdraw policy rules and cache entries; Spatial: react to changes in role, tenant, and policy-data providers; Payoff: prevents revoked policies remaining effective.

7. **Audit logger** — Temporal: detach listeners and flush/close log handles; Spatial: deactivate or reroute if the audit sink changes; Payoff: no orphan event listeners or writes to a dead collector.

8. **Payment gateway adapter** — Temporal: remove webhook handlers and close client pools; Spatial: bind to the currently selected gateway and secrets provider; Payoff: supports gateway failover without mixed credentials.

9. **Email delivery provider** — Temporal: cancel provider-specific retry jobs and unregister templates; Spatial: react when SMTP/API credentials rotate; Payoff: avoids retries through retired infrastructure.

10. **Notification channel** — Temporal: unregister Slack, SMS, or push delivery handlers; Spatial: depend on a valid tenant configuration and credential source; Payoff: channel removal does not break all notification dispatch.

11. **Search backend adapter** — Temporal: remove index hooks and close clients; Spatial: switch reactively from Elasticsearch to OpenSearch or a fallback; Payoff: search consumers avoid stale client references.

12. **Cache backend plugin** — Temporal: unregister cache interceptors and drain connections; Spatial: rebind when Redis changes endpoint or ownership; Payoff: avoids writes to a decommissioned cluster.

13. **Database migration worker** — Temporal: stop worker loops and release locks; Spatial: require the current schema version and database leadership; Payoff: prevents a detached worker from mutating the wrong schema.

14. **Background job scheduler** — Temporal: cancel scheduled timers and queued job registrations; Spatial: depend on a scheduler store and leader-election provider; Payoff: prevents duplicate recurring jobs.

15. **File-upload provider** — Temporal: remove upload endpoints and temporary-file collectors; Spatial: react to object-store or malware-scanner availability; Payoff: no uploads are accepted when validation cannot run.

16. **CDN integration** — Temporal: withdraw invalidation hooks and edge rules; Spatial: update when DNS or origin configuration changes; Payoff: avoids invalidating an obsolete distribution.

17. **Rate-limiting module** — Temporal: remove request hooks and clean its counters; Spatial: require a shared store and tenant policy provider; Payoff: turns off cleanly rather than leaving partial enforcement.

18. **GraphQL resolver package** — Temporal: unregister resolvers, directives, and subscriptions; Spatial: activate only with required domain services; Payoff: schema remains internally consistent during plugin changes.

19. **WebSocket feature** — Temporal: close feature-owned subscriptions and unregister message types; Spatial: respond to broker or authorization-service changes; Payoff: prevents zombie subscriptions after a feature unload.

20. **CLI command extension** — Temporal: remove command names, flags, completions, and handlers; Spatial: require relevant services only when invoked; Payoff: dynamic extensions do not leave broken commands in help output.

## Cloud and distributed systems

21. **Kubernetes operator** — Temporal: remove watches, finalizers it owns, and reconciliation workers; Spatial: react to CRD, API-server, or credential changes; Payoff: safe operator upgrades without duplicate controllers.

22. **Admission webhook** — Temporal: withdraw webhook configuration and certificate renewal jobs; Spatial: depend on a reachable service and CA bundle; Payoff: prevents an unavailable webhook from blocking deployments.

23. **Service-mesh policy** — Temporal: remove routing, retry, and mTLS rules it installed; Spatial: recompute when services or identity issuers change; Payoff: avoids traffic being routed to deleted workloads.

24. **Autoscaling controller** — Temporal: stop metric watches and control loops; Spatial: depend on metrics APIs and target workloads; Payoff: prevents a removed scaler from continuing to change replica counts.

25. **Terraform provider extension** — Temporal: release SDK sessions and remove registered resource types; Spatial: react to credential/configuration provider changes; Payoff: supports multi-cloud provider hot replacement in a control plane.

26. **Infrastructure drift detector** — Temporal: cancel scans and delete only its temporary snapshots; Spatial: follow current resource inventory and account bindings; Payoff: avoids reporting drift against accounts no longer managed.

27. **Cloud cost collector** — Temporal: detach billing-polling jobs and revoke temporary access; Spatial: update for account, currency, tag, and pricing-source changes; Payoff: no costs are attributed to retired accounts.

28. **DNS failover controller** — Temporal: remove health checks and scheduled records it owns; Spatial: depend on active health providers and routing zones; Payoff: clean transfer of control during failover-controller replacement.

29. **Secrets rotation worker** — Temporal: stop timers and revoke in-flight leases appropriately; Spatial: react to changes in Vault paths, KMS keys, and consuming services; Payoff: prevents rotations using stale key material.

30. **Certificate manager** — Temporal: remove renewal schedules and challenge responders; Spatial: require DNS/API credentials and a certificate store; Payoff: avoids renewal failures after provider migration.

31. **Leader-election participant** — Temporal: relinquish lease and cancel leadership-only work; Spatial: depend on quorum storage and cluster membership; Payoff: reduces split-brain risk during node or backend replacement.

32. **Consensus protocol feature** — Temporal: stop protocol rounds, remove handlers, and discard local transient state; Spatial: adapt to membership and transport changes; Payoff: prevents obsolete participants from influencing decisions.

33. **Replica placement policy** — Temporal: withdraw placement constraints it installed; Spatial: react to node capacity, failure domains, and storage-tier changes; Payoff: placement remains valid under topology churn.

34. **Data replication connector** — Temporal: checkpoint, stop streams, and release replication slots; Spatial: react to source, target, schema, and credential changes; Payoff: prevents abandoned replication slots and stale writes.

35. **Stream-processing operator** — Temporal: close state stores, unregister topics, and commit/abort work; Spatial: require brokers, schemas, and checkpoints; Payoff: allows safe replacement of a pipeline stage.

36. **Message-broker bridge** — Temporal: remove consumers/producers and revoke subscriptions; Spatial: rewire when either broker endpoint changes; Payoff: avoids duplicate forwarding loops.

37. **Observability collector** — Temporal: unregister probes and close export pipelines; Spatial: react to endpoint, tenant, and sampling-policy changes; Payoff: telemetry follows the active backend.

38. **SLO evaluator** — Temporal: stop alert timers and deregister generated alerts; Spatial: depend on current metric sources and service ownership; Payoff: avoids alerts from deleted services.

39. **Incident automation bot** — Temporal: remove temporary mitigations and escalation hooks; Spatial: react to pager, runbook, and service-catalog changes; Payoff: automation stays tied to the correct operational context.

40. **Edge-compute deployment** — Temporal: undeploy edge functions and clean routing bindings; Spatial: react to regional capacity, secrets, and origin availability; Payoff: supports moving a feature between edge regions safely.

## Security examples

41. **Endpoint detection rule** — Temporal: unregister rules and stop its event stream; Spatial: require the active telemetry schema and collector; Payoff: avoids rules silently parsing obsolete fields.

42. **SIEM enrichment plugin** — Temporal: detach enrichment processors and clean caches; Spatial: respond to threat-intelligence feed availability; Payoff: prevents stale or missing enrichments being treated as authoritative.

43. **Threat-intelligence feed** — Temporal: remove indicators it contributed and cancel update jobs; Spatial: react to confidence policy and feed-provider changes; Payoff: a retired feed cannot keep blocking domains.

44. **Firewall policy module** — Temporal: delete only rules it installed; Spatial: adapt to network inventory, identity groups, and active interfaces; Payoff: avoids overly broad cleanup that deletes another module’s rules.

45. **Zero-trust access connector** — Temporal: withdraw proxy routes and session validators; Spatial: bind reactively to an identity provider and device-posture service; Payoff: access behavior remains correct across IdP migration.

46. **OAuth client integration** — Temporal: remove callback handlers and revoke local token cache state; Spatial: react to issuer/JWKS/config changes; Payoff: prevents token validation against outdated keys.

47. **Credential scanner** — Temporal: remove repository hooks and scheduled scans; Spatial: use the current SCM source and policy engine; Payoff: scanner removal leaves no unwanted CI hooks behind.

48. **Sandboxed malware-analysis plugin** — Temporal: destroy VMs, namespaces, and packet captures; Spatial: require an isolated runtime and artifact store; Payoff: prevents leaked analysis environments.

49. **Browser instrumentation extension** — Temporal: remove hooks, tracing probes, and patched functions; Spatial: attach only to compatible browser versions and targets; Payoff: avoids persisting intrusive instrumentation after analysis ends.

50. **Fuzzing campaign** — Temporal: terminate workers, delete ephemeral corpora, and restore target settings; Spatial: react to target build, coverage collector, and crash store changes; Payoff: experiments remain reproducible and isolated.

51. **Vulnerability mitigation rule** — Temporal: roll back a temporary filter or configuration hardening; Spatial: depend on vulnerability status and asset inventory; Payoff: mitigation disappears automatically when no longer applicable.

52. **Network deception service** — Temporal: tear down honeypot listeners and fake identities; Spatial: adapt to network segment and monitoring changes; Payoff: prevents decoy infrastructure from leaking into production routing.

53. **Data-loss-prevention policy** — Temporal: unregister content-inspection hooks and delete only policy-owned quarantine state; Spatial: react to data classification and channel configuration; Payoff: policy updates do not strand documents.

54. **Privileged-access session recorder** — Temporal: close recording channels and revoke short-lived session hooks; Spatial: depend on PAM, storage, and retention-policy services; Payoff: avoids recording gaps during backend changes.

55. **Key-management provider** — Temporal: close key handles and remove cryptographic service registrations; Spatial: react to HSM/KMS availability and key-version changes; Payoff: cryptographic clients never unknowingly use retired keys.

56. **Supply-chain verification step** — Temporal: remove CI gates and attestation hooks it owns; Spatial: require active registries, trust roots, and build metadata; Payoff: avoids validating against obsolete provenance policy.

57. **Runtime policy agent** — Temporal: revoke eBPF probes, hooks, and policy maps it installed; Spatial: rebind to workload identity and kernel capabilities; Payoff: reduces both leaked kernel state and policy mismatch.

58. **Forensic collection workflow** — Temporal: stop collectors and preserve evidence manifests; Spatial: react to endpoint availability, legal hold, and storage classification; Payoff: keeps acquisition scoped and defensible.

59. **Security exception workflow** — Temporal: remove time-bound allow rules at expiry; Spatial: require approval, asset ownership, and compensating-control data; Payoff: exceptions cannot outlive their authorization context.

60. **Incident containment action** — Temporal: undo isolation, DNS blocks, or credential restrictions when authorized; Spatial: react to case status and asset identity changes; Payoff: containment is reversible rather than permanent collateral damage.

## Data, AI, and agents

61. **ETL pipeline stage** — Temporal: stop workers and clean temporary tables; Spatial: require compatible input schema, output sink, and checkpoint store; Payoff: prevents a changed source from corrupting downstream data.

62. **Schema validator** — Temporal: unregister validation rules and derived metadata; Spatial: react to schema-registry updates; Payoff: consumers do not validate new events using old contracts.

63. **Data-quality monitor** — Temporal: cancel checks and remove only its alerts; Spatial: depend on current dataset ownership and freshness policy; Payoff: avoids alerts for retired datasets.

64. **Feature-store materializer** — Temporal: stop backfills and clean temporary feature views; Spatial: respond to feature definitions and source changes; Payoff: model serving does not consume mismatched features.

65. **Model-serving deployment** — Temporal: drain requests, remove routing, and release accelerator memory; Spatial: require a compatible model artifact, tokenizer, and policy; Payoff: enables safe canary replacement.

66. **Prompt-policy layer** — Temporal: remove policy interceptors and temporary prompt transformations; Spatial: react to model, tenant, and safety-policy changes; Payoff: avoids a removed policy still altering requests.

67. **RAG retrieval backend** — Temporal: close vector clients and unregister retrieval hooks; Spatial: adapt to embedding model, index, and document-policy changes; Payoff: stops query embeddings from being sent to incompatible indexes.

68. **Document ingestion connector** — Temporal: stop watches and release cursors; Spatial: react to source permissions and document-schema changes; Payoff: avoids ingestion duplicates after source replacement.

69. **Embedding-model upgrade** — Temporal: remove temporary dual-write and backfill tasks after rollback; Spatial: depend on compatible vector schema and serving model; Payoff: preserves consistency while migrating embedding spaces.

70. **Agent tool plugin** — Temporal: unregister tools, callbacks, and credentials; Spatial: activate only when its service and authorization scope exist; Payoff: an agent cannot invoke a stale tool after its provider is removed.

71. **Agent memory module** — Temporal: remove memory hooks and close stores; Spatial: react to retention policy, encryption provider, and tenant context; Payoff: prevents memory persistence after a policy revocation.

72. **Planning strategy module** — Temporal: cancel in-flight planners and unregister selection rules; Spatial: react to task type, available tools, and budget service; Payoff: lets an agent swap planners without leaked state.

73. **Self-improvement experiment** — Temporal: revert generated code, policy changes, and experimental routes; Spatial: bind to evaluation datasets, sandbox, and approval constraints; Payoff: failed improvements leave no hidden residue.

74. **Human-approval gate** — Temporal: remove pending approval listeners and timeout jobs; Spatial: depend on the active approver directory and policy service; Payoff: requests are re-evaluated if authority changes.

75. **Multi-agent delegation rule** — Temporal: revoke delegation leases and stop child-agent tasks; Spatial: react to available specialist agents and their permissions; Payoff: prevents delegating to agents that have been withdrawn.

76. **Model fallback router** — Temporal: remove temporary routing overrides and connection pools; Spatial: react to model availability, latency, and governance constraints; Payoff: failover decisions remain valid as providers change.

77. **Evaluation harness** — Temporal: destroy sandboxes and erase ephemeral test state; Spatial: require a target version, benchmark set, and score store; Payoff: evaluations cannot accidentally score the wrong build.

78. **Fine-tuning job orchestrator** — Temporal: cancel jobs, reclaim GPUs, and remove staging artifacts; Spatial: depend on approved datasets, base model, and quota; Payoff: prevents training from continuing after data consent changes.

79. **Synthetic-data generator** — Temporal: remove generated datasets and temporary access grants; Spatial: depend on privacy constraints and schema version; Payoff: derived data remains governed by its active policy.

80. **Knowledge-graph enrichment** — Temporal: retract assertions attributable to a disabled source; Spatial: react to ontology, source trust, and entity-resolution changes; Payoff: provenance-aware rollback is possible.

## Human, physical, and scientific systems

81. **Smart-building lighting policy** — Temporal: restore previous scene settings and cancel timers; Spatial: react to occupancy sensors, daylight data, and room topology; Payoff: no lights stay stuck after automation removal.

82. **HVAC optimization module** — Temporal: restore setpoint authority and remove scheduled overrides; Spatial: depend on sensor health, occupancy, and equipment availability; Payoff: avoids controlling a failed or unavailable unit.

83. **Fleet-routing optimizer** — Temporal: revoke route assignments and temporary reservations; Spatial: react to vehicle status, depot capacity, and traffic feeds; Payoff: plans recompose when a vehicle breaks down.

84. **Drone mission component** — Temporal: cancel commands, release airspace reservations, and return control to a safe mode; Spatial: depend on GPS, geofence, battery, and communications state; Payoff: mission logic deactivates safely when prerequisites fail.

85. **Robotic manipulation skill** — Temporal: release gripper force, stop trajectories, and clear reservations; Spatial: require calibration, perception, and collision-map services; Payoff: prevents executing a manipulation plan with stale geometry.

86. **Factory quality-control camera** — Temporal: unregister inspection triggers and release GPU pipelines; Spatial: react to product SKU, camera calibration, and conveyor state; Payoff: avoids classifying the wrong product with the wrong model.

87. **Traffic-signal coordination policy** — Temporal: restore baseline timing plans; Spatial: adapt to intersection connectivity and sensor availability; Payoff: a failed coordinator does not leave unsafe partial timings.

88. **Hospital alerting rule** — Temporal: remove only alerts produced by the rule and close subscriptions; Spatial: require current patient identity, device connectivity, and clinical policy; Payoff: prevents alarms from being attached to the wrong patient.

89. **Clinical decision-support module** — Temporal: remove suggestions and temporary order-set integrations; Spatial: depend on current labs, medication list, and guideline version; Payoff: recommendations track live clinical context.

90. **Emergency-response workflow** — Temporal: release resource reservations and stop notifications when a case closes; Spatial: react to responder availability, incident location, and command structure; Payoff: reduces stale dispatches.

91. **Laboratory instrument driver** — Temporal: close sessions, reset safe state, and release sample locks; Spatial: depend on instrument identity, calibration, and assay protocol; Payoff: avoids running a protocol against a reconfigured device.

92. **Scientific simulation plugin** — Temporal: cancel jobs and delete only its scratch outputs; Spatial: require compatible meshes, solvers, and boundary-condition providers; Payoff: supports swapping numerical methods without contaminated results.

93. **Digital-twin sensor feed** — Temporal: unsubscribe streams and invalidate derived transient state; Spatial: react to asset topology and sensor replacement; Payoff: twin state remains tied to the real deployed system.

94. **Research-data access policy** — Temporal: revoke temporary access grants and cached authorizations; Spatial: depend on consent, project membership, and dataset classification; Payoff: access changes immediately when consent changes.

95. **Classroom collaboration tool** — Temporal: remove room-specific handlers and temporary groups; Spatial: react to enrollment, role, and course availability; Payoff: departing students retain no active workflow permissions.

96. **Calendar scheduling assistant** — Temporal: cancel tentative holds and notification timers; Spatial: react to calendar availability, time zone, and participant changes; Payoff: avoids leaving ghost meetings after an assistant is disabled.

97. **Workflow approval engine** — Temporal: withdraw pending transitions and timers when the workflow is removed; Spatial: depend on current organization roles and policy revisions; Payoff: decisions use the authority structure in force now.

98. **E-commerce inventory reservation** — Temporal: release reservations when a checkout component fails or is removed; Spatial: react to stock, warehouse, and payment changes; Payoff: prevents inventory leakage and overselling.

99. **Subscription billing integration** — Temporal: cancel provider-specific webhooks, retries, and scheduled invoices; Spatial: bind to active tax, payment, and customer-account services; Payoff: cleanly replaces a billing provider.

100. **Disaster-recovery runbook executor** — Temporal: undo temporary routing, scaling, and access changes after recovery; Spatial: react to live region health, replication status, and leadership; Payoff: failover actions are reversible and topology-aware rather than permanent improvisations. [agentspulse.github](https://agentspulse.github.io/tutorials/cordis-spatiotemporal-composability/)
