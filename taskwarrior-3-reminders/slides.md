---
theme: ../theme.json
author: Cloud Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Taskwarrior Reminders

```bash
~~~just intro_toilet Taskwarrior <--> Reminders

~~~
```

---

## Video Series 📹

```bash
~~~just plantuml videos-progress

~~~
```

---

## Introduction 👋

- Integrate `taskwarrior` with reminders and follow-ups
  > Non-intrusive reminders
  > Use existing tools `cron`

---

## Prerequisites 🛠️

- `tmux`                             *terminal multiplexer*
  > custom bash script triggered via taskopen
- [optional] `taskwarrior-tui`       *tasks command center*
  > TUI written in rust  
- `cron`                             *time-based job scheduler*

---

### Cron 🕒

```bash
~~~just digraph components

~~~
```

---

### Crontab Format 󰾹

```bash
.---------------- minute (0 - 59)
| .-------------- hour (0 - 23)
| | .------------ day of month (1 - 31)
| | | .---------- month (1 - 12) OR jan,feb,mar ...
| | | | .-------- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue ...
| | | | |
* * * * * command to be executed
```

> https://crontab-generator.org/

---

### Basic Commands 🛠️

- crontab -e             *Edit your crontab*
- crontab -l             *List current crontab*
- crontab -r             *Remove your crontab*
- crontab -u username -e *Edit another user's crontab (requires privileges)*

---

## Quick Demo 🚀

```bash
tmux switchc -t demo
```

---

## Reminders Integration 🕒

```bash
~~~just plantuml cron

~~~
```

---

## Under the Hood: Crontab Settings 🛠️

```bash
0 16 *  TZ=CET /home/decoder/dev/dotfiles/scripts/__tasks_followup_notifier.sh 
*/4 * *  /home/decoder/dev/dotfiles/scripts/__tasks_reminders_notifier.sh >> /tmp/script_log.txt 2>&1
```
---

## Under the Hood: Follow-ups 🛠️

```bash
#!/bin/bash
export DISPLAY=:1
# Get the list of task IDs where follow is set to Y
tasks=$(task follow.is:Y _ids)
# Check if the tasks list is not empty
if [ -n "$tasks" ]; then
    # Send the notification
    zenity --info --text "You have follow-up tasks to complete. Please check the task list."
fi
```
---

## Under the Hood: Reminders 🛠️

```bash
#!/bin/bash
export DISPLAY=:1
# Get the current time and the time in one hour
now=$(date +%s)
in_one_hour=$(date -d "+1 hour" +%s)
# Get a list of tasks due today
tasks_due_today=$(task due:today _ids)
# Initialize an empty string to hold tasks due within the next hour
tasks_due_soon=""
for task_id in $tasks_due_today; do
    # Get the due date of the task in epoch time
    task_due_date=$(task get $taskid.due)
    task_due_epoch=$(date -d "$task_due_date" +%s)
    task_description=$(task get $taskid.description)
    # Check if the task is due within the next hour
    if [ "$task_due_epoch" -gt "$now" ] && [ "$task_due_epoch" -le "$in_one_hour" ]; then
        tasks_due_soon+="- $task_id: $task_description\n "
    fi
done
# Check if the tasks_due_soon string is not empty
if [ -n "$tasks_due_soon" ]; then
    # Send the notification
    zenity --info --text "You have tasks due in the next hour:\n $tasks_due_soon"
fi
```
---
## Coming Next 🚀

```bash
~~~just freetext Time Tracking

~~~
```

---

## That's All Folks! 👋

```bash
~~~just intro_toilet That's all folks!

~~~
```

