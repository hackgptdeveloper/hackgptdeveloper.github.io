---
title: "Chasing diagram on pentagon around pentagon"
tags:
  - Graphics
---

Drawing chasing diagram on pentagon around pentagon.

<canvas id="pentagonCanvas" width="600" height="600"></canvas>
<script> 
        const canvas = document.getElementById('pentagonCanvas');
        const ctx = canvas.getContext('2d');
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const pentagonRadius = 100;
        const newPentagonRadius = 100;

        // Function to calculate a point on the pentagon given an angle
        function getPentagonPoints(centerX, centerY, radius, rotationAngle = 0) {
            const points = [];
            for (let i = 0; i < 5; i++) {
                const angle = (2 * Math.PI * i / 5) + rotationAngle;
                const x = centerX + radius * Math.cos(angle);
                const y = centerY + radius * Math.sin(angle);
                points.push({x, y});
            }
            return points;
        }

        // Function to draw a pentagon given a set of points
        function drawPolygon(points) {
            ctx.beginPath();
            ctx.moveTo(points[0].x, points[0].y);
            for (let i = 1; i < points.length; i++) {
                ctx.lineTo(points[i].x, points[i].y);
            }
            ctx.closePath();
            ctx.stroke();
        }

        // Function to calculate the midpoint of an edge
        function calculateMidpoint(p1, p2) {
            return {
                x: (p1.x + p2.x) / 2,
                y: (p1.y + p2.y) / 2
            };
        }

        // Function to find the vector A and calculate the new center for the translated pentagon
        function findNewPentagonCenter(center, midpoint) {
            const vectorA = {
                x: midpoint.x - center.x,
                y: midpoint.y - center.y
            };
            const newCenter = {
                x: center.x + 2 * vectorA.x,
                y: center.y + 2 * vectorA.y
            };
            return newCenter;
        }

        // Main function to generate the pentagons and draw them
        function generateAndDrawPentagons() {
            // Original pentagon points
            const originalPentagon = getPentagonPoints(centerX, centerY, pentagonRadius);

            // Draw the original pentagon
            ctx.strokeStyle = 'red';
            drawPolygon(originalPentagon);
            drawChasingPolygon(originalPentagon, 40);

            // Loop through each edge of the original pentagon
            for (let i = 0; i < originalPentagon.length; i++) {
                const p1 = originalPentagon[i];
                const p2 = originalPentagon[(i + 1) % originalPentagon.length];

                const angle =  -36 * Math.PI/180;

                // Calculate the midpoint of the edge
                const midpoint = calculateMidpoint(p1, p2);

                // Find the center of the new pentagon
                const newCenter = findNewPentagonCenter({x: centerX, y: centerY}, midpoint);

                // Draw the new pentagon rotated by the edge angle
                ctx.strokeStyle = 'blue';
                const rotatedPentagon = getPentagonPoints(newCenter.x, newCenter.y, newPentagonRadius, angle);
                drawPolygon(rotatedPentagon);
                drawChasingPolygon(rotatedPentagon, 40);
            }
        }

    function drawPentagon(points) {
        let edges = [];
        ctx.beginPath();
        for (let i = 0; i < points.length; i++) {
            const startPoint = points[i];
            const endPoint = points[(i + 1) % points.length]; // Connect the last point to the first
            ctx.moveTo(startPoint.x, startPoint.y);
            ctx.lineTo(endPoint.x, endPoint.y);
            edges.push([startPoint, endPoint]);
        }
        ctx.stroke();
        return edges;
    }

    // Function to calculate the next pentagon's points
    function getNextPentagonPoints(previousEdges) {
        let newPoints = [];

        // For each edge, calculate a point 1/10th along the line
        for (let i = 0; i < previousEdges.length; i++) {
            const startPoint = previousEdges[i][0];
            const endPoint = previousEdges[i][1];

            // Calculate 1/10th point along the line
            const newPoint = {
                x: startPoint.x + (endPoint.x - startPoint.x) * 0.1,
                y: startPoint.y + (endPoint.y - startPoint.y) * 0.1
            };
            newPoints.push(newPoint);
        }

        return newPoints;
    }

    // Function to create the pentagons iteratively
    function drawChasingPolygon(initialPoints, iterations) {
        let currentPoints = initialPoints;
        for (let i = 0; i < iterations; i++) {
            const edges = drawPentagon(currentPoints);
            //pentagonsEdges.push(edges); // Store the edges
            currentPoints = getNextPentagonPoints(edges); // Calculate the next pentagon's points
        }
    }

    // Call the function to generate and draw the pentagons
    generateAndDrawPentagons();
</script>
