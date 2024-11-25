---
title: "AI generated javascript: Polygon Midpoint Generator"
categories:
  - AI
tags:
  - AI, chatbot, Javascript
---

AI generated javascript: Polygon Midpoint Generator

<style>
        canvas {
            display: block;
            margin: 20px auto;
            background-color: white;
            border: 1px solid #ccc;
        }
</style>
<label for="sidesRange">Number of sides (3-16): </label>
<input type="range" id="sidesRange" min="3" max="16" value="6" oninput="updateSides()">
<span id="sidesValue">6</span>
<canvas id="polygonCanvas" width="500" height="500"></canvas>

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
