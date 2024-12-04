---
title: "Joining points on the hypotrochoids"
tags:
  - Graphics
---

Joining points on the hypotrochoid.   Compare this with that of joining lines on the circle.

[https://hackgptdeveloper.github.io/2024/12/04/heart5.html](https://hackgptdeveloper.github.io/2024/12/04/heart5.html)

<style>
    canvas {
        border: 1px solid black;
        background-color: #b5b1b1;
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
        <label for="skip-slider">skip: <span id="skip-value">5</span></label><br>
        <input type="range" id="skip-slider" min="1" max="160" value="1" step="1">
        <label for="r-slider">r: <span id="r-value">5</span></label><br>
        <input type="range" id="r-slider" min="1" max="160" value="1" step="1">
        <label for="nos_r-slider">nos_r: <span id="nos_r-value">5</span></label><br>
        <input type="range" id="nos_r-slider" min="1" max="160" value="1" step="1">
    </div>
</div>
<canvas id="heartCanvas" width="600" height="600"></canvas>
<script> 
    const canvas = document.getElementById('heartCanvas');
    const ctx = canvas.getContext('2d');
    const width = canvas.width;
    const height = canvas.height;

    const R = 160;
    const r = 40;
    const d = 150;
    const centerX = width / 2;
    const centerY = height / 2;
    const totalPoints = 160; // Total points around the circle

    // Get sliders and display elements
    const skipSlider = document.getElementById('skip-slider');
    const skipValueDisplay = document.getElementById('skip-value');
    const rSlider = document.getElementById('r-slider');
    const rValueDisplay = document.getElementById('r-value');
    const nos_rSlider = document.getElementById('nos_r-slider');
    const nos_rValueDisplay = document.getElementById('nos_r-value');

    // Update display and values dynamically
    let skip = parseInt(skipSlider.value);
    let r = parseInt(rSlider.value);
    let nos_r = parseInt(nos_rSlider.value);
    let R = nos_r * r;
    //let numLines = f1*150;
    //let delta = (1 / numLines) * 2 * Math.PI;

    skipSlider.addEventListener('input', () => {
        skip = parseInt(skipSlider.value);
        skipValueDisplay.textContent = skip;
    	drawHeartLines();
    });

    rSlider.addEventListener('input', () => {
        r = parseInt(rSlider.value);
        rValueDisplay.textContent = r;
    	drawHeartLines();
    });

    nos_rSlider.addEventListener('input', () => {
        nos_r = parseInt(nos_rSlider.value);
	R = nos_r * r;
        nos_rValueDisplay.textContent = nos_r;
    	drawHeartLines();
    });

    Math.gcd = function(a, b) {
     	return b ? Math.gcd(b, a % b) : Math.abs(a);
    };

    // Function to calculate the position of points around the circle
    function getPointOnHypotrochoid(index, totalPoints) {
        const t = (2 * Math.PI * r / Math.gcd(R, r) * index) / totalPoints;

        const x = centerX + (R - r) * Math.cos(t) + d * Math.cos(((R - r) / r) * t);
        const y = centerY + (R - r) * Math.sin(t) - d * Math.sin(((R - r) / r) * t);

        return { x, y };
    }

    // Draw the numbered points and connect them with lines
    function drawHeartLines() {
        ctx.clearRect(0, 0, width, height); // Clear the canvas

        // Draw the circle points
        ctx.fillStyle = "black";
        for (let i = 0; i < totalPoints; i++) {
            const { x, y } = getPointOnHypotrochoid(i, totalPoints);
            ctx.beginPath();
            ctx.arc(x, y, 3, 0, 2 * Math.PI);
            ctx.fill();
            ctx.fillText(i, x + 5, y + 5); // Label the points with numbers
        }

        // Draw the connecting lines
        for (let i = 0; i < totalPoints; i++) {
            const { x: x1, y: y1 } = getPointOnHypotrochoid(i, totalPoints);
            const { x: x2, y: y2 } = getPointOnHypotrochoid((i + skip) % totalPoints, totalPoints);
            
            ctx.beginPath();
            ctx.moveTo(x1, y1);
            
            // Use different colors for different regions (as per the original image)
            if (i < totalPoints / 2) {
                ctx.strokeStyle = 'blue';
            } else {
                ctx.strokeStyle = 'red';
            }
            
            ctx.lineTo(x2, y2);
            ctx.stroke();
        }
    }
    drawHeartLines();
</script>


```
	First we get one of the point on the hypotrochoid:

            const { x: x1, y: y1 } = getPointOnHypotrochoid(i, totalPoints);

	then we get another point on the hypotrochoid jumping further by "skip" steps:

            const { x: x2, y: y2 } = getPointOnHypotrochoid((i + skip) % totalPoints, totalPoints);

	then we join the two point:

            ctx.moveTo(x1, y1);
            ctx.lineTo(x2, y2);
```
