---
title: "AI assisted chat"
tags:
  - AI-assisted-chatbot-widget
---

I'll help you create a popup chatbot widget similar to the one shown in your image. This will include a floating chat button that opens a chat interface in the bottom right corner.I've created a complete chatbot popup widget that matches the design in your image. Here's what's included:

## Key Features:

1. **Floating Chat Button**: A green circular button in the bottom right corner
2. **Popup Chat Interface**: Opens when clicked, with smooth animations
3. **Chat Header**: Shows "Apollo" with a close button
4. **Welcome Message**: Includes avatar and introductory text
5. **Suggested Questions**: Pre-defined buttons for common queries
6. **Message Interface**: Shows user and bot messages with different styling
7. **Input Area**: Text input with send button and enter key support
8. **Responsive Design**: Works on both desktop and mobile devices

## Integration Instructions:

### 1. **Basic Integration**
Copy the HTML/CSS/JS code and add it to your website's pages.

### 2. **Backend Integration**
Replace the `getBotResponse()` function with actual API calls:

```javascript
async function getBotResponse(userMessage) {
    try {
        const response = await fetch('/api/chatbot', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ message: userMessage })
        });
        
        const data = await response.json();
        return data.reply;
    } catch (error) {
        return 'Sorry, I\'m having trouble connecting. Please try again later.';
    }
}
```

### 3. **Customization Options**
- Change colors by modifying the CSS variables
- Update the avatar and bot name in the welcome message
- Modify suggested questions to match your use case
- Adjust the popup size and position as needed

### 4. **Additional Features You Can Add**
- File upload support
- Typing indicators
- Message timestamps
- User authentication
- Chat history persistence
- Emoji support
- Quick reply buttons

The widget is ready to use and will provide a professional chat experience similar to popular services like tawk.to, Intercom, or Zendesk Chat.

---

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chatbot Popup Widget</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            padding: 20px;
        }

        /* Demo content */
        .demo-content {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        /* Chat Widget Styles */
        .chat-widget {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 1000;
        }

        /* Chat Button */
        .chat-button {
            width: 60px;
            height: 60px;
            background: #22c55e;
            border: none;
            border-radius: 50%;
            cursor: pointer;
            box-shadow: 0 4px 20px rgba(34, 197, 94, 0.4);
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .chat-button:hover {
            transform: scale(1.1);
            box-shadow: 0 6px 25px rgba(34, 197, 94, 0.5);
        }

        .chat-button svg {
            width: 24px;
            height: 24px;
            fill: white;
        }

        /* Chat Popup */
        .chat-popup {
            position: absolute;
            bottom: 80px;
            right: 0;
            width: 350px;
            height: 500px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 8px 30px rgba(0, 0, 0, 0.15);
            display: none;
            flex-direction: column;
            overflow: hidden;
            transform: translateY(20px);
            opacity: 0;
            transition: all 0.3s ease;
        }

        .chat-popup.show {
            display: flex;
            transform: translateY(0);
            opacity: 1;
        }

        /* Chat Header */
        .chat-header {
            background: #22c55e;
            color: white;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .chat-header h3 {
            font-size: 16px;
            font-weight: 600;
        }

        .close-btn {
            background: none;
            border: none;
            color: white;
            cursor: pointer;
            padding: 4px;
            border-radius: 4px;
            transition: background 0.2s;
        }

        .close-btn:hover {
            background: rgba(255, 255, 255, 0.1);
        }

        /* Chat Messages */
        .chat-messages {
            flex: 1;
            padding: 20px;
            overflow-y: auto;
            background: #fafafa;
        }

        .message {
            margin-bottom: 16px;
            max-width: 85%;
        }

        .message.bot {
            align-self: flex-start;
        }

        .message.user {
            align-self: flex-end;
            margin-left: auto;
        }

        .message-content {
            padding: 12px 16px;
            border-radius: 18px;
            font-size: 14px;
            line-height: 1.4;
        }

        .message.bot .message-content {
            background: white;
            border: 1px solid #e5e7eb;
            border-bottom-left-radius: 4px;
        }

        .message.user .message-content {
            background: #22c55e;
            color: white;
            border-bottom-right-radius: 4px;
        }

        /* Welcome Message */
        .welcome-message {
            text-align: center;
            padding: 20px;
            color: #6b7280;
        }

        .welcome-message .avatar {
            width: 50px;
            height: 50px;
            background: #22c55e;
            border-radius: 50%;
            margin: 0 auto 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
        }

        /* Suggested Questions */
        .suggested-questions {
            padding: 0 20px 20px;
        }

        .question-btn {
            display: block;
            width: 100%;
            background: none;
            border: 1px solid #22c55e;
            color: #22c55e;
            padding: 8px 12px;
            margin-bottom: 8px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 13px;
            transition: all 0.2s;
        }

        .question-btn:hover {
            background: #22c55e;
            color: white;
        }

        /* Chat Input */
        .chat-input {
            padding: 16px 20px;
            border-top: 1px solid #e5e7eb;
            background: white;
        }

        .input-container {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .chat-input input {
            flex: 1;
            border: 1px solid #e5e7eb;
            border-radius: 20px;
            padding: 8px 16px;
            font-size: 14px;
            outline: none;
        }

        .chat-input input:focus {
            border-color: #22c55e;
        }

        .send-btn {
            background: #22c55e;
            border: none;
            border-radius: 50%;
            width: 36px;
            height: 36px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background 0.2s;
        }

        .send-btn:hover {
            background: #16a34a;
        }

        .send-btn svg {
            width: 16px;
            height: 16px;
            fill: white;
        }

        /* Mobile Responsive */
        @media (max-width: 480px) {
            .chat-popup {
                width: 320px;
                height: 450px;
            }
            
            .chat-widget {
                bottom: 15px;
                right: 15px;
            }
        }
    </style>
</head>
<body>
    <!-- Demo content -->
    <div class="demo-content">
        <h1>Your Website Content</h1>
        <p>This is your main website content. The chatbot widget will appear in the bottom right corner.</p>
        <p>Click the green chat button to open the chatbot popup and interact with it.</p>
        <br>
        <p>The widget is responsive and will work on both desktop and mobile devices.</p>
    </div>

    <!-- Chat Widget -->
    <div class="chat-widget">
        <!-- Chat Button -->
        <button class="chat-button" onclick="toggleChat()">
            <svg viewBox="0 0 24 24">
                <path d="M20 2H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h4l4 4 4-4h4c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-2 12H6v-2h12v2zm0-3H6V9h12v2zm0-3H6V6h12v2z"/>
            </svg>
        </button>

        <!-- Chat Popup -->
        <div class="chat-popup" id="chatPopup">
            <!-- Header -->
            <div class="chat-header">
                <h3>Apollo</h3>
                <button class="close-btn" onclick="toggleChat()">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                        <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
                    </svg>
                </button>
            </div>

            <!-- Messages Container -->
            <div class="chat-messages" id="chatMessages">
                <!-- Welcome Message -->
                <div class="welcome-message">
                    <div class="avatar">🤖</div>
                    <p><strong>Hi! I'm Apollo, an AI Assistant.</strong></p>
                    <p>Ask me anything about tawk.to!</p>
                </div>

                <!-- Suggested Questions -->
                <div class="suggested-questions">
                    <button class="question-btn" onclick="askQuestion('What is tawk.to?')">What is tawk.to?</button>
                    <button class="question-btn" onclick="askQuestion('Why should I choose tawk.to?')">Why should I choose tawk.to?</button>
                    <button class="question-btn" onclick="askQuestion('How do I set up an AI Chatbot?')">How do I set up an AI Chatbot?</button>
                    <button class="question-btn" onclick="askQuestion('I have a different question')">I have a different question</button>
                </div>
            </div>

            <!-- Input Area -->
            <div class="chat-input">
                <div class="input-container">
                    <input type="text" id="messageInput" placeholder="Type and press [enter].." onkeypress="handleKeyPress(event)">
                    <button class="send-btn" onclick="sendMessage()">
                        <svg viewBox="0 0 24 24">
                            <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        let chatOpen = false;
        let messageHistory = [];

        function toggleChat() {
            const popup = document.getElementById('chatPopup');
            chatOpen = !chatOpen;
            
            if (chatOpen) {
                popup.classList.add('show');
                document.getElementById('messageInput').focus();
            } else {
                popup.classList.remove('show');
            }
        }

        function askQuestion(question) {
            addMessage(question, 'user');
            
            // Simulate bot response
            setTimeout(() => {
                let response = getBotResponse(question);
                addMessage(response, 'bot');
            }, 1000);
        }

        function sendMessage() {
            const input = document.getElementById('messageInput');
            const message = input.value.trim();
            
            if (message) {
                addMessage(message, 'user');
                input.value = '';
                
                // Simulate bot response
                setTimeout(() => {
                    let response = getBotResponse(message);
                    addMessage(response, 'bot');
                }, 1000);
            }
        }

        function handleKeyPress(event) {
            if (event.key === 'Enter') {
                sendMessage();
            }
        }

        function addMessage(text, sender) {
            const messagesContainer = document.getElementById('chatMessages');
            
            // Remove welcome message and suggested questions when first real message is sent
            if (messageHistory.length === 0) {
                messagesContainer.innerHTML = '';
            }
            
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${sender}`;
            
            const contentDiv = document.createElement('div');
            contentDiv.className = 'message-content';
            contentDiv.textContent = text;
            
            messageDiv.appendChild(contentDiv);
            messagesContainer.appendChild(messageDiv);
            
            // Scroll to bottom
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
            
            messageHistory.push({text, sender});
        }

        function getBotResponse(userMessage) {
            // Simple response logic - replace with actual backend integration
            const responses = {
                'what is tawk.to?': 'tawk.to is a free live chat application that lets you monitor and chat with visitors on your website or from a free customizable page.',
                'why should i choose tawk.to?': 'tawk.to is completely free with no limits on agents or chats. It offers real-time monitoring, customizable widgets, and mobile apps.',
                'how do i set up an ai chatbot?': 'You can set up an AI chatbot in tawk.to by going to Administration > Chat Bots and following the setup wizard to create your automated responses.',
                'i have a different question': 'Feel free to ask me anything! I\'m here to help you with questions about tawk.to and live chat solutions.'
            };
            
            const lowerMessage = userMessage.toLowerCase();
            
            for (let key in responses) {
                if (lowerMessage.includes(key.replace(/[?]/g, ''))) {
                    return responses[key];
                }
            }
            
            return 'Thanks for your message! For specific questions about tawk.to features, please visit our help center or contact our support team.';
        }

        // Initialize - you can call backend API here to get initial bot message
        document.addEventListener('DOMContentLoaded', function() {
            console.log('Chatbot widget loaded successfully!');
        });
    </script>
</body>
</html>
```
```html

---


