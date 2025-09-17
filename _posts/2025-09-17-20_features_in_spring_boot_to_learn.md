---
title: "20 important features of Spring Boot"
tags:
  - Java
  - SpringBoot
---

Here’s a list of **20 new or important things you should know in Spring Boot today (2025)** — ranging from features in recent releases, advanced patterns, integrations, and under-the-hood mechanisms:

---

### 1. **Spring Boot 3.x and Jakarta EE Migration**

* Since Spring Boot 3, the entire codebase migrated from `javax.*` to `jakarta.*` packages.
* This means libraries must be compatible with Jakarta EE 9+.

---

### 2. **Virtual Threads (Project Loom) Support**

* Spring Boot 3.2+ adds **virtual thread support** in Tomcat, Jetty, Undertow, and WebFlux.
* Configure via `spring.threads.virtual.enabled=true`.

---

### 3. **Ahead-of-Time (AOT) Processing**

* Introduced for **native images with GraalVM**.
* Spring Boot AOT engine optimizes configuration and bean creation at build-time to reduce startup time.

---

### 4. **Observability with Micrometer + OpenTelemetry**

* Micrometer 2.x integrates directly with OpenTelemetry.
* Unified APIs for metrics, logs, and tracing: `spring.observability.enabled=true`.

---

### 5. **Spring Boot Docker Image Building (Buildpacks)**

* `./mvnw spring-boot:build-image` or Gradle plugin builds OCI images without a Dockerfile.
* Uses **Paketo buildpacks** with layered JAR optimizations.

---

### 6. **HTTP Interface Clients**

* Declarative HTTP clients (`@HttpExchange`) introduced in Spring 6.
* Example:

  ```java
  @HttpExchange("/users")
  interface UserClient {
      @GetExchange("/{id}") User getUser(@PathVariable int id);
  }
  ```

---

### 7. **Problem Details (RFC 7807) Error Handling**

* Spring Boot 3.1+ automatically produces **problem+json** responses for errors.
* Unified format for REST API error responses.

---

### 8. **Configuration Properties Scanning**

* Instead of `@EnableConfigurationProperties`, Spring Boot now detects `@ConfigurationProperties` beans automatically when annotated with `@ConstructorBinding`.

---

### 9. **Testcontainers Auto-Configuration**

* Native Testcontainers support in Spring Boot 3.1+.
* Add dependency, and `@ServiceConnection` wires DB, Kafka, Redis automatically for integration tests.

---

### 10. **Declarative Retry & Resilience**

* Spring Retry and Resilience4j integrate more tightly.
* Use annotations like `@Retryable`, `@CircuitBreaker` without heavy boilerplate.

---

### 11. **`spring-modulith` Integration**

* Helps enforce **modular architecture** within monolithic Spring Boot apps.
* Automatically documents module boundaries, dependencies, and runtime events.

---

### 12. **Spring GraphQL**

* Now a first-class citizen (separate project).
* Works with WebFlux and MVC with DataLoader and subscriptions support.

---

### 13. **Native Query Support in Spring Data**

* Spring Data 3.x allows **projections** and **DTO mapping** directly in repository queries.
* Also adds `Querydsl` 5.x support.

---

### 14. **Kubernetes and Cloud-Native Configuration**

* Spring Boot integrates with **Spring Cloud Kubernetes** for ConfigMaps, Secrets, and Service discovery.
* Health probes auto-configured for liveness/readiness endpoints.

---

### 15. **Spring Boot Actuator Enhancements**

* New endpoints: `/actuator/startup` (startup steps), `/actuator/configprops` improvements.
* Micrometer tags allow per-request metrics with low overhead.

---

### 16. **CRaC (Coordinated Restore at Checkpoint) Support**

* Spring Boot apps can checkpoint JVM state and restore instantly (useful for serverless).
* Experimental but promising for ultra-fast cold starts.

---

### 17. **Functional Bean Registration**

* Beans can be registered programmatically with `GenericApplicationContext.registerBean`.
* Useful for frameworks and DSLs built on Spring.

---

### 18. **Context Lifecycle Events**

* New `ApplicationStartup` API for granular **startup timing metrics**.
* Replaces custom `ApplicationListener` hacks for startup profiling.

---

### 19. **Native Image Security**

* Security auto-config for **Spring Security** works in GraalVM native builds.
* Classpath scanning replaced by **hints** for runtime reflection.

---

### 20. **RSocket Support in Spring Boot**

* Integrated with Micrometer tracing.
* Supports request-stream, request-channel, and backpressure directly with controllers.

---

⚡ These 20 items cover **new features, best practices, integrations, and architecture shifts** in Spring Boot up to 2025.
