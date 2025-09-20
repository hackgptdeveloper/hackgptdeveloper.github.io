---
title:  "100 different types of debugging issues in n8n.io"
tags:
  - debugging
  - n8n.io
---

1. Git push credentials failing after version 1.111.0 update  
2. Executions not displaying when using sub-agents in workflows  
3. AI Agent HTTP Request tool causing workflow execution to hang indefinitely  
4. Errors during workflow import leading to uneditable nodes  
5. Performance degradation in versions 1.105.x and 1.106.0  
6. Inability to create new node projects due to n8n/node breakage  
7. Drastic slowdown in large workflow executions post-1.105.2 update (60s vs. 0.3s)  
8. High failure rate (97%) of workflows in production environments  
9. Significant performance impact during workflow development in 1.105+  
10. Code nodes ceasing to function across all workflows  
11. Complex workflows becoming unresponsive after major upgrades (e.g., 0.198 to 1.84)  
12. Build errors when compiling n8n from source code  
13. Merge node failing to wait for both inputs to arrive properly  
14. Expression syntax breaking after updates ($(...) vs. $node[...])  
15. Executions screen failing to load, especially for successful runs  
16. Nodes reverting or workflow parts deleting after saving  
17. Workflows triggered by other workflows showing as "Queued" indefinitely  
18. Variables (e.g., memory, tools) not accessible inside AI Agent tools  
19. RSS Read node returning 406 errors for specific feeds  
20. Random expression evaluation errors like "a.ok(to)" falsy value  
21. Webhook test URLs returning 404 despite correct setup and timing  
22. GitHub "List" operation failing while other operations succeed  
23. Beginners building workflows that break in production due to API variations  
24. Workflow executions failing due to third-party service errors without proper handling  
25. Workflows canceling mid-execution without errors or visible data loss  
26. Workflows marked as failed despite all nodes completing successfully  
27. Automatic reversion to older workflow versions without user input  
28. Workflows stopping response entirely, even simple webhook-HTTP chains  
29. Workflow activation toggle not reflecting active status correctly  
30. Input data not received correctly when workflows are triggered via AI Agent tools  
31. Issues loading text/title fields from documents in custom note service nodes  
32. Inability to install community nodes after updates  
33. Common syntax or runtime errors in Code nodes  
34. Challenges in testing and debugging custom nodes during development  
35. Custom nodes not displaying properly in the community nodes list  
36. Build failures in n8n-node-dev when including custom classes or files  
37. Outdated documentation for running custom nodes locally  
38. PNPM compatibility issues in node creation and setup  
39. Worker containers failing to load newly installed community nodes  
40. Toggle to disable community nodes not preventing crashes on startup  
41. Bug in custom node text fields showing weird behavior post-update  
42. HTTP Request node unable to access internal webhooks in version 1.24.1  
43. Difficulty selecting specific triggers to run in multi-trigger workflows  
44. New versions forcing use of first() in expressions, breaking legacy logic  
45. Performance bottlenecks when handling large data volumes (e.g., 12,000+ items)  
46. SSH credentials failing to parse encrypted private keys without passphrase  
47. Nodes bugged with missing inputs (e.g., Merge or Agent nodes)  
48. Version mismatches causing node inputs to disappear in UI  
49. AI-generated nodes failing due to incompatible structures  
50. Web scraping automations breaking on dynamic site changes  
51. Third-party API integrations failing due to schema updates  
52. Custom node development stalling on authentication flows  
53. Workflow design errors in complex branching logic  
54. Self-hosting setup issues with Docker configurations  
55. Migration problems from Zapier or Make to n8n  
56. Bug fixing delays in production troubleshooting  
57. Timezone mismatches in schedule triggers  
58. Email node failures when attaching binary data  
59. Database query timeouts in SQL nodes  
60. API rate limiting not handled gracefully in loops  
61. JSON parsing errors from malformed API responses  
62. Binary file handling issues in upload/download nodes  
63. IF node conditions evaluating incorrectly on edge cases  
64. Switch node misrouting items based on dynamic data  
65. Aggregate node losing items during summarization  
66. Split In Batches node skipping items unexpectedly  
67. Error workflows not triggering on node failures  
68. Manual triggers not passing full data payloads  
69. Set node accidentally overwriting nested fields  
70. Deprecated Function node compatibility issues  
71. HTTP node proxy settings ignored in certain environments  
72. OAuth2 token refresh failures mid-workflow  
73. Webhook response delays causing timeouts  
74. Execution timeout configurations being overridden  
75. Queue mode desynchronization between main and workers  
76. Multi-main instance conflicts in credential sharing  
77. Docker volume mounts failing for custom node directories  
78. Environment variables not injecting into node parameters  
79. Log levels not updating in real-time during debugging  
80. Workflow backups corrupting during export  
81. Template imports failing due to parameter mismatches  
82. Credential permissions not propagating across workflows  
83. Git integration bugs in workflow version control  
84. AI chain executions leaking memory over iterations  
85. Vector store connections dropping in persistent agents  
86. LangChain component incompatibilities with n8n updates  
87. Custom script nodes lacking execution permissions  
88. Resource cleanup failures after aborted executions  
89. Scalability issues under high concurrent loads  
90. Stack traces not visible in debugging tools  
91. Credential encryption breaking on instance restarts  
92. Node parameter validation errors on UI save  
93. Workflow pinning failing for active productions  
94. Sub-workflow calls not inheriting parent variables  
95. Cron trigger offsets miscalculating daylight savings  
96. File conversion nodes corrupting media types  
97. Pagination handling bugs in API list operations  
98. Retry logic not respecting exponential backoff  
99. Session management issues in stateful nodes  
100. UI canvas lagging during complex workflow edits


