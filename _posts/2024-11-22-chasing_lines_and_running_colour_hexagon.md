---
title: "Chasing lines and running color"
tags:
  - Graphics
---

Chasing lines and special effects of running color.

<canvas id="canvas" width="800" height="600"></canvas>
<script>
        function draw3DHexagon() {
            const canvas = document.getElementById("canvas");
            const ctx = canvas.getContext("2d");
            const parts = 30;
            const hexagonPoints = generateHexagonPoints(200);
            let isDragging = false;
            let draggedPoint = null;
            let offset = 0; // Animation offset

            function generateHexagonPoints(radius) {
                const points = [];
                for (let i = 0; i < 6; i++) {
                    const angle = Math.PI / 3 * i;
                    points.push({
                        x: radius * Math.cos(angle),
                        y: radius * Math.sin(angle),
                        z: Math.random() * 200 // Random z-axis
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

            function drawLines() {
                ctx.clearRect(0, 0, canvas.width, canvas.height);
                for (let i = 0; i < hexagonPoints.length; i++) {
                    const point1 = hexagonPoints[i];
                    const point2 = hexagonPoints[(i + 1) % hexagonPoints.length];
                    
                    const line1Points = calculatePoints({ x: 0, y: 0, z: 0 }, point1);
                    const line2Points = calculatePoints({ x: 0, y: 0, z: 0 }, point2);

                    for (let j = 0; j <= parts; j++) {
                        const startPoint = line1Points[j];
                        const endPoint = line2Points[parts - j];

                        ctx.beginPath();
                        ctx.moveTo(startPoint.x + 400, startPoint.y + 300);
                        ctx.lineTo(endPoint.x + 400, endPoint.y + 300);
                        ctx.strokeStyle = `hsl(${((j + offset) % parts / parts) * 360}, 100%, 50%)`;
                        ctx.stroke();
                    }
                }
            }

            canvas.addEventListener("mousedown", (event) => {
                const { offsetX, offsetY } = event;
                const threshold = 20;
                hexagonPoints.forEach((point, index) => {
                    const distance = Math.hypot(offsetX - (point.x + 400), offsetY - (point.y + 300));
                    if (distance < threshold) {
                        isDragging = true;
                        draggedPoint = index;
                    }
                });
            });

            canvas.addEventListener("mousemove", (event) => {
                if (isDragging && draggedPoint !== null) {
                    hexagonPoints[draggedPoint].x = event.offsetX - 400;
                    hexagonPoints[draggedPoint].y = event.offsetY - 300;
                }
            });

            canvas.addEventListener("mouseup", () => {
                isDragging = false;
                draggedPoint = null;
            });

            function animate() {
                offset++; // Increment offset for animation
                drawLines();
                requestAnimationFrame(animate);
            }

            animate(); // Start animation
        }

        draw3DHexagon();
</script>
