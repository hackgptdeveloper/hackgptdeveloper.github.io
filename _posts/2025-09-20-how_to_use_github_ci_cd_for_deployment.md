---
title: "Github CI/CD how to: deployment to Digitalocean"
tags:
  - github action
  - CI/CD
---

Got it 🚀 — let’s walk through **end-to-end deployment of a GitHub application (say a Node.js app)** to **DigitalOcean** using **GitHub Actions + CI/CD**.
I’ll show you **the YAML workflow**, **DigitalOcean setup**, and the exact configuration files you’ll need.

---

# 1. Prerequisites

1. **DigitalOcean Droplet or App Platform**

   * Droplet = VM (SSH deploy).
   * App Platform = PaaS (GitHub integration or API deploy).
   * Here I’ll show **Droplet deployment** (SSH + Docker) and **App Platform** variant.

2. **Secrets in GitHub repo** (Settings → Secrets and Variables → Actions):

   * `DO_API_TOKEN` → DigitalOcean Personal Access Token
   * `DO_SSH_KEY` → private SSH key (if deploying to Droplet via SSH)
   * `DO_SSH_HOST` → Droplet IP (e.g., `157.230.x.x`)
   * `DO_SSH_USER` → usually `root` or a created user

3. **Dockerfile** in your repo (for container build).

Example `Dockerfile`:

```dockerfile
FROM node:20-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .

EXPOSE 3000
CMD ["npm", "start"]
```

---

# 2. GitHub Action Workflow (CI/CD)

Create: `.github/workflows/deploy.yml`

```yaml
name: CI/CD to DigitalOcean

on:
  push:
    branches:
      - main   # deploys when main branch is updated

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      # 1. Checkout code
      - name: Checkout repository
        uses: actions/checkout@v3

      # 2. Set up Docker
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      # 3. Log in to DigitalOcean Container Registry (if using DOCR)
      - name: Login to DO Container Registry
        uses: docker/login-action@v2
        with:
          registry: registry.digitalocean.com
          username: do
          password: ${{ secrets.DO_API_TOKEN }}

      # 4. Build & Push Docker Image
      - name: Build and Push Docker image
        run: |
          IMAGE=registry.digitalocean.com/my-registry/myapp:$(date +%s)
          echo "IMAGE=$IMAGE" >> $GITHUB_ENV
          docker build -t $IMAGE .
          docker push $IMAGE

      # 5. Deploy to Droplet via SSH
      - name: Deploy via SSH
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.DO_SSH_HOST }}
          username: ${{ secrets.DO_SSH_USER }}
          key: ${{ secrets.DO_SSH_KEY }}
          script: |
            docker pull $IMAGE
            docker stop myapp || true
            docker rm myapp || true
            docker run -d -p 80:3000 --name myapp $IMAGE
```

---

# 3. App Platform Alternative (simpler)

If you prefer **DigitalOcean App Platform** (PaaS, no Droplet maintenance):

* Create `spec.yaml` in root:

```yaml
name: myapp
services:
- name: web
  github:
    branch: main
    repo: your-username/your-repo
    deploy_on_push: true
  run_command: "npm start"
  build_command: "npm install"
  environment_slug: node-js
  http_port: 3000
  instance_size_slug: basic-xxs
  instance_count: 1
```

* Then create a GitHub Action to trigger redeploy via API:

```yaml
jobs:
  deploy-app-platform:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger DigitalOcean App Platform Deployment
        run: |
          curl -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer ${{ secrets.DO_API_TOKEN }}" \
            "https://api.digitalocean.com/v2/apps/<APP_ID>/deployments"
```

Replace `<APP_ID>` with your App Platform ID.

---

# 4. CI/CD Flow Explained

1. **Commit → Push to GitHub `main` branch**
   → GitHub Action starts.

2. **Docker Build & Push**
   → Image pushed to DigitalOcean Container Registry.

3. **SSH Deployment** (Droplet)
   → Pulls the image, restarts container.

4. **App Platform (if used)**
   → API call redeploys new code automatically.

---

# 5. Security Notes

* Use `DO_SSH_KEY` with least privilege user (not `root` ideally).
* Use GitHub Environments for staging/prod separation.
* Consider **monitoring** with DigitalOcean’s metrics + GitHub Action notifications.

---
