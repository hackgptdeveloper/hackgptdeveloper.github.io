---
title: "Identifying access control bugs through automation"
tags:
  - AccessControl
---

### **Privilege Creep Detection**
**Example**: Verify if permissions are retained after role changes.

**Scenario**: A user is promoted to admin, performs actions, and is then demoted back to a regular user. Actions requiring admin permissions should no longer be accessible.

**Script**:
```python
base_url = "https://example.com/api/resource"
headers = {"Authorization": "Bearer USER_ACCESS_TOKEN"}

# Test admin-only endpoint after demotion
response = requests.get(f"{base_url}/admin-only", headers=headers)
if response.status_code == 200:
    print("Vulnerability Found: User retains admin privileges after demotion.")
else:
    print(f"Access denied with status: {response.status_code}")
```

**Expected Result**:  
The user should no longer have access to admin-only endpoints after role changes.

---

### **Replay Attack Detection**
**Example**: Capture a valid request, modify it, and resend it to see if access controls are enforced.

**Script**:
```python
import requests

url = "https://example.com/api/transaction"
headers = {"Authorization": "Bearer USER_ACCESS_TOKEN"}

# Simulate a valid transaction
valid_request = {
    "transaction_id": "12345",
    "amount": 100
}

response = requests.post(url, headers=headers, json=valid_request)
if response.status_code == 200:
    print("Valid transaction executed.")

# Replay the same request
response_replay = requests.post(url, headers=headers, json=valid_request)
if response_replay.status_code == 200:
    print("Vulnerability Found: Replay attack successful.")
else:
    print(f"Replay blocked with status: {response_replay.status_code}")
```

**Expected Result**:  
The replayed request should be rejected (e.g., `400 Bad Request` or `403 Forbidden`).

---

### **Testing Forgotten Password Workflow**
**Example**: Verify if users can reset passwords for accounts they do not own.

**Manual Test**:
1. Trigger a password reset for a user you don’t own (e.g., using an email parameter).
2. Observe the response and attempt to manipulate the workflow.

**Automation** (if applicable):
```python
reset_url = "https://example.com/api/password-reset"
headers = {"Authorization": "Bearer USER_ACCESS_TOKEN"}
data = {"email": "victim@example.com"}  # Email of the victim user

response = requests.post(reset_url, headers=headers, json=data)
print(f"Password reset status: {response.status_code}")
if "reset link sent" in response.text.lower():
    print("Potential vulnerability: Password reset for victim account allowed.")
```

**Expected Result**:  
Only the user owning the email should be able to initiate a password reset.

---

### **Hidden Elements and Features**
**Example**: Detect hidden admin functionality exposed in the frontend.

**Manual Test**:  
Inspect the HTML source code or use browser developer tools to find hidden elements or endpoints (e.g., `<button style="display: none;">Admin Panel</button>`).

**Script**:
```python
from bs4 import BeautifulSoup
import requests

url = "https://example.com/dashboard"
headers = {"Authorization": "Bearer USER_ACCESS_TOKEN"}

response = requests.get(url, headers=headers)
soup = BeautifulSoup(response.text, "html.parser")
hidden_elements = soup.find_all(style=lambda value: value and "display: none" in value)

for element in hidden_elements:
    print(f"Hidden element found: {element}")
```

**Expected Result**:  
Hidden elements should not reveal unauthorized functionality.

---

### **Testing Input Constraints**
**Example**: Bypass frontend restrictions by sending raw API requests.

**Manual Test**:
1. Intercept API calls using a proxy like **Burp Suite**.
2. Alter request parameters directly and observe the behavior.

**Automation**:
```python
url = "https://example.com/api/resource"
headers = {"Authorization": "Bearer USER_ACCESS_TOKEN"}
data = {"allowed_input": "test", "unauthorized_field": "malicious_data"}

response = requests.post(url, headers=headers, json=data)
if response.status_code == 200 and "malicious_data" in response.text:
    print("Vulnerability Found: Unauthorized field processed.")
```

**Expected Result**:  
The server should reject unauthorized fields or values.

---

### **Disabling Client-Side Checks**
**Example**: Modify the DOM to enable restricted functionality.

**Manual Test**:
1. Use browser developer tools to remove restrictions (e.g., disable `disabled` attributes on buttons).
2. Trigger actions and observe if access control is enforced on the server side.

**Automation** (for DOM inspection):
```javascript
// In the browser console
document.querySelectorAll('[disabled]').forEach((elem) => elem.removeAttribute('disabled'));
```

**Expected Result**:  
Server-side access controls should prevent unauthorized actions.

---

### **Rate Limiting Detection**
**Example**: Stress test an endpoint with repeated requests.

**Script**:
```python
import time
import requests

url = "https://example.com/api/resource"
headers = {"Authorization": "Bearer USER_ACCESS_TOKEN"}

for i in range(100):  # Simulate 100 rapid requests
    response = requests.get(url, headers=headers)
    print(f"Attempt {i + 1}: Status {response.status_code}")
    time.sleep(0.1)  # Optional delay to test gradual limits

    if response.status_code in [429, 403]:
        print("Rate limiting detected.")
        break
```

**Expected Result**:  
Excessive requests should be rate-limited or blocked with an appropriate status code.

---

### **Default Roles and Users**
**Example**: Test for default accounts with weak credentials.

**Manual Test**:
1. Attempt to log in using default credentials (e.g., `admin/admin`, `root/root`).
2. If an admin panel is accessible, use generic usernames to brute force login.

**Automation**:
```python
import requests

url = "https://example.com/login"
common_credentials = [("admin", "admin"), ("root", "root"), ("test", "test")]

for username, password in common_credentials:
    response = requests.post(url, data={"username": username, "password": password})
    print(f"Testing {username}/{password}: Status {response.status_code}")
    if response.status_code == 200:
        print(f"Vulnerability Found: Default credentials {username}/{password} accepted.")
        break
```

**Expected Result**:  
Default credentials should not work, and accounts should require strong passwords.

---
