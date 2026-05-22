---
title: "Double Ping Pong Game by ClaudeAI"
tags:
  - Game
---

<style>
    .ping-pong-game {
      display: flex;
      flex-direction: column;
      align-items: center;
      width: 100%;
      max-width: 100vw;
      box-sizing: border-box;
      padding: 0 8px 8px;
      touch-action: manipulation;
    }

    .ping-pong-ui {
      width: 100%;
      max-width: 400px;
      flex-shrink: 0;
    }

    #gameContainer {
      position: relative;
      width: 300px;
      height: 500px;
      border: 2px solid black;
      margin: 0 auto;
      overflow: hidden;
      touch-action: none;
      flex-shrink: 0;
      box-sizing: border-box;
      background: #1a472a;
      cursor: pointer;
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
      font-size: clamp(14px, 3.5vw, 20px);
      margin: 6px 0;
    }

    .hits {
      text-align: center;
      font-size: clamp(12px, 3vw, 16px);
      margin: 4px 0;
      color: #666;
    }

    .controls {
      text-align: center;
      margin: 6px 0;
      font-size: clamp(12px, 3vw, 14px);
    }

    .instructions {
      text-align: center;
      margin: 4px 0 8px;
      font-family: monospace;
      font-size: clamp(10px, 2.5vw, 14px);
      line-height: 1.3;
    }

    @media (max-width: 480px) {
      .ping-pong-game {
        padding: 0 4px 4px;
      }

      .score, .hits, .controls, .instructions {
        margin: 2px 0;
      }
    }

    /* Fullscreen play mode (double-tap) */
    html.ping-pong-fullscreen,
    html.ping-pong-fullscreen body {
      overflow: hidden !important;
      height: 100%;
      margin: 0;
      padding: 0;
    }

    html.ping-pong-fullscreen .masthead,
    html.ping-pong-fullscreen .site-header,
    html.ping-pong-fullscreen .page-header,
    html.ping-pong-fullscreen .page-sidebar,
    html.ping-pong-fullscreen .page-share,
    html.ping-pong-fullscreen .page-pagination,
    html.ping-pong-fullscreen .page-image,
    html.ping-pong-fullscreen .disqus,
    html.ping-pong-fullscreen footer,
    html.ping-pong-fullscreen .ping-pong-ui {
      display: none !important;
    }

    html.ping-pong-fullscreen .main-content,
    html.ping-pong-fullscreen .page-wrapper,
    html.ping-pong-fullscreen .page-content,
    html.ping-pong-fullscreen .e-content,
    html.ping-pong-fullscreen article,
    html.ping-pong-fullscreen .h-entry {
      margin: 0 !important;
      padding: 0 !important;
      max-width: none !important;
    }

    html.ping-pong-fullscreen .ping-pong-game {
      position: fixed;
      inset: 0;
      width: 100vw;
      height: 100vh;
      height: 100dvh;
      max-width: none;
      padding: 0;
      margin: 0;
      z-index: 99999;
      background: #0d2818;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    html.ping-pong-fullscreen #gameContainer {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      width: 100vw !important;
      height: 100vh !important;
      height: 100dvh !important;
      max-width: none;
      max-height: none;
      margin: 0;
      border: none;
      border-radius: 0;
    }
</style>
<div class="ping-pong-game">
  <div class="ping-pong-ui">
    <div class="score">Left: <span id="leftScore">0</span> | Right: <span id="rightScore">0</span></div>
    <div class="hits">Left Hits: <span id="leftHits">0</span> | Right: <span id="rightHits">0</span></div>
    <div class="controls">
        Speed: <input type="range" id="speedControl" min="1" max="10" value="3" style="width: min(150px, 40vw)">
        <span id="speedValue">3</span>
    </div>
    <div class="instructions">
        Use R/F for left, U/J for right — touch/drag paddles<br>
        Double-tap the table for fullscreen play (double-tap again to exit)
    </div>
  </div>
  <div id="gameContainer">
      <div id="ball"></div>
      <div id="leftPaddle" class="paddle"></div>
      <div id="rightPaddle" class="paddle"></div>
  </div>
</div>

<script>
    const ball = document.getElementById('ball');
    const leftPaddle = document.getElementById('leftPaddle');
    const rightPaddle = document.getElementById('rightPaddle');
    const container = document.getElementById('gameContainer');
    const gameWrapper = document.querySelector('.ping-pong-game');
    const gameUi = document.querySelector('.ping-pong-ui');
    const speedControl = document.getElementById('speedControl');
    const speedValue = document.getElementById('speedValue');
    const leftScoreElement = document.getElementById('leftScore');
    const rightScoreElement = document.getElementById('rightScore');
    const leftHitsElement = document.getElementById('leftHits');
    const rightHitsElement = document.getElementById('rightHits');

    const BASE_WIDTH = 300;
    const BASE_HEIGHT = 500;
    const ASPECT = BASE_WIDTH / BASE_HEIGHT;
    const DOUBLE_TAP_MS = 400;
    const DOUBLE_TAP_DISTANCE = 40;

    let isPlayMode = false;
    let gameWidth = BASE_WIDTH;
    let gameHeight = BASE_HEIGHT;
    let ballSize = 10;
    let paddleWidth = 8;
    let paddleHeight = 60;
    let maxPaddleY = 440;
    let maxBallY = 490;
    let rightPaddleHitX = 282;
    let scoreRightX = 290;

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

    const lastTapByPointer = new Map();

    function getViewportSize() {
      const vv = window.visualViewport;
      if (isPlayMode && vv) {
        return { width: vv.width, height: vv.height, offsetTop: vv.offsetTop, offsetLeft: vv.offsetLeft };
      }
      return { width: window.innerWidth, height: window.innerHeight, offsetTop: 0, offsetLeft: 0 };
    }

    function clampPaddleY(y) {
      return Math.max(0, Math.min(maxPaddleY, y));
    }

    function syncElements() {
      ball.style.width = ballSize + 'px';
      ball.style.height = ballSize + 'px';
      leftPaddle.style.width = paddleWidth + 'px';
      rightPaddle.style.width = paddleWidth + 'px';
      leftPaddle.style.height = paddleHeight + 'px';
      rightPaddle.style.height = paddleHeight + 'px';
      ball.style.left = ballX + 'px';
      ball.style.top = ballY + 'px';
      leftPaddle.style.top = leftPaddleY + 'px';
      rightPaddle.style.top = rightPaddleY + 'px';
    }

    function applyGameDimensions() {
      const scale = gameWidth / BASE_WIDTH;
      ballSize = Math.max(6, Math.round(10 * scale));
      paddleWidth = Math.max(5, Math.round(8 * scale));
      paddleHeight = Math.max(36, Math.round(60 * scale));
      maxPaddleY = gameHeight - paddleHeight;
      maxBallY = gameHeight - ballSize;
      rightPaddleHitX = gameWidth - paddleWidth - ballSize;
      scoreRightX = gameWidth - ballSize;
      paddleSpeed = Math.max(4, Math.round(8 * scale));

      container.style.width = gameWidth + 'px';
      container.style.height = gameHeight + 'px';

      ballX = Math.min(Math.max(0, ballX), gameWidth - ballSize);
      ballY = Math.min(Math.max(0, ballY), maxBallY);
      leftPaddleY = clampPaddleY(leftPaddleY);
      rightPaddleY = clampPaddleY(rightPaddleY);

      syncElements();
    }

    function resizeGame() {
      const vp = getViewportSize();

      if (isPlayMode) {
        container.style.width = '100vw';
        container.style.height = '100dvh';
        gameWidth = container.clientWidth || Math.floor(vp.width);
        gameHeight = container.clientHeight || Math.floor(vp.height);
        applyGameDimensions();
        return;
      }

      container.style.width = '';
      container.style.height = '';

      const margin = 12;
      const pageHeader = document.querySelector('.page-header');
      const pageSidebar = document.querySelector('.page-sidebar');
      const masthead = document.querySelector('.masthead, .site-header, header.masthead');
      const pageHeaderHeight = pageHeader ? pageHeader.offsetHeight : 0;
      const pageSidebarHeight = pageSidebar ? pageSidebar.offsetHeight : 0;
      const mastheadHeight = masthead ? masthead.offsetHeight : 0;
      const uiHeight = gameUi.offsetHeight;

      const availableWidth = vp.width - margin * 2;
      const availableHeight = vp.height - pageHeaderHeight - pageSidebarHeight - mastheadHeight - uiHeight - margin * 2;

      let width = Math.min(availableWidth, 400);
      let height = width / ASPECT;

      if (height > availableHeight && availableHeight > 120) {
        height = availableHeight;
        width = height * ASPECT;
      }

      gameWidth = Math.max(160, Math.floor(width));
      gameHeight = Math.max(200, Math.floor(height));
      applyGameDimensions();
    }

    function setPlayMode(enabled) {
      isPlayMode = enabled;
      document.documentElement.classList.toggle('ping-pong-fullscreen', enabled);
      if (enabled) {
        window.scrollTo(0, 0);
      }
      resizeGame();
      if (enabled) {
        resetBall();
      }
    }

    function togglePlayMode() {
      setPlayMode(!isPlayMode);
    }

    function isDoubleTap(clientX, clientY, pointerId) {
      const now = Date.now();
      const prev = lastTapByPointer.get(pointerId);
      lastTapByPointer.set(pointerId, { time: now, x: clientX, y: clientY });

      if (!prev) return false;

      const dt = now - prev.time;
      const dx = clientX - prev.x;
      const dy = clientY - prev.y;
      const dist = Math.sqrt(dx * dx + dy * dy);

      if (dt < DOUBLE_TAP_MS && dist < DOUBLE_TAP_DISTANCE) {
        lastTapByPointer.delete(pointerId);
        return true;
      }
      return false;
    }

    function clientYToGameY(clientY) {
      const rect = container.getBoundingClientRect();
      const ratio = (clientY - rect.top) / rect.height;
      return ratio * gameHeight;
    }

    function handleTouchStart(e) {
      const rect = container.getBoundingClientRect();

      for (const touch of Array.from(e.changedTouches)) {
        const inGame = touch.clientX >= rect.left && touch.clientX <= rect.right &&
                       touch.clientY >= rect.top && touch.clientY <= rect.bottom;

        if (inGame && isDoubleTap(touch.clientX, touch.clientY, touch.identifier)) {
          e.preventDefault();
          togglePlayMode();
          return;
        }
      }

      e.preventDefault();
      Array.from(e.changedTouches).forEach(touch => {
        const touchX = touch.clientX - rect.left;
        const touchY = clientYToGameY(touch.clientY);
        const halfWidth = rect.width / 2;

        if (touchX < halfWidth) {
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
      Array.from(e.changedTouches).forEach(touch => {
        const paddle = activeTouches.get(touch.identifier);
        if (paddle) {
          updatePaddlePosition(clientYToGameY(touch.clientY), paddle);
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
      const newY = clampPaddleY(touchY - paddleHeight / 2);
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

    container.addEventListener('dblclick', function(e) {
      e.preventDefault();
      togglePlayMode();
    });

    speedControl.addEventListener('input', function() {
      baseSpeed = parseInt(this.value, 10);
      speedValue.textContent = baseSpeed;
      ballSpeedX = ballSpeedX > 0 ? baseSpeed : -baseSpeed;
      ballSpeedY = ballSpeedY > 0 ? baseSpeed : -baseSpeed;
    });

    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' && isPlayMode) {
        setPlayMode(false);
        return;
      }
      switch(e.key.toLowerCase()) {
        case 'r':
          leftPaddleY = clampPaddleY(leftPaddleY - paddleSpeed);
          leftPaddle.style.top = leftPaddleY + 'px';
          break;
        case 'f':
          leftPaddleY = clampPaddleY(leftPaddleY + paddleSpeed);
          leftPaddle.style.top = leftPaddleY + 'px';
          break;
        case 'u':
          rightPaddleY = clampPaddleY(rightPaddleY - paddleSpeed);
          rightPaddle.style.top = rightPaddleY + 'px';
          break;
        case 'j':
          rightPaddleY = clampPaddleY(rightPaddleY + paddleSpeed);
          rightPaddle.style.top = rightPaddleY + 'px';
          break;
      }
    });

    function update() {
      ballX += ballSpeedX;
      ballY += ballSpeedY;

      if (ballY <= 0 || ballY >= maxBallY) {
        ballSpeedY = -ballSpeedY;
      }

      if (ballX <= paddleWidth && ballY >= leftPaddleY && ballY <= leftPaddleY + paddleHeight) {
        ballSpeedX = baseSpeed;
        leftHits++;
        if (leftHitsElement) leftHitsElement.textContent = leftHits;
      } else if (ballX >= rightPaddleHitX && ballY >= rightPaddleY && ballY <= rightPaddleY + paddleHeight) {
        ballSpeedX = -baseSpeed;
        rightHits++;
        if (rightHitsElement) rightHitsElement.textContent = rightHits;
      }

      if (ballX <= 0) {
        rightScore++;
        if (rightScoreElement) rightScoreElement.textContent = rightScore;
        resetBall();
      } else if (ballX >= scoreRightX) {
        leftScore++;
        if (leftScoreElement) leftScoreElement.textContent = leftScore;
        resetBall();
      }

      ball.style.left = ballX + 'px';
      ball.style.top = ballY + 'px';

      requestAnimationFrame(update);
    }

    function resetBall() {
      ballX = gameWidth / 2 - ballSize / 2;
      ballY = gameHeight / 2 - ballSize / 2;
      ballSpeedX = Math.random() > 0.5 ? baseSpeed : -baseSpeed;
      ballSpeedY = baseSpeed;
    }

    resizeGame();
    resetBall();
    syncElements();

    window.addEventListener('resize', resizeGame);
    window.addEventListener('orientationchange', function() {
      setTimeout(resizeGame, 150);
    });
    if (window.visualViewport) {
      window.visualViewport.addEventListener('resize', resizeGame);
      window.visualViewport.addEventListener('scroll', resizeGame);
    }

    update();
</script>
