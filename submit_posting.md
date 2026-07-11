# Pre-blog-posting checklist

General tasks applied to every blog post before it goes live. These steps are independent of the blog content.

**Site context:** This is `hackgptdeveloper.github.io` — a tech/security/AI blog using the `mmistakes/so-simple-theme` Jekyll remote theme. Posts cover security exploitation, AI/LLM agents, web technologies, and related topics. The site uses `tags:` in frontmatter (not `categories:`). Math/LaTeX rules in this checklist apply **only to posts containing mathematical notation**; skip sections 5 and 12 for non-math posts.

---

## 1. Source material preparation

Read the raw content file and identify:

- The core theorem/identity/concept
- Natural connections to other topics (cross-linking opportunities)
- Whether the post contains LaTeX math (if yes → sections 5 and 12 apply; if no → skip them entirely)
- Sections that need markdown formatting removed from math blocks
- Any raw `<` or `>` characters in math that need LaTeX replacement
- Whether an illustration file exists to integrate (e.g. `*_illustration.md`) — merge its diagrams inline

---

## 2. Frontmatter

Every post must have this YAML block at the top:

```yaml
---
title: "..."
tags:
  - tag-one
  - tag-two
---
```

Rules (specific to this blog — `hackgptdeveloper.github.io`):
- **`date`**: derived from the filename (`YYYY-MM-DD-slug.md`), NOT placed in frontmatter
- **`tags:`**: kebab-case, narrowly topical, 4-8 of them. This blog uses `tags:` only — do NOT add `categories:`, `excerpt:`, `share:`, or `read_time:` to frontmatter (the theme auto-generates excerpts and the config does not enable these frontmatter keys)
- No `Mathematics` category — this is a tech/security/AI blog, not a math blog
- The filename format is `YYYY-MM-DD-slug.md` inside `_posts/`

---

## 3. Title requirements

The title must be **viral-style**: curiosity-driven, arouses interest, promises a revelation.

Patterns that work:

| Pattern | Example skeleton |
|---------|-----------------|
| "The X That Secretly Y — And You've Never Heard of It" | Surprise + exclusivity |
| "Why X Lives Inside Y — The Strangest Secret of Z" | Unexpected connection |
| "X's Secret: How Y Escaped Z and Took Over W" | Origin story + ambition |
| "The X That Lets You Y — Z's Most Beautiful Formula" | Empowerment + beauty |

Avoid: dry declarative titles like "An Introduction to X" or "On the Theory of Y".

---

## 4. Opening hook

Immediately after the frontmatter, place a **challenge to the reader** in bold:

```markdown
**Challenge to the reader:** [concrete, verifiable task using the post's content]
```

Rules:
- It must be specific (e.g. "Compute X for Y" not "Explore X")
- It must be solvable after reading the post
- It appears **before** any body text

Scatter 2-3 additional challenges at midpoints and one final challenge at the end.

---

## 5. Math rendering rules

**⚠️ Conditional: skip this entire section if the post contains no LaTeX math.** For non-math posts (security exploits, AI/LLM, web tech), none of these rules apply.

Applied to every math-containing post:

| Rule | Do | Don't |
|------|----|-------|
| Display math | `$$...$$` | `\[...\]`, `\\[...\\]` |
| Inline math | `$...$` | `\(...\)` |
| Inside math | Valid LaTeX only | No `====`, `---`, `*`, markdown links |
| Inequalities | `$\lvert z \rvert < 1$` | Raw `|z|<1` outside math |
| Curly braces | `{}_2F_1`, `\frac{a}{b}` — safe | N/A |

Long equations use alignment environments:

```latex
$$
\begin{aligned}
x &= a + b \\
y &= c + d
\end{aligned}
$$
```

---

## 6. Content structure

Every post follows this skeleton:

1. **Challenge** (bold, before any body text)
2. **Core concept/theorem** stated upfront
3. **Why it matters** (2-3 lines)
4. **Numbered sections** — each section is one digestible idea
5. **Mid-post challenges** (after key derivations)
6. **Reference table** (where applicable — show related functions, offset maps, comparison matrices)
7. **Deeper significance / root cause** section
8. **Final challenge** (harder, synthesis-required)
9. **Source code / references** (where applicable — link to repos, CVEs, further reading)

Section headings use `## N. Descriptive Name` format.

For non-math posts (security, AI, web tech), replace "core theorem" with the post's central concept or finding, and "connection table" with any structured reference (offset map, comparison table, exploit summary table, etc.).

---

## 7. Visual separators

Use `---` to separate major sections. These must be on their own line, outside any `$$...$$` blocks.

---

## 8. Pre-publish verification

**⚠️ Conditional:** Checks 1, 4, 5, and the pipe/math sub-checks apply **only to posts with LaTeX math**. For non-math posts, only run checks 2 and 3 (and even then, only to confirm no accidental `<`/`>` issues).

Run these commands in the repo root, replacing the filename:

```bash
# 1. [MATH ONLY] No old-style math delimiters (should print nothing)
grep -n '\\\\\[\|\\\\\]\|\\(' _posts/NEW-FILE.md

# 2. No markdown headings/rules inside math blocks (should print nothing;
#    lines matching "---" or "====" are only legitimate section separators
#    OUTSIDE $$...$$ blocks)
grep -n '^=\|^--' _posts/NEW-FILE.md

# 3. No raw < or > outside of valid HTML tags and math mode
grep -n '<\|>' _posts/NEW-FILE.md
```

For check 2 and 3, manually verify that any matches are:
- Frontmatter `---` delimiters (legitimate)
- Section separator `---` lines (legitimate)
- HTML tags like `</script>` (legitimate)
- LaTeX commands like `\lt`, `\gt`, `\langle` (legitimate in `$$`/`$`)
- Code arrows like `->`, `=>` (legitimate in code blocks and text)
- Markdown table pipes `|` (legitimate outside math mode)

For check 2, also scan for `|` (pipe) inside inline `$...$` math on the same line —
kramdown interprets pipes as table column separators, shattering inline math into
broken HTML table cells. Pattern: `$...|...$` → use `\lvert`/`\rvert` instead:
```bash
# [MATH ONLY]
grep -n '\$.*|.*\$' _posts/NEW-FILE.md
```

---

## 9. Git workflow

```bash
# Stage the new post
git add _posts/NEW-FILE.md

# Commit with a message that summarizes the post content
git commit -m "Add [topic] blog post

[One line describing the core content]

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to deploy (GitHub Pages rebuilds automatically)
git push
```

Never amend. Always create a new commit. Never skip hooks.

---

## 10. Post-publish verification

After pushing, wait ~2 minutes for GitHub Pages to rebuild, then:

1. Visit the live URL: `https://hackgptdeveloper.github.io/YYYY/MM/DD/slug.html` (note: URL format is date-based, not category-based)
2. **[MATH ONLY]** Check that all `$$` blocks render as math, not raw LaTeX
3. **[MATH ONLY]** Check that inline `$` renders correctly
4. Verify the title, tags appear on the listing page
5. Verify the site index at `https://hackgptdeveloper.github.io/` lists the new post
6. **Verify updated content** — if you edited the post after pushing, curl the page and grep for key strings to confirm the latest commit rendered (e.g. `curl -s <url> | grep -c "expected-string"`)

If math blocks show raw LaTeX:
- The most common cause is a stray `\\[` or `\\(` delimiter
- Re-run the grep check from section 8
- Fix and push again

---

## 11. Post-publish: homepage and build verification

After the blog posts are deployed, always verify the homepage and site health.

### 11a. Homepage must show new posts

Visit `https://hackgptdeveloper.github.io/` and confirm the new posts appear. If they don't:

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Latest posts missing from homepage | Posts have future dates relative to build time (Jekyll excludes future-dated posts by default) | Add `future: true` to `_config.yml` |
| Homepage shows wrong layout | Wrong `index` file is active | Ensure `index.html` (not `index.md`) is committed — `.html` wins when both exist, and `jekyll-paginate` requires `.html` |
| Pagination broken / only some posts show | `paginate: false` set in index, or `index.md` overriding `index.html` | Use `index.html` with `paginate: true`; delete `index.md` to avoid conflicts |
| Stale content after push | One of the dual workflows was cancelled; or the deploy workflow didn't finish | Check both workflow runs at GitHub Actions tab; re-trigger if needed |

### 11b. Verify index file state

The site requires `index.html` at the root (not `index.md`) because the `jekyll-paginate` plugin generates numbered pages from it. Run:

```bash
# Check which index files are tracked
git ls-files index.html index.md

# Check for untracked index files
git status -- index.html index.md
```

Expected: `index.html` is tracked, `index.md` is NOT tracked.

### 11c. Verify site config for future posts

```bash
# config must include future: true to show posts dated ahead of build time
grep 'future:' _config.yml
```

Note: This blog's `_config.yml` does NOT currently have `future: true`. Posts dated today or earlier appear without it. If you ever publish a post with a future date (e.g. scheduling ahead), add `future: true` under the `# Site settings` line — otherwise Jekyll silently excludes it from the build.

### 11d. Check both GitHub Actions workflows

The repo has two deploy workflows (`.github/workflows/jekyll.yml` and `jekyll-gh-pages.yml`). Both trigger on push to `main`. At least one must complete with `success` for the site to update. Check:

```
https://github.com/hackgptdeveloper/hackgptdeveloper.github.io/actions
```

If the latest run of either workflow shows `cancelled`, the deployment may still be fine if the other workflow succeeded — but verify the live site. If both failed/cancelled, push an empty commit to re-trigger:

```bash
git commit --allow-empty -m "Re-trigger build"
git push
```

### 11e. Verify individual post pages

Pick 2-3 new post URLs from the homepage and curl them to confirm HTTP 200:

```bash
curl -sI https://hackgptdeveloper.github.io/YYYY/MM/DD/slug.html | head -3
```

A 404 on a new post usually means the post was excluded at build time (future date — see 11a).

### 11f. Homepage layout requirements

The homepage (`index.html`) should have:

```yaml
---
layout: home
show_excerpts: true
paginate: true
entries_layout: grid   # 3-column grid; use 'list' for single-column
---
```

The 3-column grid is configured in `_includes/head-custom.html`. If the grid breaks, check that file for the `.entries-grid` CSS override and the `.layout--home.page--wide .page-wrapper` width setting (default: 1400px).

---

## Quick reference card

```
□ Frontmatter: title + tags: only (no categories/excerpt/share/read_time)
□ Date in filename: YYYY-MM-DD-slug.md
□ Viral-style title (curiosity + promise)
□ Reader challenge at top (bold, concrete)
□ [MATH ONLY] All math uses $$ / $ delimiters
□ [MATH ONLY] No markdown inside $$ blocks
□ [MATH ONLY] No raw < > in math mode
□ [MATH ONLY] No \#, \{, \} in inline $...$ math (use \lbrace, \rbrace, \lvert, \rvert)
□ [MATH ONLY] No | (pipe) in inline $...$ math (use \lvert, \rvert)
□ [MATH ONLY] Inline matrices: \\ doubled to \\\\ (only inside $...$, not $$...$$)
□ [MATH ONLY] Prefer display math $$...$$ for matrices (keeps \\ as-is)
□ 2-3 additional challenges scattered through post
□ Final challenge at end
□ Source code / reference links at bottom (if applicable)
□ Illustration files merged inline (if *_illustration.md exists)
□ grep checks pass (run math checks only for math posts; always run checks 2+3)
□ git commit + push
□ Live URL: https://hackgptdeveloper.github.io/YYYY/MM/DD/slug.html verified HTTP 200
□ Homepage shows new posts (https://hackgptdeveloper.github.io/)
□ Both GitHub Actions workflows succeeded (or at least one)
□ index.html tracked, index.md removed
□ Individual post pages return HTTP 200
```

---

## 12. kramdown escaping pitfalls in math mode

**⚠️ Conditional: skip this entire section if the post contains no LaTeX math.** These issues only affect `$...$` inline math spans.

kramdown (Jekyll's markdown processor) treats certain backslash-character combinations as markdown escapes, **even inside `$...$` inline math spans**. This silently corrupts LaTeX before it reaches MathJax. Display math `$$...$$` blocks are **not affected**.

### 12a. The `\#`, `\{`, `\}` problem

kramdown interprets `\#`, `\{`, `\}` as escaped markdown special characters and strips the backslash, producing bare `#`, `{`, `}` in the HTML output:

| Source | kramdown output | MathJax sees | Result |
|--------|----------------|-------------|--------|
| `\#` | `#` | `#` | **Error:** "macro parameter character # in math mode" |
| `\{` | `{` | `{` | Invisible grouping brace — set notation vanishes |
| `\}` | `}` | `}` | Invisible grouping brace — set notation vanishes |

**Fix:** Use letter-based LaTeX commands instead. kramdown only strips backslashes before markdown special characters — backslash-letter sequences pass through unchanged:

| Bad (markdown special char) | Good (letter-based command) |
|-----------------------------|---------------------------|
| `\#` (cardinality) | `\lvert ... \rvert` for bars, or `\#` cannot be used |
| `\{` (left brace) | `\lbrace` |
| `\}` (right brace) | `\rbrace` |
| `\#{i : b_i = 1}` | `\lvert\lbrace i : b_i = 1\rbrace\rvert` |

### 12b. The `\\` line-break problem in inline matrices

kramdown processes `\\` inside inline `$...$` math as an escaped backslash, consuming one `\` and leaving `\ ` — which MathJax treats as a **control space** instead of a line break. This causes `pmatrix`, `bmatrix`, and other matrix environments to render as a single horizontal row.

| Source | kramdown output | MathJax sees | Result |
|--------|----------------|-------------|--------|
| `\begin{pmatrix} a & b \\ c & d \end{pmatrix}` | `\begin{pmatrix} a & b \ c & d \end{pmatrix}` | Control space `\ ` | Matrix renders as one row |

**Fix:** Double `\\` to `\\\\` in **inline math only**. kramdown processes `\\\\` as two escaped backslashes → `\\`, which MathJax correctly interprets as a line break:

```markdown
<!-- WRONG — renders as single row -->
$\begin{pmatrix} a & b \\ c & d \end{pmatrix}$

<!-- CORRECT — \\\\ becomes \\ after kramdown -->
$\begin{pmatrix} a & b \\\\ c & d \end{pmatrix}$
```

**Display math `$$...$$` does NOT need this fix** — `\\` passes through unchanged.

### 12c. Pre-publish grep for these issues

Add these checks to the section 8 verification:

```bash
# 4. Inline matrices with single \\ (should print nothing — or verify
#    matches are only inside $$...$$ display math blocks)
grep -n '\$.*\\\\begin{pmatrix}.*[^\\]\\\\[^\\].*\\\\end{pmatrix}' _posts/NEW-FILE.md

# 5. \#, \{, or \} inside inline math (should print nothing)
grep -n '\$.*\\[#{}]' _posts/NEW-FILE.md
```

For check 4, if output appears, verify each match is inside a `$$...$$` block — not inside `$...$`. For check 5, all matches must be replaced with letter-based commands.

### 12d. Quick decision tree

When writing math in a blog post:

```
Is the LaTeX inside $...$ (inline) or $$...$$ (display)?
  ├─ $$...$$ (display): write LaTeX normally, no special escaping
  └─ $...$ (inline):
       ├─ Contains \begin{pmatrix} / \begin{bmatrix} / etc.?
       │    └─ YES → double all \\ to \\\\
       ├─ Contains \# (hash)?
       │    └─ YES → replace with \lvert...\rvert or rewrite
       ├─ Contains \{ or \} (set braces)?
       │    └─ YES → replace with \lbrace and \rbrace
       ├─ Contains | (pipe)?
       │    └─ YES → replace with \lvert and \rvert
       └─ None of the above → write normally
```

### 12e. The `|` (pipe) problem — kramdown table parsing

kramdown interprets `|` characters as markdown table column separators, **even inside `$...$` inline math**. This shatters the math into broken HTML `<table>` cells:

| Source (single line) | kramdown output |
|---|---|
| `The set $\lbrace z : \|z\| \ge 1\rbrace$ is...` | `<td>The set $\lbrace z :</td><td>z</td><td>\ge 1\rbrace$ is...</td>` |

A single `|` inside `$...$` on a line with two or more pipes triggers table parsing. The math gets split across `<td>` cells and becomes unrenderable.

**Fix:** Replace `|` inside inline math with `\lvert` and `\rvert`:

```markdown
<!-- WRONG — pipes trigger table parsing -->
The set $\lbrace z : |z| \ge 1\rbrace$ is a fundamental domain

<!-- CORRECT — \lvert/\rvert are letter-based, safe from kramdown -->
The set $\lbrace z : \lvert z\rvert \ge 1\rbrace$ is a fundamental domain
```

### 12f. Preferred alternative: move matrices to display math

When a matrix is complex or contains multiple rows, prefer `$$...$$` display math. It avoids the escaping problem entirely and is more readable:

```markdown
<!-- Instead of inline: -->
The matrix $M = \begin{pmatrix} a & b \\\\ c & d \end{pmatrix}$ has ...

<!-- Use display math: -->
The matrix

$$
M = \begin{pmatrix} a & b \\ c & d \end{pmatrix}
$$

has ...
```

---

## 13. Blog-specific conventions (hackgptdeveloper.github.io)

These were discovered during the type-confusion exploit walkthrough posting and differ from the generic math-blog template this checklist was originally written for.

### 13a. Frontmatter — tags only

This blog uses `tags:` exclusively. Do NOT add `categories:`, `excerpt:`, `share:`, or `read_time:` to frontmatter. The so-simple theme auto-generates excerpts from the post body, and the config doesn't enable these frontmatter keys. The date is derived from the filename.

### 13b. URL scheme

Post URLs follow the pattern `/YYYY/MM/DD/slug.html` — not `/category/.../`. This is Jekyll's default permalink behavior with the so-simple theme.

### 13c. Math is conditional

This is a tech/security/AI blog, not a mathematics blog. Many posts contain zero LaTeX. The math rendering rules (sections 5, 12) and math-specific grep checks (section 8 checks 1, 4, 5, pipe check) apply **only when the post actually contains `$...$` or `$$...$$`**. For non-math posts (security exploits, AI agents, web technologies), skip those sections entirely.

### 13d. `future:` not set in config

`_config.yml` does not have `future: true`. This is fine for same-day or past-dated posts. If you ever schedule a post with a future date, add it.

### 13e. Integration of illustration files

When a companion `*_illustration.md` file exists alongside the main content, merge its diagrams and tables inline into the post rather than keeping them as separate files. This was done for `type_confusion_illustration.md` → integrated into the Phase 2 and Phase 3 sections.

### 13f. Source code references

For posts that reference a working exploit, demo, or codebase, add a "Source Code" section at the bottom with a direct link to the GitHub repo. This gives readers a concrete artifact to study alongside the writeup.

### 13g. Post-publish content verification

When edits are made after the initial push, don't just check HTTP 200 — grep the rendered HTML for key strings to confirm the latest commit's content actually deployed. Example:
```bash
curl -s https://hackgptdeveloper.github.io/YYYY/MM/DD/slug.html | grep -c "expected-string"
```
