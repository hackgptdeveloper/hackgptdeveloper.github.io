---
title: "AI generated javascript: Chasing diagram on a circle"
tags:
  - AI, chatbot, Mathematics, graphics
---

This is just drawing two circles and joing lines from one circle to another, and input parameter is just adjusting the index offset from 0 to connect.

<canvas id="circleCanvas" width="600" height="600"></canvas>
<div class="controls">
        <div class="control-container">
            <label for="aaaa">Index offset on first circle: </label>
            <input type="range" id="aaaa" name="aaaa" min="0" max="360" value="0">
            <div><span id="aaaaValue">0</span></div>
        </div>
        <div class="control-container">
            <label for="bbbb">Index offset on 2nd circle: </label>
            <input type="range" id="bbbb" name="bbbb" min="0" max="360" value="0">
            <div><span id="bbbbValue">0</span></div>
        </div>
        <div class="control-container">
            <label for="totalPoints">Total Points: </label>
            <input type="range" id="totalPoints" name="totalPoints" min="3" max="360" value="360">
            <div><span id="totalPointsValue">360</span></div>
        </div>
</div>

<script>
        const canvas = document.getElementById("circleCanvas");
        const ctx = canvas.getContext("2d");
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const radius = 250;

        // Get HTML elements for scrollbars and labels
        const aaaaSlider = document.getElementById('aaaa');
        const bbbbSlider = document.getElementById('bbbb');
        const totalPointsSlider = document.getElementById('totalPoints');
        const aaaaLabel = document.getElementById('aaaaValue');
        const bbbbLabel = document.getElementById('bbbbValue');
        const totalPointsLabel = document.getElementById('totalPointsValue');

        // Function to calculate the position of a point on the circumference
        function getPointOnCircle(angle, totalPoints) {
            const radian = (angle * Math.PI) / 180;
            const x = centerX + radius * Math.cos(radian);
            const y = centerY + radius * Math.sin(radian);
            return { x, y };
        }

        // Draw the circle
        function drawCircle() {
            ctx.clearRect(0, 0, canvas.width, canvas.height); // Clear the canvas
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
            ctx.stroke();
        }

        // Draw the lines based on the current slider values for all points
        function drawLinesForAllPoints() {
            const aaaaValue = parseInt(aaaaSlider.value);
            const bbbbValue = parseInt(bbbbSlider.value);
            const totalPoints = parseInt(totalPointsSlider.value);

            // Loop through all points based on totalPoints
            for (let i = 0; i < totalPoints; i++) {
                const pointAngle = (i * 360) / totalPoints; // Calculate angle for the ith point
                const point = getPointOnCircle(pointAngle, totalPoints); // Current point

                const pointAAAAIndex = (i + aaaaValue) % totalPoints;  // Index for point AAAA
                const pointAAAAAngle = (pointAAAAIndex * 360) / totalPoints;  // Angle for point AAAA
                const pointAAAA = getPointOnCircle(pointAAAAAngle, totalPoints);  // Point AAAA

                const pointBBBBIndex = (i + bbbbValue) % totalPoints;  // Index for point BBBB
                const pointBBBBAngle = (pointBBBBIndex * 360) / totalPoints;  // Angle for point BBBB
                const pointBBBB = getPointOnCircle(pointBBBBAngle, totalPoints);  // Point BBBB

                // Draw the first line from current point to point AAAA
                ctx.beginPath();
                ctx.moveTo(point.x, point.y);
                ctx.lineTo(pointAAAA.x, pointAAAA.y);
                ctx.strokeStyle = 'blue';
                ctx.stroke();

                // Draw the second line from point AAAA to point BBBB
                ctx.beginPath();
                ctx.moveTo(pointAAAA.x, pointAAAA.y);
                ctx.lineTo(pointBBBB.x, pointBBBB.y);
                ctx.strokeStyle = 'red';
                ctx.stroke();
            }
        }

        // Initial draw
        drawCircle();
        drawLinesForAllPoints();

        // Update the labels to show the current value of sliders
        function updateLabels() {
            aaaaLabel.textContent = aaaaSlider.value;
            bbbbLabel.textContent = bbbbSlider.value;
            totalPointsLabel.textContent = totalPointsSlider.value;
        }

        // Add event listeners for the scrollbars
        aaaaSlider.addEventListener('input', function () {
            updateLabels();
            drawCircle();
            drawLinesForAllPoints();
        });

        bbbbSlider.addEventListener('input', function () {
            updateLabels();
            drawCircle();
            drawLinesForAllPoints();
        });

        totalPointsSlider.addEventListener('input', function () {
            updateLabels();
            const totalPoints = parseInt(totalPointsSlider.value);
            aaaaSlider.max = totalPoints;
            bbbbSlider.max = totalPoints;
            drawCircle();
            drawLinesForAllPoints();
        });

</script>
