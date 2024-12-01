---
title: "Parametric Equation Visualization with Rotation"
tags:
  - Graphics
---

AI generated javascript for prametric equation visualization.

<a href="https://tthtlc.wordpress.com/2024/10/18/sinusoidal-parajetric-equalition/"> Sinusoidal Parametric Equation </a> <br>

<style>
        canvas {
            background-color: white;
            border: 1px solid #ccc;
        }
        .controls {
            position: absolute;
            bottom: 20px;
            display: flex;
            justify-content: center;
            gap: 20px;
        }
        .control-group {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
</style>

<canvas id="canvas" width="800" height="800"></canvas> <br> <br>
<div class="controls">
        <div class="control-group">
            <label for="aaaa">aaaa:</label>
            <input type="range" id="aaaa" min="1" max="10" step="0.1" value="5">
            <span id="value-aaaa">5</span>
        </div>
        <div class="control-group">
            <label for="bbbb">bbbb:</label>
            <input type="range" id="bbbb" min="1" max="10" step="0.1" value="5">
            <span id="value-bbbb">5</span>
        </div>
        <div class="control-group">
            <label for="cccc">cccc:</label>
            <input type="range" id="cccc" min="1" max="10" step="0.1" value="5">
            <span id="value-cccc">5</span>
        </div>
</div>
<script>
	document.querySelectorAll('input[type="range"]').forEach((slider) => {
    slider.addEventListener('input', drawCurveWithRotation);
});
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        const width = canvas.width;
        const height = canvas.height;
        const scale = 60;

        let aaaa = parseFloat(document.getElementById('aaaa').value);
        let bbbb = parseFloat(document.getElementById('bbbb').value);
        let cccc = parseFloat(document.getElementById('cccc').value);

        const valueAaaa = document.getElementById('value-aaaa');
        const valueBbbb = document.getElementById('value-bbbb');
        const valueCccc = document.getElementById('value-cccc');

        // Center the canvas
        ctx.translate(width / 2, height / 2);
        ctx.lineWidth = 1;
        ctx.strokeStyle = '#333';

        // Parametric equations
        function x(t) {
            return aaaa * Math.pow(Math.sin(-bbbb * t), 2) * Math.pow(2, Math.cos(Math.cos(4.28 * 2.3 * t)));
        }

        function y(t) {
            return aaaa * Math.sin(Math.sin(-bbbb * t)) * Math.pow(Math.cos(4.28 * 2.3 * t), 2);
        }

        // Draw the parametric curve with rotation
        function drawCurveWithRotation() {
            ctx.clearRect(-width / 2, -height / 2, width, height);

            for (let i = 0; i < 4; i++) {
                drawCurve();
                ctx.rotate(Math.PI / 2); // Rotate by 90 degrees
            }
        }

        // Draw the parametric curve
        function drawCurve() {
            ctx.beginPath();
            let startX = x(-cccc) * scale;
            let startY = y(-cccc) * scale;
            ctx.moveTo(startX, startY);

            for (let t = -cccc; t <= cccc; t += 0.01) {
                const newX = x(t) * scale;
                const newY = y(t) * scale;
                ctx.lineTo(newX, newY);
            }

            ctx.stroke();
        }

        // Initial drawing
        drawCurveWithRotation();

        // Update value display and variables
        function updateValueDisplay(id, value) {
            document.getElementById(`value-${id}`).textContent = value;
        }

        // Event listeners for scrollbars
        document.getElementById('aaaa').addEventListener('input', (event) => {
            aaaa = parseFloat(event.target.value);
            updateValueDisplay('aaaa', aaaa);
        });

        document.getElementById('bbbb').addEventListener('input', (event) => {
            bbbb = parseFloat(event.target.value);
            updateValueDisplay('bbbb', bbbb);
        });

        document.getElementById('cccc').addEventListener('input', (event) => {
            cccc = parseFloat(event.target.value);
            updateValueDisplay('cccc', cccc);
        });
</script>
