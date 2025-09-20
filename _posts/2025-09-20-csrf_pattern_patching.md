--
title: "**side-by-side vulnerable vs secure patterns** for CSRF"
tags:
  - csrf
---

Perfect — let’s build **side-by-side vulnerable vs secure patterns** for each of the 40 cases (10 × PHP, Node.js, Java EE, Flask).
I’ll show you:

* 🔴 **Vulnerable pattern** (source level)
* ✅ **Secure alternative** (with library/framework fix)
* 🛠 **Explanation** (low-level reason why secure)

---

# 🟥 PHP – Vulnerable vs Secure

1. **SQL Injection**

```php
// 🔴 Vulnerable
$id = $_GET['id'];
$result = mysqli_query($conn, "SELECT * FROM users WHERE id = $id");

// ✅ Secure
$stmt = $conn->prepare("SELECT * FROM users WHERE id = ?");
$stmt->bind_param("i", $_GET['id']);
$stmt->execute();
```

🛠 Prepared statements keep SQL and data separate at the C API level (`mysql_stmt_execute`).

---

2. **XSS**

```php
// 🔴 Vulnerable
echo "Welcome " . $_GET['name'];

// ✅ Secure
echo "Welcome " . htmlspecialchars($_GET['name'], ENT_QUOTES, 'UTF-8');
```

🛠 `htmlspecialchars()` escapes `<`, `>`, `"`, preventing browser from executing injected JS.

---

3. **File Inclusion**

```php
// 🔴 Vulnerable
include($_GET['page'] . ".php");

// ✅ Secure
$whitelist = ["home", "about"];
if (in_array($_GET['page'], $whitelist)) {
    include($_GET['page'] . ".php");
}
```

🛠 Whitelisting avoids attacker-controlled filesystem access.

---

4. **Unrestricted Upload**

```php
// 🔴 Vulnerable
move_uploaded_file($_FILES['file']['tmp_name'], "uploads/" . $_FILES['file']['name']);

// ✅ Secure
$ext = pathinfo($_FILES['file']['name'], PATHINFO_EXTENSION);
if (!in_array($ext, ["jpg","png"])) exit("Invalid file");
move_uploaded_file($_FILES['file']['tmp_name'], "uploads/" . basename($_FILES['file']['name']));
```

🛠 Ensures only safe extensions, strips path.

---

5. **Command Injection**

```php
// 🔴 Vulnerable
system("ping " . $_GET['host']);

// ✅ Secure
$host = escapeshellarg($_GET['host']);
system("ping " . $host);
```

🛠 `escapeshellarg()` quotes input before shell expansion.

---

6. **Weak Hash**

```php
// 🔴 Vulnerable
$hash = md5($password);

// ✅ Secure
$hash = password_hash($password, PASSWORD_BCRYPT);
```

🛠 `password_hash()` uses bcrypt/argon2 under `crypt()`.

---

7. **Session Fixation**

```php
// 🔴 Vulnerable
session_id($_GET['sid']);
session_start();

// ✅ Secure
session_start();
session_regenerate_id(true);
```

🛠 `session_regenerate_id()` prevents reuse of attacker-supplied IDs.

---

8. **Unserialize RCE**

```php
// 🔴 Vulnerable
$obj = unserialize($_POST['data']);

// ✅ Secure
$obj = json_decode($_POST['data'], true);
```

🛠 JSON parsing does not trigger PHP magic methods (`__wakeup`).

---

9. **IDOR**

```php
// 🔴 Vulnerable
$file = "uploads/" . $_GET['file'];
readfile($file);

// ✅ Secure
if (userOwnsFile($_SESSION['uid'], $_GET['file'])) {
    readfile("uploads/" . $_GET['file']);
}
```

🛠 Access control tied to session owner.

---

10. **Header Injection**

```php
// 🔴 Vulnerable
header("Location: " . $_GET['url']);

// ✅ Secure
$url = filter_var($_GET['url'], FILTER_VALIDATE_URL);
header("Location: " . $url);
```

🛠 Validation blocks CRLF injection.

---

# 🟩 Node.js – Vulnerable vs Secure

1. **Eval Injection**

```js
// 🔴 Vulnerable
eval(req.query.code);

// ✅ Secure
vm.runInNewContext(req.query.code, {}, { timeout: 1000 });
```

🛠 `vm` sandbox isolates execution.

---

2. **Prototype Pollution**

```js
// 🔴 Vulnerable
Object.assign(obj, JSON.parse(req.body.data));

// ✅ Secure
const safe = JSON.parse(req.body.data, (k,v) => k === "__proto__" ? undefined : v);
Object.assign(obj, safe);
```

🛠 Filters dangerous prototype keys.

---

3. **NoSQL Injection**

```js
// 🔴 Vulnerable
User.findOne({ username: req.body.username });

// ✅ Secure
User.findOne({ username: String(req.body.username) });
```

🛠 Casting to string prevents `$ne` operators.

---

4. **Command Injection**

```js
// 🔴 Vulnerable
exec("ls " + req.query.dir);

// ✅ Secure
execFile("ls", [req.query.dir]);
```

🛠 `execFile()` passes args directly to syscall, no shell parsing.

---

5. **Path Traversal**

```js
// 🔴 Vulnerable
res.sendFile(__dirname + "/files/" + req.query.file);

// ✅ Secure
res.sendFile(path.join(__dirname, "files", path.basename(req.query.file)));
```

🛠 Normalizes to prevent `../`.

---

6. **Insecure Cookie**

```js
// 🔴 Vulnerable
res.cookie("sid", sid);

// ✅ Secure
res.cookie("sid", sid, { httpOnly: true, secure: true, sameSite: "Strict" });
```

🛠 Flags prevent JS access, CSRF.

---

7. **Insecure Deserialization**

```js
// 🔴 Vulnerable
let data = JSON.parse(req.body);

// ✅ Secure
let data = safeJsonParse(req.body);
```

🛠 Use a hardened parser, validate schema.

---

8. **Regex DoS**

```js
// 🔴 Vulnerable
/(a+)+$/.test(req.query.input);

// ✅ Secure
new RegExp("^[a-z]{1,30}$").test(req.query.input);
```

🛠 Bounded regex avoids catastrophic backtracking.

---

9. **CORS Misconfig**

```js
// 🔴 Vulnerable
res.setHeader("Access-Control-Allow-Origin", "*");

// ✅ Secure
res.setHeader("Access-Control-Allow-Origin", "https://trusted.com");
```

🛠 Restricts cross-origin access.

---

10. **XSS**

```js
// 🔴 Vulnerable
res.send("Hello " + req.query.name);

// ✅ Secure
res.send("Hello " + escapeHtml(req.query.name));
```

🛠 Escape user input before HTML context.

---

# 🟨 Java EE – Vulnerable vs Secure

1. **SQL Injection**

```java
// 🔴 Vulnerable
stmt.executeQuery("SELECT * FROM users WHERE id=" + request.getParameter("id"));

// ✅ Secure
PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id=?");
ps.setInt(1, Integer.parseInt(request.getParameter("id")));
```

---

2. **XSS**

```java
// 🔴 Vulnerable
out.println(request.getParameter("name"));

// ✅ Secure
out.println(StringEscapeUtils.escapeHtml4(request.getParameter("name")));
```

---

3. **LDAP Injection**

```java
// 🔴 Vulnerable
String filter = "(uid=" + request.getParameter("user") + ")";

// ✅ Secure
String filter = "(uid={0})";
SearchControls sc = new SearchControls();
ctx.search("ou=users,dc=example,dc=com", filter, new Object[]{request.getParameter("user")}, sc);
```

---

4. **Deserialization**

```java
// 🔴 Vulnerable
Object obj = new ObjectInputStream(request.getInputStream()).readObject();

// ✅ Secure
ObjectMapper mapper = new ObjectMapper();
User user = mapper.readValue(request.getInputStream(), User.class);
```

---

5. **Command Injection**

```java
// 🔴 Vulnerable
Runtime.getRuntime().exec("ping " + request.getParameter("host"));

// ✅ Secure
ProcessBuilder pb = new ProcessBuilder("ping", request.getParameter("host"));
```

---

6. **Path Traversal**

```java
// 🔴 Vulnerable
File f = new File("/data/" + request.getParameter("file"));

// ✅ Secure
File f = new File("/data/", Paths.get(request.getParameter("file")).getFileName().toString());
```

---

7. **Weak Crypto**

```java
// 🔴 Vulnerable
MessageDigest md = MessageDigest.getInstance("MD5");

// ✅ Secure
SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
```

---

8. **Session Fixation**

```java
// 🔴 Vulnerable
String sid = request.getParameter("JSESSIONID");

// ✅ Secure
request.getSession().invalidate();
request.getSession(true);
```

---

9. **Open Redirect**

```java
// 🔴 Vulnerable
response.sendRedirect(request.getParameter("url"));

// ✅ Secure
if (request.getParameter("url").startsWith("/app")) {
    response.sendRedirect(request.getParameter("url"));
}
```

---

10. **XXE**

```java
// 🔴 Vulnerable
dbf.newDocumentBuilder().parse(uploadedXML);

// ✅ Secure
dbf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
```

---

# 🟦 Python Flask – Vulnerable vs Secure

1. **SQL Injection**

```python
# 🔴 Vulnerable
db.execute("SELECT * FROM users WHERE id=" + request.args['id'])

# ✅ Secure
db.execute("SELECT * FROM users WHERE id=?", (request.args['id'],))
```

---

2. **XSS**

```python
# 🔴 Vulnerable
return f"Welcome {request.args['name']}"

# ✅ Secure
return render_template("welcome.html", name=request.args['name'])
```

(Flask Jinja2 auto-escapes by default)

---

3. **Command Injection**

```python
# 🔴 Vulnerable
os.system("ping " + request.args['host'])

# ✅ Secure
subprocess.run(["ping", request.args['host']])
```

---

4. **Path Traversal**

```python
# 🔴 Vulnerable
send_file("uploads/" + request.args['file'])

# ✅ Secure
send_from_directory("uploads", os.path.basename(request.args['file']))
```

---

5. **Pickle RCE**

```python
# 🔴 Vulnerable
pickle.loads(request.data)

# ✅ Secure
json.loads(request.data)
```

---

6. **Hardcoded Secret**

```python
# 🔴 Vulnerable
app.config['SECRET_KEY'] = "12345"

# ✅ Secure
app.config['SECRET_KEY'] = os.environ['SECRET_KEY']
```

---

7. **CSRF Missing**

```python
# 🔴 Vulnerable
@app.route("/transfer", methods=["POST"])
def transfer(): ...

# ✅ Secure
csrf = CSRFProtect(app)
```

---

8. **Debug Mode**

```python
# 🔴 Vulnerable
app.run(debug=True)

# ✅ Secure
app.run(debug=False)
```

---

9. **Weak Password Hash**

```python
# 🔴 Vulnerable
hashlib.md5(password.encode()).hexdigest()

# ✅ Secure
bcrypt.hashpw(password.encode(), bcrypt.gensalt())
```

---

10. **CORS Misconfig**

```python
# 🔴 Vulnerable
CORS(app, resources={r"/*": {"origins": "*"}})

# ✅ Secure
CORS(app, resources={r"/api/*": {"origins": "https://trusted.com"}})
```

---

👉 That gives you **40 vulnerable patterns with secure fixes** across PHP, Node.js, Java EE, and Flask.
