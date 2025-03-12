---
title: "100 key aspects of Redis"
tags:
  - Redis
---

### **1-10: Basic Features and Commands**
1. **In-Memory Storage** – Redis stores data in RAM, making it extremely fast.
2. **Persistence Options** – Redis supports **RDB (snapshotting)** and **AOF (Append-Only File)** for durability.
3. **Data Structures** – Supports **strings, lists, sets, sorted sets, hashes, bitmaps, hyperloglogs, and geospatial indexes**.
4. **Basic Commands** – `SET`, `GET`, `DEL`, `EXPIRE`, `TTL`, `KEYS`, `FLUSHDB`, `FLUSHALL`.
5. **Advanced Commands** – `ZADD` (sorted sets), `HSET` (hashes), `LPUSH/RPUSH` (lists), `BITOP` (bit operations).
6. **Atomic Operations** – All Redis operations are atomic at the single command level.
7. **Pipeline Support** – Redis allows multiple commands to be sent together for efficiency.
8. **Pub/Sub Messaging** – Real-time publish-subscribe capabilities using `PUBLISH` and `SUBSCRIBE`.
9. **Transactions (MULTI/EXEC)** – Supports multiple operations in a single transaction.
10. **Lua Scripting** – Supports server-side scripting via Lua (`EVAL`, `EVALSHA`).

---

### **11-20: Tools & Plugins**
11. **redis-cli** – Official command-line interface for interacting with Redis.
12. **RedisInsight** – A GUI tool for visualizing Redis data.
13. **RediSearch** – A Redis module for full-text search.
14. **RedisJSON** – A module to store and query JSON data efficiently.
15. **RedisGraph** – A graph database on top of Redis.
16. **RedisBloom** – A probabilistic data structure module for Bloom filters.
17. **redis-benchmark** – A tool to measure Redis performance.
18. **redis-dump** – Tool for exporting and importing Redis databases.
19. **redis-stat** – A real-time monitoring tool for Redis.
20. **redigo** – A Go client for Redis.

---

### **21-30: Integrations & Ecosystem**
21. **Docker Support** – Official Redis Docker images are available.
22. **Kubernetes Integration** – Redis can be deployed using Helm charts.
23. **Redis Sentinel** – A high-availability solution for monitoring Redis instances.
24. **Redis Cluster** – A built-in solution for sharding and scaling Redis.
25. **Integration with Node.js** – Popular Node.js libraries include `ioredis` and `node-redis`.
26. **Integration with Python** – `redis-py` is the official Redis client for Python.
27. **Integration with Java** – `Jedis` and `Lettuce` are popular Java clients.
28. **Integration with .NET** – `StackExchange.Redis` is a widely used .NET client.
29. **Integration with PHP** – `phpredis` and `Predis` are popular PHP clients.
30. **Integration with Django** – Used for caching and session storage in Django.

---

### **31-40: Performance & Scalability**
31. **Ultra-low Latency** – Typical command execution time is under **1 millisecond**.
32. **Throughput** – Can handle **millions of operations per second** with proper optimization.
33. **Replication** – Supports **master-replica** replication for scalability and redundancy.
34. **Eviction Policies** – Supports various cache eviction strategies like **LRU, LFU, TTL-based**.
35. **Zero Downtime Scaling** – Redis Cluster allows adding/removing nodes dynamically.
36. **Disk-based Caching** – Uses **Redis on Flash** (RoF) to extend RAM storage with SSD.
37. **Memory Optimization** – Uses **Redis Hashes** to pack small key-value pairs efficiently.
38. **Threaded I/O** – Since Redis 6, supports **multithreading for network I/O**.
39. **Connection Pooling** – Supports efficient client connection management.
40. **Lazy Freeing** – Uses background threads to free memory asynchronously.

---

### **41-50: Use Cases & Real-World Applications**
41. **Caching** – Used as an ultra-fast cache for databases like MySQL and PostgreSQL.
42. **Session Storage** – Many web applications use Redis for session management.
43. **Rate Limiting** – Implemented using the `INCR` and `EXPIRE` commands.
44. **Leaderboard Systems** – Used in gaming applications with sorted sets (`ZADD`, `ZRANGE`).
45. **Message Queues** – Used in event-driven architectures with `LPUSH/BRPOP`.
46. **Real-Time Analytics** – Used in analytics platforms for fast aggregations.
47. **Machine Learning** – Used in AI workloads for feature stores and real-time inference.
48. **IoT Data Storage** – Used for handling high-velocity IoT data streams.
49. **Fraud Detection** – Used in fintech applications to detect anomalies in transactions.
50. **E-commerce & Ad Tech** – Used for recommendation engines and user targeting.

---

### **51-60: Advanced Commands & Features**
51. **Bitmaps** – Redis supports bit-level operations using `SETBIT`, `GETBIT`, and `BITCOUNT`.
52. **HyperLogLog** – Used for approximate cardinality estimation (`PFADD`, `PFCOUNT`).
53. **Geospatial Indexing** – Supports storing and querying geolocation data (`GEOADD`, `GEODIST`, `GEORADIUS`).
54. **Expire & TTL Management** – Set expiration on keys using `EXPIRE`, `PEXPIRE`, and `TTL`.
55. **Keyspace Notifications** – Allows event-driven applications using `CONFIG SET notify-keyspace-events`.
56. **Scan Commands** – `SCAN`, `HSCAN`, `SSCAN`, and `ZSCAN` for efficient key iteration.
57. **Slow Log** – `SLOWLOG GET` to analyze slow queries.
58. **Configurable Persistence** – Redis supports **no persistence, RDB-only, AOF-only, or mixed mode**.
59. **LRU and LFU Eviction** – Supports Least Recently Used (LRU) and Least Frequently Used (LFU) eviction policies.
60. **Multi-Key Operations** – Commands like `MSET`, `MGET`, and `DEL` operate on multiple keys at once.

---

### **61-70: More Redis Modules**
61. **RedisTimeSeries** – Time-series data support for IoT and financial applications.
62. **RedisGears** – Enables serverless functions inside Redis.
63. **RedisAI** – Integrates AI/ML models directly into Redis.
64. **RedisGears for ETL** – Used for Extract, Transform, Load (ETL) workflows.
65. **RedLock Algorithm** – Distributed locking mechanism built on Redis.
66. **RedisRaft** – Brings strong consistency to Redis using the Raft consensus algorithm.
67. **Redis Streams** – A high-performance log-based messaging system (`XADD`, `XREAD`, `XGROUP`).
68. **Custom Redis Modules** – Developers can write custom modules in C.
69. **Redis Sentinel API** – Programmatic access to Redis Sentinel for failover monitoring.
70. **Backup & Restore with RDB** – `SAVE` and `BGSAVE` allow manual backups.

---

### **71-80: Security & High Availability**
71. **AUTH & ACL** – Supports authentication (`AUTH`), and Access Control Lists (`ACL SETUSER`).
72. **TLS Encryption** – Supports **TLS/SSL** encryption for secure communication.
73. **IP Whitelisting** – Restrict access using `bind` configuration.
74. **Password Protection** – Enforce authentication via `requirepass` setting.
75. **Redis Cluster Failover** – Auto failover mechanism for Redis Cluster.
76. **Redis Sentinel Failover** – Automates failover and monitoring.
77. **Replica Promotion** – A replica can be promoted to a master in case of failure.
78. **Connection Limits** – Configurable via `maxclients` setting.
79. **Data Masking** – Protect sensitive data using encryption and ACLs.
80. **Audit Logging** – Track key access and modifications with monitoring tools.

---

### **81-90: Performance & Scaling Techniques**
81. **Sharding** – Redis Cluster enables automatic horizontal sharding.
82. **Read-Only Replicas** – Offload read requests to replicas.
83. **Lazy Deletion** – `UNLINK` command removes keys asynchronously.
84. **Memory Defragmentation** – `MEMORY PURGE` helps optimize RAM usage.
85. **Threaded I/O in Redis 6+** – Improves performance under high loads.
86. **Disk-backed Extension** – Extending Redis memory with SSD using Redis on Flash (RoF).
87. **Adaptive Hash Tables** – Auto-resizes for optimal memory usage.
88. **Pipeline Optimization** – Reduce network round trips by batching requests.
89. **Optimized Networking** – Uses **epoll/kqueue** for non-blocking I/O.
90. **AOF Rewrite Optimization** – Automatically rewrites the Append-Only File to optimize storage.

---

### **91-100: Real-World Applications**
91. **CDN & Edge Caching** – Used in Content Delivery Networks for caching.
92. **DNS Caching** – Used in applications to speed up domain resolution.
93. **Authentication Tokens** – JWT and session token storage.
94. **Stock Market Feeds** – Used in real-time financial data feeds.
95. **Gaming Matchmaking** – Used in online gaming to match players.
96. **E-commerce Flash Sales** – Manages high-volume traffic spikes.
97. **API Rate Limiting** – Prevents API abuse with per-user rate limits.
98. **Streaming Platforms** – Used for chat systems and view counts.
99. **Ad Targeting Systems** – Used for tracking and recommendation engines.
100. **Search Auto-Completion** – Used in search engines for instant suggestions.

---

Redis is **not just a cache**—it's a powerful **real-time data store** used in modern **distributed architectures**.  An incredibly versatile and high-performance data store, widely adopted in modern architectures for caching, real-time analytics, messaging, and more. 
