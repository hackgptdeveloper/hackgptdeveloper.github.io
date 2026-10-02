---
title: "Why This Hexagon Spiral Reverses Every 14 Seconds — Five Arms, Two Handednesses, One Sine Wave"
tags:
  - geometry
  - hexagon
  - spiral
  - parametric-curves
  - animation
  - interactive
  - visualization
---

**Challenge to the reader:** Open the demo below and watch one spiral arm for one full 14-second cycle. Count how many times that arm switches between curling clockwise and curling counter-clockwise, and find the single line of JavaScript that decides the switch. Then answer the question the animation is really asking: at peak curvature, has the outermost hexagon of the arm turned more than one full revolution from its seed, or less?

---

Five arms of hexagons grow outward from a single central point. Each arm is built by one rule applied 110 times: **rotate every vertex a little, then push every vertex a little further from the centre**. That is the whole algorithm — everything else is colour.

The rotation angle is not a constant. It swings smoothly from a positive peak, down through zero, to a negative peak, and back, on a 14-second cycle. Positive rotation curls the arm clockwise; negative rotation curls it counter-clockwise; zero rotation stretches it into a straight radial ray. Each arm is therefore a spiral whose *handedness* is itself an oscillating parameter. Because the five arms carry five different phases of the same oscillation, at any instant some twist one way, some the other way, and some are momentarily straight — the whole figure breathes between mirror worlds.

**Why it matters:** this is the cheapest possible way to make something look alive. There is no physics, no noise, no collision detection — just a sine wave driving the sign of a rotation inside a `for` loop. It also demonstrates something deeper: a spiral is not a shape you draw, it is a process you run, and flipping the sign of one parameter is exactly what it takes to mirror it.

---

## 1. The Machine: Rotate, Then Scale

Every expansion step is a single complex-number multiplication. Treat a vertex as a complex number $z$ measured from the canvas centre. One step sends it to

$$z_{k+1} = \lambda e^{i\theta} z_k, \qquad \lambda = 1.026, \quad \theta = \theta(t),$$

where the factor $\lambda$ scales the distance from the centre and $e^{i\theta}$ rotates by $\theta$ radians (Euler's formula: $e^{i\theta} = \cos\theta + i\sin\theta$). The same angle $\theta(t)$ is used for all 110 steps within one rendered frame, so a vertex that starts at $z_0$ ends up, after $k$ steps, at

$$z_k = \lambda^k e^{ik\theta} z_0, \qquad r_k = \lvert z_k \rvert = \lambda^k \lvert z_0 \rvert.$$

The radius formula is the first surprise: **rotation never changes how far a point is from the centre**. The arm grows outward at a fixed 2.6 percent per step no matter how hard it is twisting; the twist only decides *where* on the growing circle the next hexagon lands. With a seed radius of `startRadius = Math.min(W, H) * 0.018` — about 10.8 px on a 600 px canvas — the total growth over a full arm is the factor $1.026^{110} \approx 16.8$, so the last vertex sits roughly 181 px from the centre, a little under a third of the canvas width. The arm is tuned, deliberately, to stay inside the frame even at maximum twist.

---

## 2. Handedness Is the Sign of One Sine Wave

The curvature angle is

$$\theta(t) = \alpha \sin\left(\frac{2\pi t}{T} + \phi\right), \qquad \alpha = 0.065, \quad T = 14,$$

with $\alpha$ in radians per step, $T$ in seconds, and $\phi$ a per-arm phase offset. Everything about the reversing behaviour follows from properties of the sine:

- $\lvert \theta \rvert$ is largest a quarter of the way through the cycle, so the arm is most tightly curled there.
- $\theta = 0$ at $t = 0, T/2, T, \ldots$ — at those instants the arm unrolls into a straight radial fan.
- The sign flips at every zero crossing, so each full period contains exactly two reversals: once from clockwise to counter-clockwise, and once back.

The five arms use phases $\phi_s = 2\pi s/5$ for $s = 0, \ldots, 4$, evenly spread around the cycle. The canvas therefore always shows the full range of states at once: tight clockwise arms, straight arms, tight counter-clockwise arms, and every shade in between.

**Challenge:** at a peak, the code applies `maxAngle = 0.065` radians on each of 110 steps. Show that the accumulated twist of the outermost hexagon at peak curvature is $110 \times 0.065 = 7.15$ radians, a little over 410 degrees — so yes, it has turned more than one full revolution. Now predict the visual effect of raising `maxAngle` to `0.5`: at 55 radians, about 8.8 full turns, the arm would coil into a tight vortex instead of a gentle spiral.

---

## 3. The Demo

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

#canvas-wrap .close-btn {
  display: none;
}
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

<script>
const wrap = document.getElementById('canvas-wrap');
const canvas = document.getElementById('canvas');
const ctx = canvas.getContext('2d');

let W, H, cx, cy, time = 0, animId;

function size() {
  const full = wrap.classList.contains('fullscreen');
  const dpr = window.devicePixelRatio || 1;
  W = full ? window.innerWidth : 600;
  H = full ? window.innerHeight : 600;
  canvas.width  = W * dpr;
  canvas.height = H * dpr;
  canvas.style.width  = W + 'px';
  canvas.style.height = H + 'px';
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  cx = W / 2; cy = H / 2;
}

/* ---- tiny starting hexagon ---- */
function hexPoints(cx, cy, r, rot) {
  const pts = [];
  for (let i = 0; i < 6; i++) {
    const a = (Math.PI / 3) * i + rot;
    pts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) });
  }
  return pts;
}

/* ---- outward spiral from one hexagon ---- */
function drawOutwardSpiral(initialPts, iters, t, hueBase, phaseOffset, startRot) {
  let pts = initialPts;

  // period of one full curvature cycle (seconds)
  const period = 14;
  // maximum rotation per step in radians  (~3.7°)
  const maxAngle = 0.065;
  // expansion per step — small so the spiral is dense
  const expand = 1.026;

  for (let k = 0; k < iters; k++) {
    /* ----- draw the six edges of the current hexagon ----- */
    for (let i = 0; i < pts.length; i++) {
      const a = pts[i];
      const b = pts[(i + 1) % pts.length];

      // early skip when the edge is far outside the visible area
      const da = Math.hypot(a.x - cx, a.y - cy);
      const db = Math.hypot(b.x - cx, b.y - cy);
      if (Math.min(da, db) > Math.max(W, H) * 0.75) continue;

      ctx.beginPath();
      ctx.moveTo(a.x, a.y);
      ctx.lineTo(b.x, b.y);

      // colour: hue rotates with iteration, edge index and time
      const hue   = (hueBase + k * 4 + i * 22 + t * 18) % 360;
      const distF = Math.min(Math.max(da, db) / (Math.min(W, H) * 0.45), 1);
      const sat   = 60 + 35 * Math.sin(t * 0.7 + k * 0.10 + phaseOffset);
      const light = 40 + 28 * (1 - distF) + 12 * Math.sin(t * 0.5 + i);

      ctx.strokeStyle = `hsl(${hue}, ${sat}%, ${light}%)`;
      ctx.lineWidth   = 0.55 + 0.45 * (1 - distF);
      ctx.stroke();
    }

    /* ----- oscillating curvature -----
       rotAngle > 0  → clockwise spiral
       rotAngle ≈ 0  → straight radial expansion
       rotAngle < 0  → counter‑clockwise spiral                */
    const rotAngle = maxAngle * Math.sin(t * (2 * Math.PI) / period + phaseOffset);

    const cosA = Math.cos(rotAngle);
    const sinA = Math.sin(rotAngle);

    /* ----- build the next (larger, rotated) hexagon ----- */
    const next = [];
    for (let i = 0; i < pts.length; i++) {
      const dx = pts[i].x - cx;
      const dy = pts[i].y - cy;
      next.push({
        x: cx + (dx * cosA - dy * sinA) * expand,
        y: cy + (dx * sinA + dy * cosA) * expand
      });
    }
    pts = next;
  }
}

/* ---- animation loop ---- */
function draw(timestamp) {
  time = timestamp * 0.001;
  ctx.clearRect(0, 0, W, H);

  // deep indigo background
  ctx.fillStyle = '#07071a';
  ctx.fillRect(0, 0, W, H);

  const startRadius = Math.min(W, H) * 0.018;
  const iters       = 110;

  // soft centre glow
  const glow = ctx.createRadialGradient(cx, cy, 0, cx, cy, startRadius * 4);
  glow.addColorStop(0, 'rgba(200,210,255,0.35)');
  glow.addColorStop(1, 'rgba(200,210,255,0)');
  ctx.fillStyle = glow;
  ctx.beginPath(); ctx.arc(cx, cy, startRadius * 4, 0, Math.PI * 2); ctx.fill();

  // slow global rotation of the seed hexagon
  const globalRot = time * 0.12;

  // --- five spirals, each with a different curvature phase ---
  const spirals = 5;
  for (let s = 0; s < spirals; s++) {
    // curvature phase — evenly spread across one full cycle
    const phase   = (Math.PI * 2 / spirals) * s;
    // each spiral starts from a hexagon rotated a few degrees
    // differently so the arms separate visually
    const startRot = globalRot + (Math.PI / 3 / spirals) * s * 0.7;
    const seed     = hexPoints(cx, cy, startRadius, startRot);
    drawOutwardSpiral(seed, iters, time, s * 72, phase, startRot);
  }

  // subtle centre dot
  ctx.fillStyle = 'rgba(255,255,255,0.5)';
  ctx.beginPath(); ctx.arc(cx, cy, 2.5, 0, Math.PI * 2); ctx.fill();

  animId = requestAnimationFrame(draw);
}

/* ---- bootstrap ---- */
size();
animId = requestAnimationFrame(draw);

/* ---- fullscreen toggle (same UX as the original) ---- */
let lastTap = 0;
wrap.addEventListener('pointerdown', function(e) {
  const now = Date.now();
  if (now - lastTap < 400) {
    e.preventDefault();
    wrap.classList.toggle('fullscreen');
    size();
  }
  lastTap = now;
});

wrap.addEventListener('dblclick', function(e) {
  wrap.classList.toggle('fullscreen');
  size();
});

document.addEventListener('keydown', function(e) {
  if (e.key === 'Escape' && wrap.classList.contains('fullscreen')) {
    wrap.classList.remove('fullscreen');
    size();
  }
});

wrap.querySelector('.close-btn').addEventListener('click', function(e) {
  e.stopPropagation();
  wrap.classList.remove('fullscreen');
  size();
});
</script>

---

## 4. Distance Grows Whether You Spin or Not

The matrix form of one step makes the split between radius and direction explicit. With a vertex offset $(x_k, y_k)$ from the centre,

$$\begin{pmatrix} x_{k+1} \\ y_{k+1} \end{pmatrix} = \lambda \begin{pmatrix} \cos\theta & -\sin\theta \\ \sin\theta & \cos\theta \end{pmatrix} \begin{pmatrix} x_k \\ y_k \end{pmatrix}.$$

The rotation block has determinant $\cos^2\theta + \sin^2\theta = 1$: it rearranges the figure without changing any area. All of the growth comes from the scalar $\lambda = 1.026 \gt 1$. Radius and direction are independent channels of the same map, which is why the arms always escape outward while their handedness flips.

**Challenge:** verify the radius claim straight from the matrix: compute $x_{k+1}^2 + y_{k+1}^2$, factor out $\lambda^2$, and show the result always equals $\lambda^2 (x_k^2 + y_k^2)$, no matter what $\theta$ is. Then solve $\lambda^k = 2$ to find that an arm doubles its distance from the centre every $\ln 2 / \ln 1.026 \approx 27$ steps — so about three-quarters of the 110 drawn hexagons sit beyond twice the seed radius.

---

## 5. Five Arms, One Colour Wheel

Colour is procedural too. Each arm's base hue is `s * 72` degrees; within an arm the hue advances with the iteration index, the edge index, and time. Saturation pulses with a slow sine, and lightness dips with distance from the centre, giving the flat canvas a sense of depth.

The seed orientations deserve a second look. Arm $s$ starts from a hexagon rotated by

$$\text{startRot} = \text{globalRot} + \frac{\pi}{3} \cdot \frac{s}{5} \cdot 0.7,$$

so the five seeds are fanned inside a single 60-degree sector instead of being spread around the full circle: the arms separate without collapsing into one blob, and the shared `globalRot` term keeps the whole figure slowly turning.

**Challenge:** five hues spaced $360/5 = 72$ degrees apart traverse the colour wheel exactly once, which is why no two arms share a base colour. Explain why the same trick would break with six arms using the same hue step. Then check the largest seed offset, at $s = 4$: $(\pi/3)(4/5)(0.7) \approx 0.586$ radians, about 33.6 degrees — comfortably inside the 60-degree sector.

---

## 6. Reference Card: The Constants That Build It

Everything the animation does is controlled by seven numbers and one sine wave. Here is the whole machine, in the order you meet it in the source:

| Code constant | Value | What it controls |
|---|---|---|
| `period` | 14 | seconds per full curvature oscillation |
| `maxAngle` | 0.065 | peak radians of rotation per expansion step (about 3.7 degrees) |
| `expand` | 1.026 | radial growth per step (2.6 percent) |
| `iters` | 110 | hexagons drawn per arm |
| `startRadius` | `min(W, H) * 0.018` | seed hexagon radius (10.8 px on the 600 px canvas) |
| `spirals` | 5 | number of arms; curvature phases spaced $2\pi/5$ |
| hue base step | 72 | degrees of hue between neighbouring arms |

And the three curvature regimes, which are just the sign of the same sine:

| State | Sign of $\theta$ | What the arm does |
|---|---|---|
| Tightening | $\theta \gt 0$ | curls clockwise while the radius keeps growing |
| Unwinding | $\theta \to 0$ | straightens into a radial ray — the spiral's mirror line |
| Reversing | $\theta \lt 0$ | curls counter-clockwise: the mirror spiral |

---

## 7. Deeper Significance: A Spiral Is a Process

Hold the angle $\theta$ constant and the construction traces a discrete **logarithmic spiral**. In polar coordinates the two facts derived above — $r_k = r_0 \lambda^k$ and $\varphi_k = \varphi_0 + k\theta$ — combine when you eliminate $k$:

$$r = r_0 e^{b\varphi}, \qquad b = \frac{\ln \lambda}{\theta}.$$

The exponent $b$ is the whole personality of the curve. Large $\lvert b \rvert$ hugs the centre and coils tightly; small $\lvert b \rvert$ shoots outward almost radially. In the limit $\theta \to 0$ we get $b \to \infty$: the logarithmic spiral *becomes a straight ray*. The animation is therefore sweeping continuously through a one-parameter family of logarithmic spirals, passing through the straight-line limit and coming out the other side — mirrored — because $b$ changes sign with $\theta$. The reversing hexagon spiral is not five separate spirals; it is one spiral family continuously reflecting itself through a line.

The hexagons matter less than they look. Rotation and scaling are **similarities** — they preserve shape — so every hexagon in an arm is similar to every other. The six vertices trace six intertwined spirals, and the drawn edges are chords woven between them. Replace the hexagon with a square and the same skeleton persists: the seed points move, the process does not.

---

## 8. Final Challenge: Mirror, Then Return

Two short proofs tie the whole post together. Take a seed vertex on the positive real axis, so that $z_0 = \overline{z_0}$, and run $k$ steps with angle $+\theta$ and with $-\theta$:

$$z_k^{+} = \lambda^k e^{ik\theta} z_0, \qquad z_k^{-} = \lambda^k e^{-ik\theta} z_0.$$

**Part 1 — the mirror.** Using $e^{-i\theta} = \overline{e^{i\theta}}$ (a direct consequence of Euler's formula), prove that $z_k^{-} = \overline{z_k^{+}}$ for every $k$. That single line is the mathematics of the reversal: running the machine with the opposite handedness reflects the entire spiral across its seed axis.

**Part 2 — the return.** Now let time advance by exactly one period, $T = 14$. Show that the curvature angles satisfy $\theta_s(t + T) = \theta_s(t)$ for every arm, while two quantities drift linearly: `globalRot` gains $0.12 \times 14 = 1.68$ radians, and every hue gains $14 \times 18 = 252$ degrees. Conclude that the figure at $t + T$ is the figure at $t$ rotated about the centre by roughly 96 degrees, with every colour advanced by 252 degrees. Then answer the surprise: is the animation periodic? Each arm's *shape* repeats exactly at every period, but the *orientation* never returns — 1.68 radians is not a rational multiple of a full turn, so the figure keeps precessing forever. Shape is periodic; position is not.
