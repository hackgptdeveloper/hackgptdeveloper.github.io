---
title: "Polygon Drawing with Iterations"
tags:
  - Graphics
---

Polygon Drawing with Iterations

<style>
        canvas {
            background-color: white;
            border: 1px solid #ccc;
        }
        .controls {
            margin: 10px;
            font-size: 16px;
        }
</style>
<div class="controls">
    <label for="ngonSlider">Number of sides: <span id="ngonValue">3</span></label>
    <input type="range" id="ngonSlider" min="3" max="21" value="3">
</div>
<canvas id="polygonCanvas" width="500" height="500"></canvas>
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

let colorIndex = 0;

// Function to draw a regular polygon
function drawPolygon(sides, radius, centerX, centerY, color) {
    const angleStep = (2 * Math.PI) / sides;
    const points = [];

    ctx.strokeStyle = color;
    ctx.beginPath();

    for (let i = 0; i < sides; i++) {
        const x = centerX + radius * Math.cos(i * angleStep);
        const y = centerY + radius * Math.sin(i * angleStep);
        points.push({ x, y });
        if (i === 0) ctx.moveTo(x, y);
        else ctx.lineTo(x, y);
    }
    ctx.closePath();
    ctx.stroke();
}

// Function to update and redraw the polygon
function updatePolygon() {
    const sides = parseInt(ngonSlider.value, 10);
    ngonValue.textContent = sides;

    ctx.clearRect(0, 0, canvas.width, canvas.height);
    const radius = 200;
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;

    // Get the current color
    const color = colorPalette[colorIndex % colorPalette.length];
    colorIndex++;

    // Draw the polygon
    drawPolygon(sides, radius, centerX, centerY, color);
}

// Initial draw
updatePolygon();

// Update polygon when slider changes
ngonSlider.addEventListener('input', updatePolygon);
</script>
