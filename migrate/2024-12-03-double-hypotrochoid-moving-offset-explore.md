---
title: "Hypotrochoid Curves with Rotation and Offset Control"
tags:
  - Graphics
---

Hypotrochoid Curves with Rotation and Offset Control

<style>
        canvas {
            border: 1px solid black;
            margin-bottom: 20px;
        }
        #offsetSlider {
            margin-top: 20px;
            width: 300px;
        }
        #startStopButton {
            margin-top: 20px;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
        }
</style>
<canvas id="canvas" width="800" height="800"></canvas>
<div>
	<input type="range" id="offsetSlider" min="1" max="239" value="1">
	<label for="offsetSlider">Offset</label>
	<button id="startStopButton">Start</button>
</div>
<script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');
        const offsetSlider = document.getElementById('offsetSlider');
        const startStopButton = document.getElementById('startStopButton');
        
        const width = canvas.width;
        const height = canvas.height;
        let offset = parseInt(offsetSlider.value);
        let isAnimating = false;
        let rotationAngle = 0;
        let rotationStep = 5;
        let rotationDirection = 1;
        const maxRotation = 720;

        offsetSlider.addEventListener('input', function() {
            offset = parseInt(this.value);
        });

        // Utility function to calculate the greatest common divisor (GCD)
        Math.gcd = function(a, b) {
            return b ? Math.gcd(b, a % b) : Math.abs(a);
        };

        // Function to generate Hypotrochoid points
        function generateHypotrochoid(R, r, d, numPoints, angleOffset = 0) {
            const points = [];
            const step = (2 * Math.PI * r / Math.gcd(R, r)) / numPoints;
            const radiansOffset = (Math.PI / 180) * angleOffset;

            for (let t = 0; t <= 2 * Math.PI * r / Math.gcd(R, r); t += step) {
                const x = (R - r) * Math.cos(t + radiansOffset) + d * Math.cos(((R - r) / r) * (t + radiansOffset));
                const y = (R - r) * Math.sin(t + radiansOffset) - d * Math.sin(((R - r) / r) * (t + radiansOffset));
                points.push({ x: width / 2 + x, y: height / 2 - y });
            }

            return points;
        }

        const points1 = generateHypotrochoid(200, 40, 60, 240);

        function drawHypotrochoids() {
            const points2 = generateHypotrochoid(300, 60, 100, 240, rotationAngle);

            ctx.clearRect(0, 0, width, height);

            // Draw connections between points of both curves
            for (let i = 0; i < points1.length - 1; i++) {
                const adjustedIndex = (i + offset) % points1.length;
                ctx.beginPath();
                ctx.moveTo(points1[i].x, points1[i].y);
                ctx.lineTo(points2[i].x, points2[i].y);
                ctx.lineTo(points1[adjustedIndex].x, points1[adjustedIndex].y);
                ctx.strokeStyle = 'rgba(0, 0, 255, 0.5)';
                ctx.stroke();
            }

            // Draw the first Hypotrochoid curve
            ctx.beginPath();
            ctx.moveTo(points1[0].x, points1[0].y);
            for (let i = 1; i < points1.length; i++) {
                ctx.lineTo(points1[i].x, points1[i].y);
            }
            ctx.strokeStyle = 'red';
            ctx.stroke();

            // Draw the second Hypotrochoid curve
            ctx.beginPath();
            ctx.moveTo(points2[0].x, points2[0].y);
            for (let i = 1; i < points2.length; i++) {
                ctx.lineTo(points2[i].x, points2[i].y);
            }
            ctx.strokeStyle = 'green';
            ctx.stroke();
        }

        function animate() {
            if (isAnimating) {
                drawHypotrochoids();
                rotationAngle += rotationStep * rotationDirection;

                // Reverse rotation direction after reaching 720 degrees
                if (rotationAngle >= maxRotation || rotationAngle <= -maxRotation) {
                    rotationDirection *= -1;
                }

                requestAnimationFrame(animate);
            }
        }

        startStopButton.addEventListener('click', () => {
            isAnimating = !isAnimating;
            if (isAnimating) {
                startStopButton.textContent = 'Stop';
                animate();
            } else {
                startStopButton.textContent = 'Start';
            }
        });
</script>
