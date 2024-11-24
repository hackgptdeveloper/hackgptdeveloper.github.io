---
title: "AI generated javascript: Square with Colored Lines"
categories:
  - AI
tags:
  - AI, chatbot, Javascript
---

AI generated javascript: Square with Colored Lines

<style>
        canvas {
            background-color: white;
            border: 1px solid #ccc;
            margin-top: 20px;
        }
        .slider-container {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        label {
            margin-bottom: 5px;
        }
</style>
<div class="slider-container">
        <label for="offsetRange">Offset:</label>
        <input type="range" id="offsetRange" min="0" max="59" value="0">
</div>
<canvas id="canvas" width="600" height="600"></canvas>
<script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        const offsetRange = document.getElementById('offsetRange');

        // Square vertices
        const vertexA = { x: 100, y: 100 };
        const vertexB = { x: 500, y: 100 };
        const vertexC = { x: 500, y: 500 };
        const vertexD = { x: 100, y: 500 };

        // Function to draw the square
        function drawSquare() {
            ctx.beginPath();
            ctx.moveTo(vertexA.x, vertexA.y);
            ctx.lineTo(vertexB.x, vertexB.y);
            ctx.lineTo(vertexC.x, vertexC.y);
            ctx.lineTo(vertexD.x, vertexD.y);
            ctx.closePath();
            ctx.stroke();
        }

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

        // Divide each side into 60 equal parts
        const pointsAB = divideLine(vertexA, vertexB, 60);
        const pointsAD = divideLine(vertexA, vertexD, 60);
        const pointsBA = divideLine(vertexB, vertexA, 60);
        const pointsBC = divideLine(vertexB, vertexC, 60);
        const pointsCB = divideLine(vertexC, vertexB, 60);
        const pointsCD = divideLine(vertexC, vertexD, 60);
        const pointsDA = divideLine(vertexD, vertexA, 60);
        const pointsDC = divideLine(vertexD, vertexC, 60);

        // Function to draw connecting lines with color gradient
        function drawConnectingLines(points1, points2, hueOffset, offset) {
            for (let i = 0; i < 60; i++) {
                const point1 = points1[(60 - i - 1 + offset) % 60];
                const point2 = points2[i];
                const hue = (i * 6 + hueOffset) % 360;
                ctx.strokeStyle = `hsl(${hue}, 100%, 50%)`;
                ctx.beginPath();
                ctx.moveTo(point1.x, point1.y);
                ctx.lineTo(point2.x, point2.y);
                ctx.stroke();
            }
        }

        // Function to draw everything with the current offset
        function drawWithOffset(offset) {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            drawSquare();
            drawConnectingLines(pointsAB, pointsAD, 0, offset);    // Side AB to DA
            drawConnectingLines(pointsBA, pointsBC, 90, offset);   // Side AB to BC
            drawConnectingLines(pointsCB, pointsCD, 180, offset);  // Side BC to CD
            drawConnectingLines(pointsDA, pointsDC, 270, offset);  // Side CD to DA
        }

        // Initial draw with default offset
        drawWithOffset(0);

        // Event listener to update the drawing when the slider changes
        offsetRange.addEventListener('input', () => {
            const offset = parseInt(offsetRange.value);
            drawWithOffset(offset);
        });
</script>
