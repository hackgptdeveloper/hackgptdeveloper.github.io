---
title: "10 different ways of using React Hooks with examples"
tags:
  - ReactHooks
---

React Hooks are functions introduced in React 16.8 that allow you to use state and other React features in functional components. Here is an explanation of all the commonly used hooks, categorized into **basic hooks**, **additional hooks**, and **custom hooks**, with examples for each.

---

### **Basic React Hooks**

#### 1. `useState`
- Allows you to add state to a functional component.
- Returns an array: the current state and a function to update it.

**Example**:
```jsx
import React, { useState } from 'react';

function Counter() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
}

export default Counter;
```

---

#### 2. `useEffect`
- Used to perform side effects in a component (e.g., fetching data, subscriptions).
- By default, runs after every render. You can control when it runs by passing dependencies.

**Example**:
```jsx
import React, { useState, useEffect } from 'react';

function Timer() {
  const [seconds, setSeconds] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setSeconds((prev) => prev + 1);
    }, 1000);

    return () => clearInterval(interval); // Cleanup on unmount
  }, []); // Empty array means run only once on mount

  return <p>Seconds elapsed: {seconds}</p>;
}

export default Timer;
```

---

#### 3. `useContext`
- Provides a way to consume a React Context.

**Example**:
```jsx
import React, { useContext, createContext } from 'react';

const ThemeContext = createContext('light');

function ThemeButton() {
  const theme = useContext(ThemeContext);
  return <button style={{ background: theme === 'dark' ? '#333' : '#fff' }}>Theme: {theme}</button>;
}

function App() {
  return (
    <ThemeContext.Provider value="dark">
      <ThemeButton />
    </ThemeContext.Provider>
  );
}

export default App;
```

---

### **Additional React Hooks**

#### 4. `useReducer`
- An alternative to `useState` for managing complex state logic.

**Example**:
```jsx
import React, { useReducer } from 'react';

const initialState = { count: 0 };

function reducer(state, action) {
  switch (action.type) {
    case 'increment':
      return { count: state.count + 1 };
    case 'decrement':
      return { count: state.count - 1 };
    default:
      throw new Error();
  }
}

function Counter() {
  const [state, dispatch] = useReducer(reducer, initialState);

  return (
    <div>
      <p>Count: {state.count}</p>
      <button onClick={() => dispatch({ type: 'increment' })}>Increment</button>
      <button onClick={() => dispatch({ type: 'decrement' })}>Decrement</button>
    </div>
  );
}

export default Counter;
```

---

#### 5. `useRef`
- Provides a mutable ref object that doesn’t re-render the component.

**Example**:
```jsx
import React, { useRef } from 'react';

function FocusInput() {
  const inputRef = useRef(null);

  const focusInput = () => {
    inputRef.current.focus();
  };

  return (
    <div>
      <input ref={inputRef} type="text" />
      <button onClick={focusInput}>Focus Input</button>
    </div>
  );
}

export default FocusInput;
```

---

#### 6. `useMemo`
- Memoizes a computed value to optimize performance.

**Example**:
```jsx
import React, { useMemo, useState } from 'react';

function ExpensiveCalculation({ num }) {
  const expensiveValue = useMemo(() => {
    console.log('Calculating...');
    return num ** 2;
  }, [num]);

  return <p>Squared Value: {expensiveValue}</p>;
}

function App() {
  const [number, setNumber] = useState(0);

  return (
    <div>
      <ExpensiveCalculation num={number} />
      <button onClick={() => setNumber((n) => n + 1)}>Increase</button>
    </div>
  );
}

export default App;
```

---

#### 7. `useCallback`
- Memoizes a function reference to avoid unnecessary re-creations.

**Example**:
```jsx
import React, { useState, useCallback } from 'react';

function Child({ increment }) {
  console.log('Child Rendered');
  return <button onClick={increment}>Increment</button>;
}

function App() {
  const [count, setCount] = useState(0);

  const increment = useCallback(() => setCount((c) => c + 1), []);

  return (
    <div>
      <p>Count: {count}</p>
      <Child increment={increment} />
    </div>
  );
}

export default App;
```

---

#### 8. `useLayoutEffect`
- Similar to `useEffect`, but fires synchronously after all DOM mutations.

**Example**:
```jsx
import React, { useLayoutEffect, useRef } from 'react';

function LayoutEffectExample() {
  const divRef = useRef(null);

  useLayoutEffect(() => {
    console.log(divRef.current.getBoundingClientRect());
  }, []);

  return <div ref={divRef}>Check the console for layout details.</div>;
}

export default LayoutEffectExample;
```

---

#### 9. `useImperativeHandle`
- Customizes the instance value that is exposed when using `ref`.

**Example**:
```jsx
import React, { useImperativeHandle, forwardRef, useRef } from 'react';

const CustomInput = forwardRef((props, ref) => {
  const inputRef = useRef();

  useImperativeHandle(ref, () => ({
    focus: () => {
      inputRef.current.focus();
    },
  }));

  return <input ref={inputRef} type="text" />;
});

function App() {
  const inputRef = useRef();

  return (
    <div>
      <CustomInput ref={inputRef} />
      <button onClick={() => inputRef.current.focus()}>Focus Custom Input</button>
    </div>
  );
}

export default App;
```

---

### **Custom Hooks**

You can create your own hooks to encapsulate reusable logic.

**Example**:
```jsx
import React, { useState } from 'react';

function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue);
  const toggle = () => setValue((v) => !v);
  return [value, toggle];
}

function App() {
  const [isVisible, toggleVisibility] = useToggle();

  return (
    <div>
      <button onClick={toggleVisibility}>Toggle Visibility</button>
      {isVisible && <p>Now you see me!</p>}
    </div>
  );
}

export default App;
```

---

### **Other Hooks**
1. **`useId`**: For unique ID generation (introduced in React 18).
2. **`useDebugValue`**: Displays a label for custom hooks in React DevTools.
3. **`useTransition`**: Allows you to mark updates as non-urgent (React 18).
4. **`useDeferredValue`**: Defers a value update for performance.

