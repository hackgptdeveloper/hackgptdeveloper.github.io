---
title: "Chasing on rotating pentagon"
categories:
  - Graphics
tags:
  - AI, chatbot, Mathematics, graphics
---

Chasing on rotating pentagon.

<canvas id="pentagonCanvas" width="500" height="500"></canvas>
    <script> 
const canvas = document.getElementById('pentagonCanvas');
const ctx = canvas.getContext('2d');

// Define the gradient color palette from blue to yellow
const colorPalette = [
    '#0000FF', '#1A33FF', '#3366FF', '#4D99FF', '#66CCFF', '#80FFFF', '#99FFCC', '#B3FF99',
    '#CCFF66', '#E6FF33', '#FFFF00', '#FFCC00', '#FF9933', '#FF6600', '#FF3300', '#FFFF33'
];

let colorIndex = 0; // Start with the first color

// Function to draw a pentagon and return its edges
function drawPentagon(points, color) {
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

// Function to calculate the next pentagon's points
function getNextPentagonPoints(previousEdges) {
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

// Function to create the pentagons iteratively with shifting colors
function createPentagons(initialPoints, iterations) {
    let currentPoints = initialPoints;
    for (let i = 0; i < iterations; i++) {
        const color = colorPalette[(colorIndex + i) % colorPalette.length]; // Shift color by index
        const edges = drawPentagon(currentPoints, color);
        currentPoints = getNextPentagonPoints(edges); // Calculate the next pentagon's points
    }
}

// Initial points for the first pentagon
const centerX = canvas.width / 2;
const centerY = canvas.height / 2;
const radius = 150;

// Generate points for the initial pentagon
const initialPentagon = [];
for (let i = 0; i < 5; i++) {
    const angle = (2 * Math.PI / 5) * i - Math.PI / 2; // Starting from the top
    initialPentagon.push({
        x: centerX + radius * Math.cos(angle),
        y: centerY + radius * Math.sin(angle)
    });
}

// Function to animate the pentagons
function animatePentagons() {
    ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear canvas before each frame
    createPentagons(initialPentagon, 40);
    colorIndex = (colorIndex + 1) % colorPalette.length; // Shift color index
    setTimeout(animatePentagons, 50); // Request next frame
}

// Start the animation
animatePentagons();

</script>

