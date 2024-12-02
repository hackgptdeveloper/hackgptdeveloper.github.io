---
title: "Generalized Cardioid Shape"
tags:
  - Graphics
---

Generalized Cardioid Shape

<style>
        canvas {
            background-color: white;
            border: 1px solid #ccc;
            margin-bottom: 20px;
        }
        .controls {
            display: grid;
            grid-template-columns: auto 1fr auto;
            gap: 10px;
            align-items: center;
            width: 80%;
        }
        .footer-link {
            position: absolute;
            bottom: 20px;
            text-align: center;
            width: 100%;
        }
        .footer-link a {
            font-size: 16px;
            color: #007bff;
            text-decoration: none;
        }
        .footer-link a:hover {
            text-decoration: underline;
        }
</style>
<canvas id="cardioidCanvas" width="800" height="800"></canvas>

<div class="controls">
        <label for="a1">a1:</label>
        <input type="range" id="a1" min="1" max="30" value="3">
        <span id="a1Value">3</span>

        <label for="b1">b1:</label>
        <input type="range" id="b1" min="1" max="30" value="4">
        <span id="b1Value">4</span>

        <label for="c1">c1:</label>
        <input type="range" id="c1" min="1" max="30" value="4">
        <span id="c1Value">4</span>

        <label for="d1">d1:</label>
        <input type="range" id="d1" min="1" max="30" value="4">
        <span id="d1Value">4</span>

        <label for="e1">e1:</label>
        <input type="range" id="e1" min="1" max="30" value="3">
        <span id="e1Value">3</span>

</div>

<script>
        const canvas = document.getElementById('cardioidCanvas');
        const ctx = canvas.getContext('2d');
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const radius = 200;
        const steps = 200;
        const delta = 2 * Math.PI / steps;

        // Initialize variables
        let a1 = 3, b1 = 4, c1 = 4, d1 = 4, e1 = 3, f1 = 0;

        function drawCardioid() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            ctx.strokeStyle = 'red';
            ctx.lineWidth = 2;
            ctx.beginPath();

            for (let phasea = 0; phasea <= 2 * Math.PI ; phasea += a1 * delta) {
                for (let theta = 0; theta <= 2 * Math.PI * b1 * d1; theta += delta) {
                    let phaseb = f1 * delta;
                    let x = radius * (1 - Math.cos(b1 / c1 * theta + phasea)) * Math.sin(d1 / e1 * theta + phaseb) * Math.cos(theta) + centerX;
                    let y = radius * (1 - Math.cos(b1 / c1 * theta + phasea)) * Math.sin(d1 / e1 * theta + phaseb) * Math.sin(theta) + centerY;

                    if (theta === 0) {
                        ctx.moveTo(x, y);
                    } else {
                        ctx.lineTo(x, y);
                    }
                }
            }

            ctx.closePath();
            ctx.stroke();
        }

        function animate() {
            f1 += 0.1; // Increment f1 for animation
            drawCardioid();
            requestAnimationFrame(animate); // Request the next frame
        }

        // Update variables and redraw cardioid
        function updateCardioid() {
            a1 = parseInt(document.getElementById('a1').value);
            b1 = parseInt(document.getElementById('b1').value);
            c1 = parseInt(document.getElementById('c1').value);
            d1 = parseInt(document.getElementById('d1').value);
            e1 = parseInt(document.getElementById('e1').value);

            document.getElementById('a1Value').textContent = a1;
            document.getElementById('b1Value').textContent = b1;
            document.getElementById('c1Value').textContent = c1;
            document.getElementById('d1Value').textContent = d1;
            document.getElementById('e1Value').textContent = e1;
        }

        // Attach event listeners to sliders
        document.getElementById('a1').addEventListener('input', updateCardioid);
        document.getElementById('b1').addEventListener('input', updateCardioid);
        document.getElementById('c1').addEventListener('input', updateCardioid);
        document.getElementById('d1').addEventListener('input', updateCardioid);
        document.getElementById('e1').addEventListener('input', updateCardioid);

        animate(); // Start the animation
</script>


```
     The a1, b1, c1, d1, e1 parameters correspond to the variable in the following mathematical formula:

       for (let phasea = 0; phasea <= 2 * Math.PI ; phasea += a1 * delta) {
         for (let theta = 0; theta <= 2 * Math.PI * b1 * d1; theta += delta) {

       x = radius * (1 - Math.cos(b1 / c1 * theta + phasea)) * Math.sin(d1 / e1 * theta + phaseb) * Math.cos(theta) ;

       y = radius * (1 - Math.cos(b1 / c1 * theta + phasea)) * Math.sin(d1 / e1 * theta + phaseb) * Math.sin(theta) ;

```
