---
title: "AI generated javascript: Drawing double polygon"
tags:
  - AI, chatbot, Javascript
---

AI generated javascript for drawing double polygon - about 60%.   And about 5% of code really needs lots of manual Chrome Devtool debugging + ChatGPT advise.


<style>
        canvas {
            background-color: white;
            border: 1px solid #ccc;
            margin-bottom: 20px;
        }
        .controls {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .controls label {
            margin-right: 10px;
        }
        .controls input {
            margin-bottom: 10px;
        }
        button {
            margin-top: 10px;
            padding: 8px 16px;
            font-size: 16px;
            cursor: pointer;
        }
</style>
<script src="https://cdn.jsdelivr.net/npm/gif.js/dist/gif.js"></script>
<canvas id="animationCanvas" width="600" height="600"></canvas>
<div class="controls">
<div>
            <label for="sides">Number of sides:</label>
            <input type="range" id="sides" name="sides" min="3" max="15" step="1" value="5">
            <span id="sidesValue">5</span>
        </div>
        <div>
            <label for="largeRadius">Large Radius:</label>
            <input type="range" id="largeRadius" name="largeRadius" min="100" max="300" step="1" value="200">
            <span id="largeRadiusValue">200</span>
        </div>
        <div>
            <label for="smallRadius">Small Radius:</label>
            <input type="range" id="smallRadius" name="smallRadius" min="50" max="250" step="1" value="150">
            <span id="smallRadiusValue">150</span>
        </div>
        <button id="captureBtn">Capture JPG</button>
	<button id="generateGif">Generate GIF</button>
</div>

<script>
const canvas = document.getElementById('animationCanvas');
const ctx = canvas.getContext('2d');
let largeRadius = 200; // Initial radius of the larger polygon
let smallRadius = 150; // Initial radius of the smaller polygon
const centerX = canvas.width / 2; // Fixed center X
const centerY = canvas.height / 2; // Fixed center Y
let rotationAngleLarge = 0;
let rotationAngleSmall = 0;
let numSides = 5; // Starting with a pentagon
const numDots = 100; // Number of points along each polygon's perimeter

// Update the displayed values from the sliders
const sidesSlider = document.getElementById('sides');
const sidesValueDisplay = document.getElementById('sidesValue');
const largeRadiusSlider = document.getElementById('largeRadius');
const largeRadiusValueDisplay = document.getElementById('largeRadiusValue');
const smallRadiusSlider = document.getElementById('smallRadius');
const smallRadiusValueDisplay = document.getElementById('smallRadiusValue');

const gif = new GIF({
	workers: 2,
        workerScript: "/assets/js/gif.worker.js", 
	quality: 10 });

let frameCount = 0;
let maxFrames = 100; // Set how many frames to capture for the GIF

// Event listeners for the scrollbars
sidesSlider.addEventListener('input', (event) => {
    numSides = parseInt(event.target.value);
    sidesValueDisplay.textContent = numSides;
});
largeRadiusSlider.addEventListener('input', (event) => {
    largeRadius = parseInt(event.target.value);
    largeRadiusValueDisplay.textContent = largeRadius;
});
smallRadiusSlider.addEventListener('input', (event) => {
    smallRadius = parseInt(event.target.value);
    smallRadiusValueDisplay.textContent = smallRadius;
});

// Function to generate points along the edge of a polygon, divided into `numDots` points
function getPolygonPoints(centerX, centerY, radius, rotationAngle, numSides, numDots) {
    const points = [];
    const rotationRadians = rotationAngle * Math.PI / 180; // Convert degrees to radians

    // Angle between adjacent vertices of the polygon
    const angleStep = (2 * Math.PI) / numSides;

    // Generate points along the perimeter, divided into numDots parts
    for (let i = 0; i < numDots; i++) {
        const t = i / numDots; // Normalized parameter [0, 1)
        const vertexIndex = Math.floor(t * numSides); // Determine which edge we are on
        const tEdge = (t * numSides) % 1; // Interpolate along the edge

        const angle1 = vertexIndex * angleStep;
        const angle2 = (vertexIndex + 1) * angleStep;

        // Coordinates of the two vertices of the current edge
        const x1 = centerX + radius * Math.cos(angle1);
        const y1 = centerY + radius * Math.sin(angle1);
        const x2 = centerX + radius * Math.cos(angle2);
        const y2 = centerY + radius * Math.sin(angle2);

        // Interpolated point along the current edge
        const x = (1 - tEdge) * x1 + tEdge * x2;
        const y = (1 - tEdge) * y1 + tEdge * y2;

        // Apply rotation
        const rotatedX = centerX + (x - centerX) * Math.cos(rotationRadians) - (y - centerY) * Math.sin(rotationRadians);
        const rotatedY = centerY + (x - centerX) * Math.sin(rotationRadians) + (y - centerY) * Math.cos(rotationRadians);

        points.push({ x: rotatedX, y: rotatedY });
    }

    return points;
}

// Function to draw lines between points of two polygons
function drawLines(points1, points2) {
    for (let i = 0; i < points1.length; i++) {
        ctx.strokeStyle = i % 2 === 1 ? 'blue' : 'red';
        ctx.beginPath();
        ctx.moveTo(points1[i].x, points1[i].y);
        ctx.lineTo(points2[i].x, points2[i].y);
        ctx.stroke();
    }
}

// Function to clear canvas and fill with white background
function clearCanvasWithBackground() {
    ctx.fillStyle = 'white'; // Set the background color to white
    ctx.fillRect(0, 0, canvas.width, canvas.height); // Fill the canvas with white
}

// Function to animate the polygons
function animate() {
    clearCanvasWithBackground(); // Clear the canvas with white background

    // Get points for both polygons, divided by numDots
    const largePolygonPoints = getPolygonPoints(centerX, centerY, largeRadius, rotationAngleLarge, numSides, numDots);
    const smallPolygonPoints = getPolygonPoints(centerX, centerY, smallRadius, rotationAngleSmall, numSides, numDots);

    // Draw lines between corresponding points
    drawLines(largePolygonPoints, smallPolygonPoints);

    // Update rotation angles
    rotationAngleLarge = (rotationAngleLarge + 2) % 360; // Rotate counterclockwise
    rotationAngleSmall = (rotationAngleSmall - 2) % 360; // Rotate clockwise

    if (frameCount < maxFrames) {
	gif.addFrame(canvas, {copy: true, delay: 100});
	frameCount++;
    }

    requestAnimationFrame(animate); // Continue the animation
}

// Capture canvas as JPG and download
document.getElementById('captureBtn').addEventListener('click', function() {
    clearCanvasWithBackground(); // Ensure white background is applied before capturing

    // Redraw the polygons onto the white background before capture
    const largePolygonPoints = getPolygonPoints(centerX, centerY, largeRadius, rotationAngleLarge, numSides, numDots);
    const smallPolygonPoints = getPolygonPoints(centerX, centerY, smallRadius, rotationAngleSmall, numSides, numDots);
    drawLines(largePolygonPoints, smallPolygonPoints);

    const dataURL = canvas.toDataURL('image/jpeg', 1.0);
    const link = document.createElement('a');
    link.href = dataURL;
    link.download = 'polygon_animation.jpg';
    link.click();
});

// Generate GIF when the button is clicked
document.getElementById('generateGif').addEventListener('click', function() {
            gif.on('finished', function(blob) {
                const url = URL.createObjectURL(blob);
                const img = document.createElement('img');
                img.src = url;
                document.body.appendChild(img);
                
                // Optionally, download the GIF
                const link = document.createElement('a');
                link.href = url;
                link.download = 'animation.gif';
                link.click();
            });

            // Render the GIF
            gif.render();
});
// Start the animation

animate();

</script>

```
<script src="https://cdn.jsdelivr.net/npm/gif.js/dist/gif.js"></script>
<canvas id="animationCanvas" width="600" height="600"></canvas>
<div class="controls">
<div>
            <label for="sides">Number of sides:</label>
            <input type="range" id="sides" name="sides" min="3" max="15" step="1" value="5">
            <span id="sidesValue">5</span>
        </div>
        <div>
            <label for="largeRadius">Large Radius:</label>
            <input type="range" id="largeRadius" name="largeRadius" min="100" max="300" step="1" value="200">
            <span id="largeRadiusValue">200</span>
        </div>
        <div>
            <label for="smallRadius">Small Radius:</label>
            <input type="range" id="smallRadius" name="smallRadius" min="50" max="250" step="1" value="150">
            <span id="smallRadiusValue">150</span>
        </div>
        <button id="captureBtn">Capture JPG</button>
	<button id="generateGif">Generate GIF</button>
</div>

<script>
const canvas = document.getElementById('animationCanvas');
const ctx = canvas.getContext('2d');
let largeRadius = 200; // Initial radius of the larger polygon
let smallRadius = 150; // Initial radius of the smaller polygon
const centerX = canvas.width / 2; // Fixed center X
const centerY = canvas.height / 2; // Fixed center Y
let rotationAngleLarge = 0;
let rotationAngleSmall = 0;
let numSides = 5; // Starting with a pentagon
const numDots = 100; // Number of points along each polygon's perimeter

// Update the displayed values from the sliders
const sidesSlider = document.getElementById('sides');
const sidesValueDisplay = document.getElementById('sidesValue');
const largeRadiusSlider = document.getElementById('largeRadius');
const largeRadiusValueDisplay = document.getElementById('largeRadiusValue');
const smallRadiusSlider = document.getElementById('smallRadius');
const smallRadiusValueDisplay = document.getElementById('smallRadiusValue');

const gif = new GIF({
	workers: 2,
        workerScript: "/assets/js/gif.worker.js", 
	quality: 10 });

let frameCount = 0;
let maxFrames = 100; // Set how many frames to capture for the GIF

// Event listeners for the scrollbars
sidesSlider.addEventListener('input', (event) => {
    numSides = parseInt(event.target.value);
    sidesValueDisplay.textContent = numSides;
});
largeRadiusSlider.addEventListener('input', (event) => {
    largeRadius = parseInt(event.target.value);
    largeRadiusValueDisplay.textContent = largeRadius;
});
smallRadiusSlider.addEventListener('input', (event) => {
    smallRadius = parseInt(event.target.value);
    smallRadiusValueDisplay.textContent = smallRadius;
});

// Function to generate points along the edge of a polygon, divided into `numDots` points
function getPolygonPoints(centerX, centerY, radius, rotationAngle, numSides, numDots) {
    const points = [];
    const rotationRadians = rotationAngle * Math.PI / 180; // Convert degrees to radians

    // Angle between adjacent vertices of the polygon
    const angleStep = (2 * Math.PI) / numSides;

    // Generate points along the perimeter, divided into numDots parts
    for (let i = 0; i < numDots; i++) {
        const t = i / numDots; // Normalized parameter [0, 1)
        const vertexIndex = Math.floor(t * numSides); // Determine which edge we are on
        const tEdge = (t * numSides) % 1; // Interpolate along the edge

        const angle1 = vertexIndex * angleStep;
        const angle2 = (vertexIndex + 1) * angleStep;

        // Coordinates of the two vertices of the current edge
        const x1 = centerX + radius * Math.cos(angle1);
        const y1 = centerY + radius * Math.sin(angle1);
        const x2 = centerX + radius * Math.cos(angle2);
        const y2 = centerY + radius * Math.sin(angle2);

        // Interpolated point along the current edge
        const x = (1 - tEdge) * x1 + tEdge * x2;
        const y = (1 - tEdge) * y1 + tEdge * y2;

        // Apply rotation
        const rotatedX = centerX + (x - centerX) * Math.cos(rotationRadians) - (y - centerY) * Math.sin(rotationRadians);
        const rotatedY = centerY + (x - centerX) * Math.sin(rotationRadians) + (y - centerY) * Math.cos(rotationRadians);

        points.push({ x: rotatedX, y: rotatedY });
    }

    return points;
}

// Function to draw lines between points of two polygons
function drawLines(points1, points2) {
    for (let i = 0; i < points1.length; i++) {
        ctx.strokeStyle = i % 2 === 1 ? 'blue' : 'red';
        ctx.beginPath();
        ctx.moveTo(points1[i].x, points1[i].y);
        ctx.lineTo(points2[i].x, points2[i].y);
        ctx.stroke();
    }
}

// Function to clear canvas and fill with white background
function clearCanvasWithBackground() {
    ctx.fillStyle = 'white'; // Set the background color to white
    ctx.fillRect(0, 0, canvas.width, canvas.height); // Fill the canvas with white
}

// Function to animate the polygons
function animate() {
    clearCanvasWithBackground(); // Clear the canvas with white background

    // Get points for both polygons, divided by numDots
    const largePolygonPoints = getPolygonPoints(centerX, centerY, largeRadius, rotationAngleLarge, numSides, numDots);
    const smallPolygonPoints = getPolygonPoints(centerX, centerY, smallRadius, rotationAngleSmall, numSides, numDots);

    // Draw lines between corresponding points
    drawLines(largePolygonPoints, smallPolygonPoints);

    // Update rotation angles
    rotationAngleLarge = (rotationAngleLarge + 2) % 360; // Rotate counterclockwise
    rotationAngleSmall = (rotationAngleSmall - 2) % 360; // Rotate clockwise

    if (frameCount < maxFrames) {
	gif.addFrame(canvas, {copy: true, delay: 100});
	frameCount++;
    }

    requestAnimationFrame(animate); // Continue the animation
}

// Capture canvas as JPG and download
document.getElementById('captureBtn').addEventListener('click', function() {
    clearCanvasWithBackground(); // Ensure white background is applied before capturing

    // Redraw the polygons onto the white background before capture
    const largePolygonPoints = getPolygonPoints(centerX, centerY, largeRadius, rotationAngleLarge, numSides, numDots);
    const smallPolygonPoints = getPolygonPoints(centerX, centerY, smallRadius, rotationAngleSmall, numSides, numDots);
    drawLines(largePolygonPoints, smallPolygonPoints);

    const dataURL = canvas.toDataURL('image/jpeg', 1.0);
    const link = document.createElement('a');
    link.href = dataURL;
    link.download = 'polygon_animation.jpg';
    link.click();
});

// Generate GIF when the button is clicked
document.getElementById('generateGif').addEventListener('click', function() {
            gif.on('finished', function(blob) {
                const url = URL.createObjectURL(blob);
                const img = document.createElement('img');
                img.src = url;
                document.body.appendChild(img);
                
                // Optionally, download the GIF
                const link = document.createElement('a');
                link.href = url;
                link.download = 'animation.gif';
                link.click();
            });

            // Render the GIF
            gif.render();
});
// Start the animation

animate();

</script>
```
