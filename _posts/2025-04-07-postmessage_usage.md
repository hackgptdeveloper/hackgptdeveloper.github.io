---
title: "postMessage() usage"
tags:
  - javascript
---

How postMessage() appears across browser context.

---

# **🔵 1. iframe → iframe Communication**

Classic one:

```javascript
iframe.contentWindow.postMessage(message, targetOrigin)
```
- Sends from parent page into iframe.
- Or from iframe up to parent (`window.parent.postMessage`).

**Spec**:  
- [HTML Living Standard - Message Ports](https://html.spec.whatwg.org/multipage/comms.html#dom-window-postmessage)

---

# **🔵 2. window → window Communication**

Opening a new window and messaging it:

```javascript
const popup = window.open('url');
popup.postMessage(message, targetOrigin);
```
- Parent → popup communication.
- Popup can send back using `window.opener.postMessage`.

---

# **🔵 3. worker.postMessage() — Web Workers**

**Background worker threads**:

```javascript
const worker = new Worker('worker.js');
worker.postMessage({ foo: 'bar' });
```

Worker receives it in `onmessage`.

**Spec**:  
- [HTML Living Standard - Workers](https://html.spec.whatwg.org/multipage/workers.html#dom-worker-postmessage)

---

# **🔵 4. SharedWorker.port.postMessage()**

Multiple tabs sharing a worker:

```javascript
const worker = new SharedWorker('shared.js');
worker.port.postMessage('hi');
```
(Uses `MessagePort` under the hood.)

---

# **🔵 5. ServiceWorker.postMessage()**

Communicating with a **Service Worker**:

```javascript
navigator.serviceWorker.controller.postMessage({ action: 'sync' });
```

**Spec**:  
- [Service Workers API - postMessage()](https://w3c.github.io/ServiceWorker/#postmessage)

---

# **🔵 6. BroadcastChannel.postMessage()**

Channel to send messages across **tabs** and **windows**:

```javascript
const channel = new BroadcastChannel('my_channel');
channel.postMessage('ping');
```

**Spec**:  
- [BroadcastChannel API](https://html.spec.whatwg.org/multipage/web-messaging.html#broadcastchannel)

---

# **🔵 7. MessagePort.postMessage()**

In **MessageChannel** or **port.postMessage** (underlying concept for transferable objects):

```javascript
const { port1, port2 } = new MessageChannel();
port1.postMessage('hello');
```

---

# **🔵 8. MediaDevices / MediaStreamTrack.postMessage (Indirectly via ports)**

WebRTC / Media capture uses `MessagePort` to control data flow internally.

---

# **🔵 9. AudioWorkletNode.port.postMessage()**

Low-level audio processing:

```javascript
audioWorkletNode.port.postMessage({ frequency: 440 });
```

Spec:
- [AudioWorklet Messaging](https://webaudio.github.io/web-audio-api/#dom-audioworkletnode-port)

---

# **🔵 10. MessageEvent (receive side of postMessage)**

Receiving `postMessage`:

```javascript
window.addEventListener('message', (event) => {
  console.log(event.data);
});
```

Related to any `postMessage` sender.

---

# **🔵 11. WebRTC DataChannel.send() (similar to postMessage)**

Not literally `.postMessage()`, but **similar semantics**:

```javascript
dataChannel.send('hello');
```
- Secure peer-to-peer messaging.

---

# **🔵 12. navigator.presentation.receiver.connectionList.connections[x].postMessage()**

Presentation API for screen sharing:

```javascript
connection.postMessage('control');
```

---

# **🔵 13. USBDevice.transferOut() (Data Transfer, postMessage pattern)**

When sending bulk data to USB devices, the conceptual model is like `postMessage` between contexts.

---

# **🔵 14. WebSocket.send() (postMessage-like)**

Again, not **named** postMessage, but **same idea**:

```javascript
socket.send('hello server');
```

Data framed and delivered asynchronously.

---

# **🔵 15. MessageChannel.postMessage() inside Service Worker to Client**

Using `clients.get()` → `postMessage` back to client tab.

```javascript
event.source.postMessage('response');
```
From Service Worker to client tab.

---

# **🔵 16. IDBDatabase.postMessage()**

Not directly, but when transferring **structured clone data** into IndexedDB transactions, the **same serialization spec** is used as `postMessage`.

---

# **🔵 17. PaymentRequest.postMessage()**

Internally, the Payment API uses structured clone/postMessage patterns between the browser and payment handlers.

---

# **🔵 18. Notification.postMessage() (future planned)**

Push API proposals for *interactive notifications* included messaging channels.

---

# **🔵 19. Worklet.postMessage()**

Custom Worklets like CSSPaint or AudioWorklet use ports under the hood.

---

# **🔵 20. WebAssembly.Module.postMessage (Transferable Object Proposals)**

WASM module can be transferred between threads via `postMessage` (experimental).

---

# **🔵 21. Trusted Types Policy Violation Reporting via postMessage**

Security policies can report violations asynchronously using postMessage patterns.

---

# **🔵 22. WebGPU (GPUBuffer.postMessage proposal)**

Future `WebGPU` APIs plan to use transferable patterns for performance.

---

# **🔵 23. WebTransport Streams**

New QUIC-based messaging uses message framing very similar to postMessage semantics.

---

# **🔵 24. Document.postMessage() (within same-origin documents)**

Rare case: messaging between frames within same document tree.

---

# **🔵 25. parent.postMessage() inside iframe**

Iframe sending back up:

```javascript
window.parent.postMessage('data', '*');
```

---

# **🔵 26. opener.postMessage() inside child window**

Popup sending back:

```javascript
window.opener.postMessage('response', '*');
```

---

# **🔵 27. window.top.postMessage()**

Grandparent window messaging from deep iframes.

---

# **🔵 28. ServiceWorkerClient.postMessage()**

When handling push notifications:

```javascript
client.postMessage('new data available');
```

---

# **🔵 29. Extensions: chrome.runtime.sendMessage (internally postMessage)**

Chrome Extensions API under the hood uses internal structured clone + postMessage:

```javascript
chrome.runtime.sendMessage({ type: 'update' });
```

→ Wrapped postMessage over extension messaging internals.

---

# **🔵 30. Declarative Shadow DOM future messaging (proposals)**

New APIs for messaging between declarative shadow roots might involve postMessage-like transfers.

---

# **📚 Full Technical Spec Source Paths**

| Context | Spec / Source |
|:---|:---|
| HTML Message Ports | https://html.spec.whatwg.org/multipage/web-messaging.html |
| Worker Threads | https://html.spec.whatwg.org/multipage/workers.html |
| Service Workers | https://w3c.github.io/ServiceWorker/ |
| Audio Worklet | https://webaudio.github.io/web-audio-api/ |
| BroadcastChannel | https://html.spec.whatwg.org/multipage/web-messaging.html#broadcasting-to-other-browsing-contexts |
| MessageChannel | https://html.spec.whatwg.org/multipage/web-messaging.html#channel-messaging |

---

# **🛠 Raw Browser Code Links (Chromium)**

- [content/browser/message_port/](https://source.chromium.org/chromium/chromium/src/+/main:content/browser/message_port/)
- [extensions/renderer/messaging_util.cc](https://source.chromium.org/chromium/chromium/src/+/main:extensions/renderer/messaging_util.cc)
- [third_party/blink/renderer/core/messaging/](https://source.chromium.org/chromium/chromium/src/+/main:third_party/blink/renderer/core/messaging/)
- [content/browser/renderer_host/render_message_filter.cc](https://source.chromium.org/chromium/chromium/src/+/main:content/browser/renderer_host/render_message_filter.cc)

---

# **🚀 Summary**

✅ postMessage isn't just iframe → parent.

✅ It's a **core browser messaging backbone** for:

- Iframes
- Tabs
- Workers
- Service Workers
- Broadcast channels
- Extensions
- Future APIs (WebGPU, WASM transfer, PaymentHandler, WebTransport)

✅ All use **structured clone** internally (safe serialization, copy-only no prototype pollution).

---

# 
---
If you want next,  
👉 **I can dive into exactly how browsers handle security boundaries in postMessage** — including things like **origin check flaws**, **MessageEvent sanitization**, **how structured clone serialization protects against prototype poisoning**, and **even attack surfaces inside Chromium/Blink for postMessage**.

Would you like me to continue even deeper into **postMessage internals**? 🔥 (browser C++/Blink level)?  
Let’s go if you want 🚀
