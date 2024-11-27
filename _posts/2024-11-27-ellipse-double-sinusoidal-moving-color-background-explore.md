---
title: "AI generated javascript: Animated Sinusoidal Wave on Ellipse"
categories:
  - AI
tags:
  - AI, chatbot, Javascript
---

AI generated javascript: Animated Sinusoidal Wave on Ellipse 

Amplitude * sin(B * theta) * sin (A * theta)

<style>
    canvas {
      border: 1px solid black;
    }
    .controls {
      display: flex;
      align-items: center;
      margin-top: 10px;
    }
    .label {
      margin-right: 10px;
      font-weight: bold;
    }
    .frequency-value, .dropdown {
      margin-left: 10px;
    }
</style>
<canvas id="ellipseCanvas" width="600" height="600"></canvas>
<!-- Controls -->
<div class="controls">
    <span class="label">Amplitude:</span>
    <input type="range" id="amplitudecontrol" min="1" max="300" value="10">
    <span id="amplitudevalue" class="frequency-value">10</span>
    <span class="label">A:</span>
    <input type="range" id="frequencyControlA" min="1" max="100" value="10">
    <span id="frequencyValueA" class="frequency-value">10</span>
    <span class="label">B:</span>
    <input type="range" id="frequencyControlB" min="1" max="100" value="10">
    <span id="frequencyValueB" class="frequency-value">10</span>
    
    <div class="dropdown">
      <label class="label">Color Gradient:</label>
      <select id="colorGradientSelector">
        <option value="blueToRed">Blue to Red</option>
        <option value="greenToPurple">Green to Purple</option>
        <option value="yellowToOrange">Yellow to Orange</option>
      </select>
    </div>
    
    <div class="dropdown">
      <label class="label">Background Color:</label>
      <input type="color" id="backgroundColorPicker" value="#FFFFFF">
    </div>
</div>

<script>
    const canvas = document.getElementById('ellipseCanvas');
    const ctx = canvas.getContext('2d');

    const majorAxis = 200; // Length of the major axis of the ellipse
    const minorAxis = 100; // Length of the minor axis of the ellipse
    let A = 10;  // Amplitude of the wave
    let B1 = 10;    // Frequency multiplier for the wave (initial value)
    let B2 = 10;    // Frequency multiplier for the wave (initial value)
    let phase = 0; // Initial phase for the animation

    let baseBgColor = "#FFFFFF"; // Base background color
    let currentBgColor = { r: 255, g: 255, b: 255 }; // Current background color that morphs

    // Define color gradients
    const gradients = {
      blueToRed: ["#0000FF", "#3333FF", "#6666FF", "#9999FF", "#FF9999", "#FF6666", "#FF3333", "#FF0000"],
      greenToPurple: ["#00FF00", "#33FF33", "#66FF66", "#99FF99", "#CC99FF", "#9966FF", "#6633FF", "#3300FF"],
      yellowToOrange: ["#FFFF00", "#FFCC00", "#FF9900", "#FF6600", "#FF3300", "#FF0033", "#CC0033", "#990033"],
    };
    let selectedGradient = gradients.blueToRed;

    // Center of the canvas
    const centerX = canvas.width / 2;
    const centerY = canvas.height / 2;

    // Convert hex color to RGB
    function hexToRgb(hex) {
      const bigint = parseInt(hex.slice(1), 16);
      return {
        r: (bigint >> 16) & 255,
        g: (bigint >> 8) & 255,
        b: bigint & 255
      };
    }

    // Morph the background color slightly
    function morphBackgroundColor() {
      const { r, g, b } = currentBgColor;

      currentBgColor = {
        r: Math.min(255, Math.max(0, r + (Math.random() - 0.5) * 10)),
        g: Math.min(255, Math.max(0, g + (Math.random() - 0.5) * 10)),
        b: Math.min(255, Math.max(0, b + (Math.random() - 0.5) * 10)),
      };
      ctx.fillStyle = `rgb(${Math.floor(currentBgColor.r)}, ${Math.floor(currentBgColor.g)}, ${Math.floor(currentBgColor.b)})`;
      ctx.fillRect(0, 0, canvas.width, canvas.height);
    }

    // Function to draw the sinusoidal wave along the ellipse

function drawWaveEllipse(major, minor, amplitude, frequencyA, frequencyB, phaseShift) {
  const steps = 360 * 10; // Number of points along the ellipse
  
  ctx.beginPath(); // Begin a new path for the curve
  for (let i = 0; i < steps; i++) {
    const angle = (i * Math.PI) / 180; // Convert degrees to radians

    // Calculate the elliptical position with sinusoidal radial displacement
    const r = amplitude * Math.sin(frequencyB * angle + phaseShift) * Math.sin(frequencyA * angle);
    const x = centerX + (major + r) * Math.cos(angle);
    const y = centerY + (minor + r) * Math.sin(angle);

    if (i === 0) {
      // Move to the starting point for the curve
      ctx.moveTo(x, y);
    } else {
      // Draw a line to the next point
      ctx.lineTo(x, y);
    }
  }

  ctx.closePath(); // Close the curve (optional for continuous shapes)
  ctx.strokeStyle = selectedGradient[selectedGradient.length - 1]; // Use the final color from the gradient
  ctx.stroke(); // Render the curve
}

    // Function to draw the entire scene with the waving ellipse
    function draw() {
      morphBackgroundColor(); // Apply the morphing background color
      ctx.clearRect(0, 0, canvas.width, canvas.height);
      ctx.lineWidth = 2;

      // Draw the sinusoidal wave ellipse with the current phase shift and gradient
      drawWaveEllipse(majorAxis, minorAxis, A, B1, B2, phase);
    }

    // Animation loop
    function animate() {
      phase += 0.1; // Increment phase for animation effect
      draw();
      requestAnimationFrame(animate); // Loop the animation
    }

    // Amplitude control
    const amplitudecontrol = document.getElementById('amplitudecontrol');
    const amplitudevalue = document.getElementById('amplitudevalue');

    // Frequency control
    const frequencyControlA = document.getElementById('frequencyControlA');
    const frequencyValueA = document.getElementById('frequencyValueA');

    const frequencyControlB = document.getElementById('frequencyControlB');
    const frequencyValueB = document.getElementById('frequencyValueB');

    // Event listener to update frequency and redraw on change
    amplitudecontrol.addEventListener('input', (event) => {
      A = parseInt(event.target.value, 10);
      amplitudevalue.textContent = A;
      draw();
    });

    // Event listener to update frequency and redraw on change
    frequencyControlA.addEventListener('input', (event) => {
      B1 = parseInt(event.target.value, 10);
      frequencyValueA.textContent = B1;
      draw();
    });

    frequencyControlB.addEventListener('input', (event) => {
      B2 = parseInt(event.target.value, 10);
      frequencyValueB.textContent = B2;
      draw();
    });

    // Color gradient selector
    const colorGradientSelector = document.getElementById('colorGradientSelector');
    colorGradientSelector.addEventListener('change', (event) => {
      selectedGradient = gradients[event.target.value];
      draw();
    });

    // Background color picker
    const backgroundColorPicker = document.getElementById('backgroundColorPicker');
    backgroundColorPicker.addEventListener('input', (event) => {
      baseBgColor = event.target.value;
      currentBgColor = hexToRgb(baseBgColor);
      draw();
    });

    // Start the animation
    animate();
</script>
