---
title: "Generalized chasing rotating polygon"
tags:
  - Graphics
---

Generalized chasing rotating polygon.

This is a generalization of this:

[chasing_triangle_rotating.html](/graphics/2024/11/22/chasing_triangle_rotating.html)

<style>
        .controls {
            margin: 10px 0;
            font-family: Arial, sans-serif;
        }
        .controls label {
            margin-right: 10px;
        }
</style>
<div class="controls">
	<label for="ngonRange">Number of sides (n-gon): <span id="ngonValue">4</span></label>
	<input type="range" id="ngonRange" min="3" max="12" value="4">
</div>
<canvas id="polygonCanvas" width="500" height="500"></canvas>
<script>
    const canvas = document.getElementById('polygonCanvas');
    const ctx = canvas.getContext('2d');
    const ngonRange = document.getElementById('ngonRange');
    const ngonValue = document.getElementById('ngonValue');
    
    let ngon = parseInt(ngonRange.value); // Initial number of sides
    
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
    
    // Function to generate points for the initial polygon
    function generatePolygonPoints(sides, centerX, centerY, radius) {
        const points = [];
        for (let i = 0; i < sides; i++) {
            const angle = (2 * Math.PI / sides) * i - Math.PI / 2; // Starting from the top
            points.push({
                x: centerX + radius * Math.cos(angle),
                y: centerY + radius * Math.sin(angle)
            });
        }
        return points;
    }
    
    // Function to animate the polygons
    function animatePolygons() {
        ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas before each frame
        const initialPolygon = generatePolygonPoints(ngon, canvas.width / 2, canvas.height / 2, 150);
        createPolygons(initialPolygon, 40);
        colorIndex = (colorIndex + 1) % colorPalette.length; // Shift color index
        setTimeout(animatePolygons, 50); // Request next frame
    }
    
    // Event listener for the range input to update ngon value dynamically
    ngonRange.addEventListener('input', () => {
        ngon = parseInt(ngonRange.value);
        ngonValue.textContent = ngon; // Update the displayed value
    });
    
    // Start the animation
    animatePolygons();
</script>
