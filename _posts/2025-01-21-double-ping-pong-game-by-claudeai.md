---
title: "Double Ping Pong Game by ClaudeAI"
tags:
  - Game
---

<style>
    body {
      margin: 0;
      touch-action: none;
      overflow: hidden;
    }

    #gameContainer {
      position: relative;
      width: 300px;
      height: 500px;
      border: 2px solid black;
      margin: 20px auto;
      overflow: hidden;
      touch-action: none;
    }
    
    #ball {
      position: absolute;
      width: 10px;
      height: 10px;
      background-color: red;
      border-radius: 50%;
    }
    
    .paddle {
      position: absolute;
      width: 8px;
      height: 60px;
      background-color: blue;
      touch-action: none;
    }
    
    #leftPaddle {
      left: 0;
    }
    
    #rightPaddle {
      right: 0;
    }

    .score {
      text-align: center;
      font-size: 20px;
      margin: 10px;
    }

    .hits {
      text-align: center;
      font-size: 16px;
      margin: 10px;
      color: #666;
    }

    .controls {
      text-align: center;
      margin: 15px;
    }

    .instructions {
      text-align: center;
      margin: 15px;
      font-family: monospace;
      font-size: 14px;
    }
</style>
<div class="score">Left: <span id="leftScore">0</span> | Right: <span id="rightScore">0</span></div>
<div class="hits">Left Hits: <span id="leftHits">0</span> | Right: <span id="rightHits">0</span></div>
<div class="controls">
    Speed: <input type="range" id="speedControl" min="1" max="10" value="3" style="width: 150px">
    <span id="speedValue">3</span>
</div>
<div class="instructions">
    Use R/F for left, U/J for right<br>or touch/drag paddles
</div>
<div id="gameContainer">
    <div id="ball"></div>
    <div id="leftPaddle" class="paddle"></div>
    <div id="rightPaddle" class="paddle"></div>
</div>

<script>
    const ball = document.getElementById('ball');
    const leftPaddle = document.getElementById('leftPaddle');
    const rightPaddle = document.getElementById('rightPaddle');
    const container = document.getElementById('gameContainer');
    const speedControl = document.getElementById('speedControl');
    const speedValue = document.getElementById('speedValue');
    const leftScoreElement = document.getElementById('leftScore');
    const rightScoreElement = document.getElementById('rightScore');
    const leftHitsElement = document.getElementById('leftHits');
    const rightHitsElement = document.getElementById('rightHits');

    let ballX = 150;
    let ballY = 250;
    let baseSpeed = 3;
    let ballSpeedX = baseSpeed;
    let ballSpeedY = baseSpeed;
    let leftPaddleY = 220;
    let rightPaddleY = 220;
    let paddleSpeed = 8;
    let leftScore = 0;
    let rightScore = 0;
    let leftHits = 0;
    let rightHits = 0;
    let activeTouches = new Map();

    // Initial positions
    ball.style.left = ballX + 'px';
    ball.style.top = ballY + 'px';
    leftPaddle.style.top = leftPaddleY + 'px';
    rightPaddle.style.top = rightPaddleY + 'px';

    function handleTouchStart(e) {
      e.preventDefault();
      const containerRect = container.getBoundingClientRect();
      
      Array.from(e.changedTouches).forEach(touch => {
        const touchX = touch.clientX - containerRect.left;
        const touchY = touch.clientY - containerRect.top;
        
        if (touchX < containerRect.width / 2) {
          activeTouches.set(touch.identifier, 'left');
          updatePaddlePosition(touchY, 'left');
        } else {
          activeTouches.set(touch.identifier, 'right');
          updatePaddlePosition(touchY, 'right');
        }
      });
    }

    function handleTouchMove(e) {
      e.preventDefault();
      const containerRect = container.getBoundingClientRect();
      
      Array.from(e.changedTouches).forEach(touch => {
        const paddle = activeTouches.get(touch.identifier);
        if (paddle) {
          const touchY = touch.clientY - containerRect.top;
          updatePaddlePosition(touchY, paddle);
        }
      });
    }

    function handleTouchEnd(e) {
      e.preventDefault();
      Array.from(e.changedTouches).forEach(touch => {
        activeTouches.delete(touch.identifier);
      });
    }

    function updatePaddlePosition(touchY, paddle) {
      const newY = Math.max(0, Math.min(440, touchY - 30));
      if (paddle === 'left') {
        leftPaddleY = newY;
        leftPaddle.style.top = newY + 'px';
      } else {
        rightPaddleY = newY;
        rightPaddle.style.top = newY + 'px';
      }
    }

    container.addEventListener('touchstart', handleTouchStart, { passive: false });
    container.addEventListener('touchmove', handleTouchMove, { passive: false });
    container.addEventListener('touchend', handleTouchEnd, { passive: false });
    container.addEventListener('touchcancel', handleTouchEnd, { passive: false });

    speedControl.addEventListener('input', function() {
      baseSpeed = parseInt(this.value);
      speedValue.textContent = baseSpeed;
      ballSpeedX = ballSpeedX > 0 ? baseSpeed : -baseSpeed;
      ballSpeedY = ballSpeedY > 0 ? baseSpeed : -baseSpeed;
    });

    document.addEventListener('keydown', function(e) {
      switch(e.key.toLowerCase()) {
        case 'r':
          leftPaddleY = Math.max(0, leftPaddleY - paddleSpeed);
          leftPaddle.style.top = leftPaddleY + 'px';
          break;
        case 'f':
          leftPaddleY = Math.min(440, leftPaddleY + paddleSpeed);
          leftPaddle.style.top = leftPaddleY + 'px';
          break;
        case 'u':
          rightPaddleY = Math.max(0, rightPaddleY - paddleSpeed);
          rightPaddle.style.top = rightPaddleY + 'px';
          break;
        case 'j':
          rightPaddleY = Math.min(440, rightPaddleY + paddleSpeed);
          rightPaddle.style.top = rightPaddleY + 'px';
          break;
      }
    });

    function update() {
      ballX += ballSpeedX;
      ballY += ballSpeedY;

      if (ballY <= 0 || ballY >= 490) {
        ballSpeedY = -ballSpeedY;
      }

      if (ballX <= 8 && ballY >= leftPaddleY && ballY <= leftPaddleY + 60) {
        ballSpeedX = baseSpeed;
        leftHits++;
        leftHitsElement.textContent = leftHits;
      } else if (ballX >= 282 && ballY >= rightPaddleY && ballY <= rightPaddleY + 60) {
        ballSpeedX = -baseSpeed;
        rightHits++;
        rightHitsElement.textContent = rightHits;
      }

      if (ballX <= 0) {
        rightScore++;
        rightScoreElement.textContent = rightScore;
        resetBall();
      } else if (ballX >= 290) {
        leftScore++;
        leftScoreElement.textContent = leftScore;
        resetBall();
      }

      ball.style.left = ballX + 'px';
      ball.style.top = ballY + 'px';

      requestAnimationFrame(update);
    }

    function resetBall() {
      ballX = 150;
      ballY = 250;
      ballSpeedX = Math.random() > 0.5 ? baseSpeed : -baseSpeed;
      ballSpeedY = baseSpeed;
    }

    update();
</script>
