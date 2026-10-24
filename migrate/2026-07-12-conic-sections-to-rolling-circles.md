---
title: "The Eight Curves That Secretly Built Geometry — From Sliced Cones to Rolling Circles"
tags:
  - geometry
  - conic-sections
  - epicycloids
  - hypocycloids
  - cardioid
  - astroid
  - curves
  - interactive
---

**Challenge to the reader:** Click through the four rolling-circle curves in the demo — Astroid, Deltoid, Nephroid, Cardioid — and count their cusps, the sharp points where the curve reverses: 4, 3, 2, 1. Guess the rule that links that count to the radius ratio of the two circles that draw the curve, then read on to check your guess. One bonus puzzle, answerable purely from the source code printed below: does the Parameter slider actually change any of the eight shapes?

---

Two ancient machines produced eight of the most important curves in mathematics. The first is a **cone sliced by a plane**: tilt the knife and the cross-section is a circle, an ellipse, a parabola, or a hyperbola — the conic sections, the first family of curves ever studied systematically. The second is a **circle rolling on another circle**: pin a pen to the rolling disc and it traces a hypocycloid (rolling inside) or an epicycloid (rolling outside). The astroid, deltoid, nephroid, and cardioid are the four celebrated cases.

The widget below puts both families on one canvas. Every curve is a parametric equation, so switching shapes is just swapping one function for another — and **Morph All** interpolates point by point between neighbours, revealing that these shapes are not separate species but stations on a continuum.

**Why it matters:** the conics classify every orbit, lens, and whispering gallery; the roulettes classify every caustic and every gear-tooth envelope. Each family is ordered by a single number — eccentricity for the conics, the radius ratio for the roulettes — which is exactly why one canvas can walk you across eight curves with a single morphing animation.

---

## The Demo: Eight Curves, One Canvas

<div class="curve-selector" style="margin: 1em 0;">
  <button onclick="selectCurve(0)" style="margin:2px;padding:6px 12px;cursor:pointer;">Circle</button>
  <button onclick="selectCurve(1)" style="margin:2px;padding:6px 12px;cursor:pointer;">Ellipse</button>
  <button onclick="selectCurve(2)" style="margin:2px;padding:6px 12px;cursor:pointer;">Parabola</button>
  <button onclick="selectCurve(3)" style="margin:2px;padding:6px 12px;cursor:pointer;">Hyperbola</button>
  <button onclick="selectCurve(4)" style="margin:2px;padding:6px 12px;cursor:pointer;">Astroid</button>
  <button onclick="selectCurve(5)" style="margin:2px;padding:6px 12px;cursor:pointer;">Deltoid</button>
  <button onclick="selectCurve(6)" style="margin:2px;padding:6px 12px;cursor:pointer;">Nephroid</button>
  <button onclick="selectCurve(7)" style="margin:2px;padding:6px 12px;cursor:pointer;">Cardioid</button>
  <button onclick="selectCurve(8)" style="margin:2px;padding:6px 12px;cursor:pointer;background:#ff6b6b;color:#fff;">Morph All</button>
</div>

<style>
@media print {
  body * { visibility: hidden; }
  #canvas-wrap, #canvas-wrap * { visibility: visible; }
  #canvas-wrap {
    position: absolute;
    top: 0; left: 0; width: 100%; height: 100%;
    display: flex; align-items: center; justify-content: center;
    background: #fff;
  }
  #canvas-wrap canvas { max-width: 100vw; max-height: 100vh; width: auto; height: auto; }
}
#canvas-wrap {
  position: relative;
  display: inline-block;
  cursor: pointer;
  border: 1px solid #333;
  border-radius: 8px;
  overflow: hidden;
  line-height: 0;
}
#canvas-wrap.fullscreen {
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
#canvas-wrap .close-btn { display: none; }
#canvas-wrap.fullscreen .close-btn {
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

<div id="canvas-wrap">
  <span class="close-btn">&times;</span>
  <canvas id="canvas"></canvas>
</div>
<br/>
<label for="paramSlider">Parameter <em>k</em>: <span id="paramVal">1.00</span></label>
<input type="range" id="paramSlider" min="0" max="100" value="50" style="width:100%;" />

<script>
const wrap = document.getElementById('canvas-wrap');
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');
const slider = document.getElementById('paramSlider');
const paramVal = document.getElementById('paramVal');

let W, H, cx, cy, scale, time = 0, animId;
let curveIdx = 0;
let morphTarget = 0;
let morphProgress = 1.0;
let isMorphing = false;

function size() {
  const rect = wrap.getBoundingClientRect();
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

// Curve definitions: each returns {x, y} for parameter t in [0, 2π]
const curves = [
  { name: 'Circle', math: 'Ancient Greeks', eq: (t, k) => ({ x: Math.cos(t), y: Math.sin(t) }) },
  { name: 'Ellipse', math: 'Apollonius', eq: (t, k) => ({ x: 1.6 * Math.cos(t), y: Math.sin(t) }) },
  { name: 'Parabola', math: 'Apollonius', eq: (t, k) => {
    const s = (t / Math.PI - 1) * 2.5;
    return { x: s, y: s * s * 0.6 - 0.8 };
  }},
  { name: 'Hyperbola', math: 'Apollonius', eq: (t, k) => {
    const s = (t / Math.PI - 1) * 1.8;
    return { x: 1 / Math.cos(s) * 0.4, y: Math.tan(s) * 0.5 };
  }},
  { name: 'Astroid', math: 'Bernoulli', eq: (t, k) => ({ x: Math.cos(t) ** 3, y: Math.sin(t) ** 3 }) },
  { name: 'Deltoid', math: 'Euler', eq: (t, k) => ({
    x: (2 * Math.cos(t) + Math.cos(2 * t)) / 3,
    y: (2 * Math.sin(t) - Math.sin(2 * t)) / 3
  })},
  { name: 'Nephroid', math: 'Huygens', eq: (t, k) => ({
    x: (3 * Math.cos(t) - Math.cos(3 * t)) / 4,
    y: (3 * Math.sin(t) - Math.sin(3 * t)) / 4
  })},
  { name: 'Cardioid', math: 'Castillon', eq: (t, k) => ({
    x: (2 * Math.cos(t) - Math.cos(2 * t)) / 3,
    y: (2 * Math.sin(t) - Math.sin(2 * t)) / 3
  })},
];

function lerp(a, b, t) { return a + (b - a) * t; }

function getPoint(t, ci) {
  const c = curves[ci];
  const k = slider.value / 100;
  try {
    return c.eq(t, k);
  } catch(e) {
    return { x: 0, y: 0 };
  }
}

function selectCurve(idx) {
  if (idx === 8) {
    // Morph all mode
    isMorphing = true;
    morphTarget = (curveIdx + 1) % 8;
    morphProgress = 0;
  } else {
    isMorphing = false;
    curveIdx = idx;
    morphProgress = 1;
  }
}

function draw() {
  ctx.clearRect(0, 0, W, H);

  // draw subtle grid
  ctx.strokeStyle = 'rgba(255,255,255,0.08)';
  ctx.lineWidth = 0.5;
  for (let i = -5; i <= 5; i++) {
    const x = cx + i * scale * 0.4;
    ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, H); ctx.stroke();
    const y = cy + i * scale * 0.4;
    ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(W, y); ctx.stroke();
  }

  // axes
  ctx.strokeStyle = 'rgba(255,255,255,0.2)';
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(0, cy); ctx.lineTo(W, cy); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(cx, 0); ctx.lineTo(cx, H); ctx.stroke();

  if (isMorphing) {
    morphProgress += 0.005;
    if (morphProgress >= 1) {
      morphProgress = 1;
      curveIdx = morphTarget;
      isMorphing = false;
    }
  }

  // Draw animated tracer dot
  const N = 600;
  const traceT = time * 0.02;

  // Draw the curve
  ctx.beginPath();
  let firstPoint = true;
  for (let i = 0; i <= N; i++) {
    const t = (i / N) * Math.PI * 2;
    let pt;
    if (isMorphing) {
      const pA = getPoint(t, curveIdx);
      const pB = getPoint(t, morphTarget);
      pt = {
        x: lerp(pA.x, pB.x, morphProgress),
        y: lerp(pA.y, pB.y, morphProgress)
      };
    } else {
      pt = getPoint(t, curveIdx);
    }
    const sx = cx + pt.x * scale;
    const sy = cy - pt.y * scale;
    if (firstPoint) { ctx.moveTo(sx, sy); firstPoint = false; }
    else { ctx.lineTo(sx, sy); }
  }
  ctx.strokeStyle = '#ff6b6b';
  ctx.lineWidth = 2.5;
  ctx.shadowColor = '#ff6b6b';
  ctx.shadowBlur = 8;
  ctx.stroke();
  ctx.shadowBlur = 0;

  // Draw tracer dot
  let dotPt;
  if (isMorphing) {
    const pA = getPoint(traceT, curveIdx);
    const pB = getPoint(traceT, morphTarget);
    dotPt = { x: lerp(pA.x, pB.x, morphProgress), y: lerp(pA.y, pB.y, morphProgress) };
  } else {
    dotPt = getPoint(traceT, curveIdx);
  }
  const dx = cx + dotPt.x * scale;
  const dy = cy - dotPt.y * scale;
  ctx.beginPath();
  ctx.arc(dx, dy, 6, 0, Math.PI * 2);
  ctx.fillStyle = '#fff';
  ctx.fill();
  ctx.strokeStyle = '#ff6b6b';
  ctx.lineWidth = 2;
  ctx.stroke();

  // Label
  const displayCurve = isMorphing
    ? curves[curveIdx].name + ' → ' + curves[morphTarget].name
    : curves[curveIdx].name;
  ctx.fillStyle = '#fff';
  ctx.font = 'bold 16px "Segoe UI", sans-serif';
  ctx.textAlign = 'center';
  ctx.fillText(displayCurve, cx, 24);
  ctx.font = '12px "Segoe UI", sans-serif';
  ctx.fillStyle = '#aaa';
  const displayMath = isMorphing ? 'morphing...' : curves[curveIdx].math;
  ctx.fillText(displayMath, cx, 42);

  // Param value
  const k = slider.value / 100;
  paramVal.textContent = k.toFixed(2);

  time++;
  animId = requestAnimationFrame(draw);
}

wrap.addEventListener('click', function(e) {
  if (e.target === wrap || e.target === canvas) {
    if (document.fullscreenElement) {
      document.exitFullscreen();
    } else {
      wrap.requestFullscreen();
    }
  }
});
wrap.querySelector('.close-btn').addEventListener('click', function(e) {
  e.stopPropagation();
  if (document.fullscreenElement) document.exitFullscreen();
});
document.addEventListener('fullscreenchange', function() {
  if (document.fullscreenElement === wrap) {
    wrap.classList.add('fullscreen');
  } else {
    wrap.classList.remove('fullscreen');
  }
  setTimeout(size, 100);
});

window.addEventListener('resize', size);
size();
draw();
</script>

---

**Try it:** Click the curve buttons above to switch between shapes, or hit **Morph All** to watch a continuous transformation through the entire family. Keep an eye on the white tracer dot — it is the same parameter $t$ being swept on every curve, which is what makes the morphs line up.

<style>
.curve-selector button { transition: all 0.2s; }
.curve-selector button:hover { transform: scale(1.05); }
</style>

---

## 1. Circle — The Mother of All Curves

The circle is where geometry begins. Defined by $x = a\cos t, y = a\sin t$, every point is equidistant from the centre — the one curve whose distance to its centre never changes. Ancient cultures from Babylon to Egypt knew its properties, but the Greeks made it the foundation of their cosmos: planets moved in circles because the circle was *perfect*.

In the animation, the circle is the identity element of the family: every other curve deviates from it in exactly one way — two competing radii that no longer agree.

## 2. Ellipse — The Stretched Circle

Apollonius of Perga (c. 262–190 BCE) discovered that slicing a cone at a shallow angle produces an ellipse. Parametrically, $x = a\cos t, y = b\sin t$ — a circle with unequal axes. Kepler would later show that planets move in ellipses, not circles, breaking a two-thousand-year-old belief. The ellipse is literally the shape of revolution.

## 3. Parabola — The Throw Curve

Every projectile traces a parabola: $y = x^2$. Apollonius named it from the Greek *parabolē* ("application"), and Galileo later proved that cannonballs follow parabolic arcs (ignoring air resistance). It is the only conic section with a single focus — a property exploited by satellite dishes, telescope mirrors, and car headlights everywhere.

## 4. Hyperbola — The Asymptotic Twin

The hyperbola ($x = a\sec t, y = b\tan t$) is the conic section that escapes to infinity. It has two disconnected branches and two foci, and its asymptotes form an X that the curve approaches but never touches — a shape that appears in the shadow of a lampshade on a wall and in the paths of comets that visit the solar system only once.

**Challenge:** all four conics are slices of one double cone. Identify the knife angle that produces a parabola — the cutting plane must be parallel to exactly one line on the cone's surface — and explain why the hyperbola needs *both* nappes of the double cone to display its two branches, while the ellipse fits on a single nappe. The second branch of the hyperbola lives on the cone you have to imagine upside down.

## 5. Astroid — The Four-Cusped Star

Jump forward to the Bernoulli family: the astroid ($x = a\cos^3 t, y = a\sin^3 t$) is a hypocycloid with four cusps. Imagine a small circle rolling inside a larger circle of four times its radius — a point on the smaller circle traces this star-like shape. Its name comes from the Greek *astron* ("star"), and it appears in the shape of certain gear mechanisms.

There is a second, humbler way to meet the astroid: it is the envelope of a sliding ladder. Take a rod of length $L$ with its ends on two perpendicular axes and slide it; every position of the rod is tangent to the same astroid, whose equation is

$$x^{2/3} + y^{2/3} = L^{2/3}.$$

**Challenge:** verify the ladder claim. A position of the rod is a straight line with intercepts $L\cos\alpha$ and $L\sin\alpha$ on the axes; write the line equation, differentiate with respect to the sliding angle $\alpha$, eliminate $\alpha$, and show the envelope is $x^{2/3} + y^{2/3} = L^{2/3}$ — the astroid again, hiding inside a textbook physics problem.

## 6. Deltoid — The Three-Cusped Curve

When the rolling circle has one-third the radius of the fixed circle, you get a deltoid: $x = 2a\cos t + a\cos 2t, y = 2a\sin t - a\sin 2t$. Euler studied it extensively. It has exactly three cusps and the curious property that any tangent line to the deltoid intersects it at a point whose distance along the tangent to the cusp is constant. It also appears as the Steiner deltoid — the envelope of all the Simson lines of a triangle.

## 7. Nephroid — The Kidney Curve

Huygens discovered the nephroid ($x = a(3\cos t - \cos 3t), y = a(3\sin t - \sin 3t)$), whose name comes from the Greek *nephros* ("kidney"). It is the epicycloid formed when the rolling circle has half the radius of the fixed circle. You can see it in your morning coffee: light reflecting off the inside of a cylindrical cup forms a nephroid caustic.

## 8. Cardioid — The Heart of Mathematics

The cardioid ($x = a(2\cos t - \cos 2t), y = a(2\sin t - \sin 2t)$) is the epicycloid where both circles have equal radii. First studied by Castillon in 1741, it is the shape of the Mandelbrot set's main bulb and the pickup pattern of certain microphones. Its name — "heart-like" — needs no explanation. It is also the envelope of all circles passing through a fixed point on a given circle.

**Challenge:** look at the four roulettes side by side: the astroid has four cusps, the deltoid three, the nephroid two, and the cardioid one. State the rule connecting the cusp count $N$ to the radius ratio $R/r$ — the fixed circle's radius over the rolling circle's — then test it against the demo's own equations: the astroid's $x = \cos^3 t$ is a hypocycloid with $R = 4r$, and the nephroid's $x = (3\cos t - \cos 3t)/4$ is an epicycloid with $R = 2r$. Finally, explain why the cusp count *decreases* as the rolling circle grows toward the size of the fixed circle.

---

## 9. One Table, Two Families: Eccentricity and the Rolling Ratio

Read the eight curves as two ordered families, each walking from the roundest member to the wildest:

| Curve | Family | Selector parameter | Cusps / branches | Where it shows up |
|---|---|---|---|---|
| Circle | conic section | eccentricity $e = 0$ | none; closed | wheels, ripples, ideal orbits |
| Ellipse | conic section | $0 \lt e \lt 1$ | none; closed, two foci | planetary orbits, whispering galleries |
| Parabola | conic section | $e = 1$ | none; open, one focus | projectile arcs, satellite dishes, headlights |
| Hyperbola | conic section | $e \gt 1$ | two branches | comet fly-bys, lampshade shadows, telescope optics |
| Cardioid | epicycloid | radius ratio $R = r$ | 1 cusp | Mandelbrot set's main bulb, cardioid microphones, coffee-cup caustics |
| Nephroid | epicycloid | $R = 2r$ | 2 cusps | the bright caustic ring inside a cylindrical cup |
| Deltoid | hypocycloid | $R = 3r$ | 3 cusps | Steiner deltoid: envelope of Simson lines |
| Astroid | hypocycloid | $R = 4r$ | 4 cusps | envelope of a sliding ladder; gear-tooth patterns |

The two parameter columns behave differently in kind. Eccentricity measures *shape*: it is the ratio of a point's distance to a focus over its distance to a directrix, and it does not change when the curve is scaled. The rolling ratio measures *construction*: it counts how many times the rolling circle fits around the fixed one, and it fixes the cusp count directly. But both are single scalars that sweep a family outward from its most symmetric member — the circle among the conics, the cardioid among the roulettes — and in both families the members are not separate objects but one process at different knob settings.

---

## 10. Deeper Significance: Every Roulette Is Two Rotations

Write a point as a complex number $z = x + iy$. Then rolling *is* rotation, and every roulette on the canvas is the sum of exactly two uniform circular motions:

$$z(t) = (k+1)e^{it} - e^{(k+1)it} \qquad \text{(epicycloid, } R = kr\text{)},$$

$$z(t) = (k-1)e^{it} + e^{-(k-1)it} \qquad \text{(hypocycloid, } R = kr\text{)}.$$

Check them against the demo's own equations: the cardioid is the $k = 1$ epicycloid, $2e^{it} - e^{2it}$ (the code scales it by $1/3$); the nephroid is $k = 2$, $3e^{it} - e^{3it}$; the deltoid is the $k = 3$ hypocycloid, $2e^{it} + e^{-2it}$; and the astroid is $k = 4$, $3e^{it} + e^{-3it}$. Each term is a point moving uniformly around a circle — the epicycle of ancient astronomy — and the visible curve is the sum of the two motions.

This explains the cusps. Differentiate the template and set the velocity to zero: a cusp is precisely the instant when the two rotating terms' velocities cancel, so the point momentarily stops and reverses. It also explains why the cusp count is not an accident of drawing: the sum of two rotations whose frequencies stand in a whole-number ratio is a closed curve that returns to its start after finitely many laps, and the number of reversals per lap is fixed by that ratio. The same number-theoretic fact is what makes Lissajous figures close and epicycle astronomy possible at all.

The conics join in through the same door. The ellipse $x = a\cos t, y = b\sin t$ is also a two-term phasor sum:

$$z = \frac{a+b}{2} e^{it} + \frac{a-b}{2} e^{-it},$$

two counter-rotating circles of different sizes — the epicycle construction of ancient astronomy, in modern notation. The circle is the special case $a = b$, where the second term vanishes and only one rotation survives. Both families, it turns out, are shadows of the same idea: build a curve by letting circles rotate, and read off the trace.

---

## 11. Final Challenge: The Fifth Curve and the Honest Slider

**Part 1 — predict a curve that is not on the canvas.** Using the hypocycloid template above, predict the curve with $R = 5r$: how many cusps does it have, and what does it look like? Then take the degenerate case $R = 2r$: the template gives $z(t) = e^{it} + e^{-it} = 2\cos t$, a purely real number — a point sliding back and forth along a straight line (the Tusi couple, a motion medieval astronomers used to generate linear motion out of circles). Reconcile the two results: why does the cusp-count rule $N = R/r$ still make sense when the curve collapses to a segment with two endpoints?

**Part 2 — the puzzle from the top.** Read `getPoint` and the `curves` table in the source above. Every `eq` function accepts the parameter `k` — and not one of them ever uses it. The slider therefore changes only the number printed next to it. If you were to make the control honest, which curve would you wire it to first? (Hint: the ellipse is the obvious candidate — replace the fixed axis ratio `1.6` with something like $1 + k$ and the slider becomes an eccentricity control, morphing the circle through every ellipse toward a flat segment.)
