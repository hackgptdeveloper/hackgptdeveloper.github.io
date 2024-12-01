---
title: "Cardioid Shape"
tags:
  - Graphics
---

Cardioid Shape

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
        <input type="range" id="a1" min="1" max="30" value="1">
        <span id="a1Value">1</span>

        <label for="b1">b1:</label>
        <input type="range" id="b1" min="1" max="30" value="1">
        <span id="b1Value">1</span>

        <label for="c1">c1:</label>
        <input type="range" id="c1" min="1" max="30" value="1">
        <span id="c1Value">1</span>

        <label for="d1">d1:</label>
        <input type="range" id="d1" min="1" max="30" value="1">
        <span id="d1Value">1</span>

        <label for="e1">e1:</label>
        <input type="range" id="e1" min="1" max="30" value="1">
        <span id="e1Value">1</span>

        <label for="f1">f1:</label>
        <input type="range" id="f1" min="1" max="200" value="1">
        <span id="f1Value">1</span>
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
        let a1 = 1, b1 = 1, c1 = 1, d1 = 1, e1 = 1, f1 = 1;

        function drawCardioid() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);

            ctx.strokeStyle = 'red';
            ctx.lineWidth = 2;
            ctx.beginPath();

            for (let phasea = 0; phasea <= 2 * Math.PI ; phasea += a1*delta) {
            for (let theta = 0; theta <= 2 * Math.PI * b1 *d1; theta += delta) {
		phaseb = f1*delta;
                let x = radius * (1 - Math.sin(b1 / c1 * theta + phasea)) * Math.cos(d1 / e1 * theta + phaseb) * Math.cos(theta) + centerX;
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

        // Update variables and redraw cardioid
        function updateCardioid() {
            a1 = parseInt(document.getElementById('a1').value);
            b1 = parseInt(document.getElementById('b1').value);
            c1 = parseInt(document.getElementById('c1').value);
            d1 = parseInt(document.getElementById('d1').value);
            e1 = parseInt(document.getElementById('e1').value);
            f1 = parseInt(document.getElementById('f1').value);

            document.getElementById('a1Value').textContent = a1;
            document.getElementById('b1Value').textContent = b1;
            document.getElementById('c1Value').textContent = c1;
            document.getElementById('d1Value').textContent = d1;
            document.getElementById('e1Value').textContent = e1;
            document.getElementById('f1Value').textContent = f1;

            drawCardioid();
        }

        // Attach event listeners to sliders
        document.getElementById('a1').addEventListener('input', updateCardioid);
        document.getElementById('b1').addEventListener('input', updateCardioid);
        document.getElementById('c1').addEventListener('input', updateCardioid);
        document.getElementById('d1').addEventListener('input', updateCardioid);
        document.getElementById('e1').addEventListener('input', updateCardioid);
        document.getElementById('f1').addEventListener('input', updateCardioid);

        drawCardioid();
</script>
