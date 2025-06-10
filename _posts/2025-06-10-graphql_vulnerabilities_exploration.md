---
title: "Exploring and investigating the vulnerabilities of a GraphQL implementation"
tags:
  - graphql
---

Exploring and investigating the vulnerabilities of a GraphQL implementation requires a combination of **manual testing**, **automated tools**, and **understanding of both GraphQL’s specification** and the **underlying application stack** (backend language, framework, database). Below are **50 in-depth tasks**, organized into categories, that you should consider during your GraphQL security assessment.

---

## 🛠️ RECONNAISSANCE

1. **Locate the GraphQL endpoint**
   Common paths: `/graphql`, `/gql`, `/api/graphql`.

2. **Determine the HTTP methods allowed**
   Usually `POST`, sometimes `GET`. Misconfigured servers may allow dangerous methods.

3. **Fingerprint the GraphQL engine/framework**
   E.g., Apollo Server, Graphene, express-graphql, etc., by checking response headers, error messages, or introspection output.

4. **Check for introspection availability**
   Query using `__schema { types { name } }` to see if schema introspection is enabled.

5. **Determine if GraphiQL or GraphQL Playground is exposed**
   Access to these UIs can aid attackers by providing autocomplete and docs.

6. **Check for rate-limiting or throttling**
   Send multiple queries or batched requests to determine limits.

7. **Assess authentication requirements**
   Can you access the endpoint anonymously?

8. **Determine if CORS policy is permissive**
   Misconfigured CORS could allow cross-origin exploitation.

9. **Check HTTP headers (security-related)**
   `Cache-Control`, `Content-Type`, `X-Frame-Options`, `CSP`, etc.

10. **Look for debug info in error messages**
    Stack traces, SQL queries, file paths.

---

## 🔍 SCHEMA ENUMERATION

11. **Use introspection to dump full schema**
    Use tools like `graphql-voyager`, `InQL`, or `GraphQL Voyager`.

12. **Identify object types and input types**
    Understanding data structure is crucial for injection attacks.

13. **Enumerate mutations and queries**
    Look for dangerous operations like `create`, `update`, `delete`.

14. **Check for custom scalars (e.g., Email, URL, JSON)**
    These might have lenient or flawed validation logic.

15. **Check for file upload endpoints (`Upload` scalar)**
    These may expose arbitrary file write vulnerabilities.

16. **Identify nested types and relationships**
    Useful for crafting deep queries (e.g., for DoS).

17. **Analyze directive usage**
    E.g., `@include`, `@skip`, and custom directives.

18. **Search for deprecated fields**
    May still be functional but unmaintained/insecure.

19. **Map out access control annotations**
    E.g., `@auth`, `@admin`, `@private`.

20. **Compare schemas for different user roles**
    Use various tokens to compare visibility.

---

## ⚙️ INPUT VALIDATION / INJECTION TESTING

21. **Test for GraphQL Injection**
    Inject into fields/variables:
    Example:

    ```graphql
    query { user(id: "1) { id name }") }
    ```

22. **Test for classic SQL injection via GraphQL**
    E.g., `{ user(id: "1' OR '1'='1") { id } }`

23. **Test for NoSQL injection (MongoDB/DocumentDB)**
    E.g., passing JSON-like structures into parameters.

24. **Check for command injection in mutation fields**

25. **Try broken input types**
    E.g., sending string where int is expected.

26. **Fuzz all input arguments and variables**
    Use fuzzing tools with wordlists for edge-case handling.

27. **Try bypassing validation using aliases**
    GraphQL supports field aliases. Use them to craft confusing or deceptive queries.

28. **Check for over-permissive enums**
    Some may expose internal application states or modes.

29. **Manipulate complex input types (InputObject, Lists)**
    Submit malformed arrays or nested objects.

30. **Check for HTTP Parameter Pollution in query variables**

---

## 🔐 AUTHORIZATION / ACCESS CONTROL

31. **Test access control on all queries and mutations**
    Remove JWT, use lower-privileged roles.

32. **Access other users’ data via IDOR**
    E.g., `{ user(id: 2) { email } }`

33. **Try unauthorized role mutation (e.g., promote to admin)**

34. **Check object-level access control (OLAC)**
    Nested queries may bypass top-level ACL.

35. **Tamper with JWT (alg\:none, expired token, etc.)**

36. **Check if permissions are enforced on resolvers**
    Look for field-level permission leaks.

---

## 📉 DOS / ABUSE

37. **Perform a query depth attack**
    Deeply nested query to exhaust backend recursion limits.

38. **Send large batched queries**
    GraphQL allows batching multiple queries in a single request.

39. **Exploit alias overloading**
    Use many aliases to repeat the same field hundreds of times.

40. **Send large query payloads to stress parsing**

41. **Try cyclic queries (fragments referencing each other)**
    Some servers may not properly handle recursion.

42. **Check for logging DoS (via verbose queries)**

---

## 📦 MISC / MISCONFIGURATION

43. **Test CSRF if GraphQL is accessible over GET**

44. **Check for file uploads vulnerabilities (if supported)**
    Abuse `Upload` scalar to try overwriting or injecting.

45. **Try SSRF via user-supplied URLs in inputs**

46. **Check if subscriptions are enabled (WebSockets)**
    Misused subscriptions can lead to info leaks or persistent sockets.

47. **Abuse query complexity limits**
    Test if `@complexity` directives or query limits are enforced.

48. **Check if deprecated operations are still active**

49. **Check GraphQL federation or remote schemas**
    Misconfigured federated services can leak internal APIs.

50. **Inspect implementation source code (if available)**
    Look for resolver-level flaws, custom directives, access control logic.

---

### 🧰 Tools to Aid in the Assessment

* [InQL](https://github.com/doyensec/inql) (Burp plugin + CLI)
* [GraphQL Voyager](https://github.com/APIs-guru/graphql-voyager)
* [GraphQLMap](https://github.com/swisskyrepo/GraphQLmap)
* [GraphBreaker](https://github.com/dolevf/graphbreaker)
* \[Altair/Insomnia/Postman GraphQL Clients]
* Custom Python scripts using `requests` + `graphql-core` or `gql`

---
