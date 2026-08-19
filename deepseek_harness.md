
DeepSeek Harness is a modular agent runtime—models, tools, skills, storage, sandboxes, control loops, scheduling, and UI can be composed as plugins. So there are far more than 100 plausible things to build or automate with it; it is currently a developer preview. [deepseek](https://deepseek.com/harness/en/)

## Coding and repositories

1. Scaffold a new TypeScript service.
2. Generate a Python CLI application.
3. Implement a REST API from a specification.
4. Build a GraphQL API and resolver layer.
5. Create a gRPC service with protobuf definitions.
6. Add authentication to an existing application.
7. Add OAuth2/OIDC login flows.
8. Implement role-based access control.
9. Generate database migrations.
10. Refactor a monolith into modules.
11. Upgrade framework and dependency versions.
12. Identify and remove dead code.
13. Convert JavaScript modules to TypeScript.
14. Port a library from Python to Go.
15. Write unit-test suites for uncovered code.
16. Build integration tests with containers.
17. Diagnose and repair a failing CI job.
18. Review a pull request for correctness and regressions.
19. Produce release notes from commits and merged PRs.
20. Maintain a changelog automatically.

## Infrastructure and operations

21. Create Terraform modules for AWS, GCP, or Azure.
22. Generate a multi-cloud provisioning abstraction.
23. Audit Terraform plans for destructive changes.
24. Build Kubernetes manifests for an application.
25. Create Helm charts and values files.
26. Diagnose a Kubernetes pod crash loop.
27. Investigate failed deployments.
28. Generate Dockerfiles optimized for build caching.
29. Slim a container image and remove unnecessary packages.
30. Create Docker Compose environments for local development.
31. Automate secrets rotation workflows.
32. Review IAM policies for excessive privilege.
33. Generate cloud-network topology documentation.
34. Configure observability: logs, metrics, and traces.
35. Create alert rules from service-level objectives.
36. Investigate an incident from logs and metrics.
37. Draft an incident timeline and postmortem.
38. Automate backup validation.
39. Estimate cloud-cost drivers from billing exports.
40. Identify idle, oversized, or orphaned cloud resources.

## Security engineering

41. Perform static analysis of a repository.
42. Triage dependency vulnerabilities.
43. Generate an SBOM for a software release.
44. Scan source code for exposed credentials.
45. Review an authentication implementation.
46. Audit authorization paths for IDOR risks.
47. Map an application’s attack surface.
48. Threat-model a new API or service.
49. Build a secure code-review checklist.
50. Write fuzzing harnesses for parsers.
51. Create property-based tests.
52. Analyze a crash trace and minimize a reproducer.
53. Review C/C++ code for memory-safety flaws.
54. Audit unsafe deserialization paths.
55. Inspect web applications for common client-side security issues.
56. Build a security regression-test suite.
57. Correlate security logs for suspicious activity.
58. Generate detection rules for known indicators.
59. Help write a coordinated vulnerability-disclosure report.
60. Produce remediation guidance for a security finding.

## Research and data workflows

61. Search a codebase for how a feature is implemented.
62. Create architectural documentation from source.
63. Extract API endpoints, models, and dependencies.
64. Build a repository knowledge base.
65. Summarize long technical documents.
66. Compare implementations across branches or repositories.
67. Turn design notes into an engineering plan.
68. Convert a paper’s algorithm into reference code.
69. Implement numerical experiments.
70. Analyze benchmark outputs.
71. Clean and transform CSV or JSON datasets.
72. Generate SQL queries from a schema.
73. Profile an inefficient data pipeline.
74. Build a reproducible experiment runner.
75. Generate Jupyter notebooks for analysis.
76. Validate data quality and schema constraints.
77. Detect anomalies in time-series operational data.
78. Produce tables and plots for a technical report.
79. Trace the provenance of a derived dataset.
80. Convert research prototypes into maintainable packages.

## Agentic workflows and integrations

81. Build a custom tool plugin around an internal API.
82. Build a GitHub issue triage agent.
83. Route bug reports by component and severity.
84. Turn issue discussions into implementation plans.
85. Draft pull-request descriptions from diffs.
86. Create a code-review subagent specialized in security.
87. Create a subagent specialized in test generation.
88. Create a subagent specialized in documentation.
89. Delegate tasks to external coding agents as subagents.
90. Add human approval checkpoints before sensitive actions.
91. Run a scheduled repository-health audit.
92. Run a nightly dependency-update review.
93. Build a persistent task queue for long-running jobs.
94. Save and resume agent sessions.
95. Create workspace-specific instruction plugins.
96. Add sandboxed execution for untrusted code.
97. Set granular read/write/command permissions.
98. Build a local web interface for an internal agent.
99. Create a CLI workflow for repetitive engineering tasks.
100. Compose different models, tools, skills, sandboxes, and loops into a purpose-built autonomous engineering system.

## Practical framing

The key distinction is that Harness is not limited to “ask a model to write code.” Its plugin-first architecture is intended for building tailored agent systems, including custom tools, persistent sessions, sandboxed execution, scheduling, and orchestration. The official quick start is `npx @deepseek-ai/dsh web`; the default local Web UI is served at `http://127.0.0.1:3080`. [github](https://github.com/deepseek-ai/deepseek-harness)
