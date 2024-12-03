---
title: "Flower in Motion"
tags:
  - Graphics
---

Flower in Motion

<style>
        canvas {
            border: 1px solid black;
            background-color: #333;
        }
    
        /* Centered link at the bottom */ 
        .footer-link { 
            position: absolute; 
            bottom: 20px; 
            text-align: center; 
            width: 100%; 
        } 
 
        .footer-link a { 
            font-size: 16px; 
            color: #007bff; 
            text-decoration: none; 
        } 
 
        .footer-link a:hover { 
            text-decoration: underline; 
        } 
</style>
<canvas id="complexLineCanvas" width="600" height="600"></canvas>
    
<script> 
        const canvas = document.getElementById('complexLineCanvas');
        const ctx = canvas.getContext('2d');
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const numLines = 150;

        //let angleMultiplier1 = 2;
        //let angleMultiplier2 = 4;
        let radius1 = 100;
        let radius2 = 100;
        let radius_multiplier = 10;
        let angleOffset = 0;

        // Function to draw the complex pattern
        function drawComplexPattern() {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            ctx.strokeStyle = '#ffffff';
            ctx.lineWidth = 0.5;

            for (let i = 0; i < numLines; i++) {
                const angle1 = (i / numLines) * 2 * Math.PI;
                const angle2 = 2*angle1;
                const x1 = centerX + radius1 * Math.cos((angle2 + angleOffset)) * Math.sin(angle1 + angleOffset);
                const y1 = centerY + radius1 * Math.sin((angle2 + angleOffset)) * Math.sin(angle1 + angleOffset);
                const x2 = centerX + radius2 * Math.cos(angle1 + angleOffset) * Math.sin(angle2 + angleOffset);
                const y2 = centerY + radius2 * Math.sin(angle1 + angleOffset) * Math.sin(angle2 + angleOffset);

                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
                ctx.stroke();
            }

            // Update parameters to create animation
            angleOffset += 0.01;
            radius_multiplier = 10*Math.sin(angleOffset);
            angleMultiplier1 = 2 + Math.sin(angleOffset) * 2;
            angleMultiplier2 = 4 + Math.cos(angleOffset) * 2;
            radius1 = 100 + Math.sin(angleOffset) * 50;
            radius2 = 100 + Math.cos(2*angleOffset) * 50;

            requestAnimationFrame(drawComplexPattern);
        }

        drawComplexPattern();
</script>


```
Notice in this drawing, it is just two circular sinusoidal curve moving at different speed: one is twice the speed of another.

                const angle2 = 2*angle1;
                x1 = radius1 * Math.cos((angle2 + angleOffset)) * Math.sin(angle1 + angleOffset);
                y1 = radius1 * Math.sin((angle2 + angleOffset)) * Math.sin(angle1 + angleOffset);
                x2 = radius2 * Math.cos(angle1 + angleOffset) * Math.sin(angle2 + angleOffset);
                y2 = radius2 * Math.sin(angle1 + angleOffset) * Math.sin(angle2 + angleOffset);
```
