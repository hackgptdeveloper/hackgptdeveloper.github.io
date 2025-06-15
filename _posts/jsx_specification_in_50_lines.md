
Here's a concise **JSX specification in 50 lines**, blending syntax rules, semantics, behavior, and how JSX transpiles (mostly via Babel) to JavaScript. This aims to mirror what a minimal JSX RFC/spec might look like for language implementers or advanced users.

---

### **JSX Specification (in 50 lines)**

1. JSX is a syntactic sugar for `React.createElement` (or equivalent).
2. JSX expressions must be wrapped in a single enclosing tag.
3. JSX files typically use `.jsx` or `.tsx` extensions.
4. JSX tags resemble HTML but map to JavaScript function calls.
5. A JSX element: `<tag attr="value">children</tag>`.
6. Elements are converted to `React.createElement(type, props, ...children)`.
7. Type is a string (`"div"`, `"span"`) or a React component identifier.
8. Tag names starting with a lowercase letter map to DOM elements.
9. Tag names starting with uppercase letters map to React components.
10. Self-closing tags are allowed: `<img />`, `<Component />`.
11. JSX attributes map to object properties in `props`.
12. Attribute values must be JavaScript expressions inside `{}`.
13. String literals may be passed without `{}`: `<div title="Hi" />`.
14. Boolean attributes: `<input disabled />` ⇒ `disabled: true`.
15. The `className` attribute is used instead of `class`.
16. The `htmlFor` attribute is used instead of `for`.
17. All other attributes follow camelCase naming (e.g., `tabIndex`).
18. Event handlers are camelCase: `onClick`, `onChange`, etc.
19. Children can be strings, numbers, JSX, expressions, or arrays.
20. Text content is automatically coerced to string.
21. Comments inside JSX use `{/* like this */}`.
22. Multiple children must be inside a wrapper element or `<>...</>`.
23. Fragments can be used: `<>...</>` (transpiles to `React.Fragment`).
24. Conditional rendering: `{condition && <Component />}`.
25. Ternary operators are supported: `{cond ? A : B}`.
26. Loops must be in expressions: `{items.map(...)}`.
27. You cannot use `if`, `for`, `while` directly in JSX.
28. Expressions are evaluated at render time.
29. JSX supports spread attributes: `<Component {...props} />`.
30. JSX does not support spreading children.
31. Keys must be set when rendering arrays of elements.
32. Keys help React optimize reconciliation during re-renders.
33. JSX transforms into JavaScript before runtime (via Babel, TypeScript, etc.).
34. A JSX tag like `<div id="main">Text</div>` becomes:
35. `React.createElement("div", { id: "main" }, "Text")`.
36. If a component is used: `<MyComp name="x" />` becomes:
37. `React.createElement(MyComp, { name: "x" })`.
38. Nested JSX is recursively converted to nested `createElement` calls.
39. JSX supports inline functions: `<button onClick={() => foo()} />`.
40. JSX may be nested in JavaScript logic outside of JSX itself.
41. Attributes cannot contain statements — only expressions.
42. Dangerous inner HTML must be explicitly set: `dangerouslySetInnerHTML`.
43. Void elements (e.g., `<input />`, `<img />`) must be self-closing.
44. Comments outside of JSX use `//` or `/* ... */` as usual.
45. JSX must be in scope with `React` or `jsx` factory function (e.g., with Babel).
46. The JSX pragma (e.g., `/** @jsx h */`) can change the transformation target.
47. TypeScript can use `@jsxImportSource` to select a custom JSX runtime.
48. In React 17+, the new JSX transform eliminates the need to `import React`.
49. JSX is not HTML — it is closer to JavaScript syntax than browser DOM.
50. JSX supports both static and dynamic rendering paths depending on usage.

---
