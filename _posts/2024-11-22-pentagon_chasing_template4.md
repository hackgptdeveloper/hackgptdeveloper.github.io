---
title: "Pentagon with Animated Colored Lines"
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
    <canvas id="canvas" width="600" height="600" style="border:1px solid #000;"></canvas>
    <script>
        document.addEventListener("contextmenu", function(event) { event.preventDefault(); });
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');

        // Pentagon vertices
        let vertexA = { x: 300, y: 100 };
        let vertexB = { x: 500, y: 250 };
        let vertexC = { x: 400, y: 500 };
        let vertexD = { x: 200, y: 500 };
        let vertexE = { x: 100, y: 250 };
        let offset = 0;
        let rotationCounter = 0;  // Track the number of rotations
        const rotationSpeed = 0.1;  // Speed of each rotation
        let clockwise = true;  // Start with clockwise rotation

        // Calculate center of pentagon (P0)
        const p0 = {
            x: (vertexA.x + vertexB.x + vertexC.x + vertexD.x + vertexE.x) / 5,
            y: (vertexA.y + vertexB.y + vertexC.y + vertexD.y + vertexE.y) / 5
        };

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

        // Function to rotate a point around a center by a given angle
        function rotatePoint(point, center, angle) {
            const sinAngle = Math.sin(angle);
            const cosAngle = Math.cos(angle);
            const dx = point.x - center.x;
            const dy = point.y - center.y;

            return {
                x: center.x + cosAngle * dx - sinAngle * dy,
                y: center.y + sinAngle * dx + cosAngle * dy
            };
        }

        // Function to rotate the pentagon vertices
        function rotateVertices() {
            const angle = rotationSpeed * (clockwise ? 1 : -1);
            vertexA = rotatePoint(vertexA, p0, angle);
            vertexB = rotatePoint(vertexB, p0, angle);
            vertexC = rotatePoint(vertexC, p0, angle);
            vertexD = rotatePoint(vertexD, p0, angle);
            vertexE = rotatePoint(vertexE, p0, angle);

            // Track the number of complete rotations (10 rounds for each direction)
            rotationCounter++;
            if (rotationCounter >= 600) {  // 600 steps for 10 full rotations (clockwise or anticlockwise)
                rotationCounter = 0;
                clockwise = !clockwise;  // Change direction after 10 rounds
            }
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

            // Rotate the pentagon vertices
            rotateVertices();

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

            setTimeout(animate, 200); // Request next frame
        }

        // Initialize and start the animation
        animate();
    </script>
