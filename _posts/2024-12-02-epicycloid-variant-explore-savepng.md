<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Epicycloid Curves with Scrollbars, Labels, and Color Picker</title>
    <style>
        body {
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f0f0;
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
    </style>
</head>
<body>
    <canvas id="canvas" width="600" height="600"></canvas>

    <div class="controls">
        <div class="control-group">
            <label for="R">R (Outer radius):</label>
            <input type="range" id="R" min="50" max="300" value="125">
            <span id="R-value" class="value-label">125</span>
        </div>
        <div class="control-group">
            <label for="r">r (Inner radius):</label>
            <input type="range" id="r" min="10" max="150" value="40">
            <span id="r-value" class="value-label">40</span>
        </div>
        <div class="control-group">
            <label for="d">d (Distance):</label>
            <input type="range" id="d" min="10" max="150" value="150">
            <span id="d-value" class="value-label">150</span>
        </div>
        <div class="control-group">
            <label for="amp">amp (Amplitude Control):</label>
            <input type="range" id="amp" min="0" max="24" value="3">
            <span id="amp-value" class="value-label">1</span>
        </div>
        <div class="control-group">
            <label for="color">Select Color:</label>
            <input type="color" id="color" value="#0000ff">
        </div>
        <canvas id="gradientCanvas" width="300" height="50" class="color-spectrum"></canvas>

        <!-- Save as PNG Button -->
        <button id="saveButton">Save as PNG</button>
</div>

<script>
            document.addEventListener("contextmenu", function(event) { event.preventDefault(); });
    
            const canvas = document.getElementById('canvas');
            const ctx = canvas.getContext('2d');
            const gradientCanvas = document.getElementById('gradientCanvas');
            const gradientCtx = gradientCanvas.getContext('2d');
    
            let R = 125;
            let r = 40;
            let d = 150;
            let amp = 1; // Initialize the amp variable
            let rotationAngle = 0;
            let selectedColor = '#0000ff';
    
    function drawEpicycloid() {
        const width = canvas.width;
        const height = canvas.height;
        const centerX = width/2;
        const centerY = height/2;
    
        ctx.clearRect(0, 0, width, height);
        ctx.save();
        ctx.translate(centerX, centerY);
        ctx.rotate(rotationAngle * Math.PI / 180);
        ctx.translate(-centerX, -centerY);
    
        const colors = generateGradientColors(selectedColor, 16);
        let colorIndex = 0;
    
        ctx.beginPath();
        for (let t = 0; t <= 2 * Math.PI * r / Math.gcd(R, r); t += 0.01) {
            const x = centerX + (R - r) * Math.cos(t) * Math.sin(amp * t) - d * Math.cos((R - r) / r * t);
            const y = centerY + (R - r) * Math.sin(t) * Math.sin(amp * t) - d * Math.sin((R - r) / r * t);
    
            if (t/(2 * Math.PI) - Math.floor(t/(2 * Math.PI)) < 0.001)
                ctx.strokeStyle = colors[colorIndex % colors.length];
    
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
            document.getElementById('r').addEventListener('input', function() {
                r = parseInt(this.value);
                document.getElementById('r-value').innerText = this.value;
            });
            document.getElementById('d').addEventListener('input', function() {
                d = parseInt(this.value);
                document.getElementById('d-value').innerText = this.value;
            });
            document.getElementById('amp').addEventListener('input', function() {
                amp = parseInt(this.value);
                document.getElementById('amp-value').innerText = this.value;
            });
            document.getElementById('color').addEventListener('input', function() {
                selectedColor = this.value;
                drawColorGradient();
            });
    
            setInterval(drawEpicycloid, 100);
            drawColorGradient();
    
    function saveCanvasAsImage(canvas) {
        const dataURL = canvas.toDataURL('image/png');
        const filename = `epicycloid_variant_R_${R}_r_${r}_d_${d}_amp_${amp}.png`; // Added amp to filename
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
