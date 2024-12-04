---
title: "Hypotrochoid Curves with Slow Rotation and Offset Control"
tags:
  - Graphics
---

Hypotrochoid Curves with Slow Rotation and Offset Control

<canvas id="canvas" width="800" height="800"></canvas>
<div>
	<input type="range" id="offsetSlider" min="1" max="240" value="1">
	<label for="offsetSlider">Offset</label>
	<button id="controlButton">Start</button>
</div>
<script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        const width = canvas.width;
        const height = canvas.height;
        const offsetSlider = document.getElementById('offsetSlider');
        const controlButton = document.getElementById('controlButton');
        let offset = parseInt(offsetSlider.value);
        let isAnimating = false;
        let animationFrameId;
        offsetSlider.addEventListener('input', function() {
            offset = parseInt(this.value);
        });
        // Utility function to calculate the greatest common divisor (GCD)
        Math.gcd = function(a, b) {
            return b ? Math.gcd(b, a % b) : Math.abs(a);
        };
        function generateHypotrochoid(R, r, d, numPoints) {
            const points = [];
            const step = (2 * Math.PI * r / Math.gcd(R, r)) / numPoints;
            for (let t = 0; t <= 2 * Math.PI * r / Math.gcd(R, r); t += step) {
                const x = (R - r) * Math.cos(t) + d * Math.cos(((R - r) / r) * t);
                const y = (R - r) * Math.sin(t) - d * Math.sin(((R - r) / r) * t);
                points.push({ x: width / 2 + x, y: height / 2 - y });
            }
            return points;
        }
        function rotatePoint(point, angle, cx, cy) {
            const cosAngle = Math.cos(angle);
            const sinAngle = Math.sin(angle);
            const dx = point.x - cx;
            const dy = point.y - cy;
            return {
                x: cx + dx * cosAngle - dy * sinAngle,
                y: cy + dx * sinAngle + dy * cosAngle
            };
        }
        function rotatePoints(points, angle, cx, cy) {
            return points.map(point => rotatePoint(point, angle, cx, cy));
        }
        const points1 = generateHypotrochoid(200, 40, 60, 240);
        let rotationAngle = 0;
        let rotationStep = 1 * Math.PI / 180;
        let rotationDirection = 1;
        const maxRotation = 720 * Math.PI / 180;
        function drawHypotrochoids() {
            const rotatedPoints2 = rotatePoints(generateHypotrochoid(300, 60, 100, 240), rotationAngle, width / 2, height / 2);
            ctx.clearRect(0, 0, width, height);
            for (let i = 0; i < points1.length - 1; i++) {
                const adjustedIndex = (i + offset) % points1.length;
                ctx.beginPath();
                ctx.moveTo(points1[i].x, points1[i].y);
                ctx.lineTo(rotatedPoints2[i].x, rotatedPoints2[i].y);
                ctx.lineTo(points1[adjustedIndex].x, points1[adjustedIndex].y);
                ctx.strokeStyle = 'rgba(0, 0, 255, 0.5)';
                ctx.stroke();
            }
            ctx.beginPath();
            ctx.moveTo(points1[0].x, points1[0].y);
            for (let i = 1; i < points1.length; i++) {
                ctx.lineTo(points1[i].x, points1[i].y);
            }
            ctx.strokeStyle = 'red';
            ctx.stroke();
            ctx.beginPath();
            ctx.moveTo(rotatedPoints2[0].x, rotatedPoints2[0].y);
            for (let i = 1; i < rotatedPoints2.length; i++) {
                ctx.lineTo(rotatedPoints2[i].x, rotatedPoints2[i].y);
            }
            ctx.strokeStyle = 'green';
            ctx.stroke();
        }
        function animate() {
            if (isAnimating) {
                drawHypotrochoids();
                rotationAngle += rotationStep * rotationDirection;
                if (rotationAngle >= maxRotation || rotationAngle <= -maxRotation) {
                    rotationDirection *= -1;
                }
                animationFrameId = requestAnimationFrame(animate);
            }
        }
        controlButton.addEventListener('click', () => {
            isAnimating = !isAnimating;
            if (isAnimating) {
                controlButton.textContent = "Stop";
                animate();
            } else {
                controlButton.textContent = "Start";
                cancelAnimationFrame(animationFrameId);
            }
        });
</script>
