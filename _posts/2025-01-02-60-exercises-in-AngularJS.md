---
title: "60 **AngularJS** exercises"
tags:
  - Javascript
---

A list of 60 **AngularJS** exercises, categorized into different topics to cover basics, data binding, directives, routing, services, and advanced features.

---

### **Basic AngularJS Exercises**
1. Set up a basic AngularJS application and display "Hello, AngularJS!".
2. Use `ng-app` to initialize an AngularJS app in an HTML document.
3. Bind a variable using `ng-bind` and display its value on the page.
4. Create an input field with two-way binding using `ng-model`.
5. Display a calculated result (e.g., `{ { 2 + 2 } }`) using interpolation.
6. Create a button that changes a value in the controller using `ng-click`.
7. Create a list and use `ng-repeat` to loop through and display items.
8. Display a message only when a condition is true using `ng-if`.
9. Show or hide an element using `ng-show` and `ng-hide`.
10. Create a dropdown and display the selected value dynamically.

---

### **Controllers and Scope**
11. Define a controller and bind a variable to the `$scope`.
12. Use multiple controllers on the same page and pass data between them.
13. Create a function in a controller and invoke it from a button click.
14. Create a calculator app with addition, subtraction, multiplication, and division.
15. Pass data from a parent controller to a child controller using `$scope`.
16. Use `$watch` to track changes in a variable.
17. Dynamically add items to a list using a controller function.
18. Create a controller to handle form submission and validate input fields.
19. Use `$scope` to bind a JSON object and display its properties.
20. Implement a toggle functionality for an element.

---

### **Directives**
21. Create a custom directive that displays a "Hello World" message.
22. Use the `ng-init` directive to initialize variables.
23. Create a directive that accepts an attribute and displays it dynamically.
24. Use the `ng-class` directive to conditionally apply CSS classes.
25. Use the `ng-style` directive to apply inline styles dynamically.
26. Build a custom directive to display user profile information.
27. Create a directive to render a list of items.
28. Create a reusable directive for a navigation bar.
29. Use the `ng-repeat` directive with a custom filter.
30. Use a directive to format phone numbers dynamically.

---

### **Filters**
31. Use the `uppercase` filter to transform text.
32. Use the `currency` filter to format a number as currency.
33. Create a custom filter to reverse a string.
34. Use the `orderBy` filter to sort an array dynamically.
35. Filter a list of items based on user input.
36. Create a filter to display only even numbers from a list.
37. Chain multiple filters to transform data.
38. Use the `filter` filter to search within an array of objects.
39. Create a custom filter to mask sensitive information (e.g., credit card numbers).
40. Format a date dynamically using the `date` filter.

---

### **Routing**
41. Set up basic routing with `ngRoute`.
42. Create multiple views and navigate between them using links.
43. Use `$routeParams` to pass parameters to a route.
44. Add a default route using `otherwise`.
45. Create a 404 page for undefined routes.
46. Use nested views with `ng-view`.
47. Implement route guards using a custom service.
48. Load a view dynamically based on user authentication status.
49. Preload data for a route using a `resolve` property.
50. Create a single-page application (SPA) with navigation and dynamic views.

---

### **Services and Dependency Injection**
51. Create a custom service to fetch data from a REST API.
52. Use the `$http` service to perform a GET request.
53. Use the `$http` service to perform a POST request and handle the response.
54. Create a factory service to manage application state.
55. Share data between controllers using a service.
56. Implement a caching mechanism using `$cacheFactory`.
57. Use `$interval` to create a timer that updates every second.
58. Create a weather app using an external API and `$http`.
59. Handle errors in HTTP requests using `$http`’s `.catch` method.
60. Build a shopping cart using a custom service to manage cart items.

---

### **Bonus Suggestions**
For extended learning, you can:
- Create a form with validation for required fields, email formats, and more.
- Use `$location` to dynamically update the browser URL.
- Implement authentication and session management.
- Create a dynamic dashboard with data fetched from APIs.
- Build a to-do app with persistent storage using localStorage or an external backend.
