---
title: "The Spirograph Secret: How a Rolling Circle Draws 100 Lobes — And Why Your Browser Only Shows 26"
tags:
  - hypotrochoid
  - spirograph
  - geometry
  - parametric-curves
  - canvas
  - javascript
  - interactive
---

**Challenge to the reader:** Before you scroll past the demo, do one piece of arithmetic. The canvas below rolls a circle of radius $r$ inside a fixed circle of radius $R$ whose ratio is $R/r = 100/39$, and it samples the curve over exactly ten revolutions of the rolling circle's centre. Work out how many revolutions that centre must complete before the traced curve returns to where it started — then decide whether the picture in front of you is the finished figure or only a fragment of it. Section 4 does the arithmetic, and the answer is not ten.

---

A **hypotrochoid** is the curve traced by a pen fixed to a small circle that rolls, without slipping, around the inside of a larger fixed circle. It is the mathematics inside every Spirograph kit ever sold, and one of the few places where a toy from the 1960s does honest calculus on a bedroom floor. The rolling constraint is not decoration: every lobe, every self-crossing loop and every cusp in the picture is a consequence of one statement — *the contact point does not slide*.

That single constraint earns its living far beyond toys. Gear-cutting hobs leave trochoidal fillets at the root of every involute gear tooth, cycloidal gears and modern cycloidal drives transmit torque through exactly these curves, banknote and passport security printing is built from hypotrochoid lattices scratched out by guilloche lathes, and a special case of the same geometry — the Tusi couple — spent five centuries as a working model of planetary motion. Learn the two equations below and you have learned the same idea in four industries.

---

## 1. One Wheel Inside Another

Fix a circle of radius $R$ at the origin and let a circle of radius $r$ roll inside it. The rolling circle's centre is always exactly $R - r$ from the origin, so it rides a circle of its own, and its position is described by one angle $\theta$:

$$ C(\theta) = \bigl( (R-r)\cos\theta,\ (R-r)\sin\theta \bigr) $$

The pen sits at distance $d$ from the wheel's centre. To place it we need the wheel's own rotation, and this is where *rolling without slipping* bites. The wheel touches the fixed circle at its outermost point $P = R(\cos\theta, \sin\theta)$, and rolling without slipping means that point is instantaneously at rest. Setting the velocity of the contact point to zero, $v_C + \omega\,\hat{z}\times(P - C) = 0$, gives the wheel's spin:

$$ \omega = -\frac{R-r}{r}\,\dot\theta $$

Two details matter. First, the factor is $R - r$, not $R$: the wheel's spin is measured against a frame that is itself going around. (Relative to the rotating line of centres the rate is the more familiar $-R/r$, which is why the schoolbook "the wheel unrolls an arc $R\theta$" argument reaches the same curve — it just measures in the rotating frame.) Second, the minus sign is the entire difference between a hypotrochoid and an epitrochoid: rolling on the inside reverses the sense of rotation.

Integrating, the pen's angle is $\phi = -\frac{R-r}{r}\theta$, so the curve is

$$
\begin{aligned}
x(\theta) &= (R-r)\cos\theta + d\cos\!\left(\frac{R-r}{r}\theta\right) \\
y(\theta) &= (R-r)\sin\theta - d\sin\!\left(\frac{R-r}{r}\theta\right)
\end{aligned}
$$

and its distance from the centre collapses to something remarkably clean:

$$ \rho(\theta) = \sqrt{(R-r)^2 + d^2 + 2(R-r)d\cos\!\left(\frac{R}{r}\theta\right)} $$

That last line is the whole shape. A hypotrochoid is a polar curve whose radius breathes between $d - (R-r)$ and $d + (R-r)$, completing $R/r$ cycles for every revolution of the centre. Everything else in this post is bookkeeping about when the breathing pattern repeats.

**Challenge:** per revolution of the centre, the pen rotates about the wheel's centre by $(R-r)/r$ turns. For this demo that is $61/39$ of a turn, or 563 degrees. Before reading further, work out how many full turns the pen makes during the demo's ten-revolution sweep, and predict how many times it crosses its own path.

---

## 2. The Demo — One Wheel, 2,000 Points, and a Rainbow

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

let W, H, cx, cy, R, r, d, t = 0;

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
  R = Math.min(W, H) * 0.30;
  r = R * 0.39;
  d = R * 0.67;
}
size();

function draw() {
  ctx.clearRect(0, 0, W, H);
  ctx.beginPath();
  for (let i = 0; i < 2000; i++) {
    const a = (i / 2000) * Math.PI * 20 + t;
    const x = cx + (R - r) * Math.cos(a) + d * Math.cos(((R - r) / r) * a);
    const y = cy + (R - r) * Math.sin(a) - d * Math.sin(((R - r) / r) * a);
    if (i === 0) ctx.moveTo(x, y);
    else ctx.lineTo(x, y);
  }
  ctx.strokeStyle = `hsl(${(t * 30) % 360}, 80%, 60%)`;
  ctx.lineWidth = 1.5;
  ctx.stroke();
  t += 0.005;
  requestAnimationFrame(draw);
}
draw();

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

Click or double-click the canvas to blow it up to fullscreen, and press Escape to come back. Every pixel of that rosette comes from the two equations in section 1, evaluated at 2,000 values of $\theta$.

---

## 3. Reading the Demo's Numbers

The code fixes three lengths before it draws anything: $R$ is 30% of the smaller canvas dimension, $r = 0.39R$, and the pen rides at $d = 0.67R$. On the default 600-pixel canvas that means $R = 180$ px, $r = 70.2$ px and $d = 120.6$ px. Three consequences follow immediately.

- The wheel's centre rides a circle of radius $R - r = 0.61R$, which is 109.8 px.
- The outermost reach of the pen is $(R-r) + d = 1.28R$, or 230.4 px — comfortably inside the 300-pixel half-canvas, which is why the figure never clips.
- The innermost reach is $d - (R-r) = 0.06R$, or 10.8 px. The curve never enters that little disc; the pinprick hole in the middle of the animation is not a trick of the rendering, it is the gap between $d$ and $R - r$.

Because $d/r = 1.718$ is greater than one, the pen lies *outside* the rolling circle, and the curve crosses itself: those are the loops at each lobe. Had the ratio been below one the same code would draw a smooth, wavy ring with no crossings at all.

The sampling is generous. The loop runs 2,000 samples over $\theta \in [0, 20\pi]$ — ten revolutions — so 200 samples per revolution, and since the radial pattern completes $R/r = 2.564$ cycles per revolution there are roughly 78 samples per lobe. That is why the polyline reads as a smooth curve at 600 px instead of a polygon.

Two animated details are worth naming. The whole 2,000-point path is stroked once per frame with a single flat HSL colour whose hue is $(30t)$ modulo 360; since $t$ grows by 0.005 per frame the hue advances 0.15 degrees per frame, so the rainbow completes a full cycle every 2,400 frames — about 40 seconds at 60 fps. And $t$ is *added* to the sample angle, which slides the ten-revolution window along the curve, so the figure visibly drifts instead of sitting still. The animation is not redrawing a different curve; it is sending a moving window down the same one.

**Challenge:** the curve is confined to an annulus. Confirm from the radius formula why the inner boundary is $d - (R-r)$ here, and then work out what the two boundaries become if you halve the pen distance to $d = 0.335R$. Would the loops survive?

---

## 4. When Does the Curve Close?

For the trace to repeat, two angles must come home at once: the centre angle $\theta$ and the pen angle $\frac{R-r}{r}\theta$. Write the radius ratio in lowest terms,

$$ \frac{R}{r} = \frac{a}{b}, \qquad \gcd(a,b) = 1 $$

so that $\frac{R-r}{r} = \frac{a-b}{b}$. The centre returns after $\theta = 2\pi m$; the pen returns after $\theta = 2\pi n\frac{b}{a-b}$. Setting those equal gives $m(a-b) = nb$, and since $a - b$ shares no factor with $b$, the smallest solution is $m = b$.

The curve closes after exactly $b$ revolutions of the centre, and it carries $a$ lobes.

For the demo, $R/r = 100/39$, so $a = 100$ and $b = 39$: a full figure of **100 lobes**, closing after 39 revolutions of the centre, with the pen spinning $a - b = 61$ times about the wheel's own centre. The demo draws ten of those 39 revolutions — 25.6% of the figure, or about **26 lobes of the 100** — and then slides the window forward, forever. You are watching a fragment of a closed curve that the canvas never completes.

One honest caveat: the code stores the ratio as the floating-point number 0.39, not as the exact fraction 39/100. The closure is therefore an idealisation of the program, not a property of its arithmetic. This is the normal state of affairs when a Spirograph toy's gear teeth are machined rather than proved.

**Challenge:** set $r = R/4$ and $d = r$. The closure rule says $a = 4$, $b = 1$. How many cusps does the resulting curve have, how many revolutions of the centre does it take to close, and what does the demo's ten-revolution sweep look like then?

---

## 5. The Trochoid Family Album

Every curve in this table is the same construction with one thing moved: where the circle rolls, or how far from the wheel the pen sits.

| Curve | Where the circle rolls | Pen distance | What you see |
|-------|------------------------|--------------|--------------|
| Cycloid | along a straight line | any distance | repeated arches; pointed cusps when the pen sits on the rim |
| Epicycloid | outside a fixed circle | pen on the rim | outward-pointing cusps |
| Epitrochoid | outside a fixed circle | any distance | loops when the pen is outside the rim, soft waves when inside |
| Hypotrochoid | inside a fixed circle | any distance | inward loops or waves — the curve in this post |
| Hypocycloid | inside a fixed circle | pen on the rim | inward cusps; a radius ratio of four gives the astroid |
| Tusi couple | inside a circle exactly twice as wide | pen on the rim | a straight line segment, of all things |

Read the table as one sentence: a circle rolling without slipping traces a curve, and the only freedom left is where the circle rolls and how long the pen is.

---

## 6. Why It Matters: Guilloche, Gears and Planets

The hypotrochoid is a rare piece of mathematics that is simultaneously a toy, an industrial process and a historical model of the solar system.

**Security printing.** In the 19th century, engravers built *guilloche* machines — geometric lathes driven by eccentric gears — to cut interlaced rosettes into banknote plates. A carving engine that physically executes "a circle rolling inside a circle" with a rotating cutter will draw precisely the curves in this post, and it does so with a precision that a hand engraver cannot repeat from memory. That is the security property: a dense hypotrochoid lattice is hard to copy and easy to detect when it is wrong. Passports and banknotes still carry these patterns.

**Gears.** Rolling without slipping is the defining condition of a gear mesh, so it is no surprise that trochoids live inside gear design. The curved fillet at the root of an involute gear tooth is a trochoid swept out by the cutting hob. Cycloidal gears — the standard in clockmaking for centuries — use epicycloid and hypocycloid flanks outright, and modern cycloidal speed reducers, the kind that give robot arms their high-ratio joints, transmit load through trochoidal contact surfaces. The Wankel engine's rotary housing is an epitrochoid, and the rotor is its inner parallel curve.

**Planets.** Take $r = R/2$ and put the pen on the rim, and the hypotrochoid degenerates into a straight line that oscillates through the centre — every lobe flattens into the same segment. That degenerate case is the **Tusi couple**, introduced by Nasir al-Din al-Tusi in the 13th century to model a planet's apparent back-and-forth motion along a line using nothing but two circles. Copernicus reused the device in *De revolutionibus*, three centuries later and four thousand kilometres away, which makes the Tusi couple one of the most travelled geometric ideas in astronomy.

A final piece of mathematics: when $R/r$ is rational (as here) the hypotrochoid is an algebraic curve — the zero set of a polynomial in $x$ and $y$. When $R/r$ is irrational, no polynomial can ever contain it: the trace never closes, and instead creeps arbitrarily close to every point of the annulus between its inner and outer radii. The same twenty lines of canvas code, with 0.39 edited to an irrational number, would draw for eternity and never repeat.

---

## 7. Pushing the Parameters to Extremes

The demo's three constants are a small window onto a large space, and the extremes are all instructive.

- **Pen on the axle.** With $d = 0$ the hypotrochoid collapses to a circle of radius $R - r$: the pen rides the wheel's centre and traces the axle's own path.
- **Pen inside the rim.** When $d \lt r$ the pen never leaves the wheel, so no self-crossings appear; you get a smooth, rippling flower that swells and dips $R/r$ times per revolution.
- **Pen exactly on the rim.** With $d = r$ the loops degenerate into sharp cusps: this is the hypocycloid proper. Four cusps is the astroid, a curve drawn by every child with a Spirograph and studied by every 18th-century analyst.
- **Pen outside the rim.** When $d \gt r$ — the demo's regime — the lobes acquire the loops you see on screen.
- **A wheel almost as wide as the hole.** As $r \to R$ the axle's orbit shrinks to nothing while the pen still swings on a short leash: the curve becomes a small crinkled circle, and the figure loses its large-scale structure entirely.
- **An irrational ratio.** If $R/r$ is irrational the curve never closes, as section 6 describes.

The lobe count never depends on $d$ at all — only on the ratio $R/r$, through its numerator. The pen distance changes the *character* of the lobes (loops, cusps, waves); the ratio changes their *number*.

---

## Final Challenge

Take the closure rule and the parameter list together, and answer this without running anything. A pen of length $d = r$ rolls inside a fixed circle with $r = R/5$. How many cusps does the curve have? After how many revolutions of the centre does it close? And if you plug that same pair of values into the demo above — which sweeps ten revolutions — how many times is the closed figure drawn over itself, and what is the *only* thing that still changes frame to frame?

Section 4 gives the closure arithmetic, section 7 gives the cusp arithmetic, and section 3 gives the last part of the answer: the geometry would be frozen, and the hue would keep cycling at 0.15 degrees per frame, once around the wheel of colours every 40 seconds.

---

Browse [the full post archive](/posts/) for more interactive constructions, or start with the companion piece on [seven hexagons that fold into spirals](/2025/11/02/chasing-hexagon-spirals-animated.html). For the wider family this curve belongs to — and the century-long feud it triggered — see [the cycloid wars](/2026/07/12/the-cycloid-family-rolling-wheels.html).
