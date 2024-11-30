---
title: "Chasing diagram on hexagon around hexagon animated with color."
tags:
  - AI, chatbot, Mathematics, graphics
---

Chasing diagram on hexagon around hexagon animated with color shifting.

<canvas id="hexagonCanvas" width="600" height="600"></canvas>
<script> 
        const canvas = document.getElementById('hexagonCanvas');
        const ctx = canvas.getContext('2d');
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const hexagonRadius = 100;
        const newhexagonRadius = 100;
        let global_counter = 0;

        // Function to calculate a point on the hexagon given an angle
        function gethexagonPoints(centerX, centerY, radius, rotationAngle = 0) {
            const points = [];
            for (let i = 0; i < 6; i++) {
                const angle = (2 * Math.PI * i / 6) + rotationAngle;
                const x = centerX + radius * Math.cos(angle);
                const y = centerY + radius * Math.sin(angle);
                points.push({x, y});
            }
            return points;
        }

        // Function to draw a hexagon given a set of points
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

        // Function to find the vector A and calculate the new center for the translated hexagon
        function findNewhexagonCenter(center, midpoint) {
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

        // Main function to generate the hexagons and draw them
        function generateAndDrawhexagons() {
            // Original hexagon points
            const originalhexagon = gethexagonPoints(centerX, centerY, hexagonRadius);

            // Draw the original hexagon
            ctx.strokeStyle = 'red';
            drawPolygon(originalhexagon);
            drawChasingPolygon(originalhexagon, 40);

            // Loop through each edge of the original hexagon
            for (let i = 0; i < originalhexagon.length; i++) {
                const p1 = originalhexagon[i];
                const p2 = originalhexagon[(i + 1) % originalhexagon.length];

                const angle =  -60 * Math.PI/180;

                // Calculate the midpoint of the edge
                const midpoint = calculateMidpoint(p1, p2);

                // Find the center of the new hexagon
                const newCenter = findNewhexagonCenter({x: centerX, y: centerY}, midpoint);

                // Draw the new hexagon rotated by the edge angle
                ctx.strokeStyle = 'blue';
                const rotatedhexagon = gethexagonPoints(newCenter.x, newCenter.y, newhexagonRadius, angle);
                drawPolygon(rotatedhexagon);
                drawChasingPolygon(rotatedhexagon, 40);
            }
        }

    function drawhexagon(points) {
        let edges = [];
        ctx.beginPath();
        for (let i = 0; i < points.length; i++) {
            const startPoint = points[i];
            const endPoint = points[(i + 1) % points.length]; // Connect the last point to the first
	    ctx.strokeStyle = `hsl(${((i+global_counter)%points.length / points.length) * 360}, 100%, 50%)`;
	    global_counter += 1;
            ctx.beginPath();
            ctx.moveTo(startPoint.x, startPoint.y);
            ctx.lineTo(endPoint.x, endPoint.y);
            edges.push([startPoint, endPoint]);
            ctx.stroke();
        }
        return edges;
    }

    // Function to calculate the next hexagon's points
    function getNexthexagonPoints(previousEdges) {
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

    // Function to create the hexagons iteratively
    function drawChasingPolygon(initialPoints, iterations) {
        let currentPoints = initialPoints;
        for (let i = 0; i < iterations; i++) {
            const edges = drawhexagon(currentPoints);
            //hexagonsEdges.push(edges); // Store the edges
            currentPoints = getNexthexagonPoints(edges); // Calculate the next hexagon's points
        }
    }

        // Call the function to generate and draw the hexagons
        generateAndDrawhexagons();
</script>
