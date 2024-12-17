---
title:  "Circle Rotating Around a Circle Contour with Trail"
tags:
  - Graphics
---

***Circle Rotating Around a Circle Contour with Trail***

<div id="container">
    <canvas id="canvas" width="500" height="500"></canvas>
    <canvas id="trailCanvas" width="500" height="500"></canvas>
</div>
<div id="controls">
    <label>
      bigRadius: <input type="range" id="bigRadius1Slider" min="50" max="250" step="1" value="200">
    </label>
    <label>
      bigRadius: <input type="range" id="bigRadius2Slider" min="50" max="250" step="1" value="50">
    </label>
    <label>
      smallRadius: <input type="range" id="smallRadiusSlider" min="10" max="100" step="1" value="50">
    </label>
</div>
<script> 
  const canvas = document.getElementById('canvas');
  const trailCanvas = document.getElementById('trailCanvas');
  const ctx = canvas.getContext('2d');
  const trailCtx = trailCanvas.getContext('2d');
  
  let bigRadius1 = parseInt(document.getElementById('bigRadius1Slider').value);
  let bigRadius2 = parseInt(document.getElementById('bigRadius2Slider').value);
  let smallRadius = parseInt(document.getElementById('smallRadiusSlider').value);
  
  const centerX = canvas.width / 2;
  const centerY = canvas.height / 2;
  
  let angle = 0;
  let lastPointX, lastPointY;

  // Update values and clear trail on radius change
  document.getElementById('bigRadius1Slider').addEventListener('input', function() {
    bigRadius1 = parseInt(this.value);
    trailCtx.clearRect(0, 0, trailCanvas.width, trailCanvas.height);  // Clear trail
  });
  document.getElementById('bigRadius2Slider').addEventListener('input', function() {
    bigRadius2 = parseInt(this.value);
    trailCtx.clearRect(0, 0, trailCanvas.width, trailCanvas.height);  // Clear trail
  });
  
  document.getElementById('smallRadiusSlider').addEventListener('input', function() {
    smallRadius = parseInt(this.value);
    trailCtx.clearRect(0, 0, trailCanvas.width, trailCanvas.height);  // Clear trail
  });

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw the big circle
    ctx.beginPath();
    ctx.ellipse(centerX, centerY, bigRadius1, bigRadius2, 0, 8 * Math.PI, true);
    ctx.stroke();
    
    // Position of the small circle's center as it rotates inside the big circle
    const smallCenterX = centerX + (bigRadius1 - smallRadius) * Math.cos(angle);
    const smallCenterY = centerY + (bigRadius2 - smallRadius) * Math.sin(angle);
    
    // Draw the small circle
    ctx.beginPath();
    ctx.arc(smallCenterX, smallCenterY, smallRadius, 0, 2 * Math.PI);
    ctx.stroke();
    
    // Draw the point on the small circle tracing the contour
    const pointX = smallCenterX + smallRadius * Math.cos(-((bigRadius1 + bigRadius2)/2/smallRadius - 1) * angle);
    const pointY = smallCenterY + smallRadius * Math.sin(-((bigRadius2 + bigRadius1)/2 / smallRadius - 1) * angle);
    
    ctx.beginPath();
    ctx.arc(pointX, pointY, 3, 0, 2 * Math.PI);
    ctx.fillStyle = 'red';
    ctx.fill();

    // Draw trail on the trail canvas
    if (lastPointX !== undefined && lastPointY !== undefined) {
      trailCtx.beginPath();
      trailCtx.moveTo(lastPointX, lastPointY);
      trailCtx.lineTo(pointX, pointY);
      trailCtx.strokeStyle = 'red';
      trailCtx.lineWidth = 1;
      trailCtx.stroke();
    }

    // Update last coordinates for trail drawing
    lastPointX = pointX;
    lastPointY = pointY;

    // Update the angle for the next frame
    angle += 2 * Math.PI / 240;
    
    requestAnimationFrame(draw);
  }
  
  draw();
</script>
