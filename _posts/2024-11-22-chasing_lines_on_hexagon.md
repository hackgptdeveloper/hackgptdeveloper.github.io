---
title: "Chasing lines on rotating hexagon"
categories:
  - Graphics
tags:
  - AI, chatbot, Mathematics, graphics
---

Chasing lines on rotating hexagon.

<canvas id="canvas" width="800" height="600"></canvas>
<script>
        function drawRotating3DHexagon() {
            const canvas = document.getElementById("canvas");
            const ctx = canvas.getContext("2d");
            const parts = 60;
            const hexagonPoints = generateHexagonPoints(200);
            let rotationX = 0.01;
            let rotationY = 0.01;
            let rotationZ = 0.01;
            let counter = 0;
            let randomx = 0.01 * (Math.random() - 0.5);
            let randomy = 0.01 * (Math.random() - 0.5);
            let randomz = 0.01 * (Math.random() - 0.5);

            function generateHexagonPoints(radius) {
                const points = [];
                for (let i = 0; i < 6; i++) {
                    const angle = Math.PI / 3 * i;
                    points.push({
                        x: radius * Math.cos(angle),
                        y: radius * Math.sin(angle),
                        z: Math.random() * 200
                    });
                }
                return points;
            }

            function calculatePoints(start, end) {
                const points = [];
                for (let i = 0; i <= parts; i++) {
                    const t = i / parts;
                    points.push({
                        x: start.x + t * (end.x - start.x),
                        y: start.y + t * (end.y - start.y),
                        z: start.z + t * (end.z - start.z)
                    });
                }
                return points;
            }

            function getColorGradient(t) {
                const red = Math.floor(255 * (1 - t));
                const green = Math.floor(255 * t);
                const blue = 150;
                return `rgb(${red}, ${green}, ${blue})`;
            }

            function rotate3D(point) {
                // Rotation around X axis
                let { x, y, z } = point;
                let cosX = Math.cos(rotationX), sinX = Math.sin(rotationX);
                let y1 = y * cosX - z * sinX;
                let z1 = y * sinX + z * cosX;

                // Rotation around Y axis
                let cosY = Math.cos(rotationY), sinY = Math.sin(rotationY);
                let x2 = x * cosY + z1 * sinY;
                let z2 = -x * sinY + z1 * cosY;

                // Rotation around Z axis
                let cosZ = Math.cos(rotationZ), sinZ = Math.sin(rotationZ);
                let x3 = x2 * cosZ - y1 * sinZ;
                let y3 = x2 * sinZ + y1 * cosZ;

                return { x: x3, y: y3, z: z2 };
            }

            function drawLines() {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                const rotatedPoints = hexagonPoints.map(rotate3D);

                for (let i = 0; i < rotatedPoints.length; i++) {
                    const point1 = rotatedPoints[i];
                    const point2 = rotatedPoints[(i + 1) % rotatedPoints.length];
                    
                    const line1Points = calculatePoints({ x: 0, y: 0, z: 0 }, point1);
                    const line2Points = calculatePoints({ x: 0, y: 0, z: 0 }, point2);

                    for (let j = 0; j <= parts; j++) {
                        const startPoint = line1Points[j];
                        const endPoint = line2Points[parts - j];

                        ctx.beginPath();
                        ctx.moveTo(startPoint.x + 400, startPoint.y + 300);
                        ctx.lineTo(endPoint.x + 400, endPoint.y + 300);
                        ctx.strokeStyle = getColorGradient(j / parts);
                        ctx.stroke();
                    }
                }
            }

            function animate() {
                drawLines();
		if (counter > 500) {
                randomx = 0.01 * (Math.random() - 0.5);
                randomy = 0.01 * (Math.random() - 0.5);
                randomz = 0.01 * (Math.random() - 0.5);
		counter=0;
		}
		else {
                rotationX += randomx;
                rotationY += randomy;
                rotationZ += randomz;
		counter++;
		}
                requestAnimationFrame(animate);
            }

            animate(); // Start animation loop
        }

        drawRotating3DHexagon();
</script>
