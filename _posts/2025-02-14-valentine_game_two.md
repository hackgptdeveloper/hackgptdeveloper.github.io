---
title: "Catch the Hearts - Valentine's Day Game"
tags:
  - Graphics
---

Click on the falling hearts to make it disappear and score points.

<style>
    body {
        margin: 0;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        background: linear-gradient(to bottom, #ffccd5, #ff99aa);
        font-family: Arial, sans-serif;
        overflow: hidden;
    }
    #game-container {
        position: relative;
        width: 800px;
        height: 600px;
        background: rgba(255, 255, 255, 0.2);
        border: 2px solid #ff3366;
        border-radius: 10px;
        overflow: hidden;
    }
    #score, #timer {
        position: absolute;
        top: 10px;
        color: #ff3366;
        font-size: 24px;
        font-weight: bold;
    }
    #score { left: 20px; }
    #timer { right: 20px; }
    #game-over {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        text-align: center;
        color: #ff3366;
        font-size: 36px;
        display: none;
    }
    .heart {
        position: absolute;
        width: 70px;
        height: 70px;
        background: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="%23ff3366"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>');
        background-size: cover;
        cursor: pointer;
        transition: transform 0.2s;
    }
    .heart:hover {
        transform: scale(1.2);
    }
    button {
        padding: 10px 20px;
        font-size: 18px;
        background: #ff3366;
        color: white;
        border: none;
        border-radius: 5px;
        cursor: pointer;
    }
    button:hover {
        background: #ff6699;
    }
</style>
<div id="game-container">
    <div id="score">Score: 0</div>
    <div id="timer">Time: 30</div>
    <div id="game-over">
        <p>Game Over!</p>
        <p>Your Score: <span id="final-score">0</span></p>
        <button onclick="startGame()">Play Again</button>
    </div>
</div>
<script>
    const gameContainer = document.getElementById('game-container');
    const scoreDisplay = document.getElementById('score');
    const timerDisplay = document.getElementById('timer');
    const gameOverScreen = document.getElementById('game-over');
    const finalScoreDisplay = document.getElementById('final-score');
    
    let score = 0;
    let timeLeft = 30;
    let gameActive = false;
    let heartInterval;

    function createHeart() {
        const heart = document.createElement('div');
        heart.className = 'heart';
        heart.style.left = Math.random() * (gameContainer.offsetWidth - 40) + 'px';
        heart.style.top = '-40px';
        
        gameContainer.appendChild(heart);

        heart.addEventListener('click', () => {
            if (gameActive) {
                score += 1;
                scoreDisplay.textContent = `Score: ${score}`;
                heart.remove();
            }
        });

        let fallSpeed = 1 ;  // + Math.random() * 3;
        function fall() {
            if (!gameActive) return;
            let top = parseFloat(heart.style.top) + fallSpeed;
            heart.style.top = top + 'px';
            
            if (top > gameContainer.offsetHeight) {
                heart.remove();
            } else {
                requestAnimationFrame(fall);
            }
        }
        requestAnimationFrame(fall);
    }

    function updateTimer() {
        timerDisplay.textContent = `Time: ${timeLeft}`;
        if (timeLeft > 0) {
            timeLeft--;
            setTimeout(updateTimer, 1000);
        } else {
            endGame();
        }
    }

    function startGame() {
        score = 0;
        timeLeft = 30;
        gameActive = true;
        scoreDisplay.textContent = `Score: ${score}`;
        timerDisplay.textContent = `Time: ${timeLeft}`;
        gameOverScreen.style.display = 'none';
        
        clearInterval(heartInterval);
        heartInterval = setInterval(createHeart, 800);
        updateTimer();

        // Clear existing hearts
        document.querySelectorAll('.heart').forEach(heart => heart.remove());
    }

    function endGame() {
        gameActive = false;
        clearInterval(heartInterval);
        finalScoreDisplay.textContent = score;
        gameOverScreen.style.display = 'block';
    }

    // Start the game on page load
    startGame();
</script>
