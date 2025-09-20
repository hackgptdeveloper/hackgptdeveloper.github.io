--
title: "CSRF pattern in sources in PHP, Node.js, Java EE, Flask"
tags:
  - csrf
---

Perfect request — let’s go language by language. I’ll show you **10 vulnerable coding patterns at the source-code level** for each of PHP, Node.js, Java EE, and Python Flask. For each, I’ll give you:

* **Code snippet (vulnerable)**
* **Why it’s dangerous (root cause)**
* **Underlying source-level mechanism (e.g., function/library behavior that creates the flaw)**

---

## 🔴 PHP – 10 Vulnerable Patterns

1. **SQL Injection**

```php
$id = $_GET['id'];
$result = mysqli_query($conn, "SELECT * FROM users WHERE id = $id");
```

Cause: Direct interpolation of user input in SQL query → parsed by MySQL C parser (`sql_parse.cc`).

2. **XSS via Echo**

```php
echo "Welcome " . $_GET['name'];
```

Cause: `echo` directly writes to response without HTML escaping.

3. **File Inclusion**

```php
include($_GET['page'] . ".php");
```

Cause: `include()` executes arbitrary file contents as PHP code.

4. **Unrestricted File Upload**

```php
move_uploaded_file($_FILES['file']['tmp_name'], "uploads/" . $_FILES['file']['name']);
```

Cause: No MIME/extension validation, attacker uploads `.php`.

5. **Command Injection**

```php
system("ping " . $_GET['host']);
```

Cause: `system()` spawns `/bin/sh`, concatenated input is executed.

6. **Weak Hashing**

```php
$hash = md5($password);
```

Cause: `md5()` is cryptographically broken; rainbow tables precomputed.

7. **Session Fixation**

```php
session_id($_GET['sid']);  
session_start();
```

Cause: Accepting attacker-controlled session IDs.

8. **Insecure Deserialization**

```php
$obj = unserialize($_POST['data']);
```

Cause: PHP `unserialize()` can invoke `__wakeup`/`__destruct` methods in attacker-crafted payload.

9. **Insecure Direct Object Reference (IDOR)**

```php
$file = "uploads/" . $_GET['file'];
readfile($file);
```

Cause: No access control check.

10. **Header Injection**

```php
header("Location: " . $_GET['url']);
```

Cause: Input with `\n` allows attacker to inject additional headers.

---

## 🟢 Node.js – 10 Vulnerable Patterns

1. **Eval Injection**

```js
app.get('/eval', (req, res) => {
  eval(req.query.code);
});
```

Cause: V8 `eval()` runs arbitrary JavaScript.

2. **Prototype Pollution**

```js
let obj = {};
Object.assign(obj, JSON.parse(req.body.data));
```

Cause: `__proto__` injection changes base Object prototype.

3. **NoSQL Injection (MongoDB)**

```js
User.findOne({ username: req.body.username });
```

Cause: Input `{ "$ne": null }` bypasses authentication.

4. **Command Injection**

```js
child_process.exec("ls " + req.query.dir);
```

Cause: Input concatenated into shell command.

5. **Path Traversal**

```js
res.sendFile(__dirname + '/files/' + req.query.file);
```

Cause: `../` lets attacker escape directory.

6. **Insecure Cookie**

```js
res.cookie("sid", sid);
```

Cause: Missing `HttpOnly`, `Secure`, `SameSite`.

7. **Insecure Deserialization**

```js
let data = JSON.parse(req.body);
```

Cause: If used with libraries like `serialize-javascript` can rehydrate functions.

8. **Regex DoS**

```js
if (/^(a+)+$/.test(req.query.input)) { ... }
```

Cause: Catastrophic backtracking → event loop blocking.

9. **CORS Misconfiguration**

```js
res.setHeader("Access-Control-Allow-Origin", "*");
```

Cause: Any origin can access responses with credentials.

10. **XSS**

```js
res.send("Hello " + req.query.name);
```

Cause: No HTML encoding in `res.send()`.

---

## 🟡 Java EE – 10 Vulnerable Patterns

1. **SQL Injection (JDBC)**

```java
Statement stmt = conn.createStatement();
ResultSet rs = stmt.executeQuery("SELECT * FROM users WHERE id=" + request.getParameter("id"));
```

Cause: `Statement` concatenates query string; parsed by JDBC driver.

2. **XSS**

```java
out.println("Welcome " + request.getParameter("name"));
```

Cause: Direct reflection into HTML.

3. **LDAP Injection**

```java
String filter = "(uid=" + request.getParameter("user") + ")";
ctx.search("ou=users,dc=example,dc=com", filter, controls);
```

Cause: Input expands LDAP search filter.

4. **Insecure Deserialization**

```java
ObjectInputStream in = new ObjectInputStream(request.getInputStream());
Object obj = in.readObject();
```

Cause: Attackers send gadget chains → `readObject()` execution.

5. **Command Injection**

```java
Runtime.getRuntime().exec("ping " + request.getParameter("host"));
```

Cause: OS command interpreter invoked.

6. **Path Traversal**

```java
File f = new File("/data/" + request.getParameter("file"));
```

Cause: Input like `../../etc/passwd`.

7. **Weak Crypto**

```java
MessageDigest md = MessageDigest.getInstance("MD5");
```

Cause: Known collision vulnerabilities.

8. **Session Fixation**

```java
String sid = request.getParameter("JSESSIONID");
```

Cause: Reuses attacker’s session ID.

9. **Insecure Redirect**

```java
response.sendRedirect(request.getParameter("url"));
```

Cause: Open redirect.

10. **XXE Injection**

```java
DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
Document doc = dbf.newDocumentBuilder().parse(uploadedXML);
```

Cause: XXE enabled by default → entity expansion.

---

## 🔵 Python Flask – 10 Vulnerable Patterns

1. **SQL Injection (SQLite)**

```python
@app.route("/user")
def user():
    uid = request.args.get("id")
    return db.execute("SELECT * FROM users WHERE id = " + uid).fetchall()
```

Cause: String interpolation passed to SQLite C parser.

2. **XSS**

```python
return f"Welcome {request.args['name']}"
```

Cause: Flask `return` sends raw HTML.

3. **Command Injection**

```python
os.system("ping " + request.args['host'])
```

Cause: User input concatenated into shell command.

4. **Path Traversal**

```python
return send_file("uploads/" + request.args['file'])
```

Cause: `../` traversal to arbitrary files.

5. **Insecure Pickle**

```python
data = pickle.loads(request.data)
```

Cause: Pickle executes arbitrary opcodes.

6. **Hardcoded Secrets**

```python
app.config['SECRET_KEY'] = "12345"
```

Cause: Predictable secret allows session forgery.

7. **CSRF Missing**

```python
@app.route("/transfer", methods=["POST"])
def transfer(): ...
```

Cause: No CSRF token validation.

8. **Debug Mode Enabled**

```python
app.run(debug=True)
```

Cause: Werkzeug debugger RCE.

9. **Weak Password Storage**

```python
hashlib.md5(password.encode()).hexdigest()
```

Cause: MD5 is weak; bcrypt/argon2 recommended.

10. **Insecure CORS**

```python
CORS(app, resources={r"/*": {"origins": "*"}})
```

Cause: Any origin can send requests.

---

✅ These snippets demonstrate **source-level vulnerable patterns** that map directly to language/runtime/library internals. They’re the exact kinds of issues that bug bounty hunters and auditors search for.
