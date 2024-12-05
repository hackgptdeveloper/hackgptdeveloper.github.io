---
title: "Chasing polygon"
tags:
  - Graphics
---

Chasing polygon

<style>
        canvas {
            background-color: white;
            border: 1px solid #ccc;
        }
        .controls {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        .controls label {
            margin-right: 10px;
        }
</style>
<canvas id="polygonCanvas" width="500" height="500"></canvas>
<div class="controls">
    <label for="ngonSlider">Number of sides: <span id="ngonValue">3</span></label>
    <input type="range" id="ngonSlider" min="3" max="21" value="3">
</div>

<script> 
        const canvas = document.getElementById('polygonCanvas');
        const ctx = canvas.getContext('2d');
        const ngonSlider = document.getElementById('ngonSlider');
        const ngonValue = document.getElementById('ngonValue');
        
        // Define the gradient color palette from blue to yellow
        const colorPalette = [
            '#0000FF', '#1A33FF', '#3366FF', '#4D99FF', '#66CCFF', '#80FFFF', '#99FFCC', '#B3FF99',
            '#CCFF66', '#E6FF33', '#FFFF00', '#FFCC00', '#FF9933', '#FF6600', '#FF3300', '#FFFF33'
        ];
        
        let colorIndex = 0; // Start with the first color
        
        // Function to draw a polygon and return its edges
        function drawPolygon(points, color) {
            let edges = [];
            ctx.strokeStyle = color;
            ctx.beginPath();
            for (let i = 0; i < points.length; i++) {
                const startPoint = points[i];
                const endPoint = points[(i + 1) % points.length]; // Connect the last point to the first
                ctx.moveTo(startPoint.x, startPoint.y);
                ctx.lineTo(endPoint.x, endPoint.y);
                edges.push([startPoint, endPoint]);
            }
            ctx.stroke();
            return edges;
        }
        
        // Function to calculate the next polygon's points
        function getNextPolygonPoints(previousEdges) {
            let newPoints = [];
        
            // For each edge, calculate a point 1/10th along the line
            for (let i = 0; i < previousEdges.length; i++) {
                const startPoint = previousEdges[i][0];
                const endPoint = previousEdges[i][1];
        
                // Calculate 1/10th point along the line
                const newPoint = {
                    x: startPoint.x + (endPoint.x - startPoint.x) * 0.1,
                    y: startPoint.y + (endPoint.y - startPoint.y) * 0.1
                };
                newPoints.push(newPoint);
            }
        
            return newPoints;
        }
        
        // Function to create the polygons iteratively with shifting colors
        function createPolygons(initialPoints, iterations) {
            let currentPoints = initialPoints;
            for (let i = 0; i < iterations; i++) {
                const color = colorPalette[(colorIndex + i) % colorPalette.length]; // Shift color by index
                const edges = drawPolygon(currentPoints, color);
                currentPoints = getNextPolygonPoints(edges); // Calculate the next polygon's points
            }
        }
        
        // Initial points for the first polygon
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const radius = 150;
        let ngon = 3;
        
        // Generate points for the initial polygon
        let initialPolygon = [];
        
        // Function to update and redraw the polygon
        function updatePolygon() {
            const sides = parseInt(ngonSlider.value, 10);
            ngonValue.textContent = sides;
            ngon = sides;
            initialPolygon = [];
        
        for (let i = 0; i < ngon; i++) {
            const angle = (2 * Math.PI / ngon) * i - Math.PI / 2; // Starting from the top
            initialPolygon.push({
                x: centerX + radius * Math.cos(angle),
                y: centerY + radius * Math.sin(angle)
            });
        }
        
        }
        
            //drawPolygon(sides, radius, centerX, centerY, color);
        
        
        // Function to animate the polygons
        function animatePolygons() {
            ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas before each frame
            createPolygons(initialPolygon, 40);
            colorIndex = (colorIndex + 1) % colorPalette.length; // Shift color index
            setTimeout(animatePolygons, 50); // Request next frame
        }
        
        // Update polygon when slider changes
        ngonSlider.addEventListener('input', updatePolygon);
        
        // Start the animation
        animatePolygons();
</script>
