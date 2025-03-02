
### Why is UNION Query-Based SQLi the Fastest SQL Injection Type?

The **UNION-based SQL Injection** technique is often considered one of the **fastest** ways to extract data from a vulnerable database. This is due to several reasons, including **direct data retrieval, minimal execution complexity, and leveraging native SQL functions**. Below is a detailed explanation.

---

## **1. Direct Data Retrieval in a Single Query**
Unlike **Blind SQL Injection (Boolean-based or Time-based)**, where the attacker has to infer data **bit by bit** or introduce artificial delays, UNION-based SQL Injection allows **direct extraction of multiple rows in a single request**.  

### **Example:**  
Consider a vulnerable website where an attacker can manipulate the `id` parameter:  

```sql
http://example.com/index.php?id=1
```

If the parameter is vulnerable to SQL Injection, the attacker can modify it as:

```sql
http://example.com/index.php?id=1 UNION SELECT username, password FROM users
```

Since the `UNION` operator **merges results from two queries**, the database directly returns usernames and passwords in the web application's response. This eliminates the need for **time-consuming brute-force inference** used in Blind SQLi.

---

## **2. Leverages Native SQL Optimization**
Databases optimize **UNION queries** efficiently because they are a standard SQL operation. The execution plan for a UNION query is optimized for speed as long as:
- The columns match in count and data type.
- Indexes exist on the tables being queried.

Most databases handle UNION queries quickly using indexing and query execution plans, making them **faster than techniques requiring multiple separate queries or conditional execution (e.g., Blind SQLi).**

---

## **3. Fewer Requests Compared to Other Techniques**
Other SQLi techniques require multiple requests:
- **Boolean-based SQLi** → Requires multiple requests to infer each character (`A-Z`, `0-9`) of a string one at a time.
- **Time-based SQLi** → Relies on delays (`SLEEP()` or `WAITFOR DELAY`), making extraction slow.
- **Error-based SQLi** → Depends on error messages, which may be filtered or restricted.

In contrast, UNION-based SQLi extracts **all necessary data in a single query**, significantly **reducing** the number of requests and improving speed.

---

## **4. Works Well with Error-Based SQLi**
Many applications return **descriptive SQL errors**, which help attackers determine the number of columns required for UNION-based injection.

For example, consider:
```sql
http://example.com/index.php?id=1 ORDER BY 5 --
```
If an error occurs (`Unknown column '5' in 'order clause'`), the attacker knows the number of columns is **less than 5** and can adjust the UNION query accordingly.

Combining **Error-based SQLi** with **UNION-based SQLi** allows attackers to quickly craft a working exploit.

---

## **5. Minimal Need for Complex Logic**
- **Boolean-based SQLi** → Requires logical inference (`IF condition THEN... ELSE...`).
- **Time-based SQLi** → Requires precise timing calculations.
- **Out-of-band SQLi** → Requires secondary channels (e.g., DNS exfiltration).

UNION-based SQLi **only requires knowing the table schema**, making it simpler and faster to execute.

---

## **6. Exploits Readable Data Easily**
If an application directly displays database results on a webpage, UNION-based SQLi **instantly exposes sensitive data**.

For example:
```sql
http://example.com/index.php?id=1 UNION SELECT username, password FROM users
```
Would directly return:
```
admin | admin123
user1 | password123
```
This **instant access** makes UNION-based SQLi significantly faster than Blind SQLi.

---

## **7. Bypasses Filtering in Many Cases**
Many **WAFs (Web Application Firewalls)** and security filters focus on **common SQLi payloads** like:
- `1=1`
- `SLEEP(5)`
- `AND 'a'='a'`

However, UNION-based SQLi **often bypasses naive filtering** since:
- UNION is a valid SQL keyword.
- Filtering for UNION alone might break legitimate queries.
- Encoding tricks (`UNI%4F%4E`) can further bypass protection.

This ease of exploitation contributes to its speed.

---

# **When is UNION-Based SQLi Not Feasible?**
Despite being one of the fastest techniques, UNION-based SQL Injection **may not always work** in the following cases:
1. **Different Column Counts** → The number of columns in the first query must match the number of columns in the second.
2. **Data Type Mismatch** → The columns must have compatible data types.
3. **No Error Messages** → If error-based information is hidden, attackers might struggle to identify column count.
4. **Limited User Privileges** → If the SQL user lacks permission to query certain tables, UNION may fail.
5. **WAF Filtering** → Some WAFs detect UNION-based SQLi and block such requests.

In such cases, attackers resort to **Blind SQLi or Out-of-band (OOB) SQLi**, which are slower.

---

# **Conclusion**
UNION-based SQL Injection is the fastest method when:
- The application **returns query results on a webpage**.
- The attacker can determine the **number and types of columns**.
- The database supports **error-based information leaks**.

It is **faster than Blind and Time-based SQLi** because:
✅ It retrieves **full records in one query**.  
✅ It avoids **multiple requests per character**.  
✅ It benefits from **native SQL optimizations**.  

This efficiency makes UNION-based SQLi a **preferred attack vector** in real-world exploitation.
