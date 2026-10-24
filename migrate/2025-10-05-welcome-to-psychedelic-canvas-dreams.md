---
title: "The Sketchbook That Draws Itself — Where a Few Lines of Math Become Infinite Art"
tags:
  - generative-art
  - procedural-art
  - canvas
  - javascript
  - interactive
  - visual-math
  - psychedelic-art
---

This blog is a sketchbook where every drawing is a program. Each post pairs a self-contained HTML5 canvas — running live in the page, with nothing to install — with the mathematics that produces it: rolling circles, chasing polygons, spirals that fold inward, rosettes that never quite close.

That matters because algorithmic art is the one place where mathematics is not a tool you borrow and put back. When a curve is generated rather than drawn, the equation *is* the artwork: change one constant and the picture changes with it, predictably and reproducibly. Everything on this site is a small, honest demonstration of that fact — and every demo is short enough to read in one sitting.

---

## 1. What Psychedelic Canvas Dreams Is

A living sketchbook of generative art. Every experiment here is a single page containing one interactive canvas and an explanation of the geometry underneath it. There is no build step, no framework, no dependency tree — a `<canvas>` element, a `<script>` tag, and a few dozen lines that turn angles into pictures.

The name is not decoration. Much of what appears here is genuinely psychedelic in the literal sense — patterns whose visual interest comes from symmetry, self-similarity, and continuous motion, the same ingredients that make a Spirograph fascinating and a kaleidoscope hypnotic. The difference is that here you can see exactly where the effect comes from, because the whole recipe is printed on the page.

## 2. The Only Trick You Need: A Rule, Repeated

If there is a single idea behind everything on this blog, it is this: **a trivial rule, applied many times, produces structure you could not have predicted by looking at the rule.**

Three examples, all of them published here:

- **Rolling a circle around another circle.** One point, one wheel, one constraint — no slipping — and you get a rosette that looks hand-drawn but is completely determined.
- **Chasing polygons.** Walk a short distance along each edge of a shape, connect the points, repeat seventy times. A single interpolation turns into a spiral.
- **Joining points.** Number the points around a circle and connect each point to a fixed multiple of itself. A single skip count turns into heart-shaped line art.

None of these need clever code. They need one rule, applied more times than your intuition can simulate in its head. That gap — between a rule you can read in one line and an image you cannot picture until it exists — is the entire pleasure of procedural art.

**Challenge:** pick any demo on this site and find the one line that does the real work — the assignment inside the drawing loop. If you cannot find it in thirty seconds, the demo is failing at half its job, and that is worth knowing too.

## 3. Start Here: The Current Experiments

| Demo | The rule | What repeats | What controls the look |
|------|----------|--------------|------------------------|
| [Chasing hexagon around hexagon](/2024/11/22/chasing_6gon_around_6gon.html) | the same chase, drawn once and left still | one static frame of nested polygons | the rotation offset of each hexagon |

## 4. How to Explore the Demos

Every demo on this site is meant to be handled, not just watched.

1. **Click or double-click the canvas** to blow it up to fullscreen. Press **Escape** to return — the demos listen for the key explicitly.
2. **Open the page source.** Each demo's JavaScript sits directly in the post, unminified and un-abstracted. The line you want is inside the animation function.
3. **Find the clocks.** Almost every demo has two or three: a rotation driven by plain time, an oscillation driven by a sine, and a colour cycle driven by either. Naming them is nine-tenths of reading the code.
4. **Change one number.** The parameters are plain constants near the top of each script — a radius ratio, a step fraction, a pen distance. Halve one and predict the result before you reload.

## 5. Why Procedural Art Matters

The usual argument for generative art is aesthetic. The better argument is epistemic.

A generated image is a **claim about a rule**, and claims can be checked. When a chasing demo says each nested polygon is the previous one shrunk by a fixed factor, you can compute that factor from the geometry and verify the picture against it — no interpretation required. Determinism is not the enemy of beauty here; it is what makes the beauty legible.

It also connects to work that matters outside the sketchbook. Rolling-without-slipping is the constraint that shapes gear teeth and cycloidal drive reducers. Interpolation along polygon edges is the operation behind animation tweening and curve subdivision. Colour cycling in HSL space is the same machinery as a colour ramp in a data visualisation. Learn the trick on a spinning hexagon and you have learned it for the industrial version too.

**Challenge:** pick one demo and state, in a single sentence, a claim about it that could be falsified by measurement — a count, a ratio, an angle. Then measure it. A demo that cannot produce such a claim is decoration; a demo that can produce one is a lesson.

## 6. How to Read Any Demo on This Site

Three questions, in order, will unpack every post in this archive:

1. **What is the rule?** Almost always one line of arithmetic — a cosine, a linear interpolation, a complex multiplication.
2. **What repeats?** A loop over sample points, iterations of a map, or copies of a tile. The repetition count is usually where the visual density comes from.
3. **What animates?** The clocks again: something adds to time, something oscillates with a sine, something cycles a hue.

Answer those three and the code stops being a wall of JavaScript and becomes a description of the picture you are looking at — which is, in the end, the only reason this blog exists.

---

## Final Challenge

Take any rolling-circle demo and change two numbers: the rolling radius and the pen distance. Before you run it, predict how many sharp cusps the curve will have and whether it will close after one revolution of the wheel's centre or after many. Then verify — and if you got it right, you have read the geometry rather than the picture, which is the entire skill this blog is trying to teach.

---

New experiments appear here as they are finished. Browse [the full post archive](/posts/) to see everything.
