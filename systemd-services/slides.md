---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM, YYYY
paging: Slide %d / %d
---

# Building Notification Systems with Systemd 🔔

```bash
~~~just intro_toilet Systemd Services

~~~
```

---

## What We'll Build Today 🎯

A GitHub Issue Notification System that:
- Polls for new issues every hour
- Sends desktop notifications
- Runs as a user service
- Uses systemd best practices

---

## The Notification Script 📝

```bash
../wpane ./__get_github_issues.sh
```

---

## Service File Anatomy ⚙️

```ini
[Unit]
Description=GitHub Issues Notification Service
After=network-online.target

[Service]
Type=oneshot
Environment=DISPLAY=:1
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus
ExecStart=/home/decoder/dev/youtube/systemd-services/__get_github_issues.sh

[Install]
WantedBy=default.target
```

---

## Timer Configuration ⏰

```ini
[Unit]
Description=Check GitHub Issues Hourly

[Timer]
OnStartupSec=1min       ; Initial delay after boot
OnUnitActiveSec=1h      ; Repeat interval after each run
AccuracySec=1min        ; Timer precision target

[Install]
WantedBy=timers.target
```

---

## Run the service 🏃

> User services are managed by `systemctl --user` and are located in `~/.config/systemd/user/`

```bash
systemctl --user enable service-name.service
systemctl --user start service-name.service
systemctl --user status service-name.service
systemctl --user daemon-reload # when service file changes
```

---

## Service Lifecycle 🔄

> service-name.service and service-name.timer
> `service-name` must match in both cases

```bash
~~~just plantuml service-lifecycle

~~~
```

---

## Best Practices 💡

- Use `Type=oneshot` for scripts
- Test manually before enabling timer by `systemctl --user start service-name.service`
- Use `%h` or absolute path for home directory paths
- Keep scripts focused and simple

---

## Resources 🚚

Resources:
- `man systemd.service`
- `man systemd.timer`
- `systemctl --user --help`

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```
