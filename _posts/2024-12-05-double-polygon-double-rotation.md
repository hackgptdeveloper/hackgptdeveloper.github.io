---
title: "Double polygon double rotation"
tags:
  - Graphics
---

Double polygon double rotation

<style>
    canvas {
      border: 1px solid #555;
      background: #222;
    }
    .controls {
      display: flex;
      flex-direction: column;
      gap: 10px;
      margin-top: 10px;
    }
    .control {
      display: flex;
      justify-content: space-between;
      width: 300px;
    }
</style>
<canvas id="canvas" width="600" height="600"></canvas>
<div class="controls">
    <div class="control">
      <label for="outerVertices">Outer Vertices</label>
      <input type="range" id="outerVertices" min="3" max="20" value="6">
    </div>
    <div class="control">
      <label for="innerVertices">Inner Vertices</label>
      <input type="range" id="innerVertices" min="3" max="20" value="5">
    </div>
    <div class="control">
      <label for="outerSpeed">Outer Speed</label>
      <input type="range" id="outerSpeed" min="-5" max="5" value="1" step="0.1">
    </div>
    <div class="control">
      <label for="innerSpeed">Inner Speed</label>
      <input type="range" id="innerSpeed" min="-5" max="5" value="1" step="0.1">
    </div>
</div>
<script>
    const canvas = document.getElementById('canvas');
    const ctx = canvas.getContext('2d');

    const outerVerticesSlider = document.getElementById('outerVertices');
    const innerVerticesSlider = document.getElementById('innerVertices');
    const outerSpeedSlider = document.getElementById('outerSpeed');
    const innerSpeedSlider = document.getElementById('innerSpeed');

    let outerVertices = parseInt(outerVerticesSlider.value);
    let innerVertices = parseInt(innerVerticesSlider.value);
    let outerSpeed = parseFloat(outerSpeedSlider.value);
    let innerSpeed = parseFloat(innerSpeedSlider.value);

    let outerAngle = 0;
    let innerAngle = 0;

    function getPolygonVertices(centerX, centerY, radius, vertices, rotation) {
      const points = [];
      const angleStep = (Math.PI * 2) / vertices;
      for (let i = 0; i < vertices; i++) {
        const x = centerX + radius * Math.cos(rotation + i * angleStep);
        const y = centerY + radius * Math.sin(rotation + i * angleStep);
        points.push({ x, y });
      }
      return points;
    }

    function drawPolygon(vertices, color) {
      ctx.beginPath();
      ctx.moveTo(vertices[0].x, vertices[0].y);
      for (let i = 1; i < vertices.length; i++) {
        ctx.lineTo(vertices[i].x, vertices[i].y);
      }
      ctx.closePath();
      ctx.strokeStyle = color;
      ctx.stroke();
    }

    function connectVertices(innerPoints, outerPoints) {
      ctx.strokeStyle = 'rgba(255, 255, 255, 0.3)';
      innerPoints.forEach(innerPoint => {
        outerPoints.forEach(outerPoint => {
          ctx.beginPath();
          ctx.moveTo(innerPoint.x, innerPoint.y);
          ctx.lineTo(outerPoint.x, outerPoint.y);
          ctx.stroke();
        });
      });
    }

    function animate() {
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      const centerX = canvas.width / 2;
      const centerY = canvas.height / 2;

      const outerRadius = 200;
      const innerRadius = 100;

      const outerPoints = getPolygonVertices(centerX, centerY, outerRadius, outerVertices, outerAngle);
      const innerPoints = getPolygonVertices(centerX, centerY, innerRadius, innerVertices, innerAngle);

      connectVertices(innerPoints, outerPoints);
      drawPolygon(outerPoints, 'red');
      drawPolygon(innerPoints, 'blue');

      outerAngle += outerSpeed * 0.01;
      innerAngle += innerSpeed * 0.01;

      requestAnimationFrame(animate);
    }

    outerVerticesSlider.addEventListener('input', () => {
      outerVertices = parseInt(outerVerticesSlider.value);
    });

    innerVerticesSlider.addEventListener('input', () => {
      innerVertices = parseInt(innerVerticesSlider.value);
    });

    outerSpeedSlider.addEventListener('input', () => {
      outerSpeed = parseFloat(outerSpeedSlider.value);
    });

    innerSpeedSlider.addEventListener('input', () => {
      innerSpeed = parseFloat(innerSpeedSlider.value);
    });

    animate();
</script>
