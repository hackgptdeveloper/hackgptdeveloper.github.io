---
title: "Jakarta revolution:  Java source given to Eclipse Foundation"
tags:
  - Java
---

Here’s a detailed write-up expanding on your request about the **Spring Boot 3.x and Jakarta EE migration**:

---

# Spring Boot 3.x and Jakarta EE Migration

### 1. Background

With the release of **Spring Boot 3.0 (November 2022)**, the Spring ecosystem aligned with **Jakarta EE 9+**, which introduced a critical namespace change:

* Old Java EE packages: `javax.*`
* New Jakarta EE packages: `jakarta.*`

This change was mandated after Oracle handed over Java EE to the Eclipse Foundation, where it became **Jakarta EE**. The goal was to detach the APIs from Oracle’s trademark and governance restrictions.

📖 Reference: [Spring Boot 3.0 Release Notes](https://spring.io/blog/2022/11/24/spring-boot-3-0-goes-ga)

---

### 2. Why This Is Important

1. **Compatibility with Future Java Versions**

   * Java EE development is frozen under `javax.*`.
   * Future improvements (e.g., CDI, Servlet API, JPA, Bean Validation) will only appear under `jakarta.*`.
   * Without migration, projects risk stagnation.

2. **Library Ecosystem Alignment**

   * All libraries using `javax.*` (Hibernate, Tomcat, Jetty, Jersey, etc.) needed updates.
   * If you depend on outdated libraries, you’ll face **NoClassDefFoundError** or **ClassNotFoundException**.

3. **Native Image / Modern Runtime Support**

   * Jakarta EE APIs are being adapted for **GraalVM native images**, cloud-native workloads, and modular runtime environments.

---

### 3. Example Code Migration

#### Before (Spring Boot 2.x with Java EE / `javax`):

```java
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.validation.constraints.NotNull;

@Entity
public class Book {
    @Id
    private Long id;

    @NotNull
    private String title;
}
```

#### After (Spring Boot 3.x with Jakarta EE / `jakarta`):

```java
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.validation.constraints.NotNull;

@Entity
public class Book {
    @Id
    private Long id;

    @NotNull
    private String title;
}
```

🔍 Only the package names changed, but this rippled across **all JPA, validation, and servlet-based code**.

---

### 4. How to Achieve Migration

1. **Upgrade Dependencies**

   * Ensure all dependencies (Spring Data JPA, Hibernate, Tomcat, etc.) are Jakarta-compatible.
   * Example: Hibernate 6.x → supports `jakarta.persistence`.

2. **Refactor Imports Automatically**

   * Tools like **OpenRewrite** can refactor `javax.*` → `jakarta.*`.
   * Gradle plugin:

     ```bash
     ./gradlew rewriteRun
     ```

3. **Adjust Third-Party Libraries**

   * Check transitive dependencies. Some libraries may still be tied to `javax`.
   * Replace with Jakarta-compatible forks or upgraded versions.

---

### 5. Problems That May Arise

1. **Dependency Mismatches**

   * Example: Old Hibernate 5.x expects `javax.persistence`, while Spring Boot 3.x provides `jakarta.persistence`.
   * This results in runtime errors.

2. **IDE / Tooling Conflicts**

   * If your IDE suggests old `javax.*` imports, compilation will break.

3. **Interop Between Old and New APIs**

   * You **cannot mix** `javax.persistence.Entity` and `jakarta.persistence.Entity` in the same app.
   * Migration often requires a **“big bang” upgrade**.

---

### 6. Applicability Across Java Ecosystem

* **Servlet Containers**:

  * Tomcat 10+, Jetty 11+, Undertow 2.3+ → all switched to `jakarta.servlet.*`.
  * Old filters and servlets using `javax.servlet` must be migrated.

* **Persistence (JPA / Hibernate)**:

  * Hibernate 6.x uses `jakarta.persistence`.
  * EclipseLink also migrated.

* **Validation**:

  * Bean Validation (`javax.validation`) → now `jakarta.validation`.

* **Security**:

  * Spring Security integrates with `jakarta.servlet` filters.

* **Jakarta Faces / CDI / EJB**:

  * Entire Jakarta EE platform (Faces, CDI, EJB, JMS, JSON-B) moved to `jakarta.*`.

* **Frameworks Beyond Spring**:

  * Quarkus, Micronaut, Payara, and WildFly are also aligned with Jakarta.

---

### 7. Strategic Implications

* Migration is a **forced modernization step**:

  * Aligns enterprise Java with **cloud-native architectures**.
  * Enables **native images, modular runtimes, and observability hooks**.
* For enterprise users with legacy `javax`-based systems, this is a **major migration project**.

---

✅ **In summary**:
Spring Boot 3.x’s Jakarta EE migration is not just a namespace change — it’s a **foundational shift** ensuring future compatibility, modern tooling, and cloud-native readiness. However, it requires **careful dependency alignment** and often **all-or-nothing migration** to avoid interoperability issues.

---
