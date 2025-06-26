---
title: "50 different JSX expression"
tags:
  - React
---

Here’s a list of **50 different expressions** that can be used **inside JSX** in React. JSX allows embedding any **JavaScript expression** within `{}` — this includes literals, function calls, ternary expressions, operators, arrays, objects (as function arguments or attributes), and more.

---

### **Literals and Simple Expressions**

1. `{42}`
2. `{"Hello, JSX"}`
3. `{true}`
4. `{false}`
5. `{null}`
6. `{undefined}`
7. `{[1, 2, 3].join(", ")}`

---

### **Arithmetic Expressions**

8. `{1 + 2}`
9. `{a * b}`
10. `{price / quantity}`
11. `{count++}`
12. `{Math.pow(2, 3)}`
13. `{Math.round(value)}`
14. `{(a + b) * c}`

---

### **Logical Expressions**

15. `{isLoggedIn && <Profile />}`
16. `{!isAvailable ? "Out of stock" : "In stock"}`
17. `{x > 10 && "Greater than 10"}`
18. `{x || "Default value"}`
19. `{a ?? "Fallback if nullish"}`

---

### **Function Calls**

20. `{formatDate(new Date())}`
21. `{getUser().name}`
22. `{calculateTotal(cartItems)}`
23. `{() => handleClick()}`
24. `{onClickHandler?.()}`

---

### **Array & Map**

25. `{items.map(item => <li key={item.id}>{item.name}</li>)}`
26. `{[<li>A</li>, <li>B</li>]}`
27. `{Array(5).fill("⭐").map((s, i) => <span key={i}>{s}</span>)}`
28. `{colors.join(", ")}`

---

### **Object Access**

29. `{user.name}`
30. `{data?.profile?.email}`
31. `{config["theme"]}`
32. `{props['title']}`

---

### **Template Literals**

33. {`Hello, ${user.firstName} ${user.lastName}`}
34. `{`\${count} items in cart`}`
35. `{`Price: \$\${price.toFixed(2)}`}`

---

### **Conditionals (ternary)**

36. `{isDarkMode ? "Dark" : "Light"}`
37. `{user ? user.name : "Guest"}`
38. `{loading ? <Spinner /> : <Dashboard />}`

---

### **Boolean Expressions in Attributes**

39. `<input disabled={!isEnabled} />`
40. `<button hidden={shouldHide}>Click</button>`

---

### **IIFE (Immediately Invoked Function Expression)**

41. `{(() => { return computeValue(); })()}`

---

### **Custom Components or JSX Blocks**

42. `{<CustomComponent prop={value} />}`
43. `{condition && <AnotherComponent />}`
44. `{renderChildren()}`

---

### **Destructuring Inside JSX Scope**

45. `{(() => { const { name } = user; return name; })()}`

---

### **Date & Time**

46. `{new Date().toLocaleDateString()}`
47. `{Date.now()}`

---

### **Events**

48. `<button onClick={() => alert("Clicked!")}>Click</button>`

---

### **Styles and ClassNames**

49. `<div style={{ color: isError ? "red" : "green" }}>Status</div>`
50. `<div className={`alert \${type === "error" ? "alert-danger" : "alert-success"}`}>Message</div>`

---

### Notes:

* Every expression is wrapped in `{}` in JSX unless it is a prop assignment or JSX element itself.
* JSX **does not** allow `if`, `for`, `while`, `switch`, etc., directly — but they can be used in surrounding JavaScript blocks or via expressions like ternary or map.

