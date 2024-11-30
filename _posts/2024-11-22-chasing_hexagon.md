---
title: "Chasing on hexagon"
tags:
  - AI, chatbot, Mathematics, graphics
---

Chasing diagram on hexagon.

<canvas id="pentagonCanvas" width="500" height="500"></canvas>
<script> 
    const canvas = document.getElementById('pentagonCanvas');
    const ctx = canvas.getContext('2d');

    // Store the edges of each pentagon
    let pentagonsEdges = [];

    // Function to draw a pentagon and return its edges
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
    function createPentagons(initialPoints, iterations) {
        let currentPoints = initialPoints;
        for (let i = 0; i < iterations; i++) {
            const edges = drawPentagon(currentPoints);
            pentagonsEdges.push(edges); // Store the edges
            currentPoints = getNextPentagonPoints(edges); // Calculate the next pentagon's points
        }
    }

    // Initial points for the first pentagon ABCDE
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;
    const radius = 150;

    // Generate points for the initial pentagon ABCDE
    const initialPentagon = [];
    for (let i = 0; i < 6; i++) {
        const angle = (2 * Math.PI / 6) * i - Math.PI / 2; // Starting from the top
        initialPentagon.push({
            x: centerX + radius * Math.cos(angle),
            y: centerY + radius * Math.sin(angle)
        });
    }

    // Create and draw 3 iterations of pentagons
    createPentagons(initialPentagon, 40);

</script>
