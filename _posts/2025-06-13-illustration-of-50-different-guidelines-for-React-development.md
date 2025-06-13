---
title: "50 React Development Rules with Examples"
tags:
  - React
---

# 50 React Development Rules with Examples

## Component Design & Architecture

### 1. Use functional components over class components
**Bad:**
```jsx
class Welcome extends React.Component {
  render() {
    return <h1>Hello, {this.props.name}</h1>;
  }
}
```

**Good:**
```jsx
function Welcome({ name }) {
  return <h1>Hello, {name}</h1>;
}
```

### 2. Keep components small and focused
**Bad:**
```jsx
function UserDashboard({ user }) {
  return (
    <div>
      <div>{user.name}</div>
      <div>{user.email}</div>
      <div>
        {user.posts.map(post => (
          <div key={post.id}>
            <h3>{post.title}</h3>
            <p>{post.content}</p>
            <span>{post.date}</span>
            <button onClick={() => deletePost(post.id)}>Delete</button>
          </div>
        ))}
      </div>
      <form onSubmit={handleSubmit}>
        <input value={title} onChange={e => setTitle(e.target.value)} />
        <textarea value={content} onChange={e => setContent(e.target.value)} />
        <button type="submit">Add Post</button>
      </form>
    </div>
  );
}
```

**Good:**
```jsx
function UserDashboard({ user }) {
  return (
    <div>
      <UserProfile user={user} />
      <PostList posts={user.posts} />
      <PostForm onSubmit={handleAddPost} />
    </div>
  );
}
```

### 3. Use PascalCase for component names
**Bad:**
```jsx
function userCard() { /* ... */ }
function user_profile() { /* ... */ }
```

**Good:**
```jsx
function UserCard() { /* ... */ }
function UserProfile() { /* ... */ }
```

### 4. Create custom hooks for reusable logic
**Bad:**
```jsx
// Repeated in multiple components
function UserProfile() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('/api/user')
      .then(res => res.json())
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  return <div>{user.name}</div>;
}
```

**Good:**
```jsx
// Custom hook
function useUser() {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('/api/user')
      .then(res => res.json())
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  return { user, loading, error };
}

// Component using the hook
function UserProfile() {
  const { user, loading, error } = useUser();
  
  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  return <div>{user.name}</div>;
}
```

### 5. Prefer composition over inheritance
**Bad:**
```jsx
class BaseButton extends React.Component {
  render() {
    return <button className="btn">{this.props.children}</button>;
  }
}

class PrimaryButton extends BaseButton {
  render() {
    return <button className="btn btn-primary">{this.props.children}</button>;
  }
}
```

**Good:**
```jsx
function Button({ variant = 'default', children, ...props }) {
  return (
    <button 
      className={`btn btn-${variant}`} 
      {...props}
    >
      {children}
    </button>
  );
}

// Usage
<Button variant="primary">Click me</Button>
```

### 6. Use TypeScript for better type safety
**JavaScript:**
```jsx
function UserCard({ user }) {
  return <div>{user.name}</div>; // No type checking
}
```

**TypeScript:**
```tsx
interface User {
  id: number;
  name: string;
  email: string;
}

function UserCard({ user }: { user: User }) {
  return <div>{user.name}</div>; // Type checked!
}
```

### 7. Single responsibility principle
**Bad:**
```jsx
function UserComponent({ userId }) {
  // Fetching data
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  // Formatting data
  const formatDate = (date) => new Date(date).toLocaleDateString();

  // Handling actions
  const handleEdit = () => { /* edit logic */ };
  const handleDelete = () => { /* delete logic */ };

  // Rendering everything
  return (
    <div>
      <img src={user?.avatar} />
      <h2>{user?.name}</h2>
      <p>Joined: {formatDate(user?.joinDate)}</p>
      <button onClick={handleEdit}>Edit</button>
      <button onClick={handleDelete}>Delete</button>
    </div>
  );
}
```

**Good:**
```jsx
// Separate concerns into different components/hooks
function useUser(userId) {
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);
  return user;
}

function UserAvatar({ src, alt }) {
  return <img src={src} alt={alt} />;
}

function UserActions({ onEdit, onDelete }) {
  return (
    <div>
      <button onClick={onEdit}>Edit</button>
      <button onClick={onDelete}>Delete</button>
    </div>
  );
}

function UserCard({ userId, onEdit, onDelete }) {
  const user = useUser(userId);
  
  return (
    <div>
      <UserAvatar src={user?.avatar} alt={user?.name} />
      <h2>{user?.name}</h2>
      <p>Joined: {new Date(user?.joinDate).toLocaleDateString()}</p>
      <UserActions onEdit={onEdit} onDelete={onDelete} />
    </div>
  );
}
```

### 8. Use proper file and folder structure
**Bad:**
```
src/
  components/
    everything.js
    all-components.js
```

**Good:**
```
src/
  components/
    User/
      UserCard.jsx
      UserProfile.jsx
      UserList.jsx
      index.js
    Product/
      ProductCard.jsx
      ProductDetails.jsx
      index.js
  hooks/
    useUser.js
    useProducts.js
  utils/
    dateHelpers.js
    apiHelpers.js
```

## State Management

### 9. Use useState for local component state
**Example:**
```jsx
function Counter() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>+</button>
      <button onClick={() => setCount(count - 1)}>-</button>
    </div>
  );
}
```

### 10. Use useReducer for complex state logic
**Bad (useState for complex state):**
```jsx
function ShoppingCart() {
  const [items, setItems] = useState([]);
  const [total, setTotal] = useState(0);
  const [discount, setDiscount] = useState(0);
  const [loading, setLoading] = useState(false);

  const addItem = (item) => {
    setItems(prev => [...prev, item]);
    setTotal(prev => prev + item.price);
  };

  const removeItem = (id) => {
    const item = items.find(i => i.id === id);
    setItems(prev => prev.filter(i => i.id !== id));
    setTotal(prev => prev - item.price);
  };

  // More complex logic...
}
```

**Good (useReducer):**
```jsx
function cartReducer(state, action) {
  switch (action.type) {
    case 'ADD_ITEM':
      return {
        ...state,
        items: [...state.items, action.item],
        total: state.total + action.item.price
      };
    case 'REMOVE_ITEM':
      const item = state.items.find(i => i.id === action.id);
      return {
        ...state,
        items: state.items.filter(i => i.id !== action.id),
        total: state.total - item.price
      };
    case 'SET_LOADING':
      return { ...state, loading: action.loading };
    default:
      return state;
  }
}

function ShoppingCart() {
  const [state, dispatch] = useReducer(cartReducer, {
    items: [],
    total: 0,
    discount: 0,
    loading: false
  });

  const addItem = (item) => dispatch({ type: 'ADD_ITEM', item });
  const removeItem = (id) => dispatch({ type: 'REMOVE_ITEM', id });
}
```

### 11. Lift state up when multiple components need it
**Bad:**
```jsx
function App() {
  return (
    <div>
      <UserProfile /> {/* Has its own user state */}
      <UserSettings /> {/* Has its own user state */}
    </div>
  );
}
```

**Good:**
```jsx
function App() {
  const [user, setUser] = useState(null);

  return (
    <div>
      <UserProfile user={user} />
      <UserSettings user={user} onUserUpdate={setUser} />
    </div>
  );
}
```

### 12. Avoid unnecessary re-renders
**Bad:**
```jsx
function App() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
      <ExpensiveComponent /> {/* Re-renders every time count changes */}
    </div>
  );
}
```

**Good:**
```jsx
const MemoizedExpensiveComponent = React.memo(ExpensiveComponent);

function App() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
      <MemoizedExpensiveComponent /> {/* Only re-renders when its props change */}
    </div>
  );
}
```

### 13. Initialize state correctly
**Bad:**
```jsx
function UserProfile({ userId }) {
  // Function called on every render!
  const [user, setUser] = useState(fetchUserSync(userId));
}
```

**Good:**
```jsx
function UserProfile({ userId }) {
  // Lazy initial state - function called only once
  const [user, setUser] = useState(() => getInitialUser(userId));
  
  // Or better yet, use useEffect for async operations
  const [user, setUser] = useState(null);
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);
}
```

### 14. Use state updater functions for dependent updates
**Bad:**
```jsx
function Counter({ increment = 1 }) {
  const [count, setCount] = useState(0);

  const handleClick = () => {
    setCount(count + increment); // Stale closure problem
    setCount(count + increment); // Won't work as expected
  };
}
```

**Good:**
```jsx
function Counter({ increment = 1 }) {
  const [count, setCount] = useState(0);

  const handleClick = () => {
    setCount(prev => prev + increment);
    setCount(prev => prev + increment); // Works correctly
  };
}
```

