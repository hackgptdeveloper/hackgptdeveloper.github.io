---
title: "AI generated javascript: Polygon with Colored Lines"
categories:
  - AI
tags:
  - AI, chatbot, Javascript
---

AI generated javascript: Polygon with Colored Lines

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
	<input type="range" id="offsetRange" min="0" max="59" value="30" oninput="updateOffset()">
	<span id="offsetValue">0.5</span>
	<label for="sidesRange">Number of sides (3-16): </label>
	<input type="range" id="sidesRange" min="3" max="16" value="6" oninput="updateSides()">
	<span id="sidesValue">6</span>
</div>
<canvas id="polygonCanvas" width="500" height="500"></canvas>
<script>
        const canvas = document.getElementById('polygonCanvas');
        const ctx = canvas.getContext('2d');
        const sidesRange = document.getElementById('sidesRange');
        const sidesValue = document.getElementById('sidesValue');
        const offsetValue = parseInt(document.getElementById('offsetRange').value)/60;
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const radius = 200;

        // Function to draw the polygon and midpoints recursively
        function drawPolygon(sides, offset) {
            ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas
            let points = generatePolygonPoints(centerX, centerY, radius, sides);

	    for (let i=0;i < sides + 3; i++) {
               drawShape(points);
               points = calculateMidpoints(points, offset);
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
        function calculateMidpoints(points, offset) {
            const midpoints = [];
            for (let i = 0; i < points.length; i++) {
                const nextIndex = (i + 1) % points.length;
                const midX = points[i].x + (points[nextIndex].x - points[i].x) * offset;
                const midY = points[i].y + (points[nextIndex].y - points[i].y) * offset;
                midpoints.push({ x: midX, y: midY });
            }
            return midpoints;
        }

        // Update number of sides and redraw
        function updateSides() {
            const sides = parseInt(sidesRange.value, 10);
            const offset = parseFloat(offsetValue.value);
            sidesValue.textContent = sides;
            drawPolygon(sides, offset);
        }

        function updateOffset() {
            const offset = parseInt(offsetRange.value, 10)/60;
            const sides = parseInt(sidesRange.value, 10);
            offsetValue.textContent = offset;
            drawPolygon(sides, offset);
        }

        // Initial draw
        drawPolygon(parseInt(sidesRange.value, 10), parseFloat(offsetValue.value));
</script>
