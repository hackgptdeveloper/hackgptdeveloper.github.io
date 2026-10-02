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

**Challenge to the reader:** Open the animated hexagon-spiral demo linked in section 3 and watch one outer hexagon for ten seconds. Two things are moving at once: the spirals inside it breathe in and out, and the whole seven-hexagon flower slowly turns. Before you scroll any further, decide which of the two is driven by a sine wave and which is plain multiplication by time — then prove it by opening the page source and finding `Math.sin(time * 0.6)` and `time * 0.15` in the code. Section 4 tells you what you have just proved.

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

- **Rolling a circle inside a circle.** One point, one wheel, one constraint — no slipping — and you get a hundred-lobed rosette that looks hand-drawn but is completely determined.
- **Chasing polygons.** Walk a short distance along each edge of a shape, connect the points, repeat seventy times. A single interpolation turns into a spiral.
- **Arrangement.** Take one hexagon mid-pattern, copy it six times at the midpoints of its edges, and you have a tiling — because the copies are not "roughly adjacent", they share edges exactly.

None of these need clever code. They need one rule, applied more times than your intuition can simulate in its head. That gap — between a rule you can read in one line and an image you cannot picture until it exists — is the entire pleasure of procedural art.

**Challenge:** pick any demo on this site and find the one line that does the real work — the assignment inside the drawing loop. If you cannot find it in thirty seconds, the demo is failing at half its job, and that is worth knowing too.

## 3. Start Here: The Current Experiments

| Demo | The rule | What repeats | What controls the look |
|------|----------|--------------|------------------------|
| Hypotrochoid explorations | a wheel rolls without slipping inside a fixed circle | 2,000 sampled angles of one parametric curve | the radius ratio sets the lobe count, the pen length sets loops versus waves |
| Animated spiraling hexagons | take a fixed fraction along every edge of a polygon | 70 nested hexagons inside each of seven tiles | the step fraction sets both the shrink rate and the winding |
| [Chasing hexagon around hexagon](/2024/11/22/chasing_6gon_around_6gon.html) | the same chase, drawn once and left still | one static frame of nested polygons | the rotation offset of each hexagon |
| [Hypotrochoid curves with scrollbars](/2024/11/30/hypotrochoid-explore.html) | the same rolling wheel, exposed controls | one curve redrawn whenever a slider moves | whichever parameter you are dragging |

Two of those are new here — [a rolling circle that draws a hundred lobes](/2025/11/01/hypotrochoid-explorations.html) and [seven hexagons that fold into spirals](/2025/11/02/chasing-hexagon-spirals-animated.html). Both explain their own geometry, and both are short enough to read end to end.

**Challenge:** in the hypotrochoid post, find the ratio the code uses and work out how many lobes the finished figure has. The demo deliberately never finishes drawing it — the post explains why, and the answer is a number in the hundreds.

## 4. How to Explore the Demos

Every demo on this site is meant to be handled, not just watched.

1. **Click or double-click the canvas** to blow it up to fullscreen. Press **Escape** to return — the demos listen for the key explicitly.
2. **Open the page source.** Each demo's JavaScript sits directly in the post, unminified and un-abstracted. The line you want is inside the animation function.
3. **Find the clocks.** Almost every demo has two or three: a rotation driven by plain time, an oscillation driven by a sine, and a colour cycle driven by either. Naming them is nine-tenths of reading the code.
4. **Change one number.** The parameters are plain constants near the top of each script — a radius ratio, a step fraction, a pen distance. Halve one and predict the result before you reload.

That is the loop the top challenge asked you to close: in the hexagon demo, the breathing comes from `Math.sin(time * 0.6)` feeding the step fraction, while `time * 0.15` rotates the whole figure — one oscillates, the other accumulates. Watching the animation tells you two things are happening; the source tells you which is which.

## 5. Why Procedural Art Matters

The usual argument for generative art is aesthetic. The better argument is epistemic.

A generated image is a **claim about a rule**, and claims can be checked. When the hexagon demo says the spiral shrinks by a fixed factor every iteration, you can compute that factor from the geometry and verify the picture against it — no interpretation required. When it says the seven hexagons tile without gaps, you can measure the spacing and find exactly twice the inradius. Determinism is not the enemy of beauty here; it is what makes the beauty legible.

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

Take the hypotrochoid demo and change two numbers: set the rolling radius to one quarter of the fixed radius, and set the pen distance equal to the rolling radius. Before you run it, predict how many sharp cusps the curve will have, whether it will close after one revolution of the wheel's centre or after many, and what the demo's ten-revolution sweep will look like. Then verify — and if you got it right, you have read the geometry rather than the picture, which is the entire skill this blog is trying to teach.

---

New experiments appear here as they are finished. Browse [the full post archive](/posts/) to see everything, or start with the two demos linked in section 3.
