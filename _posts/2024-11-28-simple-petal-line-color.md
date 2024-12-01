---
title: "Dynamic Petals with Red-Blue-Yellow Gradient"
tags:
  - Graphics
---

Dynamic Petals with Red-Blue-Yellow Gradient

<canvas id="simple_petal" width="600" height="600"></canvas>
<script>
    function getRandomInt(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }
    
    // Function to create gradient palette from red to blue to yellow
    //const gradientColors = [];
    //for (let i = 0; i < 8; i++) {
    //    const r = 255;
    //    const g = Math.floor(255 * (i / 7)); // Green component increases
    //    const b = Math.floor(255 * (i / 7)); // Blue component increases
    //    gradientColors.push(`rgb(${r},${g},${b})`);
    //}
    //for (let i = 0; i < 8; i++) {
    //    const r = 255 - Math.floor(255 * (i / 7)); // Red component decreases
    ////    const g = 255;
    //    const b = 255 - Math.floor(255 * (i / 7)); // Blue component decreases
    //    gradientColors.push(`rgb(${r},${g},${b})`);
    //}
    
    // Function to draw the Petal graphics on the provided canvas
    let counter = 0;
    const colorPalette = [
        '#0000FF', '#1A33FF', '#3366FF', '#4D99FF', '#66CCFF', '#80FFFF', '#99FFCC', '#B3FF99'];
    
    
    /*
        '#CCFF66', '#E6FF33', '#FFFF00', '#FFCC00', '#FF9933', '#FF6600', '#FF3300', '#FFFF33',
        '#0000FF', '#1A33FF', '#3366FF', '#4D99FF', '#66CCFF', '#80FFFF', '#99FFCC', '#B3FF99',
        '#CCFF66', '#E6FF33', '#FFFF00', '#FFCC00', '#FF9933', '#FF6600', '#FF3300', '#FFFF33'
    ];
    */
    
    function drawPetalGraphics(canvas, radius, a, b) {
        const ctx = canvas.getContext('2d');
        const centerX = canvas.width / 2;
        const centerY = canvas.height / 2;
        const points = [];
        
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        ctx.lineWidth = 1;
        ctx.beginPath();
    
        ctx.strokeStyle = 'blue';  //colorPalette[counter % colorPalette.length]; 
        counter++;
    
        for (let theta = 0; theta <= 2 * Math.PI * b; theta += 2 * Math.PI / 30 / a) {
    
            let x = radius * Math.cos(a/b*theta) * Math.cos(theta) + centerX;
            let y = radius * Math.cos(a/b*theta) * Math.sin(theta) + centerY;
    
            if (theta === 0) {
                ctx.moveTo(x, y);
            } else {
                ctx.lineTo(x, y);
            }
            points.push({x, y});
        }
        ctx.closePath();
        ctx.stroke();
        return points;
    }
    
    const canvas = document.getElementById('simple_petal');
    const radius = 280;
    let step = 1;
    let a = 2, b = 5;
    
    function animate() {
        if (step === 58) {
            a = getRandomInt(1, 15);
            b = getRandomInt(1, 15);
    	step=0;
        }
        const points = drawPetalGraphics(canvas, radius, a, b);
        drawLines(points, step);
        step = (step % (60 - 1)) + 1;
        setTimeout(animate, 200);
    }
    
    function drawLines(points, step) {
        const ctx = canvas.getContext('2d');
        for (let i = 0; i < points.length; i++) {
        ctx.strokeStyle = colorPalette[counter % colorPalette.length]; 
        counter++;
            const j = (i + step) % points.length;
            ctx.beginPath();
            ctx.moveTo(points[i].x, points[i].y);
            ctx.lineTo(points[j].x, points[j].y);
            ctx.stroke();
        }
    }
    
    // Start animation
    animate();
</script>
