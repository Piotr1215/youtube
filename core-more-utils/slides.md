---
theme: ./theme.json
author: Cloud-Native Corner
date: MMMM dd, YYYY
paging: Slide %d / %d
---

# Coreutils & Moreutils

```bash
~~~./intro.sh

~~~
```

---

## What are Coreutils?

- 🛠️ Essential command-line utilities in Unix-like operating systems
- 🗂️ Provide basic file, shell, and text manipulation capabilities
- 🐧 Core components of the GNU operating system
- 📦 Available on most Linux distributions by default

```bash
tmux switchc -t coreutils
```

---

## The swiss army knife of coreutils

- `sed`: Stream editor for filtering and transforming text
- `awk`: Pattern scanning and text processing language
- `grep`: Search a file for a pattern, match lines that match pattern

---

## When Coreutils Are Not Enough

Enter `moreutils`:

- 📚 A collection of additional Unix utilities
- 🔧 Fills gaps in the capabilities of coreutils
- ⚙️ Provides more specialized and powerful tools

---

## Moreutils

- `chronic`: runs a command quietly unless it fails
- `combine`: combine the lines in two files using boolean operations
- `errno`: look up errno names and descriptions
- `ifdata`: get network interface info without parsing ifconfig output
- `ifne`: run a program if the standard input is not empty
---
- `isutf9`: check if a file or standard input is utf-8
- `lckdo`: execute a program with a lock held
- `mispipe`: pipe two commands, returning the exit status of the first
- `parallel`: run multiple jobs at once
- `pee`: tee standard input to pipes
---
- `sponge`: soak up standard input and write to a file
- `ts`: timestamp standard input
- `vidir`: edit a directory in your text editor
- `vipe`: insert a text editor into a pipe
- `zrun`: automatically uncompress arguments to command

---

## Moreutils: Available Everywhere

- **Cross-Platform**: Linux, macOS, BSD, also Windows with WSL
- **Package Managers**: APT, Homebrew, DNF, Pacman
- **Widely Supported**: Included in major repos
- **Flexible Usage**: Servers, desktops, containers

---

## The Origins of Moreutils

- **Created by**: Joey Hess
- **First Released**: 2007
- **Purpose**: Extend Coreutils
- **Community-Driven**: Open-source contributions

---

## Commands Operations Basics

- Pipe operator `|`: Send output of one command as input to another
- Command substitution `$()`: Use output of a command as argument for another
- Logical operators `&&` and `||`: Conditional execution of commands

---

## Combine Lines in Two Files Using Boolean Operations

`combine` allows you to merge two files line by line using boolean operations like AND, OR, and XOR.

### Example: Find Common Lines (AND Operation)

```bash
combine file1.txt and file2.txt
```
---

### Let's run the example

```bash
tmux switchc -t combine
```


---

## Run a Program If the Standard Input Is Not Empty

`ifne` executes a command only if the previous command produces output.

### Example: Compress a Log File Only If It's Not Empty

```
~~~bat ./web_access.log

~~~
```

`grep "POST" web_access.log | ifne tee post.access`

- Create post.access file if any POST calls detected

---

### Let's see the example

```bash
tmux switchc -t ifne
```
---

## Run Multiple Jobs at Once

`parallel` runs commands concurrently, utilizing multiple CPU cores.

### Example: Run load tests against an endpoint

`curl -s -o /dev/null -w "Request $i: %{http_code}\n" https://example.com >>"$LOG_FILE"`

```bash
echo "Nr of processors on my machine is $(nproc --all)"
```
---

### Let's run the example

```bash
tmux switchc -t parallel
```

---


## Tee Standard Input to Multiple Commands

`pee` allows you to send standard input to multiple commands simultaneously.
Each command receives a copy of `stdin`

### Example: Output multiple greps

`cat web_access.log | pee 'grep POST ' 'grep GET ' 'grep 404 '`

- Grep in file without the need to multiple grep

---

### Let's see an example

```bash
tmux switchc -t pee
```

---

## Soak Up Standard Input and Write to a File

`sponge` reads all input before writing to the file, preventing the overwriting of files that are being read.

### Example: Sort a File In-Place

```bash
sort numbers.txt | sponge numbers.txt
```

- Sorts `numbers.txt` and saves the sorted result back into the same file.

---

### Let's see an example

```bash
tmux swichc -t sponge
```

---

## Timestamp Standard Input

`ts` prepends a timestamp to each line of input.

### Example: Add Timestamps to Log Output

```bash
head -n 5 ./log.txt | ts
```

- Adds a timestamp to each line of the system output

---

## Edit a Directory in Your Text Editor

`vidir` lets you edit file names within a directory using a text editor.

### Example: Batch Rename Files

```bash
vidir ./
```

- Opens all file names in the current directory in `$EDITOR` for quick renaming.

> in Neovim plugins like `oil.nvim` or `mini.files` provide much more extended
> functionally

---

### Let's see an example

```bash
tmux switchc -t vidir
```

---

## Insert a Text Editor into a Pipe

`vipe` allows you to manually edit the content of a pipeline using your preferred text editor.

### Example: Alter grep output and capture it in a new file

```bash
grep "POST" web_access.log | vipe --suffix=markdown | tee modified.log
```

---

### Let's see an example

```bash
tmux switchc -t vipe
```

---

## Resources for Further Learning

- GNU Coreutils Documentation: https://www.gnu.org/software/coreutils/manual/
- Linux Command Line and Shell Scripting Bible
- The Art of Command Line: https://github.com/jlevy/the-art-of-command-line
- moreutils: https://joeyh.name/code/moreutils/

---

```bash
../thats_all_folks
```
