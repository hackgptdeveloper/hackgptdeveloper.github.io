---
title: "The Hexagon Trick That Folds a Spiral From Straight Lines — And You Can Predict the Exact Rate"
tags:
  - hexagon
  - chasing-polygons
  - spiral
  - logarithmic-spiral
  - animation
  - canvas
  - interactive
---

**Challenge to the reader:** The demo below nests 70 hexagons inside every hexagon on screen, each one built by walking the same fraction $f$ of the way along every edge of the previous one. When the animation breathes out to its widest, $f = 0.12$. Work out from $f$ alone — and the hexagon's 60-degree symmetry — the factor by which every nested hexagon shrinks and the angle by which it turns. Then predict how many *more* iterations it would take to shrink the innermost hexagon to one percent of the outermost. Section 4 does the arithmetic. The answer is unintuitive: the hexagons lose barely five percent of their size per step, and are still fifty times smaller after seventy of them.

---

There is not one curve in the animation below. There is one **hexagon**, one **number**, and a rule applied seventy times per hexagon. The rule is the most boring operation in computer graphics — linear interpolation, the `lerp` inside every animation tween. Applied to the six edges of a hexagon and iterated, it produces a spiral with an exact rate, an exact winding, and a self-similarity that never runs out.

That matters because this is the honest core of procedural art: complicated-looking output from trivial-looking rules. Nothing here is chaotic, nothing is random, and every pixel is predictable in advance. Once you can read the rate off the rule, the "hypnotic animation" stops being a mystery and becomes a dial you can turn.

---

## 1. The Demo — Seven Hexagons, Seventy Rings Each

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

let W, H, cx, cy, hexRadius, time = 0, animId;

function size() {
  const full = wrap.classList.contains('fullscreen');
  const dpr = window.devicePixelRatio || 1;
  W = full ? window.innerWidth : 600;
  H = full ? window.innerHeight : 600;
  canvas.width = W * dpr;
  canvas.height = H * dpr;
  canvas.style.width = W + 'px';
  canvas.style.height = H + 'px';
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
  cx = W / 2; cy = H / 2;
  hexRadius = Math.min(W, H) * 0.11;
}

function hexPoints(cx, cy, r, rot) {
  const pts = [];
  for (let i = 0; i < 6; i++) {
    const a = (Math.PI / 3) * i + rot;
    pts.push({ x: cx + r * Math.cos(a), y: cy + r * Math.sin(a) });
  }
  return pts;
}

function midpoint(a, b) {
  return { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 };
}

// Draw chasing polygons inside a hexagon — each iteration takes
// a step `frac` along every edge, forming a smaller inner polygon.
// Over many iterations the edges trace out a spiral.
function drawChasing(initial, iters, frac, t, hueBase) {
  let pts = initial;
  for (let k = 0; k < iters; k++) {
    for (let i = 0; i < pts.length; i++) {
      const a = pts[i];
      const b = pts[(i + 1) % pts.length];
      ctx.beginPath();
      ctx.moveTo(a.x, a.y);
      ctx.lineTo(b.x, b.y);
      const hue = (hueBase + k * 6 + i * 30 + t * 40) % 360;
      const sat = 70 + 30 * Math.sin(t * 1.3 + k * 0.2);
      ctx.strokeStyle = `hsl(${hue}, ${sat}%, ${55 + 10 * Math.sin(t * 0.7 + i)}%)`;
      ctx.lineWidth = 0.8;
      ctx.stroke();
    }
    // Next polygon: points `frac` along each edge
    const next = [];
    for (let i = 0; i < pts.length; i++) {
      const a = pts[i];
      const b = pts[(i + 1) % pts.length];
      next.push({
        x: a.x + (b.x - a.x) * frac,
        y: a.y + (b.y - a.y) * frac
      });
    }
    pts = next;
  }
}

function draw(timestamp) {
  time = timestamp * 0.001;
  ctx.clearRect(0, 0, W, H);

  const globalRot = time * 0.15;
  const centre = hexPoints(cx, cy, hexRadius, globalRot);

  // Oscillating fraction — smaller = tighter spiral, breathes with time
  const frac = 0.03 + 0.09 * (0.5 + 0.5 * Math.sin(time * 0.6));
  const iters = 70;

  // Central hexagon
  drawChasing(centre, iters, frac, time, 0);

  // Six surrounding hexagons — one centred on each edge midpoint,
  // rotated −60° so they nest cleanly against the central one.
  for (let i = 0; i < centre.length; i++) {
    const p1 = centre[i];
    const p2 = centre[(i + 1) % centre.length];
    const mid = midpoint(p1, p2);
    const vx = mid.x - cx;
    const vy = mid.y - cy;
    const nc = { x: cx + 2 * vx, y: cy + 2 * vy };
    const outer = hexPoints(nc.x, nc.y, hexRadius, globalRot - Math.PI / 3);
    drawChasing(outer, iters, frac, time, i * 60);
  }

  animId = requestAnimationFrame(draw);
}

size();
animId = requestAnimationFrame(draw);

// ---- fullscreen toggle ----
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

Click or double-click the canvas to blow it up to fullscreen, and press Escape to come back. Everything below is an explanation of those 2,940 line segments per frame: where the seven hexagons come from, what the chase does to each of them, and why the spiral has a rate you can compute in advance.

---

## 2. Seven Hexagons That Tile

The demo draws a central hexagon of circumradius $\rho = 0.11\min(W,H)$ — 66 px on the default 600-pixel canvas — and six more, one centred on each edge of it. The centre of each neighbour is placed at twice the distance from the middle of the canvas to the edge midpoint, which works out to exactly $\sqrt{3}\,\rho$ away from the central hexagon's centre.

That number is not arbitrary. A regular hexagon's inradius is $\rho\sqrt{3}/2$, and twice the inradius is exactly the centre-to-centre spacing of the regular hexagonal tiling — the same spacing as the tiles on a bathroom floor. So the seven hexagons are not "roughly adjacent": they share edges exactly, the way floor tiles do, and each neighbour has two vertices that coincide with two vertices of the central hexagon.

The code then rotates every outer hexagon by $-60^\circ$. For a regular hexagon that rotation is invisible in the outline — the shape maps onto itself, vertex for vertex. Section 6 shows what that line of code actually does change, which is not what its comment claims.

**Challenge:** take the arithmetic above apart. Confirm that a hexagon of circumradius $\rho$ has inradius $\rho\sqrt{3}/2$, that the six edge midpoints sit at that same distance, and therefore that doubling the vector to a midpoint lands a neighbour's centre exactly $\sqrt{3}\,\rho$ from the middle.

---

## 3. The Chase Is a Multiplication

Here is the whole construction in the complex plane. Put the hexagon's centre at the origin and its vertices at $z_k = \rho\,\omega^k$, where $\omega = e^{i\pi/3}$ rotates by one sixth of a turn. The chase step replaces each vertex by the point a fraction $f$ along the edge that leaves it:

$$ z_k \longmapsto (1-f)z_k + f z_{k+1} $$

Substitute $z_{k+1} = \omega z_k$ and something excellent happens:

$$ (1-f)z_k + f\omega z_k = \bigl((1-f) + f\omega\bigr) z_k = \lambda z_k $$

Every vertex is multiplied by the *same* complex number $\lambda = (1-f) + f\omega$. The polygon does not merely shrink: it undergoes a **spiral similarity** — a rotation by $\arg\lambda$ composed with a scaling by $\lvert\lambda\rvert$ — about its centre, all six vertices at once, every step, forever. Iterating the chase is exponentiation: after $k$ steps the polygon is $\lambda^k$ times the original.

For the hexagon, $\omega = e^{i\pi/3}$ makes the algebra collapse beautifully:

$$ \lvert\lambda\rvert^2 = (1-f)^2 + f^2 + 2f(1-f)\cos\frac{\pi}{3} = 1 - f + f^2 $$

For a general $n$-sided polygon the same derivation gives $\lvert\lambda\rvert^2 = 1 - 2f(1-f)\bigl(1 - \cos\frac{2\pi}{n}\bigr)$, whose minimum sits at $f = 1/2$ and equals $\cos(\pi/n)$. The hexagon's fastest collapse is therefore $\cos(\pi/6) = \sqrt{3}/2$ — but "fastest" here still means 86.6% per step, which is why the demo works in the neighbourhood of $f = 0.1$ rather than $f = 0.5$.

**Challenge:** show that for a square the same formula gives a minimum collapse factor of $\cos(\pi/4)$, and identify what the $f = 1/2$ chase of any quadrilateral is called in classical geometry.

---

## 4. The Exact Rate, in Numbers

Everything the demo does is now computable. The turn per step is $\arg\lambda$ and the shrink per step is $\lvert\lambda\rvert = \sqrt{1 - f + f^2}$, and since the demo iterates 70 times, the innermost hexagon is $\lvert\lambda\rvert^{70}$ times the outer one.

| Step fraction | Shrink per step | Turn per step | Size after 70 steps | Total winding after 70 steps |
|---------------|-----------------|---------------|---------------------|------------------------------|
| 0.03 | 0.98534 | 1.51 degrees | 35.6 percent | 106 degrees |
| 0.06 | 0.97139 | 3.07 degrees | 13.1 percent | 215 degrees |
| 0.09 | 0.95818 | 4.67 degrees | 5.0 percent | 327 degrees |
| 0.12 | 0.94573 | 6.31 degrees | 2.0 percent | 442 degrees |
| 0.50 | 0.86603 | 30.00 degrees | 0.004 percent | 2100 degrees |

Read the fourth column against the second and the design of the animation falls out. At the widest point of the breath, each hexagon is 94.57% of its parent — a loss you would never notice in a single step — but 70 steps of compounding leave 2% of the original, which at a 66 px circumradius is about **1.3 pixels**. The demo is not drawing an approximation of an infinite spiral; it is drawing 70 rings and stopping precisely where a 600-pixel canvas runs out of pixels.

The fifth column is the reason the picture reads as a *spiral* rather than as concentric rings: at $f = 0.12$ the successive polygons wind through 442 degrees — more than a full turn — over those 70 steps, while at $f = 0.03$ they wind only 106 degrees and the result looks like a stack of nearly aligned hexagons instead.

There is one more exact statement available. Because every step multiplies by the same complex number, the corresponding vertices of successive hexagons form a geometric sequence — which is to say each of the six visible spiral arms has its corners on a **perfect logarithmic spiral**. Its pitch follows from $\ln\lvert\lambda\rvert / \arg\lambda$: at $f = 0.12$ the arms cross every radius from the centre at a constant angle of about 63 degrees, the same equiangular property that makes a nautilus shell look the way it does. The drawn segments are straight chords, but the corners they connect are on a genuine log spiral.

**Challenge:** from the fourth column, work out how many iterations at $f = 0.12$ are needed to shrink the hexagon to one percent of the original. (To check yourself: one percent corresponds to a circumradius of 0.66 px on this canvas.)

---

## 5. Breathe, Spin, and Colour

The rule is static; the animation is three clocks running at once.

- **The breath.** The step fraction is not constant. The code computes $f = 0.03 + 0.09\bigl(0.5 + 0.5\sin(0.6t)\bigr)$, so the chase oscillates between $f = 0.03$ and $f = 0.12$ with a period of about 10.5 seconds. The spiral contracts and relaxes like a heartbeat, sweeping the whole range of the table in section 4 twice per period.
- **The spin.** The seven-hexagon flower rotates as a rigid body at $0.15t$ radians per second — one full turn every 41.9 seconds. This clock is pure multiplication by time, not a sine: the rotation never eases.
- **The colours.** Each segment's hue is $h_0 + 6k + 30i + 40t$ degrees, where $k$ is the iteration depth and $i$ the edge index. The $6k$ term alone sweeps the entire hue wheel by iteration 60, so every hexagon carries a full rainbow from rim to centre; the $30i$ term separates the six edges within a ring, and the $40t$ term washes the whole palette around over time. Saturation rides between 40% and 100% on a slow sine, lightness between 45% and 65%.

The budget for all of this is 7 hexagons × 70 iterations × 6 edges = **2,940 line segments per frame**, redrawn from scratch each frame — around 176,000 strokes per second at 60 fps. That is the real reason the construction is a chasing polygon and not a raster texture: line segments are cheap, and the browser's canvas is happy to draw a few thousand of them forever.

**Challenge:** the colour formula indexes the hue by iteration depth $k$. Predict what the picture looks like if that term is removed — and check your prediction against section 6, where the same trick of indexing colour by position turns out to be the *only* visible effect of a line of code that looks geometric.

---

## 6. A Rotation You Cannot See

Section 2 flagged a suspicious line: the outer hexagons are created with a rotation of $-60^\circ$, and the comment says it makes them "nest cleanly". For a regular hexagon, a $60^\circ$ rotation about the centre maps the vertex set onto itself, so the outline is unchanged. But the chase is more interesting than the outline, so the natural assumption is that the rotation at least changes the *spiral* — the winding has to start from a different corner, after all.

It does not. The chase step acts on vertex indices: vertex $i$ of the next polygon depends only on vertices $i$ and $i+1$ of the current one. Rotating the hexagon by $-60^\circ$ is exactly equivalent to renumbering the vertices by one — vertex $i$ of the rotated hexagon sits where vertex $i-1$ of the original sat. Because the rule is index-equivariant, every subsequent iterate is the same renumbering of the corresponding unrotated iterate: the traced segments are the *identical set of segments*, in a rotated order.

What actually changes is the colour. The hue formula contains $30i$ and the lightness contains $\sin(0.7t + i)$, both indexed by vertex position, so a one-step renumbering rotates the per-edge hue pattern by 30 degrees and shifts the lightness wave by one step. That is all: the line the comment describes as a geometric necessity is a colour-domain throw of the dice, and only the code's own indexing makes it visible at all.

This is the kind of detail that procedural art lives on. The geometry is over-constrained by symmetry — so the artist's remaining freedom is the parameterisation, the ordering, and the palette. Two programs that produce identical geometry can look like different artworks.

---

## 7. Why It Matters: Contractions, Subdivision, and the Nautilus

The chase is a **contraction**: every step rotates and shrinks toward a single fixed point, the polygon's centre, and after $k$ steps every point is exactly $\lvert\lambda\rvert^k$ times as far from that centre as it started. There is nothing chaotic about it — no sensitive dependence, no attractor with structure, just monotone convergence. The hypnotic quality comes from the compounding, not from complexity.

That places the chase in a family of polygon algorithms that all begin with the same `lerp`:

- **Chaikin's corner-cutting** (1974) takes each edge's one-third and two-thirds points and *doubles* the vertex count, converging to a smooth curve. The chase keeps the vertex count fixed and converges to a point.
- **Varignon's theorem** is the $f = 1/2$ case for any quadrilateral: the midpoint polygon of any quadrilateral is a parallelogram. The chase in this demo is Varignon's construction taken to thirty decimal places and coloured.
- **Logarithmic spirals** are the shape nature uses whenever growth is proportional to size — nautilus shells, sunflower heads, the arms of a galaxy. The chase produces them as a side effect of iterating a similarity.

The practical upshot for anyone building animation or generative art: a rule that shrinks by 5% per step and turns by 6 degrees per step will look, after seventy steps, like a designed rosette — and you can state its final size and total winding in advance. Procedural art is not a search for a surprise; it is a search for a rule whose consequences are worth pages of.

**Challenge:** for the square case, compute the shrink and turn per step at $f = 1/2$ and confirm the parallelogram of Varignon's theorem is reached after a single iteration — then explain why the same fraction applied to a hexagon (heading that row of the table) collapses so much faster than the demo's own fractions do.

---

## 8. Turning the Rule Inside Out

The parameter $f$ is the whole story, and the extremes are diagnostic.

- **No chase at all.** With $f = 0$ every vertex stays where it is: the identity map, and no spiral.
- **Everything contracts.** For $0 \lt f \lt 1$ the chase always shrinks, in every polygon, at every step. This is the interval the demo lives in.
- **Fastest collapse.** At $f = 1/2$ the contraction is strongest and equals $\cos(\pi/n)$: 0.866 per step for a hexagon, 0.707 for a square, 0.5 for a triangle. Even the fastest case is a factor of two per step at best, which is why the spiral needs so many rings to look dense.
- **A pure rotation.** At $f = 1$ the chase is a $60^\circ$ rotation with no shrinkage — the rings would stack exactly on top of each other, and the "spiral" would become a single hexagon drawn sixty times.
- **Mirror twins.** The fractions $f$ and $1 - f$ produce mirror-image spirals: the chase run forwards and the chase run backwards wind in opposite senses.
- **Outside the unit interval.** When $f \gt 1$ or $f \lt 0$ the step runs past the polygon's edge and the map becomes an expansion — the rings grow, and the spiral unravels off the canvas instead of into the centre. The transition at the endpoints is the entire difference between art and runaway.

---

## Final Challenge

Put everything together for the picture on this page. The outer hexagon has a circumradius of 66 px and the code iterates 70 times at $f = 0.12$, giving an innermost circumradius of about 1.33 px. Now compute how many iterations would be needed to push the innermost hexagon below one pixel — and then decide whether the demo's 70 is an arbitrary round number or the point where a 600-pixel canvas physically runs out of resolution. To finish, answer the same question for the breathing case: as $f$ oscillates down to 0.03, does the innermost ring get bigger or smaller, and by how much?

(The ratio of the two columns of the table answers the second half: at 0.03 the spiral keeps 35.6% of its size across 70 steps, against 2.0% at 0.12 — so when the animation breathes in, the innermost ring swells by a factor of about 18.)

---

Browse [the post archive](/posts/) for more constructions like this one, or compare against the original static version of the same idea, [chasing hexagon around hexagon](/2024/11/22/chasing_6gon_around_6gon.html). The same complex-multiplication machinery run the other way — growing outward instead of contracting inward — drives [the hexagon spiral that reverses every 14 seconds](/2026/07/12/reversing-hexagon-spirals.html).
