---
title: "Internal architecture of n8n running on Macbook via docker"
tags:
  - n8n
---

Got it — let’s break this down all the way from **n8n’s architecture** → **Docker internals** → **how it maps onto a MacBook Air running macOS**.

---

## 1. **What is n8n?**

* **n8n** (Node-based Workflow Automation) is a **Node.js application** that orchestrates workflows.
* Core pieces:

  * **Workflow Engine** → interprets JSON workflow definitions.
  * **Nodes** → JS/TS modules that interact with APIs, databases, OS commands, etc.
  * **Database Layer** → stores workflow definitions, execution history, credentials. Default is SQLite, but PostgreSQL/MySQL can be configured.
  * **REST/GraphQL API** → backend API serving workflow CRUD, executions.
  * **Frontend (Vue.js)** → single-page application (SPA) served by the backend.
  * **Queue System** → optional Redis-based execution scaling.

---

## 2. **n8n Inside Docker**

When you run `docker run n8nio/n8n`:

* **Container Runtime**:
  Docker creates a container with:

  * Base image (Debian/Alpine Linux).
  * Installed Node.js + `n8n` npm package.
  * Entrypoint script → runs `n8n start`.

* **Process Tree** inside container:

  ```
  PID 1: tini (init process for signal handling)
   └── node /usr/local/bin/n8n start
         ├── Express.js server (REST + frontend)
         ├── Workflow execution workers (child processes if queue mode enabled)
         └── DB connections (SQLite/Postgres/MySQL)
  ```

* **Storage**:

  * `/home/node/.n8n` → default config + SQLite DB.
  * Mounted volumes → persist workflow data across container restarts.

* **Networking**:

  * n8n listens on `0.0.0.0:5678`.
  * Docker maps container port `5678` → host port (`5678` by default, or user-defined).
  * On Mac, this is actually going through Docker Desktop’s VM networking (explained below).

---

## 3. **Docker on macOS (MacBook Air)**

Docker **does not run natively on macOS** (since macOS uses the XNU kernel, not Linux). Instead:

* **Docker Desktop for Mac** runs a **lightweight Linux VM** (via **Apple Hypervisor.framework** or previously **HyperKit/Hypervisor.framework**).

  * On Intel → HyperKit/Hypervisor.
  * On M1/M2 → uses Apple Virtualization framework + QEMU emulation for non-ARM images.

* **Container Execution Flow**:

  ```
  macOS (Darwin kernel)
     └── Docker Desktop app
           └── LinuxKit VM (tiny Linux distro)
                 └── containerd / runc (OCI runtime)
                       └── n8n container (Node.js process)
  ```

* **Filesystem**:

  * Your macOS folder (e.g. `~/n8n-data`) is mounted into the Linux VM via **gRPC-FUSE** or **virtiofs**.
  * Inside the container, it shows up as a normal bind mount.

* **Networking**:

  * n8n listens on `0.0.0.0:5678` inside the Linux container.
  * The LinuxKit VM provides a **bridge network**.
  * Docker Desktop maps host `localhost:5678` → VM → container.
  * So when you hit `http://localhost:5678` on macOS, traffic flows:

    ```
    Safari/Chrome (macOS) 
        → macOS networking stack 
            → Docker Desktop socket proxy 
                → LinuxKit VM 
                    → Docker bridge (docker0) 
                        → n8n container (port 5678)
    ```

---

## 4. **n8n Execution Inside Container**

When you trigger a workflow:

1. **Frontend (Vue.js SPA)** sends API request → Express.js backend inside container.
2. **Backend (Node.js)** loads workflow definition from DB (SQLite/Postgres).
3. **Execution**:

   * If "regular mode": workflow runs in the main process.
   * If "queue mode": task is pushed to Redis → picked up by worker process.
4. **Node Execution**:

   * Each node is just JS code (`n8n/packages/nodes-base`).
   * Uses Axios/HTTP, DB drivers, or child processes.
5. **Result**:

   * Execution log written to DB.
   * Response returned to frontend via API.

---

## 5. **Resource Interaction on a MacBook Air**

* **CPU**: n8n runs Node.js event loop on VM CPU threads. On M1/M2 MacBook Air → native ARM64 Node.js container images are faster. If using x86\_64-only image → QEMU emulates it (slower).
* **Memory**: Docker Desktop reserves RAM for the Linux VM. n8n’s memory usage (workflows, caching) lives inside that.
* **Disk**: Workflows, DB, logs persist in mounted macOS folder (via FUSE → VM → container FS).
* **Limits**: Controlled via Docker Desktop settings (e.g., CPU cores, memory allocated to Linux VM).

---

✅ **Summary Architecture Diagram (MacBook Air + Docker + n8n)**

```
macOS (Darwin)
   └── Docker Desktop
         └── LinuxKit VM (Hypervisor.framework / QEMU)
               └── containerd / runc
                     └── n8n container
                           ├── Node.js runtime
                           ├── Express.js API + Vue.js frontend
                           ├── Workflow Engine
                           ├── DB (SQLite/Postgres/MySQL)
                           └── Optional Redis workers
```

---
