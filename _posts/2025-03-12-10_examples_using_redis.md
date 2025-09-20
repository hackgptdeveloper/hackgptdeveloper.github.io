---
title: "10 examples of coding with Redis using different programming languages and Redis functionalities"
tags:
  - Redis
---

## 1. **Basic Redis Connection (Python)**
```python
import redis

# Connect to Redis
r = redis.Redis(host='localhost', port=6379, decode_responses=True)

# Set and get a key
r.set('name', 'Alice')
print(r.get('name'))  # Output: Alice
```

---

## 2. **Using Redis Hashes (Python)**
```python
r.hset("user:1000", mapping={"name": "Alice", "age": "30", "city": "New York"})
print(r.hgetall("user:1000"))
```

---

## 3. **Redis List Operations (Node.js)**
```javascript
const redis = require('redis');
const client = redis.createClient();

client.rpush('tasks', 'Task1', 'Task2', 'Task3');
client.lrange('tasks', 0, -1, (err, tasks) => {
    console.log(tasks); // ['Task1', 'Task2', 'Task3']
    client.quit();
});
```

---

## 4. **Redis Sets for Unique Values (Go)**
```go
package main

import (
	"fmt"
	"github.com/go-redis/redis/v8"
	"context"
)

func main() {
	ctx := context.Background()
	client := redis.NewClient(&redis.Options{Addr: "localhost:6379"})

	client.SAdd(ctx, "fruits", "apple", "banana", "apple")
	fruits, _ := client.SMembers(ctx, "fruits").Result()
	fmt.Println(fruits) // ["apple", "banana"]
}
```

---

## 5. **Using Redis Sorted Sets (Python)**
```python
r.zadd('leaderboard', {'Alice': 50, 'Bob': 80, 'Charlie': 70})
print(r.zrange('leaderboard', 0, -1, withscores=True))
```

---

## 6. **Using Redis Transactions (Lua Scripting)**
```lua
local key1 = KEYS[1]
local key2 = KEYS[2]

redis.call("SET", key1, "Value1")
redis.call("SET", key2, "Value2")
return redis.call("MGET", key1, key2)
```
Run it in Redis CLI:
```sh
EVAL "return redis.call('SET', KEYS[1], 'Hello')" 1 mykey
```

---

## 7. **Redis Pub/Sub Messaging (Python)**
```python
# Publisher
import redis
r = redis.Redis()
r.publish('news', 'Breaking News!')

# Subscriber
def message_handler(message):
    print(f"Received: {message['data']}")

p = r.pubsub()
p.subscribe(**{'news': message_handler})
p.run_in_thread(sleep_time=0.001)
```

---

## 8. **Redis Streams (Node.js)**
```javascript
const redis = require('redis');
const client = redis.createClient();

client.xadd('mystream', '*', 'user', 'Alice', 'action', 'login');
client.xread('STREAMS', 'mystream', '0', (err, stream) => {
    console.log(stream);
});
```

---

## 9. **Redis Bitmaps for Counting (Python)**
```python
r.setbit('active_users', 10, 1)
r.setbit('active_users', 20, 1)
print(r.bitcount('active_users'))  # Output: 2
```

---

## 10. **Using Redis with Flask as a Rate Limiter (Python)**
```python
from flask import Flask, request
import redis

app = Flask(__name__)
r = redis.Redis()

@app.route('/')
def home():
    ip = request.remote_addr
    if r.incr(ip) > 10:
        return "Rate limit exceeded", 429
    r.expire(ip, 60)
    return "Hello, World!"

if __name__ == '__main__':
    app.run()
```

---
