---
title: "An **introduction** to technology of **SQLAlchemy**
tags:
  - python
  - database
---

Here’s a **deep introduction** and **low-level technology breakdown** of **SQLAlchemy**.

---

## 1. Introduction to SQLAlchemy

SQLAlchemy is the **de-facto ORM (Object Relational Mapper)** and **SQL toolkit** for Python.
It was designed to provide:

* **High-level ORM layer** → mapping Python classes to database tables.
* **Low-level Core layer** → building SQL queries programmatically using expression trees.
* **Database-agnostic abstraction** → works with PostgreSQL, MySQL, SQLite, Oracle, MSSQL, etc.
* **Performance control** → unlike “black box” ORMs, you can always drop down to raw SQL.

> In short: SQLAlchemy is not just an ORM. It’s two systems:
>
> 1. **SQLAlchemy Core** (query builder, schema metadata, engine).
> 2. **SQLAlchemy ORM** (mapper on top of Core).

---

## 2. Core Components and Low-Level Technology

### 2.1 Engine

* The **engine** is the entry point to any database.
* Internally, it wraps a **DBAPI** (Python’s PEP 249 standard).
* Example:

  ```python
  from sqlalchemy import create_engine
  engine = create_engine("postgresql+psycopg2://user:pass@localhost/db")
  ```
* Under the hood:

  * Maintains a **connection pool** (default: `QueuePool`).
  * Each connection is a wrapper around a **DBAPI connection object**.
  * Queries flow: ORM → Core → Engine → DBAPI → Socket → Database.

**Source code pointer:** [`sqlalchemy/engine/base.py`](https://github.com/sqlalchemy/sqlalchemy/blob/main/lib/sqlalchemy/engine/base.py) → `Engine` class.

---

### 2.2 MetaData and Table

* SQLAlchemy stores schema definitions in **MetaData**.
* A `Table` object maps **table name + columns + constraints**.

Example:

```python
from sqlalchemy import MetaData, Table, Column, Integer, String
metadata = MetaData()
user_table = Table(
    "users", metadata,
    Column("id", Integer, primary_key=True),
    Column("name", String),
)
```

Internally:

* A `Table` is basically a Python object wrapping SQL DDL info.
* Columns are **descriptors** containing type, constraints, defaults.
* Constraints and indexes are objects stored inside `Table._constraints`.

**Source code pointer:** [`sqlalchemy/sql/schema.py`](https://github.com/sqlalchemy/sqlalchemy/blob/main/lib/sqlalchemy/sql/schema.py) → `Table`, `Column`.

---

### 2.3 Expression Language (Core Query Builder)

* SQLAlchemy doesn’t just generate strings — it builds **expression trees**.
* Example:

  ```python
  from sqlalchemy import select
  stmt = select(user_table).where(user_table.c.name == "alice")
  print(stmt)  # SELECT users.id, users.name FROM users WHERE users.name = :name_1
  ```

How it works:

* `select()` builds a `Select` object (not a string).
* Comparisons like `user_table.c.name == "alice"` return a **BinaryExpression** node.
* SQL compilation walks the AST to produce vendor-specific SQL.

**Source code pointer:** [`sqlalchemy/sql/selectable.py`](https://github.com/sqlalchemy/sqlalchemy/blob/main/lib/sqlalchemy/sql/selectable.py) → `Select`.

---

### 2.4 ORM Mapper

* The ORM is built on top of Core.
* A **mapper** ties a Python class to a `Table`.

Example:

```python
from sqlalchemy.orm import declarative_base, sessionmaker
Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    name = Column(String)

Session = sessionmaker(bind=engine)
session = Session()
```

Internals:

* `User` → mapped via `Mapper` object.
* A **Session** is a **unit of work** manager:

  * Tracks object states (new, dirty, deleted).
  * On `session.commit()`, it builds SQL statements.
  * Executes in a transaction via the Engine.

**Source code pointer:**
[`sqlalchemy/orm/mapper.py`](https://github.com/sqlalchemy/sqlalchemy/blob/main/lib/sqlalchemy/orm/mapper.py) → `Mapper`.
[`sqlalchemy/orm/session.py`](https://github.com/sqlalchemy/sqlalchemy/blob/main/lib/sqlalchemy/orm/session.py) → `Session`.

---

### 2.5 Lazy Loading & Query Execution

* When you do:

  ```python
  user = session.query(User).filter_by(name="alice").first()
  ```
* The flow is:

  1. ORM builds a `Query` object.
  2. Query → Core expression (`SELECT ... WHERE ...`).
  3. Core compiles SQL → DBAPI cursor.
  4. Rows → ORM → populate `User` objects.
  5. Attributes not yet accessed may use **lazy loading** (new SQL per relationship).

---

### 2.6 State Machine

Every ORM-mapped object has an **InstanceState** attached:

* States: `transient` → `pending` → `persistent` → `detached`.
* Tracks dirty attributes via Python **attribute instrumentation** (monkeypatching `__setattr__`).

**Source code pointer:** [`sqlalchemy/orm/state.py`](https://github.com/sqlalchemy/sqlalchemy/blob/main/lib/sqlalchemy/orm/state.py).

---

## 3. SQLAlchemy Design Philosophy

* **Two-tier system**: Core (universal SQL) + ORM (Python classes).
* **Explicit is better than implicit**: unlike Django ORM, SQLAlchemy doesn’t hide SQL.
* **Composable AST**: every SQL statement is an object tree, not just a string.
* **Pluggable layers**: You can replace:

  * DBAPI driver (psycopg2, mysqlclient, pyodbc).
  * Pooling strategy (QueuePool, NullPool, StaticPool).
  * Dialect (PostgresDialect, MySQLDialect).

---

✅ In short:

* SQLAlchemy is a **compiler pipeline for SQL** with an optional **object mapper** on top.
* At the **lowest level**, it is a tree of `ClauseElement` objects compiled into SQL strings.
* At the **highest level**, it’s an ORM with sessions, objects, and unit-of-work management.

---

Would you like me to **draw a full flow diagram** (Engine → MetaData → Expression AST → Compiler → DBAPI → Session/Mapper → Object) so you can see the entire SQLAlchemy pipeline visually?

