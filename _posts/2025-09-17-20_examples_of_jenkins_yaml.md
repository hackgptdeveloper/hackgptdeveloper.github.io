---
title: "Jenkins in Action: 20 Real-World YAML Pipeline Examples You Can Copy Today"
tags:
  - jenkins
  - ci/cd

---

Here’s a collection of **20 commonly used Jenkins YAML pipeline (`Jenkinsfile` with declarative YAML-style syntax)** examples. Each shows a different CI/CD use case you’d find in real-world projects.

---

## 1. Basic Build & Test (Java Maven)

```yaml
pipeline:
  agent: any
  stages:
    - stage: Checkout
      steps:
        - checkout scm
    - stage: Build
      steps:
        - sh: mvn clean install
    - stage: Test
      steps:
        - sh: mvn test
```

---

## 2. Node.js Build & Test

```yaml
pipeline:
  agent: any
  stages:
    - stage: Install
      steps:
        - sh: npm install
    - stage: Test
      steps:
        - sh: npm test
```

---

## 3. Python Pytest Pipeline

```yaml
pipeline:
  agent: any
  stages:
    - stage: Setup
      steps:
        - sh: pip install -r requirements.txt
    - stage: Test
      steps:
        - sh: pytest --maxfail=1 --disable-warnings -q
```

---

## 4. Docker Build & Push

```yaml
pipeline:
  agent: any
  environment:
    DOCKER_REGISTRY: myregistry.com
  stages:
    - stage: Build Image
      steps:
        - sh: docker build -t $DOCKER_REGISTRY/app:$BUILD_NUMBER .
    - stage: Push Image
      steps:
        - sh: docker push $DOCKER_REGISTRY/app:$BUILD_NUMBER
```

---

## 5. Kubernetes Deployment

```yaml
pipeline:
  agent: any
  stages:
    - stage: Deploy
      steps:
        - sh: kubectl apply -f k8s/deployment.yaml
```

---

## 6. Spring Boot Build & JAR Artifact

```yaml
pipeline:
  agent: any
  stages:
    - stage: Build
      steps:
        - sh: ./mvnw clean package -DskipTests
    - stage: Archive
      steps:
        - archiveArtifacts: '**/target/*.jar'
```

---

## 7. Parallel Testing

```yaml
pipeline:
  agent: any
  stages:
    - stage: Parallel Tests
      parallel:
        Unit Tests:
          steps:
            - sh: mvn test -Dgroups=unit
        Integration Tests:
          steps:
            - sh: mvn verify -Dgroups=integration
```

---

## 8. Lint & Static Analysis

```yaml
pipeline:
  agent: any
  stages:
    - stage: Lint
      steps:
        - sh: eslint .
    - stage: Static Analysis
      steps:
        - sh: sonar-scanner
```

---

## 9. Multi-Branch Pipeline

```yaml
pipeline:
  agent: any
  stages:
    - stage: Branch Check
      steps:
        - sh: echo "Running on branch ${env.BRANCH_NAME}"
```

---

## 10. GitHub Webhook Trigger

```yaml
pipeline:
  agent: any
  triggers:
    - githubPush: {}
  stages:
    - stage: Build
      steps:
        - sh: mvn clean package
```

---

## 11. Slack Notification

```yaml
pipeline:
  agent: any
  stages:
    - stage: Build
      steps:
        - sh: mvn package
  post:
    success:
      - slackSend: "Build succeeded!"
    failure:
      - slackSend: "Build failed!"
```

---

## 12. Terraform Infra Deployment

```yaml
pipeline:
  agent: any
  stages:
    - stage: Init
      steps:
        - sh: terraform init
    - stage: Apply
      steps:
        - sh: terraform apply -auto-approve
```

---

## 13. Ansible Deployment

```yaml
pipeline:
  agent: any
  stages:
    - stage: Deploy
      steps:
        - sh: ansible-playbook -i inventory site.yml
```

---

## 14. Blue/Green Deployment

```yaml
pipeline:
  agent: any
  stages:
    - stage: Deploy Blue
      steps:
        - sh: kubectl apply -f k8s/blue.yaml
    - stage: Switch Traffic
      steps:
        - sh: kubectl apply -f k8s/ingress-blue.yaml
```

---

## 15. Canary Deployment

```yaml
pipeline:
  agent: any
  stages:
    - stage: Deploy Canary
      steps:
        - sh: kubectl apply -f k8s/canary.yaml
```

---

## 16. Multi-Environment Deploy

```yaml
pipeline:
  agent: any
  stages:
    - stage: Dev
      steps:
        - sh: kubectl apply -f k8s/dev.yaml
    - stage: Staging
      when:
        branch: staging
      steps:
        - sh: kubectl apply -f k8s/staging.yaml
    - stage: Prod
      when:
        branch: main
      steps:
        - sh: kubectl apply -f k8s/prod.yaml
```

---

## 17. Matrix Build (Java Versions)

```yaml
pipeline:
  agent: any
  stages:
    - stage: Build Matrix
      matrix:
        axes:
          - axis:
              name: JAVA_VERSION
              values: [8, 11, 17]
        stages:
          - stage: Build
            steps:
              - sh: "sdk use java $JAVA_VERSION && mvn clean package"
```

---

## 18. AWS S3 Upload

```yaml
pipeline:
  agent: any
  stages:
    - stage: Upload
      steps:
        - sh: aws s3 cp target/app.jar s3://mybucket/app.jar
```

---

## 19. Security Scan (Trivy)

```yaml
pipeline:
  agent: any
  stages:
    - stage: Scan
      steps:
        - sh: trivy image myregistry.com/app:$BUILD_NUMBER
```

---

## 20. End-to-End Test + Report

```yaml
pipeline:
  agent: any
  stages:
    - stage: Deploy Test Env
      steps:
        - sh: docker-compose up -d
    - stage: Run E2E Tests
      steps:
        - sh: npm run e2e
    - stage: Publish Report
      steps:
        - junit: '**/reports/*.xml'
```

---

✅ These 20 Jenkins YAML pipeline examples cover the **most common CI/CD cases**: builds, tests, artifact handling, Docker, Kubernetes, Terraform, Ansible, multi-environments, parallel jobs, and notifications.

---
