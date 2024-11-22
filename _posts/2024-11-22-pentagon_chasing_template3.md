---
title: "Pentagon with Animated Colored Line"
categories:
  - AI, chatbot
tags:
  - AI, chatbot
---

    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
        }
        canvas {
            background-color: white;
            border: 1px solid #ccc;
        }
    </style>
<!-- Google tag (gtag.js) --> <script async src="https://www.googletagmanager.com/gtag/js?id=G-GEX61LPT08"></script> <script>   window.dataLayer = window.dataLayer || [];   function gtag(){dataLayer.push(arguments);}   gtag('js', new Date());   gtag('config', 'G-GEX61LPT08'); </script>
    <canvas id="canvas" width="600" height="600" style="border:1px solid #000;"></canvas>
    <script>
        document.addEventListener("contextmenu", function(event) { event.preventDefault(); });
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');

        // Pentagon vertices
        const vertexA = { x: 300, y: 100 };
        const vertexB = { x: 500, y: 250 };
        const vertexC = { x: 400, y: 500 };
        const vertexD = { x: 200, y: 500 };
        const vertexE = { x: 100, y: 250 };
	let offset = 0;

        // Calculate center of pentagon (P0)
        const p0 = {
            x: (vertexA.x + vertexB.x + vertexC.x + vertexD.x + vertexE.x) / 5,
            y: (vertexA.y + vertexB.y + vertexC.y + vertexD.y + vertexE.y) / 5
        };

        // Divide line from center to each vertex into 60 parts
        const pointsP0_P1 = divideLine(p0, vertexA, 60);
        const pointsP0_P2 = divideLine(p0, vertexB, 60);
        const pointsP0_P3 = divideLine(p0, vertexC, 60);
        const pointsP0_P4 = divideLine(p0, vertexD, 60);
        const pointsP0_P5 = divideLine(p0, vertexE, 60);

        // Array of points arrays for easier iteration
        const pointArrays = [pointsP0_P1, pointsP0_P2, pointsP0_P3, pointsP0_P4, pointsP0_P5];

        // Function to divide a line into equal parts
        function divideLine(start, end, parts) {
            const points = [];
            for (let i = 0; i <= parts; i++) {
                const x = start.x + (end.x - start.x) * (i / parts);
                const y = start.y + (end.y - start.y) * (i / parts);
                points.push({ x, y });
            }
            return points;
        }

        // Function to draw connecting lines with color gradient
        function drawConnectingLines(points1, points2, hueOffset, offset) {
            for (let i = 0; i < 60; i++) {
                const point1 = points1[i];
                const point2 = points2[(60-i-1+offset)%60];
                const hue = (i * 6 + hueOffset) % 360; // Offset hue to vary colors
                ctx.strokeStyle = `hsl(${hue}, 100%, 50%)`;
                ctx.beginPath();
                ctx.moveTo(point1.x, point1.y);
                ctx.lineTo(point2.x, point2.y);
                ctx.stroke();
            }
        }

        // Function to animate the drawing
        function animate() {
            ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas

            // Draw the pentagon outline
            ctx.beginPath();
            ctx.moveTo(vertexA.x, vertexA.y);
            ctx.lineTo(vertexB.x, vertexB.y);
            ctx.lineTo(vertexC.x, vertexC.y);
            ctx.lineTo(vertexD.x, vertexD.y);
            ctx.lineTo(vertexE.x, vertexE.y);
            ctx.closePath();
            ctx.stroke();

            // Draw connecting lines between adjacent point arrays
            for (let j = 0; j < pointArrays.length; j++) {
                const nextIndex = (j + 1) % pointArrays.length; // Loop back to start after last point
                drawConnectingLines(pointArrays[j], pointArrays[nextIndex], j * 72, offset++); // Adjust hue offset
            }

            //requestAnimationFrame(animate); // Request next frame
            setTimeout(animate, 200); // Request next frame
        }

        // Start the animation
        animate();
    </script>
