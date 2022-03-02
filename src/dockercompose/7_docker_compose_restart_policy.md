# Restart Policy

---

- `restart` property accepts the same values we learned before.
    - on-failure
    - unless-stopped
    - always
    - none

```yaml
version: '3'
services:
  myApp:
...
    restart: on-failure
... 
```