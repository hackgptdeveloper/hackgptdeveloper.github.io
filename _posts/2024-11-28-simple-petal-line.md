---
title: "AI generated javascript: Dynamic Petals"
tags:
  - AI, chatbot, Javascript
---

AI generated javascript: Dynamic Petals


<style>
        canvas {
            background-color: white;
            border: 1px solid #ccc;
        }
        .label {
            font-size: 16px;
            margin-bottom: 8px;
        }
        .equation {
            margin-top: 10px;
            font-size: 18px;
            font-style: italic;
        }
        .design-note {
            margin-top: 10px;
            font-size: 14px;
            color: #555;
        }
        .parameter-labels {
            margin-top: 20px;
            font-size: 16px;
        }
</style>

<div class="equation">
        Equation: x = radius * cos(a/b * θ) * cos(θ), y = radius * cos(a/b * θ) * sin(θ)
</div>

<div class="design-note">
        Every refresh is a new design!
</div>

<div class="parameter-labels">
        Current values: a = <span id="a-value">2</span>, b = <span id="b-value">5</span>
</div>
<canvas id="simple_petal" width="600" height="600"></canvas>

<script>
document.addEventListener("contextmenu", event => event.preventDefault());

// Function to generate random integer between min and max (inclusive)
function getRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

// Create a gradient palette from red to blue
const gradientColors = [];
for (let i = 0; i < 16; i++) {
    const r = 255 - Math.floor(255 * (i / 15));  // Red fades out
    const g = 0;  // No green component
    const b = Math.floor(255 * (i / 15));  // Blue fades in
    gradientColors.push(`rgb(${r},${g},${b})`);
}

// Function to draw the Petal graphics on the provided canvas
function drawPetalGraphics(canvas, radius, a, b) {
    const ctx = canvas.getContext('2d');
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    let counter = 0;
    const points = [];
    
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.lineWidth = 1;
    ctx.beginPath();

    for (let theta = 0; theta <= 2 * Math.PI * b; theta += 2 * Math.PI /30/a) {
        ctx.strokeStyle = gradientColors[counter % gradientColors.length];
        counter++;

        let x = radius * Math.cos(a / b * theta) * Math.cos(theta) + centerX;
        let y = radius * Math.cos(a / b * theta) * Math.sin(theta) + centerY;

        if (theta === 0) {
            ctx.moveTo(x, y);
        } else {
            ctx.lineTo(x, y);
        }
        points.push({x, y});
    }
    ctx.closePath();
    ctx.stroke();
    return (points);
}

document.addEventListener("contextmenu", function(event) { event.preventDefault(); });

const canvas = document.getElementById('simple_petal');
const ctx = canvas.getContext('2d');
const nPoints = 120;
let step = 1;

function drawPoints(points) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = 'blue';

    points.forEach((point, index) => {
        ctx.beginPath();
        ctx.arc(point.x, point.y, 3, 0, 2 * Math.PI);
        ctx.fill();
    });
}

function drawLines(points, step) {
    ctx.strokeStyle = 'blue';

    for (let i = 0; i < points.length; i++) {
        const j = (i + step) % points.length;
        ctx.beginPath();
        ctx.moveTo(points[i].x, points[i].y);
        ctx.lineTo(points[j].x, points[j].y);
        ctx.stroke();
    }
}

let a = 2;
let b = 5;

function updateLabels() {
    document.getElementById('a-value').textContent = a;
    document.getElementById('b-value').textContent = b;
}

function animate() {
    if (step == 59) {
        a = getRandomInt(1, 15);
        b = getRandomInt(1, 15);
        updateLabels();
    }
    const points = drawPetalGraphics(canvas, radius, a, b);
    drawLines(points, step);
    step = (step % (60 - 1)) + 1; // Increment step from 1 to 59
    setTimeout(animate, 200); // Control animation speed
}

const radius = 280;
animate();
</script>
