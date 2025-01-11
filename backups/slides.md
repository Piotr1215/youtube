---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM, YYYY
paging: Slide %d / %d
---

# Terminal Backup Strategies 💾

```bash
~~~just intro_toilet Terminal Backup

~~~
```

---

## Golden Rule of Backups


3-2-1 Rule

> 3 Copies (1 original 2 copies)
> 2 Media Types
> 1 Offsite Copy

---

## What to Back Up 📦

```bash
Types of Data/
├── Data Files/
│   ├── Documents/
│   ├── Media/
│   └── Databases/
│
├── System/
│   ├── Package Lists/
│   └── Installed Software/
│
├── Configuration/
│   ├── Dotfiles/
│   ├── App Settings/
│   └── Crontabs/
│
└── Secrets/
    ├── SSH Keys/
    ├── Certificates/
    └── Tokens/
```

---

## Backup Targets 🎯

- Local Disk
- NAS or Plex
- USB Drive
- Cloud Storage

---

## Terminal Tool 🔧

```bash
🔒 restic  [enc]-->[dedup]-->[backup]
           |---------------------|
           🔐 Encrypted Storage 🗄️

🔄 rsync   [src]====>[dest]
           |-> Fast Delta Sync
           📂 ➜ 📂

☁️  rclone  [local]==>[cloud]
           |-> Dropbox, Azure Cloud, S3 Bucket etc
           🌐 Multi-cloud 🌐

⏰ cron    [time]-->[task]-->[run]
           0 2 * * * backup.sh
           📅 Scheduled Jobs ⚡
```

---

## Backups Demo

```bash
tmux switchc -t demo
```

### Restic

- [x] creating repository
- [x] adding folder with files
- [x] restoring snapshot 

### Rsync

- [x] syncing local directories
- [x] incremental backups

### Rclone

- [x] configuring cloud storage provider
- [x] syncing local files to cloud storage

---

## Backup Script

```bash
../npane ~/dev/dotfiles/scripts/__backup.sh 
```
---

## Best Practices 📋

- Test First:      *Verify backup process in safe environment*
- Restore:         *Regular restore verification*
- Version Control: *Backup your backup scripts*
- Encryption:      *Always encrypt sensitive data*

---

## Resources 🧰

- `man restic`:      *Full restic documentation*
- `rclone.org`:      *Comprehensive rclone guide*
- `rsync.samba.org`: *Rsync user manual*
- `crontab.guru`:    *Cron schedule builder**

---

# That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```
