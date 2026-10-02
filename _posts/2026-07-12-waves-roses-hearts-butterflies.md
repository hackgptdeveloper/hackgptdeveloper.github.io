---
title: "Waves, Roses, Hearts, and Butterflies: The Transcendental Curves That Hide in Sines and Cosines"
tags:
  - lissajous
  - rose-curve
  - butterfly-curve
  - polar-coordinates
  - transcendental-curves
  - limacon
  - math-history
  - interactive
---

**Challenge to the reader:** Two different curves in the widget below change character at the *same* slider setting. Find it twice: turn the **Rose Curve** to the smallest setting that draws exactly five petals, and turn the **Limaçon** to the setting where its inner loop pinches shut into a cardioid. (Answers at the end of the post.)

When mathematicians moved beyond polynomials — into sines, cosines, and exponentials — they unlocked a new world of curves. Unlike their algebraic cousins, curves built from these transcendental ingredients can cross themselves infinitely many times, spiral without end, and trace shapes of heart-stopping beauty. From the hypnotic dance of Lissajous figures to the improbable butterfly curve, here are seven curves that transcend algebra.

**Why this matters:** Every MP3 file, every JPEG image, and every oscilloscope trace is a conversation between these curves and the world. Fourier's insight — that any repeating signal is a sum of sine waves — is why your phone can compress music. Lissajous figures are how physicists compare frequencies. Rose curves describe the radiation patterns of antennas. And the butterfly curve is a reminder that even in an age of instant computation, a simple formula can still surprise the person who plots it.

<div class="curve-selector" style="margin: 1em 0;">
  <button onclick="selectCurve(0)" style="margin:2px;padding:6px 12px;cursor:pointer;">Sine Wave</button>
  <button onclick="selectCurve(1)" style="margin:2px;padding:6px 12px;cursor:pointer;">Lissajous</button>
  <button onclick="selectCurve(2)" style="margin:2px;padding:6px 12px;cursor:pointer;">Butterfly</button>
  <button onclick="selectCurve(3)" style="margin:2px;padding:6px 12px;cursor:pointer;">Heart Curve</button>
  <button onclick="selectCurve(4)" style="margin:2px;padding:6px 12px;cursor:pointer;">Rose Curve</button>
  <button onclick="selectCurve(5)" style="margin:2px;padding:6px 12px;cursor:pointer;">Limaçon</button>
  <button onclick="selectCurve(6)" style="margin:2px;padding:6px 12px;cursor:pointer;">Tangent</button>
  <button onclick="selectCurve(7)" style="margin:2px;padding:6px 12px;cursor:pointer;background:#ff6b6b;color:#fff;">Gallery</button>
</div>

<style>
@media print {
  body * { visibility: hidden; }
  #canvas-wrap5, #canvas-wrap5 * { visibility: visible; }
  #canvas-wrap5 {
    position: absolute;
    top: 0; left: 0; width: 100%; height: 100%;
    display: flex; align-items: center; justify-content: center;
    background: #fff;
  }
  #canvas-wrap5 canvas { max-width: 100vw; max-height: 100vh; width: auto; height: auto; }
}
#canvas-wrap5 {
  position: relative;
  display: inline-block;
  cursor: pointer;
  border: 1px solid #333;
  border-radius: 8px;
  overflow: hidden;
  line-height: 0;
}
#canvas-wrap5.fullscreen {
  position: fixed;
  top: 0; left: 0; width: 100vw; height: 100vh;
  background: #000;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  border: none;
  border-radius: 0;
}
#canvas-wrap5 .close-btn { display: none; }
#canvas-wrap5.fullscreen .close-btn {
  display: block;
  position: absolute;
  top: 12px; right: 16px;
  color: #fff;
  font-size: 28px;
  line-height: 1;
  cursor: pointer;
  z-index: 1;
  user-select: none;
}
</style>

<div id="canvas-wrap5">
  <span class="close-btn">&times;</span>
  <canvas id="canvas5"></canvas>
</div>
<br/>
<label for="paramSlider5">Variation: <span id="paramVal5">0.50</span></label>
<input type="range" id="paramSlider5" min="5" max="95" value="50" style="width:100%;" />

<script>
(function(){
const wrap = document.getElementById('canvas-wrap5');
const canvas = document.getElementById('canvas5');
const ctx = canvas.getContext('2d');
const slider = document.getElementById('paramSlider5');
const paramVal = document.getElementById('paramVal5');

let W, H, cx, cy, scale, time = 0, animId;
let curveIdx = 0;
let galleryMode = false;

function size() {
  const dpr = window.devicePixelRatio || 1;
  W = Math.min(700, window.innerWidth - 32);
  H = Math.min(500, W * 0.75);
  canvas.width = W * dpr;
  canvas.height = H * dpr;
  canvas.style.width = W + 'px';
  canvas.style.height = H + 'px';
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  cx = W / 2;
  cy = H / 2;
  scale = Math.min(W, H) * 0.35;
}

const curves = [
  {
    name: 'Sine Wave', math: 'Fourier & Euler',
    eq: function(t, k) {
      const freq = 1 + k * 4;
      return { x: t, y: Math.sin(freq * t) };
    },
    range: [-Math.PI * 2, Math.PI * 2],
    desc: 'The fundamental building block of every periodic function.',
    color: '#ff6b6b'
  },
  {
    name: 'Lissajous Curve', math: 'Jules Lissajous, 1857',
    eq: function(t, k) {
      const a = 3, b = 4;
      const delta = k * Math.PI;
      return {
        x: Math.sin(a * t + delta),
        y: Math.sin(b * t)
      };
    },
    desc: 'Two perpendicular harmonic motions create intricate looping patterns.',
    color: '#4ecdc4'
  },
  {
    name: 'Butterfly Curve', math: 'Temple H. Fay, 1989',
    eq: function(t, k) {
      const r = Math.exp(Math.cos(t)) - 2 * Math.cos(4 * t) + Math.pow(Math.sin(t / 12), 5);
      return {
        x: Math.sin(t) * r,
        y: Math.cos(t) * r
      };
    },
    range: [0, Math.PI * 12],
    desc: 'Discovered by a computer scientist. Needs 12π to complete its wing pattern.',
    color: '#fd79a8'
  },
  {
    name: 'Heart Curve', math: 'Popular culture',
    eq: function(t, k) {
      const s = 1 + k * 0.3;
      return {
        x: s * 16 * Math.pow(Math.sin(t), 3) / 16,
        y: s * (13 * Math.cos(t) - 5 * Math.cos(2 * t) - 2 * Math.cos(3 * t) - Math.cos(4 * t)) / 16
      };
    },
    desc: 'A modern parametric valentine. Best plotted and shared on February 14th.',
    color: '#e17055'
  },
  {
    name: 'Rose Curve (Rhodonea)', math: 'Luigi Guido Grandi, 1723',
    eq: function(t, k) {
      const petals = Math.floor(1 + k * 8); // 1-9 petals
      const r = Math.cos(petals * t);
      return {
        x: r * Math.cos(t),
        y: r * Math.sin(t)
      };
    },
    desc: 'Polar equation r = cos(kθ). Number of petals depends on parity of k.',
    color: '#a29bfe'
  },
  {
    name: 'Limaçon', math: 'Étienne Pascal, c. 1650',
    eq: function(t, k) {
      const a = 1, b = k * 2;
      const r = b + a * Math.cos(t);
      return {
        x: r * Math.cos(t),
        y: r * Math.sin(t)
      };
    },
    desc: 'The "snail" curve. At b=a it becomes the cardioid; at b<a it has an inner loop.',
    color: '#00b894'
  },
  {
    name: 'Tangent Curve', math: 'Leonhard Euler',
    eq: function(t, k) {
      const freq = 1 + k * 3;
      return { x: t, y: Math.tan(freq * t) };
    },
    range: [-Math.PI * 0.8, Math.PI * 0.8],
    desc: 'Asymptotic — shoots to infinity at odd multiples of π/2. Never crosses its own vertical lines.',
    color: '#f9ca24'
  }
];

function selectCurve(idx) {
  if (idx === 7) { galleryMode = !galleryMode; return; }
  galleryMode = false;
  curveIdx = idx;
}
	window.selectCurve = selectCurve;
function drawCurve(cx0, cy0, sc, curve, tMax, alpha, k) {
  const N = 600;
  ctx.beginPath();
  let first = true;
  for (let i = 0; i <= N; i++) {
    const t = (i / N) * tMax;
    try {
      const pt = curve.eq(t, k);
      if (!isFinite(pt.x) || !isFinite(pt.y)) { first = true; continue; }
      const sx = cx0 + pt.x * sc;
      const sy = cy0 - pt.y * sc;
      if (Math.abs(sx - cx0) > W || Math.abs(sy - cy0) > H) { first = true; continue; }
      if (first) { ctx.moveTo(sx, sy); first = false; }
      else { ctx.lineTo(sx, sy); }
    } catch(e) { first = true; }
  }
  ctx.strokeStyle = curve.color;
  ctx.globalAlpha = alpha;
  ctx.lineWidth = 2;
  ctx.shadowColor = curve.color;
  ctx.shadowBlur = 3;
  ctx.stroke();
  ctx.shadowBlur = 0;
  ctx.globalAlpha = 1;
}

function draw() {
  ctx.clearRect(0, 0, W, H);
  const k = slider.value / 100;

  if (galleryMode) {
    // Grid of all curves
    const cols = 3, rows = 3;
    const cellW = W / cols, cellH = H / rows;
    for (let i = 0; i < 7; i++) {
      const col = i % cols, row = Math.floor(i / cols);
      const cxi = cellW * col + cellW / 2;
      const cyi = cellH * row + cellH / 2;
      const sci = Math.min(cellW, cellH) * 0.28;
      const tRange = curves[i].range || [0, Math.PI * 2];
      drawCurve(cxi, cyi, sci, curves[i], tRange[1] - tRange[0], 1, k);
      ctx.fillStyle = '#fff';
      ctx.font = 'bold 10px "Segoe UI", sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText(curves[i].name, cxi, cyi - cellH * 0.32);
    }
  } else {
    const curve = curves[curveIdx];
    const tRange = curve.range || [0, Math.PI * 2];
    const tMax = tRange[1] - tRange[0];
    drawCurve(cx, cy, scale, curve, tMax, 1, k);

    // Tracer
    const traceT = tRange[0] + ((time * 0.025) % 1) * tMax;
    try {
      const dp = curve.eq(traceT, k);
      if (isFinite(dp.x) && isFinite(dp.y)) {
        const dx = cx + dp.x * scale;
        const dy = cy - dp.y * scale;
        ctx.beginPath();
        ctx.arc(dx, dy, 5, 0, Math.PI * 2);
        ctx.fillStyle = '#fff';
        ctx.fill();
        ctx.strokeStyle = curve.color;
        ctx.lineWidth = 2;
        ctx.stroke();
      }
    } catch(e) {}

    ctx.fillStyle = '#fff';
    ctx.font = 'bold 15px "Segoe UI", sans-serif';
    ctx.textAlign = 'center';
    ctx.fillText(curve.name, cx, 18);
    ctx.font = '11px "Segoe UI", sans-serif';
    ctx.fillStyle = '#aaa';
    ctx.fillText(curve.math, cx, 34);
    ctx.fillText(curve.desc, cx, H - 10);
  }

  paramVal.textContent = k.toFixed(2);
  time++;
  animId = requestAnimationFrame(draw);
}

wrap.addEventListener('click', function(e) {
  if (e.target === wrap || e.target === canvas) {
    if (document.fullscreenElement) { document.exitFullscreen(); }
    else { wrap.requestFullscreen(); }
  }
});
wrap.querySelector('.close-btn').addEventListener('click', function(e) {
  e.stopPropagation();
  if (document.fullscreenElement) document.exitFullscreen();
});
document.addEventListener('fullscreenchange', function() {
  if (document.fullscreenElement === wrap) { wrap.classList.add('fullscreen'); }
  else { wrap.classList.remove('fullscreen'); }
  setTimeout(size, 100);
});
window.addEventListener('resize', size);
size();
draw();
})();
</script>

**Controls:** Select any curve to see it animated. Move the slider to adjust frequency, petal count, or inner radius. Click **Gallery** to compare all curves at once.

---

## 1. The Sine Wave: Music Made Visible

The sine wave ($y = \sin x$) is the atomic unit of periodic motion. Every sound you hear, from a violin to a whisper, can be decomposed into sines of different frequencies — this is the essence of Fourier analysis, which Joseph Fourier developed in 1822 while studying heat diffusion. Today it underpins everything from MP3 compression to quantum mechanics.

The sine wave's shape is also the projection of a point moving uniformly around a circle — a fact that connects trigonometry to every rotating machine ever built.

The widget plots its sine as $y = \sin(f t)$ over the window $t \in [-2\pi, 2\pi]$, with the slider setting the frequency $f = 1 + 4k$.

**Challenge:** Set the slider to 0.50. The code sets $f = 3$, so the wave should show $2f = 6$ complete oscillations across the $4\pi$-wide window — count them. Then explain why the slider can never show a single complete wave, no matter where you set it.

---

## 2. Lissajous: The Dancing Figures

In 1857, Jules Lissajous made sound visible. He attached mirrors to tuning forks, bounced a light beam off them, and projected the resulting patterns onto a screen. The curves traced by two perpendicular harmonic motions —

$$
x = A \sin(at + \delta), \quad y = B \sin(bt)
$$

— produce an infinite variety of looping, tangled figures. The ratio $a:b$ fixes the fundamental shape; the phase $\delta$ controls the twist. At integer ratios you get stable closed loops; at irrational ratios the curve never repeats, eventually filling a rectangle entirely.

You have seen Lissajous figures: they are the classic oscilloscope music visualiser, and the Australian Broadcasting Corporation's logo is a 1:1 figure. In the 1:1 case the phase does all the work — at one extreme you get a circle, at the other a straight line.

The widget fixes a 3:4 ratio and sweeps the phase shift $\delta = k\pi$.

---

## 3. The Rose Curve: Petals from the Polar World

Luigi Guido Grandi named the **rhodonea** (rose) in 1723. In polar coordinates:

$$
r = \cos(k\theta)
$$

When $k$ is an integer, the curve has $k$ petals if $k$ is odd, and $2k$ petals if $k$ is even. When $k$ is rational, you get overlapping petals; when irrational, the curve fills an annulus densely. Grandi was so pleased with his roses that he sent them to Leibniz, who was duly impressed.

The widget takes a shortcut through all of that. It reads a whole-number petal count $p = \lfloor 1 + 8k \rfloor$ off the slider, then plots $r = \cos(p\theta)$.

**Challenge:** Find the smallest slider value that draws exactly five petals — then explain why the setting $k = 0.40$, where the formula gives $p = 4$, draws eight petals instead.

---

## 4. The Butterfly Curve: A Computer-Age Discovery

Temple H. Fay discovered this curve in **1989** — not in the 17th or 18th century, but in the age of personal computers. Its equation looks implausibly messy:

$$
r = e^{\cos \theta} - 2\cos(4\theta) + \sin^5(\theta/12)
$$

But plot it over $[0, 12\pi]$ and a butterfly emerges, complete with antenna-like spirals at the tips. The $\sin^5(\theta/12)$ term is the key to the wing shape: it is the slowest-moving term in the equation, with a period twelve times longer than the swing that drives $e^{\cos\theta}$. Without it, you just get a lumpy blob. Even in an age where computers can plot anything instantly, a beautiful curve can still surprise us.

Watch the widget while the butterfly is on screen: the slider does nothing, because this curve's equation has no $k$ in it at all.

---

## 5. The Limaçon: Pascal's Snail

Étienne Pascal (Blaise's father) studied the limaçon around 1650. Its polar form is $r = b + a\cos\theta$. Depending on the ratio $b/a$, it morphs through four forms:

- $b \gt a$: a dimpled oval
- $b = a$: the **cardioid** (heart-shape, with a cusp)
- $a/2 \lt b \lt a$: an inner loop appears
- $b \le a/2$: the inner loop dominates

The name "limaçon" comes from the Latin *limax* (snail), which is fitting — the curve does resemble a snail shell when the inner loop is present.

The widget fixes $a = 1$ and lets the slider set $b = 2k$. One diplomatic footnote: though it keeps company with transcendental curves, the limaçon is secretly algebraic — square the equation and it becomes the polynomial $(x^2 + y^2 - ax)^2 = b^2(x^2 + y^2)$. It earns its place in this gallery as the polar family's gateway, and because the cardioid at $b = a$ is the shape everyone means when they say "heart".

**Challenge:** Find the slider setting where the inner loop pinches shut into the cardioid, then predict the smallest $b$ for which the curve has no inner loop at all — and say whether the widget's slider can smooth the dimple away completely. (Hint: the dimple survives all the way up to $b = 2$.)

---

## 6. The Heart Curve: A Valentine from Popular Culture

Pop culture's heart has no patience for the cardioid's single cusp. The widget's version is parametric —

$$
x = \sin^3 t, \qquad y = \frac{13\cos t - 5\cos 2t - 2\cos 3t - \cos 4t}{16}
$$

— up to a sliding scale, and it is a trigonometric polynomial: a truncated Fourier series wearing a valentine costume. Every term is a cosine, so the machinery of Fourier analysis applies even to the shape at the bottom of a love letter. The slider scales the heart without changing its shape, and no physical principle chose it: the heart curve is a product of the graphics age, found by asking what a handful of cosines can be made to look like.

---

## 7. The Tangent Curve: The Function That Never Touches Its Walls

Set the slider loose on the tangent and the curve does something none of its neighbours can: it escapes. The widget plots

$$
y = \tan(f t), \qquad f = 1 + 3k
$$

over the window $t \in [-0.8\pi, 0.8\pi]$, and wherever the window crosses an odd multiple of $\pi/2$, the curve shoots off the canvas. Those walls are asymptotes — lines the curve approaches but never touches, because the tangent is the sine divided by the cosine, and the cosine simply reaches zero there. What you see is not one curve but infinitely many separate branches, each trapped between two walls; the drawing code has to know this, because it breaks the path whenever a point leaves the canvas. Without that break, the routine would connect one branch to the next with a false vertical line. Nothing in the algebraic world behaves this way: a polynomial is always bounded on a finite window.

---

## 8. The Family at a Glance

| Curve | Equation | What fixes the shape | Signature feature |
|-------|----------|----------------------|-------------------|
| Sine wave | y = sin(f t) | Frequency f | The atom of Fourier analysis |
| Lissajous | x = sin(3t + δ), y = sin(4t) | The ratio 3:4 and the phase δ | Closes for rational ratios; fills a rectangle otherwise |
| Rose | r = cos(pθ) | Petal count p | p petals for odd p, 2p petals for even p |
| Butterfly | r = exp(cos t) − 2 cos(4t) + sin^5(t/12) | Nothing — one fixed shape | The slow wing term needs a 12π window |
| Limaçon | r = b + cos θ | The ratio b/a | Cardioid at b = a; inner loop when b drops below a |
| Heart | x = sin³t, y = (13cos t − 5cos 2t − 2cos 3t − cos 4t)/16 | Fixed shape; the slider only scales it | A trigonometric polynomial valentine |
| Tangent | y = tan(f t) | Frequency f | Unbounded branches between asymptotes |

---

## 9. Deeper Significance: Why These Curves Never Run Out of Surprises

Why do sines and exponentials produce curves that polynomials cannot match? The answer is periodicity with *incommensurable* periods. A polynomial's shape is rigid: it can cross a given line only finitely many times, so it can never revisit a pattern endlessly. A sum of sines with rationally related frequencies is periodic and closes; make one frequency irrational and the curve never repeats — yet it never escapes either. It wanders densely through its rectangle forever. That is ergodic theory in miniature: the Lissajous figure with an irrational ratio is the simplest picture of a trajectory that becomes evenly spread over its whole domain.

The same duality — closing versus filling — runs through all of these curves. The rose closes for integer petal counts and fills an annulus otherwise. The butterfly, built from three frequencies locked in a ratio of small integers, traces its wings exactly once every $12\pi$ of parameter. And the sine wave, humblest curve in the gallery, turns out to be the alphabet the others are written in: Fourier's theorem says every repeating function, however jagged, is a sum of sine waves. These curves are not a random gallery at all — they are different sentences in one language.

---

## 10. Final Challenge

**Synthesis challenge:** Three parts, all resting on one parity argument.

(a) Prove the rose petal rule. For the curve $r = \cos(p\theta)$ with $p$ a whole number, compare the point at angle $\theta$ with the point at angle $\theta + \pi$. When $p$ is odd the cosine flips sign, so the curve retraces the same petals; when $p$ is even it does not flip, so a second set of petals is drawn. Explain why this yields $p$ petals for odd $p$ and $2p$ petals for even $p$.

(b) Use the widget's formula $p = \lfloor 1 + 8k \rfloor$ to give the smallest slider setting that produces exactly 1, 3, 5, and 7 petals.

(c) The same closing argument governs the Lissajous figure. Explain why $x = \sin(3t + \delta)$ and $y = \sin(4t)$ close into a loop, while a frequency ratio like $3:\pi$ never does, no matter how long you watch.

---

**Answers to the challenges:**

- **Five petals:** $p = \lfloor 1 + 8k \rfloor = 5$ first happens at $k = 0.50$. At $k = 0.40$ the formula gives $p = 4$, and because even petal counts double, the curve shows eight petals.
- **Cardioid:** the widget's limaçon is $r = 2k + \cos\theta$, which becomes the cardioid when $2k = 1$, i.e. $k = 0.50$. The inner loop needs $b \lt 1$; the dimple survives up to $b = 2$, and the widget's largest is $b = 1.9$ — so the dimple never fully disappears.
- **Sine:** the window shows $2f = 2 + 8k$ full waves, so the fewest the widget can draw is $2.4$ — a single wave is out of reach.
- **Final challenge (b):** the settings are $0.05$, $0.25$, $0.50$, and $0.75$, for 1, 3, 5, and 7 petals.

<style>
.curve-selector button { transition: all 0.2s; }
.curve-selector button:hover { transform: scale(1.05); }
</style>
