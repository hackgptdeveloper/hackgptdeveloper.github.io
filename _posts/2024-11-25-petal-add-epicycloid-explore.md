---
title: "AI generated javascript: Epicycloid Curves with Petal with Scrollbars, Labels, and Color Picker"
categories:
  - AI
tags:
  - AI, chatbot, Javascript
---

AI generated javascript: Epicycloid Curves with Petal with Scrollbars, Labels, and Color Picker

<style>
        .canvas-container {
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        canvas {
            border: 1px solid black;
        }
        .controls {
            margin-top: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .control-group {
            margin: 10px 0;
            display: flex;
            align-items: center;
        }
        .control-group label {
            margin-right: 10px;
        }
        .color-spectrum {
            margin: 10px 0;
            width: 300px;
        }
        input[type="range"] {
            width: 200px;
        }
        .value-label {
            margin-left: 10px;
            font-weight: bold;
        }
        #gitalk-container {
            width: 600px;
        }
</style>
<div class="canvas-container">
        <canvas id="canvas" width="800" height="800"></canvas>
    <div class="controls">
        <div class="control-group">
            <label for="R">R (Outer radius):</label>
            <input type="range" id="R" min="50" max="300" value="125">
            <span id="R-value" class="value-label">125</span>
        </div>
        <div class="control-group">
            <label for="a">a :</label>
            <input type="range" id="a" min="1" max="30" value="10">
            <span id="a-value" class="value-label">10</span>
        </div>
        <div class="control-group">
            <label for="b">b :</label>
            <input type="range" id="b" min="1" max="30" value="2">
            <span id="b-value" class="value-label">2</span>
        </div>
        <div class="control-group">
            <label for="R1">R1 (Second Outer Radius):</label>
            <input type="range" id="R1" min="50" max="300" value="100">
            <span id="R1-value" class="value-label">100</span>
        </div>
        <div class="control-group">
            <label for="r1">r1 (Second Inner Radius):</label>
            <input type="range" id="r1" min="10" max="150" value="21">
            <span id="r1-value" class="value-label">21</span>
        </div>
        <div class="control-group">
            <label for="color">Select Color:</label>
            <input type="color" id="color" value="#0000ff">
        </div>
        <canvas id="gradientCanvas" width="300" height="50" class="color-spectrum"></canvas>

        <button id="saveButton">Save as PNG</button>
        <div id="gitalk-container"></div>
</div>
<script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        const gradientCanvas = document.getElementById('gradientCanvas');
        const gradientCtx = gradientCanvas.getContext('2d');

        let R = 125;
        let a = 10;
        let b = 2;
        let R1 = 101;
        let r1 = 21;
        let rotationAngle = 0;
        let selectedColor = '#0000ff';

        function drawEpicycloid() {
            const width = canvas.width;
            const height = canvas.height;
            const centerX = width / 2;
            const centerY = height / 2;

            ctx.clearRect(0, 0, width, height);
            ctx.save();
            ctx.translate(centerX, centerY);
            ctx.rotate(rotationAngle * Math.PI / 180);
            ctx.translate(-centerX, -centerY);

            const colors = generateGradientColors(selectedColor, 16);
            let colorIndex = 0;

            ctx.beginPath();
            for (let t = 0; t <= 2 * Math.PI * Math.max(b / Math.gcd(b, a), r1 / Math.gcd(R1, r1)); t += 0.01) {


                const x = centerX + (R1 + r1) * Math.cos(t) - r1 * Math.cos((R1 + r1) / r1 * t) + R * Math.cos(a/b*t)*Math.cos(t) ;
                const y = centerY + (R1 + r1) * Math.sin(t) - r1 * Math.sin((R1 + r1) / r1 * t) + R * Math.cos(a/b*t)*Math.sin(t) ;

                if (t / (2 * Math.PI) - Math.floor(t / (2 * Math.PI)) < 0.001) ctx.strokeStyle = colors[colorIndex % colors.length];

                if (t == 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }

                colorIndex++;
            }
            ctx.stroke();

            ctx.restore();
            rotationAngle += 1;
        }

        Math.gcd = function(a, b) {
            return b ? Math.gcd(b, a % b) : Math.abs(a);
        };

        function generateGradientColors(baseColor, steps) {
            let base = hexToRgb(baseColor);
            let colors = [];
            for (let i = 0; i < steps; i++) {
                let ratio = i / (steps - 1);
                let color = {
                    r: Math.round(base.r * (1 - ratio)),
                    g: Math.round(base.g * (1 - ratio)),
                    b: Math.round(base.b * (1 - ratio))
                };
                colors.push(`rgb(${color.r}, ${color.g}, ${color.b})`);
            }
            return colors;
        }

        function hexToRgb(hex) {
            let bigint = parseInt(hex.slice(1), 16);
            let r = (bigint >> 16) & 255;
            let g = (bigint >> 8) & 255;
            let b = bigint & 255;
            return { r, g, b };
        }

        function drawColorGradient() {
            const colors = generateGradientColors(selectedColor, 32);
            const width = gradientCanvas.width;
            const height = gradientCanvas.height;
            gradientCtx.clearRect(0, 0, width, height);
            const grad = gradientCtx.createLinearGradient(0, 0, width, 0);
            colors.forEach((color, index) => {
                grad.addColorStop(index / (colors.length - 1), color);
            });
            gradientCtx.fillStyle = grad;
            gradientCtx.fillRect(0, 0, width, height);
        }

        document.getElementById('R').addEventListener('input', function() {
            R = parseInt(this.value);
            document.getElementById('R-value').innerText = this.value;
        });
        document.getElementById('a').addEventListener('input', function() {
            a = parseInt(this.value);
            document.getElementById('a-value').innerText = this.value;
        });
        document.getElementById('b').addEventListener('input', function() {
            b = parseInt(this.value);
            document.getElementById('b-value').innerText = this.value;
        });
        document.getElementById('R1').addEventListener('input', function() {
            R1 = parseInt(this.value);
            document.getElementById('R1-value').innerText = this.value;
        });
        document.getElementById('r1').addEventListener('input', function() {
            r1 = parseInt(this.value);
            document.getElementById('r1-value').innerText = this.value;
        });
        document.getElementById('color').addEventListener('input', function() {
            selectedColor = this.value;
            drawColorGradient();
        });

        setInterval(drawEpicycloid, 100);
        drawColorGradient();

        function saveCanvasAsImage(canvas) {
            const dataURL = canvas.toDataURL('image/png');
            const filename = `epicycloid_R_${R}_a_${a}_b_${b}_R1_${R1}_r1_${r1}.png`;
            const link = document.createElement('a');
            link.href = dataURL;
            link.download = filename;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        document.getElementById('saveButton').addEventListener('click', function() {
            saveCanvasAsImage(canvas);
        });
</script>
