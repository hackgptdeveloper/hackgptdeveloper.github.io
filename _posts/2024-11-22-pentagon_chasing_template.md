---
title: "Pentagon with Colored Line"
tags:
  - Graphics
---

How to draw pentagon with colored lines.   This method of drawing lines is called chasing diagram.   The two adjacent edge of the pentagon are specified.

<style>
        canvas {
            background-color: white;
            border: 1px solid #ccc;
        }
</style>
<canvas id="canvas" width="600" height="600" style="border:1px solid #000;"></canvas>
<script>
        const canvas = document.getElementById('canvas');
        const ctx = canvas.getContext('2d');

        // Pentagon vertices
        const vertexA = { x: 300, y: 100 };
        const vertexB = { x: 500, y: 250 };
        const vertexC = { x: 400, y: 500 };
        const vertexD = { x: 200, y: 500 };
        const vertexE = { x: 100, y: 250 };

        // Draw the pentagon
        ctx.beginPath();
        ctx.moveTo(vertexA.x, vertexA.y);
        ctx.lineTo(vertexB.x, vertexB.y);
        ctx.lineTo(vertexC.x, vertexC.y);
        ctx.lineTo(vertexD.x, vertexD.y);
        ctx.lineTo(vertexE.x, vertexE.y);
        ctx.closePath();
        ctx.stroke();

        // Function to divide a line into equal parts
        function divideLine(start, end, parts) {
            const points = [];
            for (let i = 0; i <= parts; i++) {
                const x = start.x + (end.x - start.x) * (i / parts);
                const y = start.y + (end.y - start.y) * (i / parts);
                points.push({ x, y });
            }
            return points;
        }

        // Divide each side into 60 equal parts
        const pointsAB = divideLine(vertexA, vertexB, 60);
        const pointsBA = divideLine(vertexB, vertexA, 60);
        const pointsBC = divideLine(vertexB, vertexC, 60);
        const pointsCB = divideLine(vertexC, vertexB, 60);
        const pointsCD = divideLine(vertexC, vertexD, 60);
        const pointsDC = divideLine(vertexD, vertexC, 60);
        const pointsDE = divideLine(vertexD, vertexE, 60);
        const pointsED = divideLine(vertexE, vertexD, 60);
        const pointsEA = divideLine(vertexE, vertexA, 60);
        const pointsAE = divideLine(vertexA, vertexE, 60);

        // Function to draw connecting lines with color gradient
        function drawConnectingLines(points1, points2, hueOffset) {
            for (let i = 0; i < 60; i++) {
                const point1 = points1[60 - i - 1];
                const point2 = points2[i];
                const hue = (i * 6 + hueOffset) % 360; // Offset hue to vary colors
                ctx.strokeStyle = `hsl(${hue}, 100%, 50%)`;
                ctx.beginPath();
                ctx.moveTo(point1.x, point1.y);
                ctx.lineTo(point2.x, point2.y);
                ctx.stroke();
            }
        }

        // Draw connecting lines for each pair of sides
        drawConnectingLines(pointsAB, pointsAE, 0);    // Side AB to EA
        drawConnectingLines(pointsBA, pointsBC, 72);   // Side AB to BC
        drawConnectingLines(pointsCB, pointsCD, 144);  // Side BC to CD
        drawConnectingLines(pointsDC, pointsDE, 216);  // Side CD to DE
        drawConnectingLines(pointsED, pointsEA, 288);  // Side DE to EA
</script>
