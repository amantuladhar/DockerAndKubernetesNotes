# Health Check

---

## healthcheck
- We also have healthcheck property if we want to override the healthcheck of Image.
- Like HEALTHCHECK instruction, we can provide different option to configure our healthcheck
  - interval
  - timeout
  - retries
  - start_period

```yaml
version: '3'
services:
  myApp:
...
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/test"]
      interval: 10s
      timeout: 5s
      retries: 3
      start_period: 20s
```
