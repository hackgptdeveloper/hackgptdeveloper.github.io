---
title: "The Cycloid Wars: How One Rolling Wheel Sparked a Century of Mathematical Feuding — And the Eight Curves It Spawned"
tags:
  - cycloid
  - epicycloid
  - hypocycloid
  - brachistochrone
  - catenary
  - tractrix
  - math-history
  - interactive
---

**Challenge to the reader:** Using the interactive widget below: (1) find the slider setting that turns the **Hypocycloid** into the astroid — the four-cusped star; (2) find *every* setting at which the hypocycloid closes into a curve with a whole number of cusps; and (3) decide whether the prolate cycloid's self-crossing loop can ever be made to disappear inside the widget's range. (Answers at the end of the post.)

What shape does a point on a rolling wheel trace? The answer — the cycloid — sparked one of the most bitter rivalries in mathematical history, and it turned out to be the fastest path under gravity. But the cycloid is only the first member of a family. Roll a circle inside another circle, outside it, or lift the tracing point away from the rim, and a whole collection of curves falls out — each one the answer to a different physical problem.

**Why this matters:** These are not museum pieces. The involute of the circle is the tooth profile of virtually every gear in every machine; the cycloid gave Huygens the most accurate pendulum clock of the 17th century; the catenary holds up suspension bridges and the Gateway Arch; and the tractrix, revolved about its asymptote, was the first concrete model of hyperbolic geometry — a geometry in which Euclid's parallel postulate fails.

<div class="curve-selector" style="margin: 1em 0;">
  <button onclick="selectCurve(0)" style="margin:2px;padding:6px 12px;cursor:pointer;">Cycloid</button>
  <button onclick="selectCurve(1)" style="margin:2px;padding:6px 12px;cursor:pointer;">Prolate</button>
  <button onclick="selectCurve(2)" style="margin:2px;padding:6px 12px;cursor:pointer;">Curtate</button>
  <button onclick="selectCurve(3)" style="margin:2px;padding:6px 12px;cursor:pointer;">Epicycloid</button>
  <button onclick="selectCurve(4)" style="margin:2px;padding:6px 12px;cursor:pointer;">Hypocycloid</button>
  <button onclick="selectCurve(5)" style="margin:2px;padding:6px 12px;cursor:pointer;">Involute</button>
  <button onclick="selectCurve(6)" style="margin:2px;padding:6px 12px;cursor:pointer;">Tractrix</button>
  <button onclick="selectCurve(7)" style="margin:2px;padding:6px 12px;cursor:pointer;">Catenary</button>
  <button onclick="selectCurve(8)" style="margin:2px;padding:6px 12px;cursor:pointer;background:#ff6b6b;color:#fff;">Animate Roll</button>
</div>

<style>
@media print {
  body * { visibility: hidden; }
  #canvas-wrap3, #canvas-wrap3 * { visibility: visible; }
  #canvas-wrap3 {
    position: absolute;
    top: 0; left: 0; width: 100%; height: 100%;
    display: flex; align-items: center; justify-content: center;
    background: #fff;
  }
  #canvas-wrap3 canvas { max-width: 100vw; max-height: 100vh; width: auto; height: auto; }
}
#canvas-wrap3 {
  position: relative;
  display: inline-block;
  cursor: pointer;
  border: 1px solid #333;
  border-radius: 8px;
  overflow: hidden;
  line-height: 0;
}
#canvas-wrap3.fullscreen {
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
#canvas-wrap3 .close-btn { display: none; }
#canvas-wrap3.fullscreen .close-btn {
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

<div id="canvas-wrap3">
  <span class="close-btn">&times;</span>
  <canvas id="canvas3"></canvas>
</div>
<br/>
<label for="paramSlider3">Rolling radius ratio: <span id="paramVal3">0.50</span></label>
<input type="range" id="paramSlider3" min="10" max="90" value="50" style="width:100%;" />

<script>
(function(){
const wrap = document.getElementById('canvas-wrap3');
const canvas = document.getElementById('canvas3');
const ctx = canvas.getContext('2d');
const slider = document.getElementById('paramSlider3');
const paramVal = document.getElementById('paramVal3');

let W, H, cx, cy, scale, time = 0, animId;
let view = { s: 1, ox: 0, oy: 0 };
let curveIdx = 0;
let showRolling = true;

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
  scale = Math.min(W, H) * 0.32;
}

function selectCurve(idx) {
  if (idx === 8) { showRolling = !showRolling; return; }
  curveIdx = idx;
}
	window.selectCurve = selectCurve;
// The curve definitions with roll data for animation
const curves = [
  {
    name: 'Cycloid',
    math: 'Galileo & Mersenne',
    type: 'line',
    R: 1, r: 0, d: 1,
    desc: 'The brachistochrone: fastest path under gravity.'
  },
  {
    name: 'Prolate Cycloid',
    math: 'Christiaan Huygens',
    type: 'line',
    R: 1, r: 0, d: 1.5,
    desc: 'Tracing point beyond the wheel rim — loops back on itself.'
  },
  {
    name: 'Curtate Cycloid',
    math: 'Christiaan Huygens',
    type: 'line',
    R: 1, r: 0, d: 0.5,
    desc: 'Tracing point inside the wheel — a gentle wave with no cusps.'
  },
  {
    name: 'Epicycloid',
    math: 'Ole Rømer, 1674',
    type: 'epi',
    R: 2, r: 1, d: 1,
    desc: 'Circle rolling on the OUTSIDE of another circle.'
  },
  {
    name: 'Hypocycloid',
    math: 'Ole Rømer, 1674',
    type: 'hypo',
    R: 3, r: 1, d: 1,
    desc: 'Circle rolling on the INSIDE of another — the Spirograph curve.'
  },
  {
    name: 'Involute of Circle',
    math: 'Christiaan Huygens',
    type: 'involute',
    R: 1,
    desc: 'The path traced by unwinding a taut string from a circle — gear tooth profile.'
  },
  {
    name: 'Tractrix',
    math: 'Gottfried Leibniz, 1693',
    type: 'tractrix',
    R: 1,
    desc: 'The "pursuit curve" — dragged by a leash. Revolve it to get the pseudosphere.'
  },
  {
    name: 'Catenary',
    math: 'Huygens, Leibniz, Bernoulli',
    type: 'catenary',
    R: 1,
    desc: 'The shape of a hanging chain. NOT a parabola, as Galileo once thought.'
  }
];

function getCurvePoint(curve, t, k) {
  const c = curve;
  switch (c.type) {
    case 'line': {
      const R = c.R;
      const d = c.d;
      // Adjust d based on slider for prolate/curtate
      const dd = (curveIdx === 0) ? R : (curveIdx === 1 ? 1 + k : 1 - k * 0.9);
      return {
        x: R * (t - dd * Math.sin(t)),
        y: R * (1 - dd * Math.cos(t)),
        cx: R * t, cy: R  // rolling circle center for animation
      };
    }
    case 'epi': {
      const Rr = 1 + k * 3;
      const rr = 1;
      return {
        x: (Rr + rr) * Math.cos(t) - rr * Math.cos((Rr + rr) / rr * t),
        y: (Rr + rr) * Math.sin(t) - rr * Math.sin((Rr + rr) / rr * t),
        cx: (Rr + rr) * Math.cos(t), cy: (Rr + rr) * Math.sin(t)
      };
    }
    case 'hypo': {
      const Rr = 2 + k * 4;
      const rr = 1;
      return {
        x: (Rr - rr) * Math.cos(t) + rr * Math.cos((Rr - rr) / rr * t),
        y: (Rr - rr) * Math.sin(t) - rr * Math.sin((Rr - rr) / rr * t),
        cx: (Rr - rr) * Math.cos(t), cy: (Rr - rr) * Math.sin(t)
      };
    }
    case 'involute': {
      const a = 0.4 + k * 1.2;
      return {
        x: a * (Math.cos(t) + t * Math.sin(t)),
        y: a * (Math.sin(t) - t * Math.cos(t))
      };
    }
    case 'tractrix': {
      const a = 0.5 + k * 1.5;
      return {
        x: a * (t - Math.tanh(t)),
        y: a / Math.cosh(t)
      };
    }
    case 'catenary': {
      const a = 0.3 + k * 1.2;
      return {
        x: t,
        y: a * Math.cosh(t / a)
      };
    }
    default: return { x: Math.cos(t), y: Math.sin(t) };
  }
}

// Natural t-range for each curve type
function getTMin(curve, k) {
  if (curve.type === 'catenary') { const a = 0.3 + k * 1.2; return -2.2 * a; }
  return 0;
}
function getTMax(curve, k) {
  switch (curve.type) {
    case 'line': return Math.PI * 4;
    case 'involute': return Math.PI * 2;
    case 'tractrix': return 4;
    case 'catenary': { const a = 0.3 + k * 1.2; return 2.2 * a; }
    default: return Math.PI * 2; // epi, hypo
  }
}

// Auto-fit the view so the whole curve (plus rolling geometry) is visible
function computeView(curve, k) {
  const tMin = getTMin(curve, k), tMax = getTMax(curve, k);
  const NS = 400;
  let minX = Infinity, maxX = -Infinity, minY = Infinity, maxY = -Infinity;
  const add = (x, y) => {
    if (!isFinite(x) || !isFinite(y)) return;
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
  };
  for (let i = 0; i <= NS; i++) {
    const t = tMin + (i / NS) * (tMax - tMin);
    try { const p = getCurvePoint(curve, t, k); add(p.x, p.y); } catch (e) {}
  }
  if (curve.type === 'line') {
    // rolling wheel: centre at (t, 1), radius 1
    add(-1, 1); add(Math.PI * 4 + 1, 1);
    if (minY > 0) minY = 0;
    if (maxY < 2) maxY = 2;
  } else if (curve.type === 'epi' || curve.type === 'hypo') {
    const R = (curve.type === 'epi') ? (1 + k * 3 + 1) : (2 + k * 4 - 1);
    add(-R, 0); add(R, 0); add(0, -R); add(0, R);
    for (let i = 0; i <= NS; i++) {
      const t = (i / NS) * (Math.PI * 2);
      const p = getCurvePoint(curve, t, k);
      // rolling circle of radius 1 around its centre
      add(p.cx - 1, p.cy); add(p.cx + 1, p.cy);
      add(p.cx, p.cy - 1); add(p.cx, p.cy + 1);
    }
  }
  const bw = Math.max(maxX - minX, 1e-6);
  const bh = Math.max(maxY - minY, 1e-6);
  const s = Math.min(W * 0.88 / bw, H * 0.8 / bh);
  return { s, ox: cx - (minX + maxX) / 2 * s, oy: cy + (minY + maxY) / 2 * s };
}

function toScreen(p) {
  return { x: view.ox + p.x * view.s, y: view.oy - p.y * view.s };
}

function draw() {
  ctx.clearRect(0, 0, W, H);

  // Grid
  ctx.strokeStyle = 'rgba(255,255,255,0.06)';
  ctx.lineWidth = 0.5;
  for (let i = -6; i <= 6; i++) {
    ctx.beginPath(); ctx.moveTo(cx + i * scale * 0.3, 0); ctx.lineTo(cx + i * scale * 0.3, H); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(0, cy + i * scale * 0.3); ctx.lineTo(W, cy + i * scale * 0.3); ctx.stroke();
  }
  ctx.strokeStyle = 'rgba(255,255,255,0.12)';
  ctx.lineWidth = 1;
  ctx.beginPath(); ctx.moveTo(0, cy); ctx.lineTo(W, cy); ctx.stroke();
  ctx.beginPath(); ctx.moveTo(cx, 0); ctx.lineTo(cx, H); ctx.stroke();

  const curve = curves[curveIdx];
  const k = slider.value / 100;
  const N = 1000;
  const tMin = getTMin(curve, k);
  const tMax = getTMax(curve, k);
  view = computeView(curve, k);

  // Draw rolling circle / base circle for cycloid types
  if (showRolling && (curve.type === 'line')) {
    const tNow = (time * 0.03) % (Math.PI * 4);
    const pt = getCurvePoint(curve, tNow, k);
    const rc = toScreen({ x: pt.cx, y: pt.cy });
    const p0 = toScreen({ x: 0, y: 1 });
    const p1 = toScreen({ x: Math.PI * 4, y: 1 });
    // Base line
    ctx.strokeStyle = 'rgba(255,255,255,0.25)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(p0.x, p0.y);
    ctx.lineTo(p1.x, p1.y);
    ctx.stroke();
    // Rolling circle
    ctx.strokeStyle = 'rgba(255,200,100,0.4)';
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.arc(rc.x, rc.y, view.s, 0, Math.PI * 2);
    ctx.stroke();
    // Spoke
    ctx.strokeStyle = 'rgba(255,200,100,0.3)';
    const pc = toScreen({ x: pt.x, y: pt.y });
    ctx.beginPath(); ctx.moveTo(rc.x, rc.y); ctx.lineTo(pc.x, pc.y); ctx.stroke();
  }

  if (showRolling && (curve.type === 'epi' || curve.type === 'hypo')) {
    const tNow = (time * 0.02) % (Math.PI * 2);
    const pt = getCurvePoint(curve, tNow, k);
    const R = (curve.type === 'epi') ? (1 + k * 3 + 1) : (2 + k * 4 - 1);
    const o = toScreen({ x: 0, y: 0 });
    // Base circle
    ctx.strokeStyle = 'rgba(255,255,255,0.2)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.arc(o.x, o.y, R * view.s, 0, Math.PI * 2);
    ctx.stroke();
    // Rolling circle
    if (pt.cx !== undefined) {
      const rc2 = toScreen({ x: pt.cx, y: pt.cy });
      ctx.strokeStyle = 'rgba(255,200,100,0.4)';
      ctx.lineWidth = 1.5;
      ctx.beginPath();
      ctx.arc(rc2.x, rc2.y, view.s, 0, Math.PI * 2);
      ctx.stroke();
    }
  }

  // Draw the curve
  ctx.beginPath();
  let first = true;
  for (let i = 0; i <= N; i++) {
    const t = tMin + (i / N) * (tMax - tMin);
    try {
      const pt = getCurvePoint(curve, t, k);
      if (!isFinite(pt.x) || !isFinite(pt.y)) { first = true; continue; }
      const s = toScreen(pt);
      if (first) { ctx.moveTo(s.x, s.y); first = false; }
      else { ctx.lineTo(s.x, s.y); }
    } catch(e) { first = true; }
  }
  ctx.strokeStyle = '#f9ca24';
  ctx.lineWidth = 2.5;
  ctx.shadowColor = '#f9ca24';
  ctx.shadowBlur = 6;
  ctx.stroke();
  ctx.shadowBlur = 0;

  // Tracer
  const traceT = tMin + ((time * 0.03) % (tMax - tMin));
  try {
    const dp = getCurvePoint(curve, traceT, k);
    if (isFinite(dp.x) && isFinite(dp.y)) {
      const d = toScreen(dp);
      ctx.beginPath();
      ctx.arc(d.x, d.y, 5, 0, Math.PI * 2);
      ctx.fillStyle = '#fff';
      ctx.fill();
      ctx.strokeStyle = '#f9ca24';
      ctx.stroke();
    }
  } catch(e) {}

  // Labels
  ctx.fillStyle = '#fff';
  ctx.font = 'bold 15px "Segoe UI", sans-serif';
  ctx.textAlign = 'center';
  ctx.fillText(curve.name, cx, 18);
  ctx.font = '11px "Segoe UI", sans-serif';
  ctx.fillStyle = '#aaa';
  ctx.fillText(curve.math, cx, 34);
  ctx.fillText(curve.desc, cx, H - 10);

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

**Controls:** Click a curve to select it. Drag the slider to adjust the rolling ratio. Toggle **Animate Roll** to show or hide the rolling wheel. Click the canvas for fullscreen.

---

## 1. The Cycloid Wars: Six Geniuses and a Rolling Wheel

Galileo first studied the cycloid around 1599 and even tried to determine its area by weighing paper cutouts. Mersenne, Descartes, Fermat, Pascal, and Huygens all worked on it — and each claimed priority. Pascal, in a moment of religious fervour, abandoned mathematics, but later, sleepless with a toothache, he started thinking about the cycloid and the pain vanished. He took it as a divine sign and returned to math.

The cycloid has an almost magical property: it is the **brachistochrone** — the curve of fastest descent under gravity. Drop a bead from any height along a cycloidal wire, and it reaches the bottom faster than on any other path, including a straight line. Johann Bernoulli posed this as a challenge in 1696; Newton solved it overnight, anonymously — but Bernoulli recognised "the lion by his claw."

A second property is stranger still. The cycloid is also the **tautochrone**: a bead released from *any* point on a cycloidal wire reaches the bottom in exactly the same time, no matter how high it starts. Huygens used this to build the cycloidal pendulum clock, the most accurate timekeeper of its era.

**Challenge:** Galileo estimated the cycloid's area by weighing paper cutouts. Do it exactly instead. With $x = a(t - \sin t)$ and $y = a(1 - \cos t)$, the area under one arch is $\int_{0}^{2\pi} y \, dx$. Change variables to $t$ and show that the area equals $3\pi a^2$ — exactly three times the area of the rolling circle.

---

## 2. Prolate and Curtate: Variations on a Wheel

Move the tracing point beyond the wheel's rim — the **prolate** cycloid — and the curve loops back on itself, like the path of a point on a train wheel's flange. Move the point inside the rim — the **curtate** cycloid — and the cusps disappear entirely, leaving a gentle undulation. All three shapes come from the same pair of equations:

$$
x = a(t - k \sin t), \quad y = a(1 - k \cos t)
$$

where $k = 1$ is the cycloid, $k \gt 1$ is prolate, and $k \lt 1$ is curtate. The parameter $a$ is the wheel's radius, and $k$ measures how far from the hub the tracing point sits, in wheel radii.

The widget builds these shapes its own way: with the slider at $k$, the prolate tracing distance is $1 + k$ wheel radii and the curtate distance is $1 - 0.9k$.

---

## 3. Epicycloids and Hypocycloids: The Spirograph Curves

When one circle rolls around another, you get **epicycloids** (rolling outside) and **hypocycloids** (rolling inside). The ratio of the radii fixes the number of cusps: if $R/r$ is a whole number $N$, the curve closes into a perfect $N$-cusped star; if the ratio is any other rational number, the curve still closes, but only after several revolutions. This is the principle behind every Spirograph toy ever sold.

Ole Rømer — better known for measuring the speed of light — first studied these systematically in 1674, while investigating gear-tooth profiles. The cardioid, nephroid, astroid, and deltoid are all special cases: the cardioid is an epicycloid of two equal circles, and the astroid is the four-cusped hypocycloid.

The widget follows the same recipe. Its epicycloid has base radius $1 + 3k$ and its hypocycloid $2 + 4k$, each rolling a circle of radius 1 — so in both cases the cusp count equals the base radius, whenever that radius comes out a whole number.

**Challenge:** The hypocycloid closes cleanly whenever its base radius $2 + 4k$ is a whole number, but the epicycloid's radius is $1 + 3k$, and the slider only produces two-decimal values. Find the setting at which the epicycloid comes closest to a three-cusped curve, and explain why the widget can never hit it exactly.

---

## 4. Catenary vs. Parabola: Galileo's Mistake

Galileo thought a hanging chain formed a parabola. It doesn't — it forms a catenary,

$$
y = a \cosh(x/a)
$$

Near its lowest point the two curves agree almost perfectly, which is exactly why Galileo was fooled. Push the chain far enough, though, and the gap becomes visible: writing $\cosh$ as a series, the catenary is $a + x^2/(2a) + x^4/(24a^3) + \cdots$, while the parabola that matches its height, slope, and curvature at the bottom is just $a + x^2/(2a)$. The extra terms are always positive, so the hanging chain always rides a little above the parabola — Galileo's error was small, but it was not zero.

When Robert Hooke announced he could determine the ideal shape for an arch by inverting a hanging chain, he was applying the catenary's properties. The Gateway Arch in St. Louis is an inverted catenary.

---

## 5. The Tractrix: A Dog on a Leash

Imagine pulling a heavy object by a string while walking in a straight line. The path the object traces is the tractrix. Leibniz discovered it in 1693, and its defining property is exactly what the leash implies: the tangent line from any point of the curve back to the walking path has constant length.

Revolve the tractrix about the path you walked — its asymptote — and you get the **pseudosphere**, the first concrete realisation of hyperbolic geometry, a surface on which Euclid's parallel postulate fails.

**Challenge:** Prove the leash property for the widget's tractrix, $x = a(t - \tanh t)$, $y = a/\cosh t$. Its slope is $dy/dx = -1/\sinh t$; show that the tangent line at parameter $t$ meets the x-axis at exactly $x = at$, and that the distance from that point back to the curve is exactly $a$, whatever $t$ is.

---

## 6. The Whole Family at a Glance

| Curve | How it is generated | Defining property | Where you meet it |
|-------|---------------------|-------------------|-------------------|
| Cycloid | A point on the rim of a wheel rolling along a line | Brachistochrone and tautochrone — fastest descent, equal-time descent | Huygens's pendulum clock |
| Prolate / curtate cycloid | The tracing point beyond or inside the rim | Loops (prolate) or smooths (curtate) the cycloid | Train-wheel flanges |
| Epicycloid | A circle rolling outside a fixed circle | Cusp count equals the radius ratio | Gear teeth; planetary gear trains; Wankel engine housings (epitrochoids) |
| Hypocycloid | A circle rolling inside a fixed circle | Cusp count equals the radius ratio | Spirograph toys; the astroid and deltoid |
| Involute of a circle | A taut string unwound from a circle | Tangent length equals the arc length unwound | Nearly every gear tooth in service |
| Tractrix | A weighted object dragged by a leash of fixed length | Constant tangent length | Revolved, it is the pseudosphere of hyperbolic geometry |
| Catenary | A hanging chain | Minimum potential energy | Suspension bridges; the Gateway Arch |

---

## 7. Deeper Significance: Curves Are Answers, Not Drawings

Look again at that table and a pattern appears: not one of these curves was invented as a picture. Each is the *solution* to a problem — minimise descent time (cycloid), minimise potential energy (catenary), hold a distance fixed (tractrix), hold a tangent length fixed (involute), keep two surfaces rolling without slipping (the epicycloids and hypocycloids). The wheel is not the subject; the wheel is the *constraint*, and the curve is what falls out of it.

That is why the same shapes keep reappearing in unrelated fields. A gear designer draws an involute because it is the one profile that keeps the contact angle steady as the teeth engage. A clockmaker draws a cycloid because that is what an isochronous pendulum needs. An architect hangs a chain because that is what a structure in pure compression needs. The mathematics does not care what you call the problem.

The deepest example is the tractrix. Revolve it and you get the pseudosphere, a surface of constant negative curvature built in ordinary three-dimensional space. When Eugenio Beltrami mapped hyperbolic geometry onto it in 1868, a geometry that had seemed like a logical curiosity became a surface you could, in principle, build. A curve drawn with a leash on a tabletop turned out to be the gateway to non-Euclidean geometry.

The family keeps growing, too. The same outside-rolling recipe gives the epitrochoids inside a Wankel engine and the discs of a cycloidal drive gearbox; the involute is why your car's gears run at a constant speed instead of lurching over every tooth.

---

## 8. Final Challenge

**Synthesis challenge:** Verify a classical theorem using the widget's own formulas. The **tractrix is the involute of the catenary** — it is traced by unwinding a taut string from the curve $y = a\cosh(x/a)$. The widget's tractrix is $x = a(t - \tanh t)$, $y = a/\cosh t$. Start from the catenary point $(at, a\cosh t)$: its unit tangent is $(\operatorname{sech} t, \tanh t)$, and the arc length from the vertex to that point is $a\sinh t$. Subtract $a\sinh t$ times the unit tangent from the point, and show that you land exactly on the tractrix. Then say, in one sentence, why this makes the curves of Sections 4 and 5 geometric cousins.

Then the Spirograph question: a fixed ring has 52 teeth and the rolling gear has 30. How many cusps does the closed curve have, and how many revolutions of the gear does it take before the pattern repeats? (Hint: reduce the ratio $52/30$ and read off its numerator and denominator.)

---

**Answers to the challenges:**

- **Astroid:** the widget's hypocycloid has base radius $2 + 4k$, so four cusps need $k = 0.50$.
- **Closed hypocycloids:** the base radius $2 + 4k$ must be a whole number, so the settings are $k = 0.25$, $0.50$, and $0.75$ — with 3, 4, and 5 cusps.
- **Prolate loop:** the loop exists only while the tracing distance exceeds 1; the widget uses $1 + k$, so the loop would first vanish at $k = 0$ — below the slider's minimum of $0.10$. It can never disappear inside the widget.
- **Cycloid area:** with $dx = a(1 - \cos t)\,dt$, the area is $a^2\int_{0}^{2\pi}(1 - \cos t)^2\,dt = a^2 \cdot 3\pi = 3\pi a^2$.
- **Epicycloid:** three cusps need $1 + 3k = 3$, so $k = 2/3$ — the slider's closest values are $0.66$ and $0.67$, and neither closes the curve exactly.
- **Tractrix:** the tangent at parameter $t$ meets the x-axis at $x = at$, and the distance from $(at, 0)$ back to the curve is $\sqrt{a^2\tanh^2 t + a^2\operatorname{sech}^2 t} = a$.
- **Final challenge:** the string construction lands on $(at - a\tanh t, a\operatorname{sech} t)$ — the tractrix. The Spirograph ring and gear reduce to $26/15$, giving 26 cusps after 26 revolutions of the gear (and 15 laps of the ring).

<style>
.curve-selector button { transition: all 0.2s; }
.curve-selector button:hover { transform: scale(1.05); }
</style>
