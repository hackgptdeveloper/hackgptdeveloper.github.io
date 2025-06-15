---
title: "50 React Development Rules with Examples (Part2)"
tags:
  - React
---

# 50 React Development Rules with Examples (Part2)

### 15. Consider using context for deeply nested props
**Bad (Prop drilling):**
```jsx
function App() {
  const [theme, setTheme] = useState('light');
  return <Header theme={theme} setTheme={setTheme} />;
}

function Header({ theme, setTheme }) {
  return <Navigation theme={theme} setTheme={setTheme} />;
}

function Navigation({ theme, setTheme }) {
  return <ThemeToggle theme={theme} setTheme={setTheme} />;
}

function ThemeToggle({ theme, setTheme }) {
  return <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
    {theme}
  </button>;
}
```

**Good (Context):**
```jsx
const ThemeContext = createContext();

function App() {
  const [theme, setTheme] = useState('light');
  return (
    <ThemeContext.Provider value={ { theme, setTheme } }>
      <Header />
    </ThemeContext.Provider>
  );
}

function Header() {
  return <Navigation />;
}

function Navigation() {
  return <ThemeToggle />;
}

function ThemeToggle() {
  const { theme, setTheme } = useContext(ThemeContext);
  return <button onClick={() => setTheme(theme === 'light' ? 'dark' : 'light')}>
    {theme}
  </button>;
}
```

### 16. Use external state management for complex apps
**Example with Zustand:**
```jsx
import { create } from 'zustand';

// Global store
const useStore = create((set) => ({
  user: null,
  posts: [],
  loading: false,
  setUser: (user) => set({ user }),
  addPost: (post) => set((state) => ({ posts: [...state.posts, post] })),
  setLoading: (loading) => set({ loading })
}));

// Components can access store directly
function UserProfile() {
  const { user, loading } = useStore();
  
  if (loading) return <div>Loading...</div>;
  return <div>{user?.name}</div>;
}

function PostList() {
  const posts = useStore(state => state.posts);
  return posts.map(post => <div key={post.id}>{post.title}</div>);
}
```

## Props & Data Flow

### 17. Validate props with PropTypes or TypeScript
**PropTypes:**
```jsx
import PropTypes from 'prop-types';

function UserCard({ user, onEdit }) {
  return (
    <div>
      <h2>{user.name}</h2>
      <button onClick={onEdit}>Edit</button>
    </div>
  );
}

UserCard.propTypes = {
  user: PropTypes.shape({
    id: PropTypes.number.isRequired,
    name: PropTypes.string.isRequired,
    email: PropTypes.string
  }).isRequired,
  onEdit: PropTypes.func.isRequired
};
```

**TypeScript:**
```tsx
interface User {
  id: number;
  name: string;
  email?: string;
}

interface UserCardProps {
  user: User;
  onEdit: () => void;
}

function UserCard({ user, onEdit }: UserCardProps) {
  return (
    <div>
      <h2>{user.name}</h2>
      <button onClick={onEdit}>Edit</button>
    </div>
  );
}
```

### 18. Use destructuring for cleaner prop handling
**Bad:**
```jsx
function UserCard(props) {
  return (
    <div>
      <h2>{props.user.name}</h2>
      <p>{props.user.email}</p>
      <button onClick={props.onEdit}>Edit</button>
      <button onClick={props.onDelete}>Delete</button>
    </div>
  );
}
```

**Good:**
```jsx
function UserCard({ user, onEdit, onDelete }) {
  const { name, email } = user;
  
  return (
    <div>
      <h2>{name}</h2>
      <p>{email}</p>
      <button onClick={onEdit}>Edit</button>
      <button onClick={onDelete}>Delete</button>
    </div>
  );
}
```

### 19. Provide default props when appropriate
**Function default parameters:**
```jsx
function Button({ 
  children, 
  variant = 'primary', 
  size = 'medium',
  disabled = false,
  onClick = () => {}
}) {
  return (
    <button 
      className={`btn btn-${variant} btn-${size}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

**DefaultProps (legacy):**
```jsx
function Button({ children, variant, size, disabled, onClick }) {
  return (
    <button 
      className={`btn btn-${variant} btn-${size}`}
      disabled={disabled}
      onClick={onClick}
    >
      {children}
    </button>
  );
}

Button.defaultProps = {
  variant: 'primary',
  size: 'medium',
  disabled: false,
  onClick: () => {}
};
```

### 20. Pass objects and arrays carefully
**Bad:**
```jsx
function App() {
  const [count, setCount] = useState(0);

  return (
    <div>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
      {/* New object created on every render! */}
      <ExpensiveComponent config={ { theme: 'dark', size: 'large' } } />
      {/* New array created on every render! */}
      <ListComponent items={['a', 'b', 'c']} />
    </div>
  );
}
```

**Good:**
```jsx
function App() {
  const [count, setCount] = useState(0);
  
  // Stable references
  const config = useMemo(() => ({ theme: 'dark', size: 'large' }), []);
  const items = useMemo(() => ['a', 'b', 'c'], []);

  return (
    <div>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
      <ExpensiveComponent config={config} />
      <ListComponent items={items} />
    </div>
  );
}
```

### 21. Use proper key props in lists
**Bad:**
```jsx
function TodoList({ todos }) {
  return (
    <ul>
      {todos.map(todo => (
        <li>{todo.text}</li> // Missing key!
      ))}
    </ul>
  );
}
```

**Good:**
```jsx
function TodoList({ todos }) {
  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>{todo.text}</li>
      ))}
    </ul>
  );
}
```

### 22. Avoid using array indices as keys
**Bad:**
```jsx
function TodoList({ todos }) {
  return (
    <ul>
      {todos.map((todo, index) => (
        <li key={index}>{todo.text}</li> // Index as key can cause issues
      ))}
    </ul>
  );
}
```

**Good:**
```jsx
function TodoList({ todos }) {
  return (
    <ul>
      {todos.map(todo => (
        <li key={todo.id}>{todo.text}</li> // Unique, stable ID
      ))}
    </ul>
  );
}

// If no ID exists, create one:
function TodoList({ todos }) {
  const todosWithIds = useMemo(() => 
    todos.map(todo => ({ ...todo, id: todo.id || crypto.randomUUID() }))
  , [todos]);

  return (
    <ul>
      {todosWithIds.map(todo => (
        <li key={todo.id}>{todo.text}</li>
      ))}
    </ul>
  );
}
```

### 23. Use callback props for child-to-parent communication
**Example:**
```jsx
function ParentComponent() {
  const [message, setMessage] = useState('');

  const handleChildMessage = (childMessage) => {
    setMessage(childMessage);
  };

  return (
    <div>
      <p>Message from child: {message}</p>
      <ChildComponent onMessage={handleChildMessage} />
    </div>
  );
}

function ChildComponent({ onMessage }) {
  const handleClick = () => {
    onMessage('Hello from child!');
  };

  return <button onClick={handleClick}>Send Message</button>;
}
```

## Effects & Side Effects

### 24. Use useEffect for side effects only
**Bad:**
```jsx
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  
  // Don't do calculations in useEffect that could be done during render
  useEffect(() => {
    if (user) {
      const fullName = `${user.firstName} ${user.lastName}`;
      setFullName(fullName);
    }
  }, [user]);

  return <div>{fullName}</div>;
}
```

**Good:**
```jsx
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  
  // Side effect - fetching data
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  // Calculation during render
  const fullName = user ? `${user.firstName} ${user.lastName}` : '';

  return <div>{fullName}</div>;
}
```

### 25. Always include dependencies in useEffect
**Bad:**
```jsx
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetchUser(userId).then(setUser); // userId not in dependency array!
  }, []); // Empty dependency array is wrong here

  return <div>{user?.name}</div>;
}
```

**Good:**
```jsx
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]); // Include all dependencies

  return <div>{user?.name}</div>;
}
```

### 26. Clean up effects when necessary
**Bad:**
```jsx
function Timer() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCount(c => c + 1);
    }, 1000);
    // No cleanup - memory leak!
  }, []);

  return <div>{count}</div>;
}
```

**Good:**
```jsx
function Timer() {
  const [count, setCount] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCount(c => c + 1);
    }, 1000);

    // Cleanup function
    return () => clearInterval(interval);
  }, []);

  return <div>{count}</div>;
}
```

### 27. Use multiple useEffect hooks for separation of concerns
**Bad:**
```jsx
function UserDashboard({ userId }) {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    // Multiple unrelated side effects in one useEffect
    fetchUser(userId).then(setUser);
    fetchUserPosts(userId).then(setPosts);
    
    document.title = `User ${userId} Dashboard`;
    
    const handleResize = () => setWindowWidth(window.innerWidth);
    window.addEventListener('resize', handleResize);
    
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, [userId]);
}
```

**Good:**
```jsx
function UserDashboard({ userId }) {
  const [user, setUser] = useState(null);
  const [posts, setPosts] = useState([]);

  // Separate effect for user data
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);

  // Separate effect for posts data
  useEffect(() => {
    fetchUserPosts(userId).then(setPosts);
  }, [userId]);

  // Separate effect for document title
  useEffect(() => {
    document.title = `User ${userId} Dashboard`;
  }, [userId]);

  // Separate effect for window resize
  useEffect(() => {
    const handleResize = () => setWindowWidth(window.innerWidth);
    window.addEventListener('resize', handleResize);
    
    return () => window.removeEventListener('resize', handleResize);
  }, []);
}
```

### 28. Avoid infinite loops in useEffect
**Bad:**
```jsx
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const userData = { id: userId, name: 'John' };
    setUser(userData);
  }, [{ id: userId }]); // Object dependency causes infinite loop!
}
```

**Good:**
```jsx
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const userData = { id: userId, name: 'John' };
    setUser(userData);
  }, [userId]); // Primitive dependency
}

// Or if you need object dependency:
function UserProfile({ userConfig }) {
  const [user, setUser] = useState(null);
  
  // Memoize object dependency
  const stableConfig = useMemo(() => userConfig, [userConfig.id, userConfig.type]);

  useEffect(() => {
    fetchUser(stableConfig).then(setUser);
  }, [stableConfig]);
}
```

### 29. Use useLayoutEffect for DOM measurements
**useEffect example (may cause flicker):**
```jsx
function Tooltip({ children }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const ref = useRef();

  useEffect(() => {
    // This might cause visual flicker
    const rect = ref.current.getBoundingClientRect();
    setPosition({ x: rect.left, y: rect.top });
  });

  return (
    <div ref={ref} style=`{{ left: position.x, top: position.y }}`>
      {children}
    </div>
  );
}
```

**useLayoutEffect example (no flicker):**
```jsx
function Tooltip({ children }) {
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const ref = useRef();

  useLayoutEffect(() => {
    // Runs synchronously before paint
    const rect = ref.current.getBoundingClientRect();
    setPosition({ x: rect.left, y: rect.top });
  });

  return (
    <div ref={ref} style=`{{ left: position.x, top: position.y }}`>
      {children}
    </div>
  );
}
```

## Performance Optimization

### 30. Use React.memo for expensive components
**Example:**
```jsx
// Expensive component that shouldn't re-render unnecessarily
const ExpensiveUserList = React.memo(function UserList({ users, onUserClick }) {
  console.log('UserList rendered'); // Won't log unless users or onUserClick changes
  
  return (
    <div>
      {users.map(user => (
        <div key={user.id} onClick={() => onUserClick(user)}>
          {user.name}
        </div>
      ))}
    </div>
  );
});

function App() {
  const [count, setCount] = useState(0);
  const [users] = useState([/* user data */]);
  
  const handleUserClick = useCallback((user) => {
    console.log('User clicked:', user);
  }, []);

  return (
    <div>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
      {/* UserList won't re-render when count changes */}
      <ExpensiveUserList users={users} onUserClick={handleUserClick} />
    </div>
  );
}
```

### 31. Implement useMemo for expensive calculations
**Bad:**
```jsx
function ProductList({ products, searchTerm }) {
  // Expensive calculation runs on every render
  const filteredProducts = products.filter(product =>
    product.name.toLowerCase().includes(searchTerm.toLowerCase())
  ).sort((a, b) => a.price - b.price);

  return (
    <div>
      {filteredProducts.map(product => (
        <div key={product.id}>{product.name} - ${product.price}</div>
      ))}
    </div>
  );
}
```

**Good:**
```jsx
function ProductList({ products, searchTerm }) {
  // Expensive calculation only runs when dependencies change
  const filteredProducts = useMemo(() => {
    return products
      .filter(product =>
        product.name.toLowerCase().includes(searchTerm.toLowerCase())
      )
      .sort((a, b) => a.price - b.price);
  }, [products, searchTerm]);

  return (
    <div>
      {filteredProducts.map(product => (
        <div key={product.id}>{product.name} - ${product.price}</div>
      ))}
    </div>
  );
}
```

### 32. Use useCallback for function props
**Bad:**
```jsx
function TodoApp() {
  const [todos, setTodos] = useState([]);

  return (
    <div>
      {todos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          // New function created on every render!
          onToggle={() => toggleTodo(todo.id)}
          onDelete={() => deleteTodo(todo.id)}
        />
      ))}
    </div>
  );
}

const TodoItem = React.memo(({ todo, onToggle, onDelete }) => {
  // Component re-renders even when todo hasn't changed
  // because onToggle and onDelete are new functions each time
  return (
    <div>
      <span>{todo.text}</span>
      <button onClick={onToggle}>Toggle</button>
      <button onClick={onDelete}>Delete</button>
    </div>
  );
});
```

**Good:**
```jsx
function TodoApp() {
  const [todos, setTodos] = useState([]);

  const handleToggle = useCallback((id) => {
    setTodos(prev => prev.map(todo => 
      todo.id === id ? { ...todo, completed: !todo.completed } : todo
    ));
  }, []);

  const handleDelete = useCallback((id) => {
    setTodos(prev => prev.filter(todo => todo.id !== id));
  }, []);

  return (
    <div>
      {todos.map(todo => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onToggle={handleToggle}
          onDelete={handleDelete}
        />
      ))}
    </div>
  );
}

const TodoItem = React.memo(({ todo, onToggle, onDelete }) => {
  return (
    <div>
      <span>{todo.text}</span>
      <button onClick={() => onToggle(todo.id)}>Toggle</button>
      <button onClick={() => onDelete(todo.id)}>Delete</button>
    </div>
  );
});
```

### 33. Avoid creating objects and arrays in render
**Bad:**
```jsx
function UserProfile({ user }) {
  return (
    <div>
      {/* New object created on every render */}
      <UserCard user={user} style=`{{ margin: 10, padding: 5 }}` />
      {/* New array created on every render */}
      <UserMenu items={['Profile', 'Settings', 'Logout']} />
    </div>
  );
}
```

**Good:**
```jsx
const cardStyle = { margin: 10, padding: 5 };
const menuItems = ['Profile', 'Settings', 'Logout'];

function UserProfile({ user }) {
  return (
    <div>
      <UserCard user={user} style={cardStyle} />
      <UserMenu items={menuItems} />
    </div>
  );
}

// Or using useMemo for dynamic values:
function UserProfile({ user, isAdmin }) {
  const menuItems = useMemo(() => {
    const items = ['Profile', 'Settings'];
    if (isAdmin) items.push('Admin Panel');
    items.push('Logout');
    return items;
  }, [isAdmin]);

  return (
    <div>
      <UserCard user={user} style={cardStyle} />
      <UserMenu items={menuItems} />
    </div>
  );
}
```

### 34. Use lazy loading with React.lazy
**Example:**
```jsx
import { lazy, Suspense } from 'react';

// Lazy load components
const Dashboard = lazy(() => import('./Dashboard'));
const UserProfile = lazy(() => import('./UserProfile'));
const Settings = lazy(() => import('./Settings'));

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard />;
      case 'profile':
        return <UserProfile />;
      case 'settings':
        return <Settings />;
      default:
        return <Dashboard />;
    }
  };

  return (
    <div>
      <nav>
        <button onClick={() => setActiveTab('dashboard')}>Dashboard</button>
        <button onClick={() => setActiveTab('profile')}>Profile</button>
        <button onClick={() => setActiveTab('settings')}>Settings</button>
      </nav>
      
      <Suspense fallback={<div>Loading...</div>}>
        {renderContent()}
      </Suspense>
    </div>
  );
}
```

### 35. Optimize bundle size
**Bad imports:**
```jsx
import * as _ from 'lodash'; // Imports entire library
import { Button } from '@material-ui/core'; // May import more than needed
```

**Good imports:**
```jsx
import debounce from 'lodash/debounce'; // Import only what you need
import Button from '@material-ui/core/Button'; // Direct import
```

**Webpack Bundle Analyzer usage:**
```bash
npm install --save-dev webpack-bundle-analyzer
# Add to package.json scripts:
"analyze": "npm run build && npx webpack-bundle-analyzer build/static/js/*.js"
```

### 36. Use React DevTools Profiler
**Example profiling session:**
```jsx
function App() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <button onClick={() => setCount(count + 1)}>Count: {count}</button>
      <ExpensiveComponent />
      <AnotherComponent count={count} />
    </div>
  );
}

// In React DevTools:
// 1. Go to Profiler tab
// 2. Click record
// 3. Interact with your app (click the button)
// 4. Stop recording
// 5. Analyze which components rendered and why
```

## Error Handling & Testing

### 37. Implement error boundaries
**Example:**
```jsx
class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    // Log to error reporting service
  }

  render() {
    if (this.state.hasError) {
      return (
        <div>
          <h2>Something went wrong.</h2>
          <details>
            {this.state.error && this.state.error.toString()}
          </details>
        </div>
      );
    }

    return this.props.children;
  }
}

// Usage:
function App() {
  return (
    <ErrorBoundary>
      <Header />
      <ErrorBoundary>
        <UserProfile />
      </ErrorBoundary>
      <ErrorBoundary>
        <PostList />
      </ErrorBoundary>
    </ErrorBoundary>
  );
}

// Modern hook-based error boundary (using react-error-boundary):
import { ErrorBoundary } from 'react-error-boundary';

function ErrorFallback({ error, resetErrorBoundary }) {
  return (
    <div role="alert">
      <h2>Something went wrong:</h2>
      <pre>{error.message}</pre>
      <button onClick={resetErrorBoundary}>Try again</button>
    </div>
  );
}

function App() {
  return (
    <ErrorBoundary
      FallbackComponent={ErrorFallback}
      onError={(error, errorInfo) => {
        console.error('Error:', error, errorInfo);
      }}
    >
      <MyApp />
    </ErrorBoundary>
  );
}
```

### 38. Use try-catch in async functions
**Example:**
```jsx
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        setLoading(true);
        setError(null);
        const userData = await api.getUser(userId);
        setUser(userData);
      } catch (err) {
        console.error('Failed to fetch user:', err);
        setError('Failed to load user data. Please try again.');
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId]);

  const handleSave = async (userData) => {
    try {
      await api.updateUser(userId, userData);
      setUser(userData);
      // Show success message
    } catch (err) {
      console.error('Failed to save user:', err);
      setError('Failed to save changes. Please try again.');
    }
  };

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!user) return <div>User not found</div>;

  return <UserForm user={user} onSave={handleSave} />;
}
```

### 39. Write unit tests for components
**Example with React Testing Library:**
```jsx
// UserCard.test.jsx
import { render, screen, fireEvent } from '@testing-library/react';
import UserCard from './UserCard';

const mockUser = {
  id: 1,
  name: 'John Doe',
  email: 'john@example.com'
};

test('renders user information', () => {
  render(<UserCard user={mockUser} />);
  
  expect(screen.getByText('John Doe')).toBeInTheDocument();
  expect(screen.getByText('john@example.com')).toBeInTheDocument();
});

test('calls onEdit when edit button is clicked', () => {
  const handleEdit = jest.fn();
  render(<UserCard user={mockUser} onEdit={handleEdit} />);
  
  fireEvent.click(screen.getByText('Edit'));
  expect(handleEdit).toHaveBeenCalledWith(mockUser);
});

test('shows loading state', () => {
  render(<UserCard user={null} loading={true} />);
  expect(screen.getByText('Loading...')).toBeInTheDocument();
});
```

### 40. Test user interactions
**Example:**
```jsx
// TodoApp.test.jsx
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import TodoApp from './TodoApp';

test('allows user to add and complete todos', async () => {
  const user = userEvent.setup();
  render(<TodoApp />);

  // Add a new todo
  const input = screen.getByPlaceholderText('Add a todo...');
  const addButton = screen.getByText('Add');

  await user.type(input, 'Buy groceries');
  await user.click(addButton);

  // Check if todo was added
  expect(screen.getByText('Buy groceries')).toBeInTheDocument();

  // Complete the todo
  const checkbox = screen.getByRole('checkbox');
  await user.click(checkbox);

  // Check if todo is marked as completed
  expect(checkbox).toBeChecked();
  expect(screen.getByText('Buy groceries')).toHaveClass('completed');
});

test('allows user to delete todos', async () => {
  const user = userEvent.setup();
  render(<TodoApp initialTodos={[{ id: 1, text: 'Test todo', completed: false }]} />);

  // Delete the todo
  const deleteButton = screen.getByText('Delete');
  await user.click(deleteButton);

  // Check if todo was removed
  expect(screen.queryByText('Test todo')).not.toBeInTheDocument();
});
```

### 41. Mock external dependencies in tests
**Example:**
```jsx
// UserProfile.test.jsx
import { render, screen, waitFor } from '@testing-library/react';
import UserProfile from './UserProfile';
import * as api from '../services/api';

// Mock the API module
jest.mock('../services/api');
const mockedApi = api as jest.Mocked<typeof api>;

test('displays user data when loaded successfully', async () => {
  const mockUser = { id: 1, name: 'John Doe', email: 'john@example.com' };
  mockedApi.getUser.mockResolvedValue(mockUser);

  render(<UserProfile userId={1} />);

  // Wait for the user data to load
  await waitFor(() => {
    expect(screen.getByText('John Doe')).toBeInTheDocument();
  });

  expect(screen.getByText('john@example.com')).toBeInTheDocument();
});

test('displays error message when API call fails', async () => {
  mockedApi.getUser.mockRejectedValue(new Error('API Error'));

  render(<UserProfile userId={1} />);

  await waitFor(() => {
    expect(screen.getByText(/failed to load user data/i)).toBeInTheDocument();
  });
});
```

## Code Quality & Best Practices

### 42. Use consistent naming conventions
**Examples:**
```jsx
// Components: PascalCase
function UserProfile() { }
function ProductCard() { }

// Variables and functions: camelCase
const userName = 'john';
const isLoggedIn = true;
const handleSubmit = () => { };

// Constants: UPPER_SNAKE_CASE
const API_BASE_URL = 'https://api.example.com';
const MAX_RETRY_ATTEMPTS = 3;

// Custom hooks: start with 'use'
function useUser() { }
function useLocalStorage() { }

// Event handlers: start with 'handle'
const handleClick = () => { };
const handleSubmit = () => { };
const handleInputChange = () => { };

// Boolean variables: start with 'is', 'has', 'can', 'should'
const isLoading = false;
const hasPermission = true;
const canEdit = user.role === 'admin';
const shouldShowModal = error !== null;
```

### 43. Avoid inline styles for complex styling
**Bad:**
```jsx
function ProductCard({ product }) {
  return (
    <div 
      style={{
        border: '1px solid #ccc',
        borderRadius: '8px',
        padding: '16px',
        margin: '8px',
        backgroundColor: product.featured ? '#f0f8ff' : 'white',
        boxShadow: product.featured ? '0 4px 8px rgba(0,0,0,0.1)' : 'none',
        transition: 'all 0.3s ease',
        cursor: 'pointer'
      }}
      onMouseEnter={(e) => {
        e.target.style.transform = 'translateY(-2px)';
        e.target.style.boxShadow = '0 6px 12px rgba(0,0,0,0.15)';
      }}
      onMouseLeave={(e) => {
        e.target.style.transform = 'translateY(0)';
        e.target.style.boxShadow = product.featured ? '0 4px 8px rgba(0,0,0,0.1)' : 'none';
      }}
    >
      <h3 style=`{{ color: '#333', marginBottom: '8px' }}`>{product.name}</h3>
      <p style=`{{ color: '#666', fontSize: '14px' }}`>{product.description}</p>
    </div>
  );
}
```

**Good (CSS Modules):**
```jsx
// ProductCard.module.css
.card {
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 16px;
  margin: 8px;
  background-color: white;
  transition: all 0.3s ease;
  cursor: pointer;
}

.card.featured {
  background-color: #f0f8ff;
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 12px rgba(0,0,0,0.15);
}

.title {
  color: #333;
  margin-bottom: 8px;
}

.description {
  color: #666;
  font-size: 14px;
}

// ProductCard.jsx
import styles from './ProductCard.module.css';

function ProductCard({ product }) {
  return (
    <div className={`${styles.card} ${product.featured ? styles.featured : ''}`}>
      <h3 className={styles.title}>{product.name}</h3>
      <p className={styles.description}>{product.description}</p>
    </div>
  );
}
```

**Good (Styled Components):**
```jsx
import styled from 'styled-components';

const Card = styled.div`
  border: 1px solid #ccc;
  border-radius: 8px;
  padding: 16px;
  margin: 8px;
  background-color: ${props => props.featured ? '#f0f8ff' : 'white'};
  box-shadow: ${props => props.featured ? '0 4px 8px rgba(0,0,0,0.1)' : 'none'};
  transition: all 0.3s ease;
  cursor: pointer;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(0,0,0,0.15);
  }
`;

const Title = styled.h3`
  color: #333;
  margin-bottom: 8px;
`;

const Description = styled.p`
  color: #666;
  font-size: 14px;
`;

function ProductCard({ product }) {
  return (
    <Card featured={product.featured}>
      <Title>{product.name}</Title>
      <Description>{product.description}</Description>
    </Card>
  );
}
```

### 44. Keep JSX readable and well-formatted
**Bad:**
```jsx
function UserProfile({user,onEdit,onDelete,isEditing}){
return (<div><div><img src={user.avatar}/><h2>{user.name}</h2><p>{user.email}</p></div><div>{isEditing?<form onSubmit={handleSubmit}><input value={name} onChange={e=>setName(e.target.value)}/><input value={email} onChange={e=>setEmail(e.target.value)}/><button type="submit">Save</button><button type="button" onClick={()=>setIsEditing(false)}>Cancel</button></form>:<div><button onClick={onEdit}>Edit</button><button onClick={onDelete}>Delete</button></div>}</div></div>);}
```

**Good:**
```jsx
function UserProfile({ user, onEdit, onDelete, isEditing }) {
  return (
    <div className="user-profile">
      <div className="user-info">
        <img src={user.avatar} alt={user.name} />
        <h2>{user.name}</h2>
        <p>{user.email}</p>
      </div>
      
      <div className="user-actions">
        {isEditing ? (
          <form onSubmit={handleSubmit}>
            <input 
              value={name} 
              onChange={e => setName(e.target.value)}
              placeholder="Name"
            />
            <input 
              value={email} 
              onChange={e => setEmail(e.target.value)}
              placeholder="Email"
            />
            <button type="submit">Save</button>
            <button 
              type="button" 
              onClick={() => setIsEditing(false)}
            >
              Cancel
            </button>
          </form>
        ) : (
          <div>
            <button onClick={onEdit}>Edit</button>
            <button onClick={onDelete}>Delete</button>
          </div>
        )}
      </div>
    </div>
  );
}
```

### 45. Use fragments to avoid unnecessary DOM nodes
**Bad:**
```jsx
function UserList({ users }) {
  return (
    <div> {/* Unnecessary wrapper div */}
      {users.map(user => (
        <div key={user.id}> {/* Another wrapper div */}
          <UserCard user={user} />
        </div>
      ))}
    </div>
  );
}
```

**Good:**
```jsx
function UserList({ users }) {
  return (
    <>
      {users.map(user => (
        <UserCard key={user.id} user={user} />
      ))}
    </>
  );
}

// Or when you need a key on the fragment:
function UserList({ users }) {
  return (
    <>
      {users.map(user => (
        <React.Fragment key={user.id}>
          <UserCard user={user} />
          <UserStats userId={user.id} />
        </React.Fragment>
      ))}
    </>
  );
}
```

### 46. Avoid mutating state directly
**Bad:**
```jsx
function TodoList() {
  const [todos, setTodos] = useState([]);

  const addTodo = (text) => {
    // Mutating state directly!
    todos.push({ id: Date.now(), text, completed: false });
    setTodos(todos);
  };

  const toggleTodo = (id) => {
    // Mutating nested object!
    const todo = todos.find(t => t.id === id);
    todo.completed = !todo.completed;
    setTodos(todos);
  };

  const updateTodo = (id, updates) => {
    // Mutating array and object!
    const index = todos.findIndex(t => t.id === id);
    todos[index] = { ...todos[index], ...updates };
    setTodos(todos);
  };
}
```

**Good:**
```jsx
function TodoList() {
  const [todos, setTodos] = useState([]);

  const addTodo = (text) => {
    // Create new array
    setTodos(prev => [...prev, { id: Date.now(), text, completed: false }]);
  };

  const toggleTodo = (id) => {
    // Create new array with updated object
    setTodos(prev => prev.map(todo => 
      todo.id === id 
        ? { ...todo, completed: !todo.completed }
        : todo
    ));
  };

  const updateTodo = (id, updates) => {
    // Create new array with updated object
    setTodos(prev => prev.map(todo =>
      todo.id === id
        ? { ...todo, ...updates }
        : todo
    ));
  };

  const deleteTodo = (id) => {
    // Create new array without the item
    setTodos(prev => prev.filter(todo => todo.id !== id));
  };
}
```

### 47. Use ESLint and Prettier
**ESLint configuration (.eslintrc.js):**
```javascript
module.exports = {
  extends: [
    'react-app',
    'react-app/jest',
    '@typescript-eslint/recommended'
  ],
  plugins: ['react-hooks'],
  rules: {
    'react-hooks/rules-of-hooks': 'error',
    'react-hooks/exhaustive-deps': 'warn',
    'no-unused-vars': 'warn',
    'prefer-const': 'error',
    'no-var': 'error'
  }
};
```

**Prettier configuration (.prettierrc):**
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2,
  "useTabs": false
}
```

### 48. Handle loading and error states
**Example:**
```jsx
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchUser = async () => {
      try {
        setLoading(true);
        setError(null);
        const userData = await api.getUser(userId);
        setUser(userData);
      } catch (err) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    };

    fetchUser();
  }, [userId]);

  // Loading state
  if (loading) {
    return (
      <div className="loading-container">
        <div className="spinner" />
        <p>Loading user profile...</p>
      </div>
    );
  }

  // Error state
  if (error) {
    return (
      <div className="error-container">
        <h3>Oops! Something went wrong</h3>
        <p>{error}</p>
        <button onClick={() => window.location.reload()}>
          Try Again
        </button>
      </div>
    );
  }

  // Empty state
  if (!user) {
    return (
      <div className="empty-state">
        <p>User not found</p>
        <button onClick={() => history.goBack()}>
          Go Back
        </button>
      </div>
    );
  }

  // Success state
  return (
    <div className="user-profile">
      <img src={user.avatar} alt={user.name} />
      <h2>{user.name}</h2>
      <p>{user.email}</p>
    </div>
  );
}
```

### 49. Use semantic HTML elements
**Bad:**
```jsx
function BlogPost({ post }) {
  return (
    <div>
      <div>
        <div>{post.title}</div>
        <div>By {post.author} on {post.date}</div>
      </div>
      <div>
        <div dangerouslySetInnerHTML={{ __html: post.content }} />
      </div>
      <div>
        <div>Comments</div>
        <div>
          {post.comments.map(comment => (
            <div key={comment.id}>
              <div>{comment.author}</div>
              <div>{comment.text}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
```

**Good:**
```jsx
function BlogPost({ post }) {
  return (
    <article>
      <header>
        <h1>{post.title}</h1>
        <p>
          By <span>{post.author}</span> on 
          <time dateTime={post.date}>{post.date}</time>
        </p>
      </header>
      
      <main>
        <div dangerouslySetInnerHTML={{ __html: post.content }} />
      </main>
      
      <section>
        <h2>Comments</h2>
        {post.comments.map(comment => (
          <article key={comment.id}>
            <header>
              <h3>{comment.author}</h3>
            </header>
            <p>{comment.text}</p>
          </article>
        ))}
      </section>
    </article>
  );
}
```

### 50. Keep dependencies up to date
**Package.json example:**
```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "scripts": {
    "audit": "npm audit",
    "audit-fix": "npm audit fix",
    "outdated": "npm outdated"
  }
}
```

**Regular maintenance commands:**
```bash
# Check for outdated packages
npm outdated

# Update packages (be careful with major version updates)
npm update

# Check for security vulnerabilities
npm audit

# Fix security vulnerabilities
npm audit fix

# Use tools like npm-check-updates for major version updates
npx npm-check-updates -u
npm install
```

**Example of a dependency update strategy:**
```jsx
// Create a simple component to display package versions
function DependencyInfo() {
  const dependencies = {
    react: require('react/package.json').version,
    'react-dom': require('react-dom/package.json').version,
    // Add other important dependencies
  };

  return (
    <div>
      <h3>Current Dependencies</h3>
      {Object.entries(dependencies).map(([name, version]) => (
        <p key={name}>{name}: {version}</p>
      ))}
    </div>
  );
}
```
These examples demonstrate practical implementations of each rule. Following these patterns will help you write more maintainable, performant, and robust React applications. Remember that some rules may have exceptions depending on your specific use case, but they serve as excellent guidelines for most React development scenarios.

