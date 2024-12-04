---
title: "Flower in Motion (v2)"
tags:
  - Graphics
---

Flower in Motion (v2)

<style>
    canvas {
        border: 1px solid black;
        background-color: #333;
        display: block;
        margin: 20px auto;
    }
    .controls {
        display: flex;
        justify-content: center;
        margin: 10px 0;
    }
    .slider-container {
        margin: 0 10px;
        text-align: center;
    }
</style>

<div class="controls">
    <div class="slider-container">
        <label for="f1-slider">f1: <span id="f1-value">1</span></label><br>
        <input type="range" id="f1-slider" min="1" max="20" value="1" step="1">
    </div>
    <div class="slider-container">
        <label for="f2-slider">f2: <span id="f2-value">1</span></label><br>
        <input type="range" id="f2-slider" min="1" max="20" value="1" step="1">
    </div>
</div>

<canvas id="complexLineCanvas" width="600" height="600"></canvas>

<script>
    const canvas = document.getElementById('complexLineCanvas');
    const ctx = canvas.getContext('2d');
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    let radius1 = 100;
    let radius2 = 200;
    let angleOffset = 0;

    // Get sliders and display elements
    const f1Slider = document.getElementById('f1-slider');
    const f2Slider = document.getElementById('f2-slider');
    const f1ValueDisplay = document.getElementById('f1-value');
    const f2ValueDisplay = document.getElementById('f2-value');

    // Update display and values dynamically
    let f1 = parseFloat(f1Slider.value);
    let f2 = parseFloat(f2Slider.value);
    let numLines = f1*150;
    let delta = (1 / numLines) * 2 * Math.PI;

    f1Slider.addEventListener('input', () => {
        f1 = parseFloat(f1Slider.value);
        f1ValueDisplay.textContent = f1;
    });

    f2Slider.addEventListener('input', () => {
        f2 = parseFloat(f2Slider.value);
        f2ValueDisplay.textContent = f2;
    });

    // Function to draw the complex pattern
    function drawComplexPattern() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        //ctx.strokeStyle = '#ffffff';
        ctx.lineWidth = 0.5;

        for (let i = 0; i < numLines*f2; i++) {
            const angle1 = (i * delta);
            const angle2 = (f1 / f2) * angle1;
            const x1 = centerX + radius1 * Math.cos((angle2 + angleOffset)) * Math.sin(angle1 + angleOffset);
            const y1 = centerY + radius1 * Math.sin((angle2 + angleOffset)) * Math.sin(angle1 + angleOffset);
            const x2 = centerX + radius2 * Math.cos(angle1 + angleOffset) * Math.sin(angle2 + angleOffset);
            const y2 = centerY + radius2 * Math.sin(angle1 + angleOffset) * Math.sin(angle2 + angleOffset);

	    ctx.strokeStyle = `hsl(${(i / numLines) * 360}, 100%, 50%)`;
            ctx.beginPath();
            ctx.moveTo(x1, y1);
            ctx.lineTo(x2, y2);
            ctx.stroke();
        }

        // Update parameters to create animation
        angleOffset += 0.01;

        requestAnimationFrame(drawComplexPattern);
    }

    drawComplexPattern();
</script>

```
	Now instead of 2 it is generalized to f1/f2:

	const angle2 = (f1 / f2) * angle1;
        x1 = radius1 * Math.cos((angle2 + angleOffset)) * Math.sin(angle1 + angleOffset);
        y1 = radius1 * Math.sin((angle2 + angleOffset)) * Math.sin(angle1 + angleOffset);
        x2 = radius2 * Math.cos(angle1 + angleOffset) * Math.sin(angle2 + angleOffset);
        y2 = radius2 * Math.sin(angle1 + angleOffset) * Math.sin(angle2 + angleOffset);
```
