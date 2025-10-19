---
title: "Setting up Kali linux to connect to OneDrive"
tags:
  - OneDrive
---

Let’s go step-by-step from the **system setup** to the **protocol-level details**, showing both **CLI sync** and **programmatic access**.

---

# 🧩 1. Environment Context

* **OS**: Kali Linux (Debian-based)
* **Kernel**: Linux 6.x+
* **Goal**: Connect, list, and optionally sync OneDrive (Microsoft 365 / personal)
* **Access methods available**:

  1. 🧱 `rclone` — easiest and most reliable CLI mount/sync.
  2. ⚙️ `onedrive` (abraunegg) — native sync daemon in D language.
  3. 🧠 Direct API (Microsoft Graph) — custom automation or pentesting use.

---

# ⚙️ 2. Option 1 — Using `rclone` (recommended)

`rclone` is the cleanest option for Kali because:

* Works in CLI (no GUI dependencies).
* Mounts or syncs data using FUSE.
* Uses Microsoft Graph API for authentication and data access.

---

### 🧰 Step 1: Install Dependencies

```bash
sudo apt update
sudo apt install rclone fuse -y
```

### 🔧 Step 2: Configure OneDrive

Run the interactive config:

```bash
rclone config
```

Then follow these steps:

```
n) New remote
name> onedrive
storage> onedrive
client_id> (press Enter)
client_secret> (press Enter)
region> global
edit advanced config? n
use auto config? y
```

A browser window will open — login to your Microsoft account and allow access.
After authentication, `rclone` stores the refresh/access tokens at:

```
~/.config/rclone/rclone.conf
```

Example config snippet:

```ini
[onedrive]
type = onedrive
token = {"access_token":"<...>","expiry":"2025-10-19T21:00:00Z"}
drive_id = b!AbCdEf1234xyz
drive_type = personal
```

---

### 🧪 Step 3: Test Connection

```bash
rclone lsd onedrive:
```

Expected output:

```
          -1 2025-10-19  Documents
          -1 2025-10-19  Pictures
          -1 2025-10-19  Music
```

---

### 🌀 Step 4: Sync or Mount

**Sync example:**

```bash
rclone sync ~/Downloads onedrive:Backup --progress
```

**Mount example:**

```bash
mkdir -p ~/OneDrive
rclone mount onedrive: ~/OneDrive --vfs-cache-mode full &
```

To unmount:

```bash
fusermount -u ~/OneDrive
```

---

### 🧰 Step 5: Optional – Add to systemd for persistent mount

Create file `/etc/systemd/system/onedrive.service`:

```ini
[Unit]
Description=Mount OneDrive via rclone
After=network-online.target

[Service]
ExecStart=/usr/bin/rclone mount onedrive: /home/<user>/OneDrive --vfs-cache-mode full
Restart=always
User=<user>
Group=<user>

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable onedrive
sudo systemctl start onedrive
```

---

# ⚙️ 3. Option 2 — Using Native OneDrive Client (`onedrive` by abraunegg)

This client offers native synchronization (no mount). It’s also available in Kali repositories.

### 🧰 Step 1: Install

```bash
sudo apt install onedrive -y
```

### 🔐 Step 2: Authorize

Run:

```bash
onedrive
```

You’ll get a URL:

```
Authorize this app visiting:
https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=...
```

Open it in your browser, sign in, and paste back the final redirected URL.

### 🌀 Step 3: Sync

```bash
onedrive --synchronize
```

### ⚙️ Step 4: Continuous Sync (Daemon)

```bash
onedrive --monitor
```

To make it persistent:

```bash
systemctl --user enable onedrive
systemctl --user start onedrive
```

### 🔍 Config file

Stored at:

```
~/.config/onedrive/config
```

Example:

```ini
sync_dir = "~/OneDrive"
skip_dir = "node_modules|tmp"
```

---

# 🧠 4. Option 3 — Microsoft Graph API (Low-level)

If you want to connect programmatically or perform manual API testing (for example, in a pentest or forensic tool), use **Microsoft Graph API**.

### 🔧 Step 1: Register App in Azure Portal

Go to [https://portal.azure.com](https://portal.azure.com) → Azure Active Directory → App registrations → **New registration**

Set:

* Redirect URI: `http://localhost`
* Permissions: `Files.ReadWrite`, `User.Read`, `offline_access`

Then note:

* `client_id`
* `tenant_id`
* `client_secret`

---

### 🔐 Step 2: Get Access Token (OAuth2)

```bash
curl -X POST https://login.microsoftonline.com/<tenant_id>/oauth2/v2.0/token \
  -d "client_id=<client_id>" \
  -d "scope=https://graph.microsoft.com/.default offline_access" \
  -d "client_secret=<client_secret>" \
  -d "grant_type=client_credentials"
```

You’ll receive:

```json
{
  "token_type": "Bearer",
  "expires_in": 3599,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOi..."
}
```

---

### 🧾 Step 3: List Files

```bash
curl -H "Authorization: Bearer <access_token>" \
     https://graph.microsoft.com/v1.0/me/drive/root/children
```

### 📤 Step 4: Upload File

```bash
curl -X PUT -H "Authorization: Bearer <access_token>" \
     -H "Content-Type: text/plain" \
     --data-binary @/etc/hosts \
     https://graph.microsoft.com/v1.0/me/drive/root:/hosts:/content
```

---

# 🧩 5. Behind the Scenes — Technical Flow

Both `rclone` and `onedrive` (abraunegg) communicate using **Microsoft Graph REST API**:

```
https://graph.microsoft.com/v1.0/me/drive/*
```

Typical flow:

| Step | Action                             | API Endpoint                                                 |
| ---- | ---------------------------------- | ------------------------------------------------------------ |
| 1    | OAuth2 Authorization Code exchange | `https://login.microsoftonline.com/common/oauth2/v2.0/token` |
| 2    | Refresh Token                      | same endpoint, `grant_type=refresh_token`                    |
| 3    | Query drive info                   | `/me/drive`                                                  |
| 4    | List directory                     | `/me/drive/root/children`                                    |
| 5    | Upload file                        | `/me/drive/root:/path:/content`                              |
| 6    | Track deltas                       | `/me/drive/root/delta`                                       |

**HTTP transport:** HTTPS/1.1 JSON
**Auth header:** `Authorization: Bearer <token>`
**rclone source (simplified)**:

```go
url := "https://graph.microsoft.com/v1.0/me/drive/root:/path:/content"
req, _ := http.NewRequest("PUT", url, bytes.NewReader(data))
req.Header.Set("Authorization", "Bearer "+token)
client.Do(req)
```

---

# ✅ 6. Verify Integration

```bash
rclone about onedrive:
rclone ls onedrive:
```

Check tokens:

```bash
cat ~/.config/rclone/rclone.conf
```

Check mount:

```bash
mount | grep OneDrive
```

---

# 🧠 Summary Table

| Goal                                | Recommended Tool         | Notes                 |
| ----------------------------------- | ------------------------ | --------------------- |
| Simple CLI sync                     | `onedrive --synchronize` | Native client         |
| Mount as local drive                | `rclone mount onedrive:` | FUSE mount            |
| Automate / Script                   | Microsoft Graph API      | Full control          |
| Penetration Testing / API debugging | Graph API with `curl`    | Raw HTTP-level access |

---
