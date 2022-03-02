# Docker Compose Logs

---
## Accessing logs

- If you run the app using `-d` option, you won't see the outputs (logs) on the screen.
- If you want to access them or see them, you use `docker-compose logs @option @service` command.
- If you run `docker-compose logs` it will show you all the logs for all `services`, but it won't show you new ones.
- If you want to follow the logs in realtime you use `-f` option. `docker-compose logs -f`.
- If you have multiple services, and you want to see logs for only single service, you can use: `docker-compose logs @options @serviceName` syntax.