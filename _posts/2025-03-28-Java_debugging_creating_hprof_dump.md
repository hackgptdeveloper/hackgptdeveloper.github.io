---
title: "HPROF dump file"
tags:
  - HPROF dump file
---

### Creating a Java HPROF Dump

An HPROF (Heap Profiler) dump is a snapshot of a Java application's heap memory, which is useful for diagnosing memory leaks, analyzing memory usage, and debugging performance issues.

There are several ways to generate an HPROF dump in Java:

---

## **1. Using `jmap` Command-Line Tool**
`jmap` is a JDK tool that allows you to obtain heap dumps of a running Java process.

### **Steps:**
1. Find the process ID (PID) of the Java application:
   ```sh
   jps
   ```
   Example output:
   ```
   12345 MyJavaApplication
   ```
   
2. Generate the heap dump using `jmap`:
   ```sh
   jmap -dump:format=b,file=heapdump.hprof 12345
   ```
   - `format=b` → Binary format
   - `file=heapdump.hprof` → Output file
   - `12345` → Java process ID

**Example:**
```sh
jmap -dump:format=b,file=heap.hprof 9876
```

**Location:** The dump file (`heap.hprof`) will be created in the working directory.

---

## **2. Using `jcmd` Command**
`jcmd` is a more advanced alternative to `jmap`.

### **Steps:**
1. Find the Java process ID:
   ```sh
   jps
   ```
   
2. Run the following command:
   ```sh
   jcmd <PID> GC.heap_dump heapdump.hprof
   ```
   Example:
   ```sh
   jcmd 9876 GC.heap_dump heapdump.hprof
   ```

**Advantages of `jcmd`:**
- Works on newer Java versions (`jmap` might not work on some JVM versions)
- Safer than `jmap` for heap dumps

---

## **3. Using JVM Startup Options (`-XX:+HeapDumpOnOutOfMemoryError`)**
If you want an automatic heap dump when an `OutOfMemoryError` occurs:

1. Start your Java application with:
   ```sh
   java -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/path/to/dump MyJavaApplication
   ```
   - `-XX:+HeapDumpOnOutOfMemoryError` → Generates a heap dump when an OOM error happens.
   - `-XX:HeapDumpPath=/path/to/dump` → Specifies the dump file path.

---

## **4. Programmatically Trigger Heap Dump in Java**
If you want to trigger an HPROF dump from inside a Java program, you can use:

### **Using `com.sun.management.HotSpotDiagnostic`**
```java
import com.sun.management.HotSpotDiagnostic;
import java.lang.management.ManagementFactory;
import java.io.IOException;

public class HeapDumpGenerator {
    public static void dumpHeap(String filePath, boolean live) throws IOException {
        HotSpotDiagnostic mxBean = ManagementFactory.getPlatformMXBean(HotSpotDiagnostic.class);
        mxBean.dumpHeap(filePath, live);
    }

    public static void main(String[] args) {
        try {
            dumpHeap("heapdump.hprof", true);
            System.out.println("Heap dump created.");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```
- `dumpHeap("heapdump.hprof", true);` → Dumps only live objects (`true`) or the full heap (`false`).

---

## **5. Using `kill -3` (For UNIX/Linux)**
- Send a `SIGQUIT` (`kill -3`) signal to the Java process:
  ```sh
  kill -3 <PID>
  ```
- This prints a heap dump into the Java application's standard output (e.g., `catalina.out` for Tomcat).

---

## **Where is the HPROF Dump Stored?**
- By default, the `.hprof` file is stored in the Java application's working directory unless a specific path is given.
- If using `HeapDumpOnOutOfMemoryError`, it will be stored in the same directory as the running Java process unless `-XX:HeapDumpPath=<path>` is set.

---

## **How to Analyze an HPROF File?**
Once you have the `heapdump.hprof` file, you can analyze it using:
- **Eclipse Memory Analyzer (MAT)**:  
  ```sh
  mat heapdump.hprof
  ```
- **VisualVM**:  
  Open VisualVM (`jvisualvm`), load the `.hprof` file and inspect the heap.
- **JProfiler** (Commercial)

---

### **Comparison of Methods**
| Method | Requires PID | Triggers Heap Dump | Notes |
|--------|-------------|-------------------|-------|
| `jmap` | ✅ | ✅ | May not work in newer Java versions |
| `jcmd` | ✅ | ✅ | Preferred for Java 8+ |
| `-XX:+HeapDumpOnOutOfMemoryError` | ❌ | Auto | Dumps on OOM automatically |
| `kill -3` | ✅ | ❌ | Outputs heap info to logs |
| Java Code | ❌ | ✅ | Can be triggered programmatically |

---

## **Conclusion**
- If you're debugging **a running process**, use `jcmd <PID> GC.heap_dump`.
- If you want a **dump on OOM**, use `-XX:+HeapDumpOnOutOfMemoryError`.
- If you need to **programmatically generate a heap dump**, use the `HotSpotDiagnostic` API.
- If `jmap` fails, try `jcmd`, which is more reliable on newer Java versions.

Would you like help analyzing an HPROF file? 🚀
