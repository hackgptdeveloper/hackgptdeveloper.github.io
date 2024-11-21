---
layout: post
title: "Creating a Java source code vulnerabilities analyser"
description: "To analyze Java source codes vulnerabilities using ChatGPT technologies"
date: 2024-11-21
feature_image: images/road.jpg
tags: [vulnerabilities, java, static-analysis, bugbounty]
---

Any programmer in Java source code can use this to analyze for potential vulnerabiliites.

<!--more-->

## Characteristics

- to explore the types of vulnerabilities in Java source code
- to explore the complexity of programming and how to overcome its analysis


<script>
        window.addEventListener("message",function(t){var e=document.getElementById("openassistantgpt-chatbot-iframe"),s=document.getElementById("openassistantgpt-chatbot-button-iframe");"openChat"===t.data&&(console.log("Toggle chat visibility"),e&&s?(e.contentWindow.postMessage("openChat","*"),s.contentWindow.postMessage("openChat","*"),e.style.pointerEvents="auto",e.style.display="block",window.innerWidth<640?(e.style.position="fixed",e.style.width="100%",e.style.height="100%",e.style.top="0",e.style.left="0",e.style.zIndex="9999"):(e.style.position="fixed",e.style.width="480px",e.style.height="65vh",e.style.bottom="0",e.style.right="0",e.style.top="",e.style.left="")):console.error("iframe not found")),"closeChat"===t.data&&e&&s&&(e.style.display="none",e.style.pointerEvents="none",e.contentWindow.postMessage("closeChat","*"),s.contentWindow.postMessage("closeChat","*"))});
</script>

<body>
  <iframe src="https://www.openassistantgpt.io/embed/cm3pbjgbp000113g3a9u9037y/button?chatbox=false"
    style="z-index: 50; margin-right: 6px; margin-bottom: 6px; position: fixed; right: 0; bottom: 0; width: 60px; height: 60px; border: 0; border: 2px solid #e2e8f0; border-radius: 50%; color-scheme: none; background: none;box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);"
    id="openassistantgpt-chatbot-button-iframe"></iframe>
  <!-- This chatbot is build using https://openassistantgpt.io/ -->
  <iframe src="https://www.openassistantgpt.io/embed/cm3pbjgbp000113g3a9u9037y/window?chatbox=false&withExitX=true"
    style="z-index: 50; margin-right: 6px; margin-bottom: 98px; display: none; position: fixed; right: 0; bottom: 0; pointer-events: none; overflow: hidden; height: 65vh; border: 2px solid #e2e8f0; border-radius: 0.375rem; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); width: 480px;"
    allow="clipboard-read; clipboard-write"
    allowfullscreen id="openassistantgpt-chatbot-iframe"></iframe>
</body>
