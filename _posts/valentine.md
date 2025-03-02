
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hearts Mouse Follower</title>
    <style>
        body {
            margin: 0;
            overflow: hidden;
            background: #222;
            cursor: none;
            font-family: Arial, sans-serif;
        }
        .heart {
            position: absolute;
            pointer-events: none;
            z-index: 1000;
        }
        #instructions {
            position: fixed;
            bottom: 20px;
            left: 20px;
            color: white;
            font-size: 16px;
            z-index: 2000;
            background: rgba(0,0,0,0.5);
            padding: 10px;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div id="instructions">Move your mouse to generate hearts!</div>
    
    <script>
        const body = document.querySelector('body');
        let lastX = 0;
        let lastY = 0;
        let heartCount = 0;
        const maxHearts = 200;
        
        // Function to generate a random color
        function getRandomColor() {
            const hue = Math.floor(Math.random() * 360);
            return `hsl(${hue}, 100%, 65%)`;
        }
        
        // Function to create a heart SVG
        function createHeart() {
            const heart = document.createElement('div');
            heart.className = 'heart';
            
            const size = Math.random() * 20 + 10;
            const color = getRandomColor();
            
            const svg = `
                <svg width="${size}" height="${size}" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path fill="${color}" d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/>
                </svg>
            `;
            
            heart.innerHTML = svg;
            heart.id = `heart-${heartCount++}`;
            
            // Initial position
            heart.style.left = `${lastX - size/2}px`;
            heart.style.top = `${lastY - size/2}px`;
            
            body.appendChild(heart);
            
            // Animate the heart
            const angle = Math.random() * Math.PI * 2;
            const velocity = Math.random() * 2 + 1;
            const rotationSpeed = Math.random() * 10 - 5;
            const lifetime = Math.random() * 2000 + 1000;
            
            let vx = Math.cos(angle) * velocity;
            let vy = Math.sin(angle) * velocity;
            let scale = 1;
            let opacity = 1;
            let rotation = 0;
            
            const startTime = Date.now();
            
            function animateHeart() {
                const elapsed = Date.now() - startTime;
                const progress = elapsed / lifetime;
                
                if (progress >= 1) {
                    heart.remove();
                    return;
                }
                
                const x = parseFloat(heart.style.left) + vx;
                const y = parseFloat(heart.style.top) + vy;
                
                vy += 0.03; // Gravity effect
                rotation += rotationSpeed;
                scale = 1 - 0.7 * progress;
                opacity = 1 - progress;
                
                heart.style.left = `${x}px`;
                heart.style.top = `${y}px`;
                heart.style.transform = `scale(${scale}) rotate(${rotation}deg)`;
                heart.style.opacity = opacity;
                
                requestAnimationFrame(animateHeart);
            }
            
            requestAnimationFrame(animateHeart);
            
            // Clean up hearts if we have too many
            if (document.querySelectorAll('.heart').length > maxHearts) {
                const oldest = document.getElementById(`heart-${heartCount - maxHearts}`);
                if (oldest) oldest.remove();
            }
        }
        
        // Generate hearts on mouse move
        document.addEventListener('mousemove', function(event) {
            lastX = event.clientX;
            lastY = event.clientY;
            
            // Generate hearts only when mouse has moved enough
            if (Math.random() < 0.3) {
                createHeart();
            }
        });
        
        // Generate hearts at regular intervals as long as mouse has moved
        setInterval(() => {
            if (lastX > 0 || lastY > 0) {
                createHeart();
            }
        }, 50);
    </script>
</body>
</html>
