---
title: "Vortex Parametric Equation Visualization"
tags:
  - Graphics
---

Vortex Parametric Equation Visualization

<style>
        .url-container {
            position: absolute;
            top: 10px;
            text-align: center;
            width: 100%;
            font-size: 1.2em;
            color: #333;
        }
        canvas {
            background-color: white;
            border: 1px solid #ccc;
        }
        .controls {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 10px;
        }
        .control-group {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
</style>
<canvas id="canvas" width="800" height="800"></canvas>
<div class="controls">
    <!-- Existing controls -->
    <div class="control-group">
        <label for="aaaa">aaaa:</label>
        <input type="range" id="aaaa" min="0" max="140" step="1" value="123">
        <span id="value-aaaa">123</span>
    </div>
    <div class="control-group">
        <label for="bbbb">bbbb:</label>
        <input type="range" id="bbbb" min="0" max="260" step="1" value="250">
        <span id="value-bbbb">250</span>
    </div>
    <div class="control-group">
        <label for="cccc">cccc:</label>
        <input type="range" id="cccc" min="0" max="20" step="1" value="0">
        <span id="value-cccc">0</span>
    </div>

    <!-- New controls for dddd, eeee, and ffff -->
    <div class="control-group">
        <label for="dddd">dddd:</label>
        <input type="range" id="dddd" min="1" max="100" step="1" value="10">
        <span id="value-dddd">10</span>
    </div>
    <div class="control-group">
        <label for="eeee">eeee:</label>
        <input type="range" id="eeee" min="1" max="50" step="1" value="5">
        <span id="value-eeee">5</span>
    </div>
    <div class="control-group">
        <label for="ffff">ffff:</label>
        <input type="range" id="ffff" min="1" max="20" step="1" value="10">
        <span id="value-ffff">10</span>
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
        const scale = 200;

        let aaaa = parseFloat(document.getElementById('aaaa').value);
        let bbbb = parseFloat(document.getElementById('bbbb').value);
        let cccc = parseFloat(document.getElementById('cccc').value);

        const valueAaaa = document.getElementById('value-aaaa');
        const valueBbbb = document.getElementById('value-bbbb');
        const valueCccc = document.getElementById('value-cccc');


let dddd = parseFloat(document.getElementById('dddd').value);
let eeee = parseFloat(document.getElementById('eeee').value);
let ffff = parseFloat(document.getElementById('ffff').value);

const valueDddd = document.getElementById('value-dddd');
const valueEeee = document.getElementById('value-eeee');
const valueFfff = document.getElementById('value-ffff');





        // Center the canvas
        ctx.translate(width / 2, height / 2);
        ctx.lineWidth = 1;
        ctx.strokeStyle = '#333';

function x(t) {
    return Math.cos(t) + dddd / eeee * (Math.cos(aaaa / ffff * t) + Math.sin(bbbb * t));
}

function y(t) {
    return Math.sin(t) + dddd / eeee * (Math.sin(aaaa / ffff * t) + Math.cos((bbbb - cccc) * t));
}


        // Draw the parametric curve with rotation
        function drawCurveWithRotation() {
            ctx.clearRect(-width / 2, -height / 2, width, height);

            for (let i = 0; i < 1; i++) {
                drawCurve();
                ctx.rotate(Math.PI / 2); // Rotate by 90 degrees
            }
        }

        // Draw the parametric curve
        function drawCurve() {
            ctx.beginPath();
            let startX = x(0) * scale;
            let startY = y(0) * scale;
            ctx.moveTo(startX, startY);

            for (let t = 0; t <= 2 * Math.PI; t += 2 * Math.PI / 7200) {
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

// Update value display and variables for new controls
document.getElementById('dddd').addEventListener('input', (event) => {
    dddd = parseFloat(event.target.value);
    updateValueDisplay('dddd', dddd);
    drawCurveWithRotation();
});

document.getElementById('eeee').addEventListener('input', (event) => {
    eeee = parseFloat(event.target.value);
    updateValueDisplay('eeee', eeee);
    drawCurveWithRotation();
});

document.getElementById('ffff').addEventListener('input', (event) => {
    ffff = parseFloat(event.target.value);
    updateValueDisplay('ffff', ffff);
    drawCurveWithRotation();
});
</script>
