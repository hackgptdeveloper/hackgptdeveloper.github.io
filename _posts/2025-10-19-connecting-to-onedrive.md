---
title: "Connecting to **OneDrive from Linux**"
tags:
  - OneDrive
---

## 🧩 1. Overview of Options

| Method                   | Description                                                               | Sync / Mount | API Access                  |
| ------------------------ | ------------------------------------------------------------------------- | ------------ | --------------------------- |
| **rclone**               | Universal cloud storage sync tool supporting OneDrive, Google Drive, etc. | ✅ Sync       | ✅ Uses Microsoft Graph API  |
| **onedrive (abraunegg)** | Native Linux OneDrive client written in D                                 | ✅ Sync       | ✅ Uses Microsoft Graph API  |
| **mount via rclone**     | Mount OneDrive as a local folder using FUSE                               | ✅ Mount      | ✅ Uses Graph API            |
| **Graph API (manual)**   | Access OneDrive directly via HTTPS REST API                               | ❌            | ✅ Full programmable control |

---

## ⚙️ 2. Option 1 — Using `rclone` (Recommended)

### 🔧 Installation

```bash
sudo apt install rclone -y
```

or from source:

```bash
curl https://rclone.org/install.sh | sudo bash
```

### 🔐 Configure for OneDrive

Run the configuration wizard:

```bash
rclone config
```

Then:

```
n) New remote
name> onedrive
storage> onedrive
client_id> (leave empty unless using your own Azure app)
client_secret> (leave empty unless using your own)
region> global
edit advanced config? n
use auto config? y
```

This will open your browser → log in to your Microsoft account → authorize `rclone`.

When finished, you can test:

```bash
rclone lsd onedrive:
```

---

### 🗂️ Sync or Mount Commands

**Sync local folder → OneDrive:**

```bash
rclone sync ~/Documents onedrive:Documents --progress
```

**Mount OneDrive as local folder (via FUSE):**

```bash
mkdir ~/OneDrive
rclone mount onedrive: ~/OneDrive --vfs-cache-mode full &
```

Unmount:

```bash
fusermount -u ~/OneDrive
```

---

## ⚙️ 3. Option 2 — Using Native Linux Client (`onedrive` by abraunegg)

This client is written in **D** language and supports:

* Background sync (systemd)
* Differential uploads
* Multiple account support

### 🔧 Install

```bash
sudo apt install onedrive
# Or latest release:
sudo add-apt-repository ppa:yann1ck/onedrive
sudo apt update
sudo apt install onedrive
```

### 🔐 Authenticate

```bash
onedrive
```

You’ll get a link → open it in your browser → login → paste the response URL.

### 🌀 Sync Files

```bash
onedrive --synchronize
```

### ⚙️ Continuous Sync (Daemon)

```bash
onedrive --monitor
```

---

## 🧠 4. Option 3 — Direct API Access (Microsoft Graph)

If you want **low-level control** (like building tools or integrating into a script), you can directly call the **Microsoft Graph API**.

### Authentication

1. Register an app in **Azure Portal** → “App registrations”.
2. Add API permissions:

   * `Files.ReadWrite`, `offline_access`, `User.Read`
3. Get `client_id`, `client_secret`, `tenant_id`.

### Obtain OAuth2 Token

```bash
curl -X POST https://login.microsoftonline.com/<tenant_id>/oauth2/v2.0/token \
  -d "client_id=<client_id>" \
  -d "scope=https://graph.microsoft.com/.default offline_access" \
  -d "client_secret=<client_secret>" \
  -d "grant_type=client_credentials"
```

### List OneDrive Files

```bash
curl -H "Authorization: Bearer <access_token>" \
     https://graph.microsoft.com/v1.0/me/drive/root/children
```

### Upload a File

```bash
curl -X PUT -H "Authorization: Bearer <access_token>" \
     -H "Content-Type: text/plain" \
     --data-binary @localfile.txt \
     https://graph.microsoft.com/v1.0/me/drive/root:/Documents/localfile.txt:/content
```

---

## 🧩 5. Under the Hood — Protocol & Code Path

**rclone** and **onedrive (abraunegg)** both use **Microsoft Graph REST API** underneath:

* Auth flow: OAuth2 Authorization Code → Refresh token → Access token
* Endpoints: `https://graph.microsoft.com/v1.0/me/drive/*`
* Transport: HTTPS + JSON over HTTP 1.1
* Files transmitted as multipart or PUT binary streams.

Example (from `rclone/backend/onedrive/onedrive.go`):

```go
// upload small file
url := fmt.Sprintf("%s/root:/%s:/content", apiURL, path)
resp, err := httpClient.Put(url, body)
```

From `onedrive/src/onedrive.d`:

```d
auto request = new HTTPRequest("PUT", endpoint ~ "/content");
request.setRequestHeader("Authorization", "Bearer " ~ accessToken);
request.send(fileData);
```

So fundamentally both tools are just **wrappers over Microsoft Graph**, automating token refresh, delta queries (`/delta` endpoint for change tracking), and FUSE mounting.

---

## 🧩 6. Verify Connectivity

To verify your OneDrive mount or sync:

```bash
rclone about onedrive:
rclone ls onedrive:
```

Check network logs:

```bash
sudo lsof -i | grep rclone
```

If mounted via FUSE:

```bash
mount | grep OneDrive
```

---

## 🧠 Summary

| Goal                             | Recommended Method   |
| -------------------------------- | -------------------- |
| Mount OneDrive like a local disk | `rclone mount`       |
| Auto-sync in background          | `onedrive --monitor` |
| Programmatic access              | Microsoft Graph API  |
| Lightweight CLI access           | `rclone`             |

---
