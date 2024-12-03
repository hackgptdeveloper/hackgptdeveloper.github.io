---
title: "Direct addition of two hypotrochoids"
tags:
  - Graphics
---

This is the result of direct addition of two hypotrochoids on top of each other, i.e., (x, y) = (x_hypotrochoid1, y_hypotrochoid1) + (x_hypotrochoid2, y_hypotrochoid2)

<style>
        canvas {
            border: 1px solid black;
            margin-top: 20px; /* Adds space below the label */
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
</style>
<canvas id="canvas" width="600" height="600"></canvas>
<div class="controls">
        <!-- Curve 1 Controls -->
        <div class="control-group">
            <label for="R1">R1 (Outer radius 1):</label>
            <input type="range" id="R1" min="50" max="300" value="240">
            <span id="R1-value" class="value-label">240</span>
        </div>
        <div class="control-group">
            <label for="r1">r1 (Inner radius 1):</label>
            <input type="range" id="r1" min="10" max="150" value="40">
            <span id="r1-value" class="value-label">40</span>
        </div>
        <div class="control-group">
            <label for="d1">d1 (Distance 1):</label>
            <input type="range" id="d1" min="10" max="150" value="150">
            <span id="d1-value" class="value-label">150</span>
        </div>
        
        <!-- Curve 2 Controls -->
        <div class="control-group">
            <label for="R2">R2 (Outer radius 2):</label>
            <input type="range" id="R2" min="50" max="300" value="240">
            <span id="R2-value" class="value-label">240</span>
        </div>
        <div class="control-group">
            <label for="r2">r2 (Inner radius 2):</label>
            <input type="range" id="r2" min="10" max="150" value="40">
            <span id="r2-value" class="value-label">40</span>
        </div>
        <div class="control-group">
            <label for="d2">d2 (Distance 2):</label>
            <input type="range" id="d2" min="10" max="150" value="150">
            <span id="d2-value" class="value-label">150</span>
        </div>

        <div class="control-group">
            <label for="color">Select Color:</label>
            <input type="color" id="color" value="#0000ff">
        </div>
        <canvas id="gradientCanvas" width="300" height="50" class="color-spectrum"></canvas>
</div>
<script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        const gradientCanvas = document.getElementById('gradientCanvas');
        const gradientCtx = gradientCanvas.getContext('2d');

        // Parameters for two curves
        let R1 = 240, r1 = 40, d1 = 150;
        let R2 = 240, r2 = 40, d2 = 150;
        let rotationAngle = 0;
        let selectedColor = '#0000ff';

        function drawHypotrochoids() {
            const width = canvas.width;
            const height = canvas.height;

            ctx.clearRect(0, 0, width, height); // Clear canvas
            ctx.save();
            ctx.translate(width / 2, height / 2);
            ctx.rotate(rotationAngle * Math.PI / 180);
            ctx.translate(-width / 2, -height / 2);

            ctx.beginPath();
            const gradient = ctx.createLinearGradient(0, 0, width, height);
            const colors = generateGradientColors(selectedColor, 8);
            colors.forEach((color, index) => {
                gradient.addColorStop(index / (colors.length - 1), color);
            });
            ctx.strokeStyle = gradient;
            ctx.lineWidth = 2;

            // Draw composite curve
            for (let t = 0; t <= 2 * Math.PI * (R1-r1)*(R2-r2) ; t += 0.01) {
                const x1 = (R1 - r1) * Math.cos(t) + d1 * Math.cos(((R1 - r1) / r1) * t);
                const y1 = (R1 - r1) * Math.sin(t) - d1 * Math.sin(((R1 - r1) / r1) * t);

                const x2 = (R2 - r2) * Math.cos(t) + d2 * Math.cos(((R2 - r2) / r2) * t);
                const y2 = (R2 - r2) * Math.sin(t) - d2 * Math.sin(((R2 - r2) / r2) * t);

                const x = x1 + x2;
                const y = y1 + y2;

		if (t==0) 
            		ctx.moveTo(width / 2 + x, height / 2 - y);
		else
                	ctx.lineTo(width / 2 + x, height / 2 - y);
            }

            ctx.stroke();
            ctx.restore();

            rotationAngle += 1;
        }

        // Utility function to calculate the greatest common divisor (GCD)
        Math.gcd = function(a, b) {
            return b ? Math.gcd(b, a % b) : Math.abs(a);
        };

        // Generate gradient of 8 colors near the selected base color
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

        // Convert hex color to RGB
        function hexToRgb(hex) {
            let bigint = parseInt(hex.slice(1), 16);
            let r = (bigint >> 16) & 255;
            let g = (bigint >> 8) & 255;
            let b = bigint & 255;
            return { r, g, b };
        }

        // Draw color spectrum
        function drawColorGradient() {
            const colors = generateGradientColors(selectedColor, 8);
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

        // Event listeners for the scrollbars and color input
        document.getElementById('R1').addEventListener('input', function() {
            R1 = parseInt(this.value);
            document.getElementById('R1-value').innerText = this.value;
        });
        document.getElementById('r1').addEventListener('input', function() {
            r1 = parseInt(this.value);
            document.getElementById('r1-value').innerText = this.value;
        });
        document.getElementById('d1').addEventListener('input', function() {
            d1 = parseInt(this.value);
            document.getElementById('d1-value').innerText = this.value;
        });
        document.getElementById('R2').addEventListener('input', function() {
            R2 = parseInt(this.value);
            document.getElementById('R2-value').innerText = this.value;
        });
        document.getElementById('r2').addEventListener('input', function() {
            r2 = parseInt(this.value);
            document.getElementById('r2-value').innerText = this.value;
        });
        document.getElementById('d2').addEventListener('input', function() {
            d2 = parseInt(this.value);
            document.getElementById('d2-value').innerText = this.value;
        });
        document.getElementById('color').addEventListener('input', function() {
            selectedColor = this.value;
            drawColorGradient();
        });

        // Initialize the drawing and the color gradient
        setInterval(drawHypotrochoids, 100);
        drawColorGradient();
</script>
