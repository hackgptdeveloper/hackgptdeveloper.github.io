---
title: "Tools for **deobfuscating**, **decoding**, or **decrypting** JavaScript'
tags:
  - Javascript
---

Here’s a list of tools and websites commonly used for **deobfuscating**, **decoding**, or **decrypting** JavaScript. These tools serve various purposes, including simplifying obfuscated code, reversing encoded strings, or analyzing minified JavaScript.

---

### 1. **Beautification and Deobfuscation Tools**
These tools help format and deobfuscate JavaScript.

1. **[JSBeautifier](https://beautifier.io/)**  
   Beautifies and reformats obfuscated JavaScript code for better readability.
2. **[Prettier](https://prettier.io/playground/)**  
   A modern code formatter for JavaScript and other languages.
3. **[Unminify](https://unminify.com/)**  
   Simplifies minified JavaScript by expanding it to readable form.
4. **[Online JavaScript Beautifier](https://beautifytools.com/javascript-beautifier.php)**  
   Provides options for beautification and indentation customization.
5. **[Javascript Minifier](https://javascript-minifier.com/)**  
   Offers unminifying capabilities in addition to minification.

---

### 2. **String Decoding Tools**
These tools help decode Base64, hex, or other encoded strings within JavaScript.

6. **[CyberChef](https://gchq.github.io/CyberChef/)**  
   A versatile tool for encoding, decoding, and deobfuscating strings.
7. **[DecodeBase64](https://www.base64decode.org/)**  
   Decodes Base64-encoded strings.
8. **[Dencode](https://dencode.com/)**  
   Decodes and encodes strings in various formats like Base64 and URL encoding.
9. **[Web Toolkit Online Decoder](https://www.webtoolkitonline.com/)**  
   Features tools for Base64, URL, and HTML decoding.
10. **[Hex Decoder](https://www.rapidtables.com/convert/number/hex-to-ascii.html)**  
    Converts hex-encoded JavaScript to ASCII text.

---

### 3. **Static Analysis Tools**
Useful for reverse engineering and debugging.

11. **[AST Explorer](https://astexplorer.net/)**  
    Analyzes and visualizes JavaScript's Abstract Syntax Tree (AST).
12. **[JStillery](https://github.com/qsniyg/jstillery)**  
    An open-source JavaScript deobfuscation tool for static analysis.
13. **[JsNice](http://www.jsnice.org/)**  
    Enhances code readability and renames variables to meaningful names.
14. **[Esprima](https://esprima.org/)**  
    A JavaScript parsing library and online tool for AST generation.
15. **[Octopus](https://github.com/jalangi/ot) (Open Threat)**  
    A tool for analyzing JavaScript behavior and deobfuscation.

---

### 4. **Dynamic Analysis Tools**
These tools execute and analyze JavaScript in runtime.

16. **[Chrome Developer Tools](https://developer.chrome.com/docs/devtools/)**  
    Debugs and deobfuscates JavaScript by stepping through execution.
17. **[Firefox Developer Tools](https://firefox-source-docs.mozilla.org/devtools/)**  
    Similar to Chrome’s tools for dynamic JavaScript debugging.
18. **[JSDebugger](https://debugger.io/)**  
    A cloud-based JavaScript debugging platform.
19. **[Node.js Inspector](https://nodejs.org/api/debugger.html)**  
    Debugs server-side JavaScript with Node.js.
20. **[Replay.io](https://replay.io/)**  
    A browser debugging tool that records JavaScript execution for analysis.

---

### 5. **Malware-Specific JavaScript Analysis Tools**
These tools are tailored for malicious or suspicious JavaScript.

21. **[Malzilla](http://malzilla.sourceforge.net/)**  
    A tool for analyzing and decoding obfuscated malicious scripts.
22. **[Any.run](https://any.run/)**  
    A dynamic sandbox for executing suspicious JavaScript.
23. **[Hybrid Analysis](https://www.hybrid-analysis.com/)**  
    Provides insights into JavaScript behavior and indicators of compromise (IoC).
24. **[VirusTotal](https://www.virustotal.com/)**  
    Detects malicious JavaScript using various antivirus engines.
25. **[JS Detangler](https://github.com/benharri/js-detangler)**  
    A tool to analyze and untangle suspicious JavaScript files.

---

### 6. **Obfuscation-Specific Reversal Tools**
Dedicated to undoing popular JavaScript obfuscation techniques.

26. **[De4JS](https://lelinhtinh.github.io/de4js/)**  
    Decrypts common JavaScript obfuscation methods (e.g., eval, Array obfuscation).
27. **[Unpacker for Packer](http://packer.unpacker.me/)**  
    Unpacks JavaScript obfuscated with Dean Edwards’ packer.
28. **[Obfuscator.io Decoder](https://obfuscator.io/)**  
    Deobfuscates scripts generated with popular JavaScript obfuscators.
29. **[JScrambler Analysis Tool](https://www.jscrambler.com/)**  
    Analyzes and helps reverse JScrambler-obfuscated JavaScript.
30. **[Fox-Dec](https://github.com/fox-it/fox-dec)**  
    Decrypts obfuscated scripts found in malware.

---

### Other Notes
- **Custom Scripts:** Writing custom scripts using libraries like [Acorn](https://github.com/acornjs/acorn) or [UglifyJS](https://github.com/mishoo/UglifyJS) can help with specific obfuscation cases.
- **Manual Debugging:** Advanced users often rely on manual analysis combined with the above tools for the most challenging cases.
