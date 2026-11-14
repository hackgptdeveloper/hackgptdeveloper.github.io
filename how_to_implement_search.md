# How the site search box works — and how to copy it to another Jekyll site

This document describes the client-side search implementation used in this
repository (a `mmistakes/so-simple-theme` site built by GitHub Pages) and gives
a step-by-step recipe for dropping the same search box into a different Jekyll
theme hosted on GitHub Pages.

Everything here is **pure Liquid + browser JavaScript**. No custom Jekyll
plugin is involved, so it works on GitHub Pages, which only allows the
`github-pages` plugin whitelist.

---

## 1. What it does

- A small search `<input>` sits in the masthead on every page.
- Typing submits a normal `GET` request to `/search/?q=<term>` (works with JS disabled).
- The `/search/` page has a second, larger search box plus an empty `#results` div.
- On the search page, a bundled copy of [lunr.js](https://lunrjs.com) builds an
  in-memory index from a generated JavaScript file and renders results **live**
  as you type (debounced 120 ms), updating the address bar with `?q=`.
- Results show title, a 20-word excerpt, and a link.

The search index is generated at build time by Jekyll from every document in
`site.collections` (in this repo: `_posts`), so the browser has no backend to
talk to.

---

## 2. Architecture at a glance

```text
Build time (Jekyll / GitHub Actions)
  assets/js/search-data.js      -> emits  var store = [ {title, excerpt, categories, tags, url}, ... ]
  |                              (a Jekyll page: has front matter, Liquid runs, output is JavaScript)
  v
  _site/assets/js/search-data.js

Request time (browser)
  any page  --[masthead form, GET /search/?q=term]-->  /search/
                                                        |
  _layouts/search.html  renders two boxes + <div id="results">
  _includes/scripts.html (only when page.layout == "search")
        -> _includes/lunr-search-scripts.html
             -> loads lunr.min.js, search-data.js
             -> builds lunr index over `store`
             -> binds input#search, renders matches into #results
```

---

## 3. Dependencies

| Dependency | Version used here | Where it comes from |
|---|---|---|
| Jekyll | 3.10.0 (`github-pages` v232) | GitHub Actions |
| lunr.js | **2.1.5** (must be 2.x) | vendored in `assets/js/lunr/lunr.min.js` |
| jQuery | 3.3.1 | `_includes/scripts.html` (CDN) |
| Font Awesome | 5.0.12 | `_includes/scripts.html` (CDN) — only for the magnifier icon |

> lunr **2.x** is required: the query code uses `lunr.tokenizer.separator`,
> `lunr.Query.wildcard.TRAILING`, and `editDistance`, which do not exist in
> lunr 1.x. The 2.3.x release is also compatible if you vendor a newer copy.

---

## 4. Files involved

| File | Role |
|---|---|
| `search.md` | The `/search/` page stub (front matter only) |
| `_layouts/search.html` | Page layout: large search form + `#results` container |
| `_includes/search-form.html` | The compact masthead search box |
| `_includes/masthead.html` | Renders the compact box (must include the file above) |
| `_includes/scripts.html` | Loads the search JS **only** on the search page |
| `_includes/lunr-search-scripts.html` | Builds the lunr index and all client logic |
| `assets/js/search-data.js` | Build-time index generator (Liquid → JS) |
| `assets/js/lunr/*.min.js` | vendored lunr runtime (+ optional language packs) |
| `assets/css/custom.css` | Styling for both forms and results |
| `_data/text.yml` | Placeholder and result labels, per locale |
| `_config.yml` | `search_full_content`, `locale` |

TL;DR for porting: add rows 1, 3, 6 and 7 as-is, adapt rows 2, 4 and 5 to your
theme's layout/header/script includes, vendor lunr (row 8), merge the CSS block,
copy the three `_data/text.yml` keys, and add the two one-line include hooks.

---

## 5. Step-by-step implementation

### Step 1 — Vendor lunr.js

Create `assets/js/lunr/` and copy at minimum:

```text
assets/js/lunr/lunr.min.js
```

Copy `lunr.stemmer.support.min.js` plus the relevant `lunr.<lang>.min.js`
(e.g. `lunr.de.min.js`, `lunr.fr.min.js`) **only** if the site is not English.
This repo vendors the full set (19 files) from lunr 2.1.5; it costs nothing
unless referenced, since Jekyll just copies them into `_site`.

### Step 2 — Generate the index at build time

`assets/js/search-data.js` (note the front matter — it is what makes Jekyll run
Liquid over a `.js` file):

```liquid
---
layout: null
sitemap: false
---

var store = [
  {%- for c in site.collections -%}
    {%- if forloop.last -%}
      {%- assign l = true -%}
    {%- endif -%}
    {%- assign docs = c.docs | where_exp: 'doc', 'doc.search != false' -%}
    {%- for doc in docs -%}
      {
        "title": {{ doc.title | jsonify }},
        "excerpt":
          {%- if site.search_full_content == true -%}
          {{ doc.content | 
            replace:"</p>", " " | 
            replace:"</h1>", " " | 
            replace:"</h2>", " " | 
            replace:"</h3>", " " | 
            replace:"</h4>", " " | 
            replace:"</h5>", " " | 
            replace:"</h6>", " "|
          strip_html | strip_newlines | jsonify }},
        {%- else -%}
          {{ doc.content | 
            replace:"</p>", " " | 
            replace:"</h1>", " " | 
            replace:"</h2>", " " | 
            replace:"</h3>", " " | 
            replace:"</h4>", " " | 
            replace:"</h5>", " " | 
            replace:"</h6>", " "|
           strip_html | strip_newlines | truncatewords: 50 | jsonify }},
        {%- endif -%}
        "categories": {{ doc.categories | jsonify }},
        "tags": {{ doc.tags | jsonify }},
        "url": {{ doc.url | absolute_url | jsonify }}
      } {%- unless forloop.last and l -%}, {%- endunless -%}
    {%- endfor -%}
  {%- endfor -%}
]
```

Key points:

- `layout: null` and `sitemap: false` keep the output as raw JS and out of the sitemap.
- Only **collections** are indexed (`site.collections`). Standalone pages such as
  `about.md` are **not** included — see the gotchas in §8 if you want pages too.
- `doc.search != false` lets a document opt out with `search: false` in its front matter.
- `search_full_content: false` truncates the body to 50 words; set it to `true`
  in `_config.yml` to index the whole post (heavier page, better recall).
- `url` is absolute, so results can be linked from anywhere.

### Step 3 — The `/search/` page

`search.md` (front matter only; the layout renders everything):

```yaml
---
title: Search
layout: search
permalink: /search/
sitemap: false
---
```

### Step 4 — The search page layout

`_layouts/search.html`:

```liquid
---
layout: page
---

{{ content }}

<form class="search-form search-form--page" action="{{ '/search/' | relative_url }}" method="get" role="search">
  <label class="screen-reader-text" for="search">Search</label>
  <input type="search" id="search" name="q" class="search-input" placeholder="{{ site.data.text[site.locale].search_placeholder_text | default: 'Enter your search term...' }}" autofocus autocomplete="off">
  <button type="submit" class="search-submit" aria-label="Search"><i class="fas fa-search" aria-hidden="true"></i><span>Search</span></button>
</form>

<div id="results" aria-live="polite"></div>
```

The IDs and names here are load-bearing:

| Attribute | Why it matters |
|---|---|
| `id="search"` | The JS binds to `input#search` |
| `name="q"` | The query parameter the form submits and the JS reads |
| `#results` | Target container for rendered matches |
| `aria-live="polite"` | Screen readers announce result updates |
| `layout: page` | Inherits the theme chrome; `page.layout` becomes `search` |

### Step 5 — The compact masthead box

`_includes/search-form.html`:

```liquid
{%- unless page.layout == "search" -%}
  {%- assign search_placeholder = site.data.text[site.locale].search_placeholder_text | default: "Search the site..." -%}
  <form class="site-search" action="{{ '/search/' | relative_url }}" method="get" role="search">
    <label class="screen-reader-text" for="site-search-input">Search</label>
    <input type="search" id="site-search-input" name="q" placeholder="{{ search_placeholder }}" autocomplete="off">
    <button type="submit" aria-label="Search"><i class="fas fa-search" aria-hidden="true"></i><span>Search</span></button>
  </form>
{%- endunless -%}
```

This box intentionally has **no JavaScript**. It is a plain `GET` form: on any
page it navigates to `/search/?q=<term>`, and the search page picks the term up
from the URL on load. It is hidden on the search page itself to avoid two
competing inputs.

Wire it into the masthead with one line inside `_includes/masthead.html`:

```liquid
{% include search-form.html %}
```

### Step 6 — Load the search JavaScript only on the search page

`_includes/scripts.html` ends with:

```liquid
{%- if page.layout == "search" -%}
  {% include lunr-search-scripts.html %}
{%- endif -%}
```

Because `scripts.html` is included by the default layout, this runs on every
page but only emits code when `page.layout == "search"`. Visitors reading a post
never download lunr.js or the index.

This file also guarantees the two runtime dependencies: jQuery (line 11) and
Font Awesome (line 14). If another theme does not load them, add them yourself.

### Step 7 — The search engine and UI logic

`_includes/lunr-search-scripts.html` — the complete file:

```liquid
{%- assign lang = site.locale | slice: 0,2 | default: "en" -%}
  {%- case lang -%}
    {%- when "da" -%}
      {%- assign lang = "da" -%}
    {%- when "de" -%}
      {%- assign lang = "de" -%}
    {%- when "du" -%}
      {%- assign lang = "du" -%}
    {%- when "es" -%}
      {%- assign lang = "es" -%}
    {%- when "fi" -%}
      {%- assign lang = "fi" -%}
    {%- when "fr" -%}
      {%- assign lang = "fr" -%}
    {%- when "hu" -%}
      {%- assign lang = "hu" -%}
    {%- when "it" -%}
      {%- assign lang = "it" -%}
    {%- when "ja" -%}
      {%- assign lang = "ja" -%}
    {%- when "jp" -%}
      {%- assign lang = "jp" -%}
    {%- when "no" -%}
      {%- assign lang = "no" -%}
    {%- when "pt" -%}
      {%- assign lang = "pt" -%}
    {%- when "ro" -%}
      {%- assign lang = "ro" -%}
    {%- when "ru" -%}
      {%- assign lang = "ru" -%}
    {%- when "sv" -%}
      {%- assign lang = "sv" -%}
    {%- when "tr" -%}
      {%- assign lang = "tr" -%}
    {%- else -%}
      {%- assign lang = "en" -%}
  {%- endcase -%}
  <script src="{{ '/assets/js/lunr/lunr.min.js' | relative_url }}"></script>
  <script src="{{ '/assets/js/search-data.js' | relative_url }}"></script>
  {%- unless lang == "en" -%}
    <script src="{{ '/assets/js/lunr/lunr.stemmer.support.min.js' | relative_url }}"></script>
    <script src="{{ '/assets/js/lunr/lunr.' | append: lang | append: '.min.js' | relative_url }}"></script>
  {%- endunless -%}
  <script>
    (function () {
      var idx = lunr(function () {
        {% unless lang == "en" %}
          // use the language
          this.use(lunr.{{ lang }});
        {% endunless %}
        // the normal lunr index initialization
        this.field('title');
        this.field('excerpt');
        this.field('categories');
        this.field('tags');
        this.ref('id');

        this.pipeline.remove(lunr.trimmer);

        // add documents to index
        for (var item in store) {
          this.add({
            title: store[item].title,
            excerpt: store[item].excerpt,
            categories: store[item].categories,
            tags: store[item].tags,
            id: item
          });
        }
      });

      var resultsText = {{ site.data.text[site.locale].results_found | default: "Result(s) found" | jsonify }};
      var noResultsText = {{ site.data.text[site.locale].no_results | default: "No results found." | jsonify }};

      function escapeHtml(value) {
        return $('<div>').text(value == null ? '' : String(value)).html();
      }

      function escapeAttr(value) {
        return escapeHtml(value).replace(/"/g, '&quot;').replace(/'/g, '&#39;');
      }

      function renderResults(value) {
        var query = $.trim((value || '').toLowerCase());
        var resultDiv = $('#results');
        resultDiv.empty();

        if (!query) {
          return;
        }

        var result = idx.query(function (q) {
          query.split(lunr.tokenizer.separator).forEach(function (term) {
            if (!term) {
              return;
            }
            q.term(term, { boost: 100 });
            if (query.lastIndexOf(' ') != query.length - 1) {
              q.term(term, { usePipeline: false, wildcard: lunr.Query.wildcard.TRAILING, boost: 10 });
            }
            q.term(term, { usePipeline: false, editDistance: 1, boost: 1 });
          });
        });

        resultDiv.append('<p class="results__found">' + result.length + ' ' + escapeHtml(resultsText) + '</p>');

        if (!result.length) {
          resultDiv.append('<p class="results__empty">' + escapeHtml(noResultsText) + '</p>');
          return;
        }

        result.forEach(function (match) {
          var item = store[match.ref];
          if (!item) {
            return;
          }
          var excerpt = (item.excerpt || '').split(/\s+/).slice(0, 20).join(' ');
          resultDiv.append(
            '<article class="entry">' +
              '<h3 class="entry-title">' +
                '<a href="' + escapeAttr(item.url) + '">' + escapeHtml(item.title) + '</a>' +
              '</h3>' +
              '<div class="entry-excerpt">' +
                '<p>' + escapeHtml(excerpt) + (excerpt ? '&hellip;' : '') + '</p>' +
              '</div>' +
            '</article>'
          );
        });
      }

      function updateUrl(value) {
        if (!window.history || !window.history.replaceState) {
          return;
        }
        var url = new URL(window.location.href);
        if ($.trim(value)) {
          url.searchParams.set('q', $.trim(value));
        } else {
          url.searchParams.delete('q');
        }
        window.history.replaceState(null, '', url.pathname + url.search);
      }

      $(document).ready(function () {
        var $input = $('input#search');
        if (!$input.length) {
          return;
        }

        var params = new URLSearchParams(window.location.search);
        var initial = params.get('q') || params.get('query') || '';
        if (initial) {
          $input.val(initial);
          renderResults(initial);
        }

        var timer;
        $input.on('input keyup search', function () {
          var value = $(this).val();
          clearTimeout(timer);
          timer = setTimeout(function () {
            renderResults(value);
            updateUrl(value);
          }, 120);
        });

        $input.closest('form').on('submit', function (event) {
          event.preventDefault();
          clearTimeout(timer);
          renderResults($input.val());
          updateUrl($input.val());
        });
      });
    })();
  </script>
```

#### How the query works

For every whitespace-separated term lunr adds three clauses:

1. **exact match** — `boost: 100` (dominant ranking signal)
2. **prefix wildcard** — `usePipeline: false, wildcard: TRAILING, boost: 10`,
   applied only when the query does not end in a space, so results appear while
   the user is still typing
3. **fuzzy match** — `editDistance: 1, boost: 1` (tolerates one typo)

`this.pipeline.remove(lunr.trimmer)` keeps tokens containing punctuation (useful
for posts like `CVE-2026-124194`) from being mangled by the default trimmer.

Indexed fields are `title`, `excerpt`, `categories`, `tags`, with the array
index as `ref`. Excerpts are re-truncated to 20 words at render time purely for
display.

#### Output safety

Titles and excerpts are passed through `escapeHtml()` (jQuery's `.text()→.html()`
trick) and URLs through `escapeAttr()` before string-concatenation into HTML.
Do not remove these — post titles come from front matter and can contain any
character.

#### URL state

- On load: reads `?q=` (falls back to legacy `?query=`) and renders immediately,
  so a masthead submission works without JS-side navigation.
- On typing: `history.replaceState` rewrites `?q=` without adding history entries.
- On submit: `preventDefault()` and render inline.

### Step 8 — Styles

Add the following block to `assets/css/custom.css` (this repo's theme loads it
via `_layouts/default.html`: `<link rel="stylesheet" href="{{ '/assets/css/custom.css' | relative_url }}">`):

```css
/* ==========================================================================
   Site search
   ========================================================================== */

.site-search,
.search-form--page {
  display: flex;
  align-items: stretch;
  justify-content: center;
  gap: 0.5rem;
  max-width: 36rem;
  margin: 1.25rem auto 0;
  text-align: left;
}

.search-form--page {
  margin-top: 0;
  margin-bottom: 2rem;
}

.site-search {
  padding-right: 1rem;
  padding-left: 1rem;
}

.site-search input[type="search"],
.search-form--page input[type="search"] {
  flex: 1 1 auto;
  width: auto;
  min-width: 0;
  margin: 0;
  padding: 0.65em 1.1em;
  border: 1px solid rgba(0, 0, 0, 0.15);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.96);
  color: #1a1a1a;
  font-family: inherit;
  font-size: 0.95rem;
  line-height: 1.4;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.12);
}

.site-search input[type="search"]:focus,
.search-form--page input[type="search"]:focus {
  outline: 3px solid rgba(255, 255, 255, 0.7);
  outline-offset: 2px;
}

.site-search button,
.search-form--page .search-submit {
  flex: 0 0 auto;
  padding: 0.65em 1.2em;
  border: 0;
  border-radius: 999px;
  background: #000;
  color: #fff;
  font: inherit;
  font-size: 0.8rem;
  font-weight: 700;
  letter-spacing: 0.05em;
  text-transform: uppercase;
  cursor: pointer;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.12);
}

.site-search button:hover,
.site-search button:focus,
.search-form--page .search-submit:hover,
.search-form--page .search-submit:focus {
  background: #34374c;
  color: #fff;
}

.site-search button i,
.search-form--page .search-submit i {
  margin-right: 0.45em;
}

#results {
  margin-top: 1rem;
}

.results__found {
  font-weight: 700;
}

.results__empty {
  opacity: 0.85;
}

@media (max-width: 30em) {
  .site-search button span,
  .search-form--page .search-submit span {
    display: none;
  }

  .site-search button i,
  .search-form--page .search-submit i {
    margin-right: 0;
  }
}
```

Note the mobile rule hides the button's text `span` and relies on the Font
Awesome magnifier. If the target theme has no Font Awesome, drop that
`@media` block so the button keeps its "Search" label.

### Step 9 — Labels (`_data/text.yml`)

Three keys under each locale (English shown; German/Spanish/French/Italian/
Turkish already exist in this repo's file):

```yaml
en: &DEFAULT_EN
  results_found: "Result(s) found"
  no_results: "No results found. Try a different search term."
  search_placeholder_text: "Enter your search term..."
en-US:
  <<: *DEFAULT_EN
```

The templates look these up with `site.data.text[site.locale].<key>` and every
lookup has a `| default:` fallback, so a missing locale still renders English.
If your site has no `_data/text.yml`, either create it with this shape or hard-code
the strings in the three templates.

### Step 10 — Config

```yaml
locale: en-US                    # drives placeholder + lunr language pack
search_full_content: false       # true = index full post bodies (larger search-data.js)
```

There is intentionally **no** plugin entry: lunr is client-side and
`search-data.js` is generated with stock Liquid.

---

## 6. Runtime flow, end to end

1. Visitor clicks a masthead search box on any page and presses Enter.
2. Browser does `GET /search/?q=term`.
3. GitHub Pages serves the static `/search/` page built from `search.md`.
4. `_layouts/search.html` renders the large form and `#results`.
5. `scripts.html` sees `page.layout == "search"` and includes
   `lunr-search-scripts.html`, which loads `lunr.min.js` then `search-data.js`.
6. The inline script builds the index from `store`, binds `input#search`, reads
   `?q=term`, and renders matches.
7. Further keystrokes re-query locally — no network calls, no backend.
8. `history.replaceState` keeps `?q=` in sync so the result page is shareable.

---

## 7. Porting checklist for another GitHub Pages theme

1. **Copy files**
   - `_layouts/search.html`
   - `_includes/search-form.html`
   - `_includes/lunr-search-scripts.html`
   - `assets/js/search-data.js`
   - `assets/js/lunr/lunr.min.js`
2. **Add the page** `search.md` with `layout: search`, `permalink: /search/`.
3. **Hook the JS** — add the `page.layout == "search"` guard from Step 6 to
   whichever include your target theme renders before `</body>` (often
   `_includes/scripts.html`, `_includes/footer.html`, or the layout directly).
4. **Hook the form** — add `{% include search-form.html %}` in the theme's header
   or navigation include. If there is no suitable place, put it in the layout and
   rely on the `/search/` page's own large box.
5. **Ensure jQuery and Font Awesome are loaded** on the search page. If the
   theme does not use jQuery, either add it (one `<script>` tag) or port the
   script to vanilla JS — the only jQuery APIs used are `$()`, `.val()`,
   `.on()`, `.closest()`, `.empty()`, `.append()`, `.trim()`, `.text()`, and
   `.html()`.
6. **Merge the CSS** from Step 8, adapting the color/shadow values to the
   target theme.
7. **Add `_data/text.yml` keys** (Step 9) or hard-code the labels.
8. **Set `locale`** in `_config.yml`; add the matching `lunr.<lang>.min.js` and
   include it via the existing `unless lang == "en"` branch for non-English sites.
9. **Build and test locally**, then commit **every new file** (see §8).

Minimal diff for a theme that already has a `scripts.html` and a header include:

```diff
  <!-- _includes/scripts.html, before </body> -->
+ {%- if page.layout == "search" -%}
+   {% include lunr-search-scripts.html %}
+ {%- endif -%}
```

```diff
  <!-- _includes/masthead.html (or header.html), inside the header -->
+ {% include search-form.html %}
```

---

## 8. Gotchas (learned from this repo)

### 8.1 Untracked files break the GitHub Actions build

GitHub Actions builds only the **committed** tree. `_includes/masthead.html`
referencing `{% include search-form.html %}` while that file exists only in the
working tree produces:

```text
Liquid Exception: Could not locate the included file 'search-form.html' in any of
["/github/workspace/_includes", "/tmp/jekyll-remote-theme-.../_includes"] ... in /_layouts/default.html
```

Before pushing, verify every new file is tracked:

```bash
git status --porcelain          # look for '??' in _includes/, _layouts/, assets/
git ls-files _includes/search-form.html assets/js/search-data.js
```

A quick audit for any include referenced from tracked templates but absent from
git:

```bash
git ls-files '_includes/*' '_layouts/*' '*.md' \
  | xargs grep -hoE '\{%-? *include +=? *[^ %]+' \
  | sed -E 's/.*include *//; s/=//' | tr -d '"' | sort -u \
  | while read f; do [ -e "_includes/$f" ] || echo "MISSING: $f"; done
```

### 8.2 GitHub Pages "safe mode"

- Files in `_includes/` **must not be symlinks** (the error text says so
  explicitly). If you keep shared includes in another directory and symlink
  them, the build fails on Pages while working locally.
- No custom `_plugins` — this is why the index generator is a Liquid-templated
  `.js` asset rather than a Ruby generator.

### 8.3 `assets/js/search-data.js` needs front matter

Without the `---` block Jekyll copies the file verbatim and Liquid never runs,
so the browser receives literal `{%- for c in site.collections -%}` and the
console shows a syntax error. Keep at least:

```yaml
---
layout: null
---
```

### 8.4 Only collections are indexed

`site.collections` contains `posts` plus collections declared in `_config.yml`.
Standalone pages (`about.md`, `index.md`, project pages) are **not** searchable.
To include them, extend the generator with, for example:

```liquid
{%- for p in site.pages -%}
  {%- unless p.url contains '.js' or p.url contains '.css' or p.search == false -%}
    { "title": {{ p.title | jsonify }},
      "excerpt": {{ p.content | strip_html | strip_newlines | truncatewords: 50 | jsonify }},
      "categories": {{ p.categories | jsonify }},
      "tags": {{ p.tags | jsonify }},
      "url": {{ p.url | absolute_url | jsonify }} },
  {%- endunless -%}
{%- endfor -%}
```

Watch the comma placement — the template builds JSON by hand, so a trailing
comma or a missing one makes `store` invalid JavaScript and silently kills
search.

### 8.5 ID collisions / duplicate inputs

Only the input with `id="search"` gets live results. The masthead input uses
`id="site-search-input"` on purpose: two elements sharing `id="search"` would
bind the handler to the first one found and leave the other inert.

### 8.6 Search page must not also show the masthead box

`search-form.html` is wrapped in `{%- unless page.layout == "search" -%}`. If you
remove that guard, the search page shows two boxes, and the smaller one's input
is never read.

### 8.7 jQuery must exist before the search script runs

`lunr-search-scripts.html` assumes `$`. In this repo the theme's `scripts.html`
loads jQuery at line 11 and the search include at line 52, so ordering is
correct. If your theme loads scripts in `<head>` with `defer`, or omits jQuery,
the `$(document).ready(...)` block throws `$ is not defined` and nothing is
searchable. Check the browser console first when results never appear.

### 8.8 Front matter can opt a post out

`search: false` in a post's front matter removes it from `store` (the
`where_exp` filter). Useful for drafts, redirects, or very large posts.

### 8.9 Performance

- `search_full_content: false` keeps `search-data.js` small (50 words per doc).
  With thousands of posts, enabling full content can push the file into the
  megabytes.
- The index is rebuilt in the browser on every visit to `/search/`; it is not
  cached across page loads. For a few hundred posts that is milliseconds.
- lunr.js (~30 KB minified) is loaded only on the search page thanks to the
  `page.layout == "search"` guard.

---

## 9. Optional improvements

- **Limit rendered results** (e.g. top 20) to avoid long pages on short queries.
- **Highlight matches**: wrap query terms in `<mark>` inside the excerpt
  (remember to escape first, then insert the tags).
- **Keyboard shortcut**: focus `#search` on `/` or `Ctrl/Cmd+K`.
- **Index headings**: parse `doc.content` for `<h2>/<h3>` at build time and add a
  `headings` field for better ranking.
- **Server-side alternative**: `jekyll-lunr-js-search` and similar plugins do the
  same job but add configuration; the hand-rolled version above has no plugin
  dependency and survives theme swaps.
