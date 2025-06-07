---
title: "AI assisted chat popup implementation (with server)"
tags:
  - AI-assisted-chat
---

To set up a popup chatbot at the bottom right of a webpage, similar to the example shown, follow these steps. This will involve HTML, CSS, and JavaScript to create the UI and connect to a backend chatbot. I’ll provide a basic implementation that you can adapt based on your backend.

### Step 1: HTML Structure
Create the HTML for the chat popup. This includes a button to toggle the chat window and a container for the chat messages.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chatbot Popup</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <!-- Chat Button -->
    <button id="chat-toggle" onclick="toggleChat()">💬</button>

    <!-- Chat Window -->
    <div id="chat-window" class="chat-hidden">
        <div id="chat-header">
            <span>Chat with Us</span>
            <button onclick="toggleChat()">✖</button>
        </div>
        <div id="chat-messages"></div>
        <div id="chat-input">
            <input type="text" id="user-input" placeholder="Type and press Enter..." onkeypress="handleKeyPress(event)">
            <button onclick="sendMessage()">➤</button>
        </div>
    </div>

    <script src="script.js"></script>
</body>
</html>
```

### Step 2: CSS Styling
Style the chat popup to appear at the bottom right, with a toggleable window, similar to the example.

```css
/* styles.css */
body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
}

/* Chat Toggle Button */
#chat-toggle {
    position: fixed;
    bottom: 20px;
    right: 20px;
    background-color: #28a745;
    color: white;
    border: none;
    border-radius: 50%;
    width: 50px;
    height: 50px;
    font-size: 24px;
    cursor: pointer;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
}

/* Chat Window */
#chat-window {
    position: fixed;
    bottom: 80px;
    right: 20px;
    width: 300px;
    height: 400px;
    background-color: white;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
    display: flex;
    flex-direction: column;
    overflow: hidden;
    transition: all 0.3s ease;
}

/* Hidden State */
.chat-hidden {
    transform: scale(0);
    opacity: 0;
    visibility: hidden;
}

/* Chat Header */
#chat-header {
    background-color: #28a745;
    color: white;
    padding: 10px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

#chat-header button {
    background: none;
    border: none;
    color: white;
    font-size: 16px;
    cursor: pointer;
}

/* Chat Messages */
#chat-messages {
    flex: 1;
    padding: 10px;
    overflow-y: auto;
    background-color: #f5f5f5;
}

.message {
    margin: 5px 0;
    padding: 8px;
    border-radius: 10px;
    max-width: 80%;
}

.bot-message {
    background-color: #fff3cd;
    align-self: flex-start;
}

.user-message {
    background-color: #28a745;
    color: white;
    align-self: flex-end;
    margin-left: auto;
}

/* Chat Input */
#chat-input {
    display: flex;
    padding: 10px;
    border-top: 1px solid #ddd;
}

#user-input {
    flex: 1;
    padding: 8px;
    border: 1px solid #ddd;
    border-radius: 5px;
    outline: none;
}

#chat-input button {
    background-color: #28a745;
    color: white;
    border: none;
    border-radius: 5px;
    margin-left: 5px;
    padding: 0 10px;
    cursor: pointer;
}
```

### Step 3: JavaScript Functionality
Add JavaScript to toggle the chat window, handle user input, and communicate with the backend chatbot. This example assumes a simple backend API endpoint for the chatbot.

```javascript
// script.js
function toggleChat() {
    const chatWindow = document.getElementById('chat-window');
    chatWindow.classList.toggle('chat-hidden');
}

// Send message on Enter key press
function handleKeyPress(event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
}

// Send user message and get bot response
function sendMessage() {
    const userInput = document.getElementById('user-input');
    const chatMessages = document.getElementById('chat-messages');
    const messageText = userInput.value.trim();

    if (messageText === '') return;

    // Add user message to chat
    const userMessage = document.createElement('div');
    userMessage.className = 'message user-message';
    userMessage.textContent = messageText;
    chatMessages.appendChild(userMessage);

    // Clear input
    userInput.value = '';

    // Scroll to bottom
    chatMessages.scrollTop = chatMessages.scrollHeight;

    // Send message to backend and get response
    fetch('https://your-backend-api/chat', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message: messageText }),
    })
        .then(response => response.json())
        .then(data => {
            // Add bot response to chat
            const botMessage = document.createElement('div');
            botMessage.className = 'message bot-message';
            botMessage.textContent = data.reply || 'Sorry, I didn’t understand that.';
            chatMessages.appendChild(botMessage);

            // Scroll to bottom
            chatMessages.scrollTop = chatMessages.scrollHeight;
        })
        .catch(error => {
            console.error('Error:', error);
            const botMessage = document.createElement('div');
            botMessage.className = 'message bot-message';
            botMessage.textContent = 'Error connecting to the chatbot.';
            chatMessages.appendChild(botMessage);
        });
}

// Add initial bot message when chat opens
document.getElementById('chat-toggle').addEventListener('click', () => {
    const chatMessages = document.getElementById('chat-messages');
    if (chatMessages.children.length === 0) {
        const botMessage = document.createElement('div');
        botMessage.className = 'message bot-message';
        botMessage.textContent = 'Hi! I’m your assistant. How can I help you today?';
        chatMessages.appendChild(botMessage);
    }
});
```

### Step 4: Backend Setup (Simplified)
You’ll need a backend to handle chatbot requests. This example assumes a simple API endpoint (`/chat`) that accepts a POST request with a JSON body `{ "message": "user input" }` and returns a response like `{ "reply": "bot response" }`.

If you’re using Node.js with Express, here’s a basic setup:

```javascript
// server.js (Node.js with Express)
const express = require('express');
const app = express();
app.use(express.json());

app.post('/chat', (req, res) => {
    const userMessage = req.body.message.toLowerCase();
    let reply = 'I’m not sure how to respond to that.';

    // Simple logic for demo purposes
    if (userMessage.includes('hello')) {
        reply = 'Hi! How can I assist you today?';
    } else if (userMessage.includes('help')) {
        reply = 'I’m here to help! What do you need assistance with?';
    }

    res.json({ reply });
});

app.listen(3000, () => console.log('Server running on port 3000'));
```

### Step 5: Integration and Testing
1. Replace `'https://your-backend-api/chat'` in the JavaScript code with your actual backend API endpoint.
2. Host your HTML, CSS, and JavaScript files on a web server.
3. Ensure your backend is running and accessible.
4. Test the chat popup by clicking the toggle button, sending messages, and verifying the bot responses.

### Notes
- **Security:** Add proper authentication and validation to your backend API to prevent abuse.
- **Styling:** Adjust the CSS to match your website’s design, including colors and fonts.
- **Backend:** The example backend is simplistic. For a real chatbot, you might integrate with a service like Dialogflow, Rasa, or a custom solution using NLP.
- **Accessibility:** Ensure the chat is accessible (e.g., keyboard navigation, screen reader support).

This setup should give you a functional chat popup similar to the one in the image! Let me know if you need further customization.
