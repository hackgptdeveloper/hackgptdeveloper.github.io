---
title: "20 examples of using `gobuster` for directory traversal and discovery"
tags:
  - Gobuster
---

Below are 20 examples of using `gobuster` for directory traversal and discovery. These examples cover different scenarios, including custom wordlists, extensions, and output formatting.

### Basic Examples
1. **Simple directory scan**
   ```bash
   gobuster dir -u http://example.com -w /path/to/wordlist.txt
   ```

2. **Directory scan with custom extensions**
   ```bash
   gobuster dir -u http://example.com -w /path/to/wordlist.txt -x php,html,js
   ```

3. **Recursive directory scan**
   ```bash
   gobuster dir -u http://example.com -w /path/to/wordlist.txt -r
   ```

4. **Ignoring length-based results**
   ```bash
   gobuster dir -u http://example.com -w /path/to/wordlist.txt --exclude-length 0
   ```

5. **Directory scan using a proxy**
   ```bash
   gobuster dir -u http://example.com -w /path/to/wordlist.txt --proxy http://127.0.0.1:8080
   ```

### Advanced Examples
6. **HTTPS with insecure certificate**
   ```bash
   gobuster dir -u https://example.com -w /path/to/wordlist.txt -k
   ```

7. **Custom User-Agent**
   ```bash
   gobuster dir -u http://example.com -w /path/to/wordlist.txt -a "MyCustomAgent/1.0"
   ```

8. **Custom HTTP headers**
   ```bash
   gobuster dir -u http://example.com -w /path/to/wordlist.txt -H "Authorization: Bearer TOKEN"
   ```

9. **Concurrent threads**
   ```bash
   gobuster dir -u http://example.com -w /path/to/wordlist.txt -t 50
   ```

10. **Timeout adjustments**
    ```bash
    gobuster dir -u http://example.com -w /path/to/wordlist.txt --timeout 10s
    ```

### Output Handling
11. **Save output to a file**
    ```bash
    gobuster dir -u http://example.com -w /path/to/wordlist.txt -o results.txt
    ```

12. **Verbose output**
    ```bash
    gobuster dir -u http://example.com -w /path/to/wordlist.txt -v
    ```

13. **JSON formatted output**
    ```bash
    gobuster dir -u http://example.com -w /path/to/wordlist.txt -o results.json -z
    ```

14. **Filtering status codes**
    ```bash
    gobuster dir -u http://example.com -w /path/to/wordlist.txt -s "200,204,301"
    ```

15. **Custom DNS resolver**
    ```bash
    gobuster dir -u http://example.com -w /path/to/wordlist.txt --dns-resolver 1.1.1.1
    ```

### Specialized Scans
16. **Scan specific ports**
    ```bash
    gobuster dir -u http://example.com:8080 -w /path/to/wordlist.txt
    ```

17. **Use environment variables for authentication**
    ```bash
    gobuster dir -u http://example.com -w /path/to/wordlist.txt --username $USERNAME --password $PASSWORD
    ```

18. **Rate limiting requests**
    ```bash
    gobuster dir -u http://example.com -w /path/to/wordlist.txt --rate-limit 2
    ```

19. **Scanning a subdirectory**
    ```bash
    gobuster dir -u http://example.com/admin -w /path/to/wordlist.txt
    ```

20. **Using a brute-force strategy**
    ```bash
    gobuster dir -u http://example.com -w /path/to/large-wordlist.txt --wildcard
    ```

