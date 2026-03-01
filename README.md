# Doors XP

*A Cook, Serve, Delicious-style typing game set on a Windows XP desktop.*

![Login Screen](docs/images/01_login.png)

You're the new IT worker. Tasks flood your taskbar — emails to read, documents to print, viruses to quarantine, hard drives to defrag. Press the right keys in the right order, keep your boss happy, and survive your shift.

Built with **Godot 4.6** (GDScript). All UI drawn programmatically — no sprite assets needed.

---

## How It Plays

![Desktop with Bliss wallpaper and taskbar](docs/images/02_desktop_idle.png)

Tasks spawn on your taskbar throughout the day. Press **1-8** to open a task, then follow the key prompts to complete it step by step.

![Reading an email in Outlook Express](docs/images/03_read_email.png)

Each task type has its own visual — Outlook Express for emails, a Word doc for printing, a Security Alert for viruses. Every step shows you which key to press next.

![Print Document - opening a Word file](docs/images/04_print_doc.png)

Some steps are timed waits: the printer needs to spool, the antivirus needs to scan, the defrag needs to run. You can't rush the machine.

![Print spooler at 57%](docs/images/05_spooling.png)

Complete tasks in a row to build your combo multiplier. Perfect runs (zero mistakes) earn a 1.5x bonus.

![Combo x3, Score 712](docs/images/07_combo_score.png)

---

## 7 Task Types

| Task | Difficulty | What You're Doing |
|------|-----------|-------------------|
| **Read Email** | Easy | Open Outlook Express, read, reply, send |
| **Print Document** | Easy | Open doc, File > Print, select printer, wait for spooler |
| **Organize Files** | Easy | Open Explorer, select all, cut, paste, confirm |
| **Virus Alert** | Medium | Acknowledge threat, open antivirus, scan, quarantine, delete |
| **Install Software** | Medium | Insert CD, run setup, accept EULA, install, reboot |
| **Defrag HDD** | Medium | Open My Computer, right-click, defrag, wait, done |
| **Blue Screen Fix** | Hard | The big one. Long sequence, long waits, high reward |

![Virus Alert - THREAT DETECTED!](docs/images/06_virus_alert.png)

![Install Software - Insert the installation disc](docs/images/08_install_software.png)

![Defrag HDD - My Computer with C: D: A: drives](docs/images/09_defrag.png)

---

## Shift Structure

Each work day is **6 minutes**. Tasks spawn faster as the day goes on, with a rush hour in the middle third. After each shift, a summary shows your stats.

![Day 1 Shift Complete - 12 tasks completed, score 1912](docs/images/10_day_summary.png)

Difficulty scales across days: more tasks, shorter timers, harder task types unlocked. Day 1 caps at 4 simultaneous tasks. By Day 3+, you're juggling 8.

Let your reputation drop too low and...

![BSOD - IRQL_REPUTATION_NOT_SUFFICIENT](docs/images/11_bsod.png)

---

## Scoring

| Mechanic | Details |
|----------|---------|
| Base score | 80-250 points per task (harder = more) |
| Combo | +0.25x per consecutive completion, resets on fail |
| Perfect bonus | 1.5x multiplier for zero-mistake tasks |
| Reputation | Starts at 50/100, game over at 10 or below |

## Running

Open the project in **Godot 4.6** and run the main scene (`scenes/main_menu.tscn`).

## License

All rights reserved. VollkornGames.
