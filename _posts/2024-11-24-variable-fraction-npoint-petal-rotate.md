---
title: "AI generated javascript: Variable Petal Lines Animation"
categories:
  - AI
tags:
  - AI, chatbot, Javascript
---

AI generated javascript: Variable Petal Lines Animation


<style>
        .controls {
            margin: 10px 0;
            font-family: Arial, sans-serif;
        }
        .controls label {
            margin-right: 10px;
        }
</style>
<div class="controls">
        <label for="freqRange1">A: <span id="freqValue1">1</span></label>
        <input type="range" id="freqRange1" min="1" max="24" step="1" value="1">
        <label for="freqRange2">B: <span id="freqValue2">1</span></label>
        <input type="range" id="freqRange2" min="1" max="24" step="1" value="1">
        <label for="nPointsRange">nPoints: <span id="nPointsValue">240</span></label>
        <input type="range" id="nPointsRange" min="50" max="500" step="10" value="240">
</div>
<canvas id="animationCanvas" width="600" height="600"></canvas>
<script>

        const canvas = document.getElementById('animationCanvas');
        const ctx = canvas.getContext('2d');
        const freqRange1 = document.getElementById('freqRange1');
        const freqValue1 = document.getElementById('freqValue1');
        const freqRange2 = document.getElementById('freqRange2');
        const freqValue2 = document.getElementById('freqValue2');
        const nPointsRange = document.getElementById('nPointsRange');
        const nPointsValue = document.getElementById('nPointsValue');
        
        let FREQ1 = parseInt(freqRange1.value);
        let FREQ2 = parseInt(freqRange2.value);
        let nPoints = parseInt(nPointsRange.value);
        let step = 1;
        let rotationAngle = 0;

        freqRange1.addEventListener('input', () => {
            FREQ1 = parseInt(freqRange1.value);
            freqValue1.textContent = FREQ1;
        });

        freqRange2.addEventListener('input', () => {
            FREQ2 = parseInt(freqRange2.value);
            freqValue2.textContent = FREQ2;
        });

        nPointsRange.addEventListener('input', () => {
            nPoints = parseInt(nPointsRange.value);
            nPointsValue.textContent = nPoints;
        });

        function getPoints() {
            const points = [];
            const centerX = canvas.width / 2;
            const centerY = canvas.height / 2;
            const radius = Math.min(centerX, centerY) * 0.9;

            for (let i = 0; i < nPoints * (FREQ1 * FREQ2); i++) {
                const theta = (2 * Math.PI * i) / nPoints;
                const r = Math.cos(FREQ1 / FREQ2 * theta);
                const x = centerX + radius * r * Math.cos(theta);
                const y = centerY + radius * r * Math.sin(theta);
                points.push({ x, y });
            }

            return points;
        }

        function rotatePoints(points, angle) {
            const rotatedPoints = [];
            const centerX = canvas.width / 2;
            const centerY = canvas.height / 2;
            const rad = angle * (Math.PI / 180);

            for (const point of points) {
                const x = point.x - centerX;
                const y = point.y - centerY;

                const newX = x * Math.cos(rad) - y * Math.sin(rad);
                const newY = x * Math.sin(rad) + y * Math.cos(rad);

                rotatedPoints.push({
                    x: newX + centerX,
                    y: newY + centerY,
                });
            }

            return rotatedPoints;
        }

        function drawPoints(points) {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.fillStyle = 'blue';

            for (const point of points) {
                ctx.beginPath();
                ctx.arc(point.x, point.y, 3, 0, 2 * Math.PI);
                ctx.fill();
            }
        }

        function drawLines(points, step) {
            ctx.strokeStyle = 'blue';

            for (let i = 0; i < points.length; i++) {
                const j = (i + step) % points.length;
                ctx.strokeStyle = `hsl(${(i / points.length) * 360}, 100%, 50%)`;
                ctx.beginPath();
                ctx.moveTo(points[i].x, points[i].y);
                ctx.lineTo(points[j].x, points[j].y);
                ctx.stroke();
            }
        }

        function animate() {
            const points = getPoints();
            const rotatedPoints = rotatePoints(points, rotationAngle);
            drawPoints(rotatedPoints);
            drawLines(rotatedPoints, step);

            step = (step % (nPoints - 1)) + 1;
            rotationAngle += 3;

            setTimeout(animate, 200);
        }

        animate();
</script>
