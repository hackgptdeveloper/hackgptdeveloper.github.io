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
	<label for="sidesRange">Number of sides (3-16): </label>
	<input type="range" id="sidesRange" min="3" max="16" value="6" oninput="updateSides()">
	<span id="sidesValue">6</span>
</div>
<canvas id="polygonCanvas" width="500" height="500"></canvas>
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



<script>
        const canvas = document.getElementById('polygonCanvas');
        const ctx = canvas.getContext('2d');
        const sidesRange = document.getElementById('sidesRange');
        const sidesValue = document.getElementById('sidesValue');
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const radius = 200;

        // Function to draw the polygon and midpoints recursively
        function drawPolygon(sides) {
            ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas
            let points = generatePolygonPoints(centerX, centerY, radius, sides);

	    for (let i=0;i < sides + 3; i++) {
               drawShape(points);
               points = calculateMidpoints(points);
	    }
        }

        // Generate points of a regular polygon
        function generatePolygonPoints(cx, cy, r, sides) {
            const points = [];
            const angleIncrement = (2 * Math.PI) / sides;

            for (let i = 0; i < sides; i++) {
                const angle = i * angleIncrement;
                const x = cx + r * Math.cos(angle);
                const y = cy + r * Math.sin(angle);
                points.push({ x, y });
            }
            return points;
        }

        // Draw a shape given a set of points
        function drawShape(points) {
            ctx.beginPath();
            ctx.moveTo(points[0].x, points[0].y);

            points.forEach(point => {
                ctx.lineTo(point.x, point.y);
            });
            ctx.closePath();
            ctx.stroke();
        }

        // Calculate midpoints of the edges of a polygon
        function calculateMidpoints(points) {
            const midpoints = [];
            for (let i = 0; i < points.length; i++) {
                const nextIndex = (i + 1) % points.length;
                const midX = (points[i].x + points[nextIndex].x) / 2;
                const midY = (points[i].y + points[nextIndex].y) / 2;
                midpoints.push({ x: midX, y: midY });
            }
            return midpoints;
        }

        // Update number of sides and redraw
        function updateSides() {
            const sides = parseInt(sidesRange.value, 10);
            sidesValue.textContent = sides;
            drawPolygon(sides);
        }

        // Initial draw
        drawPolygon(parseInt(sidesRange.value, 10));
</script>




</script>
