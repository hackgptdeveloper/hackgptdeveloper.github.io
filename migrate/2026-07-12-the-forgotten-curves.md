---
title: "The Forgotten Curves: Seven Shapes Time Left Behind — and the One That Squared the Circle by Cheating"
tags:
  - geometry
  - plane-curves
  - math-history
  - ancient-greece
  - quadratrix
  - theodorus-spiral
  - interactive
  - visualization
---

**Challenge to the reader:** Try to trisect an angle using only a compass and a straightedge. You will fail — Pierre Wantzel proved in 1837 that nobody can. Hold on to that frustration. By the end of this post you should be able to: **(1)** explain how a single mechanical curve trisects *any* angle and even squares the circle, **(2)** say exactly which triangle gives the Spiral of Theodorus its next vertex, and **(3)** name the curve that turns a pendulum's swing into a perfect clock. Then open the widget and find the curve with a single cusp — and the one with four.

---

Not every famous curve is a household name. Some were invented to solve a specific ancient problem and then forgotten. Others bear the names of mathematicians who barely studied them. Still others are so simple you wonder why they were not discovered earlier.

The seven curves in the widget below all share one thing: each was invented to answer a question, and each was left behind when mathematics moved on — some because the question was settled, some because a better tool arrived, and some simply because the curve was too strange to teach. This post is their case for a comeback.

<div class="curve-selector" style="margin: 1em 0;">
  <button onclick="selectCurve(0)" style="margin:2px;padding:6px 12px;cursor:pointer;">Kappa Curve</button>
  <button onclick="selectCurve(1)" style="margin:2px;padding:6px 12px;cursor:pointer;">Tschirnhausen Cubic</button>
  <button onclick="selectCurve(2)" style="margin:2px;padding:6px 12px;cursor:pointer;">Semicubical Parabola</button>
  <button onclick="selectCurve(3)" style="margin:2px;padding:6px 12px;cursor:pointer;">Quadratrix of Hippias</button>
  <button onclick="selectCurve(4)" style="margin:2px;padding:6px 12px;cursor:pointer;">Theodorus Spiral</button>
  <button onclick="selectCurve(5)" style="margin:2px;padding:6px 12px;cursor:pointer;">Evolute of Ellipse</button>
  <button onclick="selectCurve(6)" style="margin:2px;padding:6px 12px;cursor:pointer;">Versiera</button>
  <button onclick="selectCurve(7)" style="margin:2px;padding:6px 12px;cursor:pointer;background:#ff6b6b;color:#fff;">Tour All</button>
</div>

<style>
@media print {
  body * { visibility: hidden; }
  #canvas-wrap6, #canvas-wrap6 * { visibility: visible; }
  #canvas-wrap6 {
    position: absolute;
    top: 0; left: 0; width: 100%; height: 100%;
    display: flex; align-items: center; justify-content: center;
    background: #fff;
  }
  #canvas-wrap6 canvas { max-width: 100vw; max-height: 100vh; width: auto; height: auto; }
}
#canvas-wrap6 {
  position: relative;
  display: inline-block;
  cursor: pointer;
  border: 1px solid #333;
  border-radius: 8px;
  overflow: hidden;
  line-height: 0;
}
#canvas-wrap6.fullscreen {
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
#canvas-wrap6 .close-btn { display: none; }
#canvas-wrap6.fullscreen .close-btn {
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

<div id="canvas-wrap6">
  <span class="close-btn">&times;</span>
  <canvas id="canvas6"></canvas>
</div>
<br/>
<label for="paramSlider6">Parameter: <span id="paramVal6">0.50</span></label>
<input type="range" id="paramSlider6" min="5" max="95" value="50" style="width:100%;" />

<script>
(function(){
const wrap = document.getElementById('canvas-wrap6');
const canvas = document.getElementById('canvas6');
const ctx = canvas.getContext('2d');
const slider = document.getElementById('paramSlider6');
const paramVal = document.getElementById('paramVal6');

let W, H, cx, cy, scale, time = 0, animId;
let curveIdx = 0;
let tourMode = false;
let tourTimer = 0;

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
    name: 'Kappa Curve', math: 'Joseph Gergonne, 1813',
    eq: function(t, k) {
      const a = 0.4 + k * 1.2;
      const st = Math.sin(t);
      const ct = Math.cos(t);
      if (Math.abs(st) < 0.005) return { x: 0, y: 0 };
      return { x: a * ct / st, y: a * ct };
    },
    range: [0.08, Math.PI - 0.08],
    desc: 'Resembles the Greek letter κ (kappa). Two branches, asymptotic to the y-axis.',
    color: '#a29bfe'
  },
  {
    name: 'Tschirnhausen Cubic', math: 'Ehrenfried von Tschirnhaus, 1682',
    eq: function(t, k) {
      const a = 0.3 + k * 1.0;
      return {
        x: a * (3 - t * t),
        y: a * t * (3 - t * t)
      };
    },
    range: [-2.2, 2.2],
    desc: 'A cubic curve with a single cusp. Tschirnhaus is better known for his work on equations.',
    color: '#4ecdc4'
  },
  {
    name: 'Semicubical Parabola', math: '17th-century geometers',
    eq: function(t, k) {
      const a = 0.3 + k * 1.2;
      return { x: t * t, y: a * t * t * t };
    },
    range: [-1.8, 1.8],
    desc: 'y² = x³ — the simplest curve with a cusp. An evolutionary dead-end in curve taxonomy.',
    color: '#f9ca24'
  },
  {
    name: 'Quadratrix of Hippias', math: 'Hippias of Elis, c. 420 BCE',
    eq: function(t, k) {
      const a = 0.5 + k * 1.5;
      const tt = t * 0.99; // avoid exact π/2
      if (Math.abs(Math.cos(tt)) < 0.001) return { x: a * 2 / Math.PI, y: tt };
      return { x: a * tt / Math.tan(tt) / Math.PI * 2, y: a * tt / Math.PI * 2 - a };
    },
    range: [-Math.PI * 0.48, Math.PI * 0.48],
    desc: 'The first curve ever invented for a specific purpose: trisecting angles and squaring the circle.',
    color: '#fd79a8'
  },
  {
    name: 'Spiral of Theodorus', math: 'Theodorus of Cyrene, c. 400 BCE',
    eq: function(t, k) {
      // Build discrete points: right triangles with hypotenuse √n
      const pts = [];
      let x = 0, y = 0, angle = 0;
      const nMax = Math.floor(3 + k * 25); // up to ~26 triangles
      for (let n = 1; n <= nMax; n++) {
        const r = Math.sqrt(n);
        const prevR = Math.sqrt(n - 1 || 1);
        angle += Math.atan2(1, Math.sqrt(n - 1 || 1));
        x += Math.cos(angle);
        y += Math.sin(angle);
        pts.push({ x: x, y: y });
      }
      return { pts: pts };
    },
    desc: 'Built from right triangles, each with hypotenuse √n. A discrete spiral of roots.',
    color: '#00b894'
  },
  {
    name: 'Evolute of Ellipse', math: 'Christiaan Huygens, 1673',
    eq: function(t, k) {
      const a = 1.6, b = 0.6 + k * 1.0;
      const ct = Math.cos(t), st = Math.sin(t);
      const denom = a * a * st * st + b * b * ct * ct;
      if (Math.abs(denom) < 0.001) return { x: 0, y: 0 };
      const x0 = a * ct, y0 = b * st;
      const curv = Math.pow(a * a * st * st + b * b * ct * ct, 1.5) / (a * b);
      const nx = -b * ct / Math.sqrt(b * b * ct * ct + a * a * st * st);
      const ny = -a * st / Math.sqrt(b * b * ct * ct + a * a * st * st);
      return { x: x0 + curv * nx, y: y0 + curv * ny };
    },
    desc: 'The locus of curvature centres of an ellipse. Astroid-like, but distinct.',
    color: '#74b9ff'
  },
  {
    name: 'Versiera (Simplified Witch)', math: 'Maria Agnesi, 1748',
    eq: function(t, k) {
      const a = 0.3 + k * 1.5;
      return { x: t, y: a / (1 + t * t) };
    },
    range: [-3, 3],
    desc: 'A simplified parametric form of the Witch of Agnesi. Bell-shaped and elegant.',
    color: '#e17055'
  }
];

function selectCurve(idx) {
  if (idx === 7) { tourMode = !tourMode; if (tourMode) tourTimer = 0; return; }
  tourMode = false;
  curveIdx = idx;
}
	window.selectCurve = selectCurve;
function drawCurve(cx0, cy0, sc, curve, tRange, alpha, k) {
  if (curve.eq.length === 0) return;
  const N = 600;

  // Special handling for Theodorus (discrete)
  const result = curve.eq(0, k);
  if (result && result.pts) {
    ctx.strokeStyle = curve.color;
    ctx.globalAlpha = alpha;
    ctx.lineWidth = 2;
    ctx.shadowColor = curve.color;
    ctx.shadowBlur = 3;
    ctx.beginPath();
    const pts = result.pts;
    // Scale to fit
    const maxR = Math.sqrt(pts.length + 1);
    const s = sc * 0.7;
    ctx.moveTo(cx0, cy0);
    for (let i = 0; i < pts.length; i++) {
      const sx = cx0 + pts[i].x * s;
      const sy = cy0 - pts[i].y * s;
      ctx.lineTo(sx, sy);
    }
    ctx.stroke();
    // Draw dots at vertices
    ctx.fillStyle = curve.color;
    for (let i = 0; i < pts.length; i++) {
      const sx = cx0 + pts[i].x * s;
      const sy = cy0 - pts[i].y * s;
      ctx.beginPath();
      ctx.arc(sx, sy, 2.5, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.shadowBlur = 0;
    ctx.globalAlpha = 1;
    return;
  }

  ctx.beginPath();
  let first = true;
  for (let i = 0; i <= N; i++) {
    const t = tRange[0] + (i / N) * (tRange[1] - tRange[0]);
    try {
      const pt = curve.eq(t, k);
      if (!pt || !isFinite(pt.x) || !isFinite(pt.y)) { first = true; continue; }
      if (pt.pts) continue;
      const sx = cx0 + pt.x * sc;
      const sy = cy0 - pt.y * sc;
      if (Math.abs(sx - cx0) > W || Math.abs(sy - cy0) > H) { first = true; continue; }
      if (first) { ctx.moveTo(sx, sy); first = false; }
      else { ctx.lineTo(sx, sy); }
    } catch(e) { first = true; }
  }
  ctx.strokeStyle = curve.color;
  ctx.globalAlpha = alpha;
  ctx.lineWidth = 2.5;
  ctx.shadowColor = curve.color;
  ctx.shadowBlur = 4;
  ctx.stroke();
  ctx.shadowBlur = 0;
  ctx.globalAlpha = 1;
}

function draw() {
  ctx.clearRect(0, 0, W, H);
  const k = slider.value / 100;

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

  if (tourMode) {
    tourTimer++;
    if (tourTimer > 300) { tourTimer = 0; curveIdx = (curveIdx + 1) % 7; }
  }

  const curve = curves[curveIdx];
  const tRange = curve.range || [0, Math.PI * 2];
  drawCurve(cx, cy, scale, curve, tRange, 1, k);

  // Tracer (skip for Theodorus)
  const result = curve.eq(0, k);
  if (!result || !result.pts) {
    const traceT = tRange[0] + ((time * 0.025) % 1) * (tRange[1] - tRange[0]);
    try {
      const dp = curve.eq(traceT, k);
      if (dp && isFinite(dp.x) && isFinite(dp.y) && !dp.pts) {
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
  }

  ctx.fillStyle = '#fff';
  ctx.font = 'bold 15px "Segoe UI", sans-serif';
  ctx.textAlign = 'center';
  const label = tourMode ? 'Tour: ' + curve.name : curve.name;
  ctx.fillText(label, cx, 18);
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

---

## 1. Why a Curve Gets Forgotten

A curve survives in the curriculum when mathematics needs it as a *tool*; it becomes trivia when it is only an *answer*. That is exactly what happened here. The quadratrix was invented to trisect angles and square the circle — and both problems were eventually proved impossible with compass and straightedge alone (Wantzel in 1837, and Lindemann in 1882 for squaring the circle, by showing that $\pi$ is transcendental). The mechanical curves that *did* solve the classical problems were quietly reclassified from "solution" to "cheating" and dropped from the syllabus.

Why it matters: these forgotten curves are where several modern ideas first appear. A curve defined by *motion* rather than by algebra is the ancestor of every parametric curve in computer graphics. A cusp is the first example of a *singularity* — a place where smoothness fails — and the study of singularities became a central subject of modern geometry. And the envelope of a family of lines, which is what an evolute is, is the idea Huygens turned into the pendulum clock.

**Challenge:** Every curve in the widget is defined parametrically in the page's own JavaScript. Before reading on, click through all seven and sort them into three piles: curves with a *cusp* (a sharp point), curves with an *asymptote* (a line the curve approaches but never reaches), and curves that are smooth everywhere. You will be able to check every answer by the final section.

---

## 2. The Quadratrix: The First Curve With a Mission

Around 420 BCE, Hippias of Elis set out to solve one of the three classical problems of Greek geometry: **trisecting an angle**. He invented what is probably the first curve in history defined not by a geometric construction but by a *kinematic* description — the simultaneous motion of two lines, one rotating and one translating.

A horizontal line moves downward at constant speed while a radius rotates clockwise at constant speed. Their intersection traces the curve. In modern notation, if the square has side $a$:

$$x = \frac{2a}{\pi}\,\theta\cot\theta, \qquad y = \frac{2a}{\pi}\,\theta$$

Once you have the quadratrix, you can trisect any angle — divide the sliding segment into three equal parts and read the angles off the curve. Further out, it does something even more audacious: as $\theta \to 0$ the curve meets the base line at exactly $2a/\pi$ from the centre, a constructible length that contains $\pi$. That is Dinostratus's theorem, and it is why the curve is called the *quadratrix* — it lets you build a square with the same area as a circle.

It caused a philosophical scandal. Greek geometers insisted curves should be constructible with compass and straightedge; the quadratrix required a *mechanical* motion. Sporus of Nicaea also spotted the deepest flaw: at the very endpoint that does the squaring, the two moving lines coincide, so the crucial point is a limit rather than a genuine intersection you can construct. It was a curve ahead of its time — and, by the standards of its own time, a cheat.

**Challenge:** Set the widget's parameter to its maximum and watch the quadratrix. The slider changes $a$ in the parametrisation above — a pure scale factor. Now the arithmetic: with $a = 2$, compute where the curve meets the base line ($2a/\pi$) and compare it with the radius. What does that number let you construct that compass and straightedge alone cannot?

---

## 3. The Spiral of Theodorus: Building √n, One Triangle at a Time

Theodorus of Cyrene — a mathematician of Socrates' circle — constructed this discrete spiral around 400 BCE. Start with a right triangle whose legs are both 1 (hypotenuse $\sqrt{2}$). Build another right triangle using $\sqrt{2}$ as one leg and 1 as the other (hypotenuse $\sqrt{3}$). Continue: each step adds a triangle whose hypotenuse is the square root of the next integer.

$$h_n = \sqrt{n}, \qquad \text{built from legs } \sqrt{n-1} \text{ and } 1$$

The resulting spiral of points winds outward, each vertex at distance $\sqrt{n}$ from the origin. Theodorus proved the irrationality of $\sqrt{3}, \sqrt{5}, \dots, \sqrt{17}$ using this construction — and then, mysteriously, stopped at $\sqrt{17}$. Mathematicians still debate why. The spiral itself approximates an Archimedean spiral for large $n$, but its discrete, triangle-by-triangle nature gives it a unique jagged beauty.

**Challenge:** Each new triangle reuses the previous hypotenuse as a leg and adds a leg of length 1, so triangle number $n$ has hypotenuse $\sqrt{n}$. Check the claim at $n = 17$, then push the widget's slider to its maximum: how many triangles does the widget build, and does anything special happen when it passes vertex 17? Theodorus allegedly stopped there — the geometry gives no reason to.

---

## 4. The Semicubical Parabola: A Cusp and Nothing More

$$y^2 = x^3$$

Here is one of the simplest curves with a **cusp** — a sharp point where the curve reverses direction. It has no loops, no asymptotes, no petals. Its very simplicity made it important: it was one of the first examples where mathematicians recognised that a curve could be smooth everywhere except at isolated singularities. William Neile found its arc length in 1657, making it one of the first algebraic curves ever to be rectified.

---

## 5. The Kappa Curve: Gergonne's Greek Letter

$$x^2\left(x^2 + y^2\right) = a^2y^2$$

First studied by Gérard van Gutschoven around 1662, the curve earned its name from Gergonne, who thought it resembled the Greek letter κ (kappa). Its branches sweep out of the origin and press against the vertical lines $x = \pm a$ without ever crossing them — the upright spine and flared arms of the letter. Gergonne was the founding editor of the first purely mathematical journal, the *Annales de Mathématiques*, in 1810, and the kappa curve was one of dozens he catalogued. The widget draws a rotated variant, so there the κ lies on its side.

---

## 6. Tschirnhausen's Cubic: A Polynomial With Style

$$27ay^2 = (a - x)(x + 3a)^2$$

Ehrenfried von Tschirnhaus is mostly remembered for the Tschirnhaus transformation — a method for eliminating intermediate terms from polynomial equations. His cubic curve is a lesser legacy but a beautiful one: a single graceful loop, a cusp where a branch turns back on itself, and a self-crossing point where the curve passes through itself. Cusp, loop and crossing in one polynomial.

---

## 7. The Evolute of an Ellipse: The Curve Behind the Pendulum Clock

The evolute is the envelope of the normals — equivalently, the locus of all centres of curvature. If the ellipse is traced by $(a\cos t, b\sin t)$, its evolute is:

$$\left(\frac{a^2-b^2}{a}\cos^3 t, \qquad \frac{b^2-a^2}{b}\sin^3 t\right)$$

The evolute of an ellipse is a stretched astroid with four cusps, each corresponding to a point of extreme curvature on the ellipse — one of its four vertices. Huygens used the theory of evolutes in his design of pendulum clocks: by hanging the bob between cycloidal cheeks he made the swing follow a cycloid, whose period does not depend on the amplitude — the first isochronous pendulum.

**Challenge:** The evolute's four cusps are not arbitrary: each sits at the centre of curvature of one of the ellipse's four vertices. Drag the widget's parameter, which squashes the ellipse from strongly flattened toward nearly circular, and describe what happens to the four cusps as the ellipse flattens — and what happens to the whole evolute when the ellipse becomes a circle.

---

## 8. Agnesi's Versiera: The Curve With the Wrong Name

$$y = \frac{a}{1+x^2}$$

The widget draws a simplified form of the **witch of Agnesi**, a curve Maria Gaetana Agnesi published in 1748 in her *Instituzioni analitiche*, one of the first comprehensive calculus textbooks written by a woman. It is a bell-shaped curve that flattens toward the horizontal axis as it spreads, smooth everywhere: no cusp, no loop, no sharp turn.

Its name is a translation accident. Agnesi's word *versiera* comes from the Latin *vertere*, "to turn", but it was confused with *aversiera*, an Italian word for a she-devil — and the curve entered English as the "witch of Agnesi". The mathematics is gentler than the name.

---

## 9. Reference Table: The Forgotten Curves at a Glance

| Curve | Who / when | What makes it interesting | Equation |
|---|---|---|---|
| Quadratrix of Hippias | Hippias of Elis, c. 420 BCE | Kinematic, not algebraic; trisects any angle and squares the circle | $x = \frac{2a}{\pi}\,\theta\cot\theta$ |
| Spiral of Theodorus | Theodorus of Cyrene, c. 400 BCE | Discrete spiral of right triangles whose hypotenuse is the square root of n | $r_n = \sqrt{n}$ |
| Semicubical parabola | William Neile, 1657 | Simplest curve with a cusp; among the first curves ever rectified | $y^2 = x^3$ |
| Kappa curve | Gutschoven, c. 1662; named by Gergonne | Two branches pressed against a pair of vertical asymptotes | $x^2(x^2+y^2) = a^2y^2$ |
| Tschirnhausen cubic | Tschirnhaus, 1682 | A loop, a cusp and a self-crossing in one cubic | $27ay^2 = (a-x)(x+3a)^2$ |
| Evolute of an ellipse | Christiaan Huygens, 1673 | Envelope of the normals; four cusps at the ellipse's vertices | $\left(\frac{a^2-b^2}{a}\cos^3 t, \qquad \frac{b^2-a^2}{b}\sin^3 t\right)$ |
| Versiera | Maria Gaetana Agnesi, 1748 | Bell-shaped and smooth everywhere; the mistranslated "witch" | $y = \frac{a}{1+x^2}$ |

---

## 10. Why These Curves Still Matter

The three classical problems — trisecting an angle, doubling the cube, squaring the circle — are impossible with compass and straightedge, and that impossibility is not a footnote: Wantzel proved the first two in 1837, and Lindemann finished the job in 1882 by showing that $\pi$ is transcendental. The only honest solutions anyone ever found ran *through* the curves in this post, which bent the rules by allowing motion. That is why they were studied so intensely and then dropped so completely: they were answers to questions that mathematics decided to declare unanswerable.

Their real legacy is the machinery they forced mathematicians to build:

- **Curves defined by motion** became parametric curves — the way every shape is defined in computer graphics today.
- **Cusps and nodes** became singularities, the study of where smoothness breaks down, which is now central to geometry.
- **Evolutes and envelopes** became the theory of curvature, born from Huygens' need to make a pendulum keep perfect time.
- **Rectification** — finding the length of a curve — started with the semicubical parabola and ended with the integral calculus.

The pattern is worth remembering: the mathematics that looked like a detour turned out to be the main road.

**Challenge:** Sort the seven curves into the three piles from the opening challenge — *has a cusp or sharp point*, *has an asymptote*, *smooth everywhere* — and then answer the two hardest questions in the gallery. Which curve has four cusps, and which curve is not a smooth curve at all, but a chain of triangles?

---

## 11. The Final Challenge

**Final challenge.**

(a) Which of the seven curves is defined by *counting* rather than by a smooth formula — and how many triangles does the widget's slider let you build at its maximum?

(b) Which curve has four cusps, and what does each cusp correspond to on the shape it came from?

(c) Name two of the three classical problems that compass and straightedge cannot solve, and the single curve in this gallery that solves both — then explain why the number $2a/\pi$ is the key.

(d) The semicubical parabola and the Tschirnhausen cubic both have a cusp. Using their equations, explain why a cusp is unavoidable in each: what happens to $y^2$ as $x$ approaches the cusp point, and why does that force the tangent line to become vertical?

---

**Try it:** Click buttons to switch between curves. Move the slider to modify each curve's defining parameter. Hit **Tour All** for a hands-free journey through every forgotten curve.

<style>
.curve-selector button { transition: all 0.2s; }
.curve-selector button:hover { transform: scale(1.05); }
</style>
