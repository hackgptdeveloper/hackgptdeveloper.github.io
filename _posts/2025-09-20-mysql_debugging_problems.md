---
title: "100 debugging challenges in MySQL development"
tags:
  - MySQL
  - debugging
---

Perfect — let’s build a **comprehensive list of 100 different types of development-related problems in MySQL programming**.
I’ll group them by **categories** (schema design, indexing, queries, transactions, replication, performance, security, etc.) so it’s structured and easier to navigate.

---

# 🔹 **Schema Design Problems**

1. Using `VARCHAR(255)` everywhere without reason.
2. Storing numbers as `VARCHAR` instead of `INT/DECIMAL`.
3. No primary key in tables.
4. Overuse of composite primary keys.
5. Using `TEXT` where `VARCHAR` is sufficient.
6. Storing JSON in `TEXT` instead of `JSON` type.
7. Not normalizing repeated fields (1NF violation).
8. Over-normalization leading to too many joins.
9. Using ENUM where lookup tables are better.
10. Schema drift between dev, test, and prod databases.

---

# 🔹 **Indexing Problems**

11. Missing indexes on foreign keys.
12. Duplicate indexes created accidentally.
13. Over-indexing tables, slowing down writes.
14. Using `FULLTEXT` where `LIKE '%...%'` would suffice.
15. No composite index for multi-column WHERE clauses.
16. Wrong index order (`INDEX(a,b)` vs `INDEX(b,a)`).
17. Indexes not used due to datatype mismatch.
18. Index fragmentation over time.
19. Unused indexes wasting storage.
20. Index not covering query (forcing table lookups).

---

# 🔹 **Query Writing Problems**

21. `SELECT *` used in production queries.
22. Hard-coded values instead of parameters.
23. Queries not parameterized (SQL injection risk).
24. Cartesian product from missing join conditions.
25. Using subqueries instead of JOINs.
26. Correlated subqueries slowing performance.
27. Misuse of `DISTINCT` to “fix” duplicate joins.
28. ORDER BY without an index.
29. GROUP BY non-indexed column.
30. HAVING used instead of WHERE.
31. Joins across different collations.
32. Using `IN (SELECT ...)` instead of `JOIN`.
33. LIKE with leading wildcard (`'%value'`).
34. Misuse of UNION instead of UNION ALL.
35. Query depending on implicit type casting.

---

# 🔹 **Transaction & Concurrency Problems**

36. Forgetting to `COMMIT` in transactions.
37. Long-running transactions locking rows.
38. Deadlocks between concurrent transactions.
39. Phantom reads in REPEATABLE READ isolation.
40. Lost updates from concurrent `UPDATE`.
41. Unnecessary use of SERIALIZABLE isolation.
42. Lock escalation on large updates.
43. Gap locks blocking inserts.
44. Using autocommit when multiple operations need atomicity.
45. Forgetting to rollback on error.

---

# 🔹 **Replication & Clustering Problems**

46. Replication lag causing stale reads.
47. Non-deterministic functions (`NOW()`, `RAND()`) in statements replicated.
48. Large transactions slowing replication.
49. Row vs statement-based replication mismatch.
50. GTID replication conflicts after failover.
51. Replication break due to schema drift.
52. Circular replication loops.
53. Writes going to read replicas accidentally.
54. Incorrect failover handling in application.
55. Binlog corruption breaking replication.

---

# 🔹 **Stored Procedures & Functions Problems**

56. Lack of error handling inside stored procs.
57. Overuse of stored procedures for business logic.
58. Recursive stored procedure calls causing stack overflow.
59. Deterministic flag misused in stored functions.
60. Procedures returning inconsistent result sets.
61. Using triggers for application logic.
62. Multiple triggers on same event causing order dependency.
63. Infinite trigger loops (insert/update triggers firing each other).
64. Triggers silently failing without raising error.
65. Using UDFs with untrusted code.

---

# 🔹 **Performance Problems**

66. Table scans due to missing indexes.
67. Slow joins with large intermediate results.
68. Temporary table creation on disk.
69. Filesort for ORDER BY without index.
70. Using OFFSET in pagination causing slow queries.
71. Non-sargable queries (`WHERE YEAR(date)=2025`).
72. Query plan changes due to bad statistics.
73. MySQL choosing wrong index.
74. Large IN() lists slowing optimizer.
75. Ignoring EXPLAIN for query analysis.

---

# 🔹 **Storage Engine Problems**

76. Mixing InnoDB and MyISAM incorrectly.
77. Forgetting to use InnoDB for transactions.
78. MyISAM table crashes requiring repair.
79. InnoDB buffer pool too small for workload.
80. Temp tables on disk because MEMORY engine not used.
81. Incorrect use of MEMORY tables for large datasets.
82. Failure to adjust `innodb_log_file_size` for big transactions.
83. Foreign keys ignored in MyISAM tables.
84. Too many partitions (overhead > performance gain).
85. Poor sharding strategy.

---

# 🔹 **Migration & Version Upgrade Problems**

86. Breaking changes between MySQL versions.
87. Collation changes breaking string comparisons.
88. Default authentication plugin mismatch (`caching_sha2_password` vs `mysql_native_password`).
89. Deprecated features still in use (`TIMESTAMP DEFAULT 0`).
90. Migration script dropping indexes unintentionally.
91. Data truncation during migration.
92. Incompatible schema with ORMs.
93. Downgrade not possible after upgrade.
94. Application not tested against new optimizer.
95. Timezone mismatches after upgrade.

---

# 🔹 **Security Problems**

96. Hardcoded MySQL credentials in source code.
97. No TLS encryption between app and DB.
98. Over-granting privileges (`GRANT ALL ON *.*`).
99. SQL injection from dynamic queries.
100. No audit logging for sensitive queries.

---

✅ That’s **100 MySQL programming problems** across all major aspects of development.
They range from schema design flaws to security issues, touching the entire lifecycle of database-backed software.
