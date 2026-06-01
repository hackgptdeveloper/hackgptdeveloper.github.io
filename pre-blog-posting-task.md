# Pre-blog-posting checklist

General tasks applied to every blog post before it goes live. These steps are independent of the blog content.

---

## Lessons learned (2026-06-01 session)

### Citation rendering bug

Markdown **reference-style links** (`[1]` in text + `[1]: url` at bottom) are **consumed by kramdown** (Jekyll's parser) and never rendered as visible content. The "Citations" heading shows, but the URLs underneath are invisible. The fix: use **kramdown footnote syntax** instead:

| Before (broken) | After (works) |
|---|---|
| `context[1]` | `context[^1]` |
| `[1]: https://...` | `[^1]: <https://...>` |

Footnotes render as clickable superscript links in the text and a visible list at the bottom. Each footnote scrolls bidirectionally between reference and definition.

### Checklist adaptation per site

This checklist was originally written for a math blog but applies to any Jekyll blog. Key adaptations:
- **Frontmatter**: Match the **existing post conventions** of the site. If all posts use only `title` and `tags`, don't force `categories`, `share`, `read_time`, `excerpt` — those fields may not be supported by the theme.
- **Math rules**: Skip or de-emphasize for non-math posts. Still run the grep checks but understand that clean output is expected.
- **"Mathematics" category**: Only include if the site actually uses categories and the post is math-related.

### YouTube/reference link spam

Raw source material often has **excessive repeated links** (e.g. the same two YouTube URLs pasted 40+ times across every sentence and table cell). Detection and fix:
- Identify unique URLs with `grep -oP '\[.*?\]\(https?://[^)]+\)'` and count duplicates
- Consolidate all duplicates into a **References** section at the bottom
- Remove all inline link spam from body text
- Keep only genuinely distinct, context-specific links inline

### Dry-run before push

Always run the grep checks (section 8) before committing. Catching a stray `\[` or raw `<>` after pushing means a second commit to fix rendering — avoidable with 10 seconds of grep.

---

## 1. Source material preparation

Read the raw content file and identify:

- The core theorem/identity/concept
- Natural connections to other topics (cross-linking opportunities)
- Sections that need markdown formatting removed from math blocks
- Any raw `<` or `>` characters in math that need LaTeX replacement
- **Excessive repeated links** — consolidate duplicates into a References section
- **Citation format** — if the source uses `[N]` / `[N]: url` reference-style links, convert to `[^N]` / `[^N]: <url>` kramdown footnotes

---

## 2. Frontmatter

Every post must have this YAML block at the top:

```yaml
---
title: "..."
date: YYYY-MM-DD
categories:
  - CategoryName
  - Mathematics
tags:
  - tag-one
  - tag-two
share: true
read_time: true
excerpt: "..."
---
```

Rules:
- `date` must be the current date
- `categories` must include at least one topic category plus "Mathematics"
- `tags` should be kebab-case, narrowly topical, 4-8 of them
- `excerpt` must be 2-3 sentences, no more than ~300 characters

**Adaptation note:** Match the existing frontmatter conventions of the target site. If the site's existing posts only use `title` and `tags`, follow that pattern. Adding unsupported fields like `categories` or `share` may cause build warnings or be silently ignored. Check at least 3-5 existing posts to determine the actual convention before writing frontmatter.

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

From `change_for_math.md`, applied to every post:

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
2. **Core identity/theorem** stated upfront
3. **Why it matters** (2-3 lines)
4. **Numbered sections** — each section is one digestible idea
5. **Mid-post challenges** (after key derivations)
6. **Connection table** (where applicable — show related functions)
7. **Deeper significance** section
8. **Final challenge** (harder, synthesis-required)

Section headings use `## N. Descriptive Name` format.

---

## 7. Visual separators

Use `---` to separate major sections. These must be on their own line, outside any `$$...$$` blocks.

---

## 8. Pre-publish verification

Run these commands in the repo root, replacing the filename:

```bash
# 1. No old-style math delimiters (should print nothing)
grep -n '\\\\\[\|\\\\\]\|\\(' _posts/NEW-FILE.md

# 2. No markdown headings/rules inside math blocks (should print nothing;
#    lines matching "---" or "====" are only legitimate section separators
#    OUTSIDE $$...$$ blocks)
grep -n '^=\|^--' _posts/NEW-FILE.md

# 3. No raw < or > outside of valid HTML tags and math mode
grep -n '<\|>' _posts/NEW-FILE.md

# 4. Check for excessive repeated links (count unique URLs and their occurrences)
grep -oP '\[.*?\]\(https?://[^)]+\)' _posts/NEW-FILE.md | sort | uniq -c | sort -rn

# 5. Check for broken reference-style citations (these are invisible in kramdown output)
grep -n '^\[[0-9]\+\]:' _posts/NEW-FILE.md
```

For checks 2 and 3, manually verify that any matches are:
- Frontmatter `---` delimiters (legitimate)
- Section separator `---` lines (legitimate)
- HTML tags like `</script>` (legitimate)
- LaTeX commands like `\lt`, `\gt`, `\langle` (legitimate in `$$`/`$`)

For check 4, if any link appears more than 3 times, consolidate duplicates into a References section at the bottom.

For check 5, if any `[N]: url` lines exist, they will NOT render visibly. Convert to `[^N]: <url>` kramdown footnote syntax, and update all in-text `[N]` references to `[^N]`.

---

## 9. Git workflow

```bash
# Stage the new post
git add _posts/NEW-FILE.md

# Commit with a message that summarizes the post content
git commit -m "Add [topic] blog post

[One line describing the core content]

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"

# Push to deploy (GitHub Pages rebuilds automatically)
git push
```

Never amend. Always create a new commit. Never skip hooks.

---

## 10. Post-publish verification

After pushing, wait ~2 minutes for GitHub Pages to rebuild, then:

1. Visit the live URL: `https://hackmathsdeveloper.github.io/category/mathematics/post-slug/`
2. Check that all `$$` blocks render as math, not raw LaTeX
3. Check that inline `$` renders correctly
4. Verify the title, excerpt, tags, and read-time appear on the listing page
5. Verify the site index at `https://hackmathsdeveloper.github.io/` lists the new post
6. **Citation-specific:** Verify footnote references (`[^1]`, `[^2]`, etc.) are clickable and the Citations section at the bottom displays all URLs

If math blocks show raw LaTeX:
- The most common cause is a stray `\\[` or `\\(` delimiter
- Re-run the grep check from section 8
- Fix and push again

If citations don't appear:
- Check that you used `[^N]` (footnote) syntax, not `[N]:` (reference-style link) syntax
- Reference-style definitions are invisible — convert to footnotes
- Re-run check 5 from section 8

---

## Quick reference card

```
□ Frontmatter complete (title, date, tags — match existing site conventions)
□ Viral-style title (curiosity + promise)
□ Reader challenge at top (bold, concrete)
□ All math uses $$ / $ delimiters (skip for non-math posts)
□ No markdown inside $$ blocks
□ No raw < > in math mode
□ No excessive repeated links (>3 occurrences → consolidate to References)
□ No [N]: reference-style citations (use [^N]: footnote syntax instead)
□ 2-3 additional challenges scattered through post
□ Final challenge at end
□ grep checks 1-5 pass
□ git commit + push
□ Live URL verified (including footnote/citation rendering)
```
