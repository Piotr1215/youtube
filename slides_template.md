# Replace Me

> One line: what the viewer can do after this video

```bash +exec_replace
echo "Your Title Here" | figlet -f small -w 90
```

<!-- end_slide -->

## Why It Matters

> Which problem does the viewer already have?

```bash +exec_replace
./journey.sh 1
```

<!-- end_slide -->

## Everyday Loop

> One sentence the diagram below proves.

```bash +exec_replace
printf '  \e[36m%s\e[90m%s\e[36m%s\e[90m%s\e[1;33m%s\e[90m%s\e[36m%s\e[0m\n' 'first step' ' ──▶ ' 'second step' ' ──▶ ' 'painful step' ' ──▶ ' 'last step'
printf '  \e[90m%s\e[0m\n' '    ▲                                                   │'
printf '  \e[90m%s\e[0m\n\n' '    └───────────────────────────────────────────────────┘'
printf '\e[33m%s\e[0m\n' 'The painful step, in one yellow line.'
```

<!-- end_slide -->

## First Look

> Show the payoff before explaining it.

```bash +exec
tmux switchc -t demo
```

<!-- end_slide -->

## Basic Concepts

> What does the viewer need to know first?

```bash +exec_replace
./journey.sh 2
```

<!-- end_slide -->

## Concept Name

> One-line definition of the concept.

```bash +exec_replace
printf '  \e[90m%s\e[0m\n' '┌─ history ─────────────────────────'
printf '  \e[90m│\e[0m %s\n' 'older lines, off screen'
printf '  \e[90m%s\e[0m\n' '├─ screen ──────────────────────────'
printf '  \e[90m│\e[0m \e[1;33m%s\e[0m\n' 'the line the viewer cares about'
printf '  \e[90m%s\e[0m\n\n' '└───────────────────────────────────'
printf '\e[32m%s\e[0m\n' '✓ what this concept buys the viewer'
```

<!-- end_slide -->

## The Solution

> What does the tool add?

```bash +exec_replace
./journey.sh 3
```

<!-- end_slide -->

## Existing Options

> The same task, done every available way.

```bash +exec_replace
printf '  \e[31m%s\e[0m\e[36m%s\e[0m%s\n' '✗ ' 'option one     ' 'what it costs the viewer'
printf '  \e[31m%s\e[0m\e[36m%s\e[0m%s\n' '✗ ' 'option two     ' 'what it costs the viewer'
printf '  \e[32m%s\e[0m\e[1;36m%s\e[0m\e[32m%s\e[0m\n' '✓ ' 'this tool      ' 'what it does instead'
```

<!-- end_slide -->

## Pipeline

> PlantUML for sequences, digraph for components, both render as ASCII.

```bash +exec_replace
just plantuml diagram-name
```

<!-- end_slide -->

## Getting Started

> What should the viewer know before trying it?

```bash +exec_replace
./journey.sh 4
```

<!-- end_slide -->

## Install

> Minimum version or the one requirement that matters.

```bash
# the install command the viewer copies
```

<!-- end_slide -->

## Takeaways

```bash +exec_replace
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'so what     ' 'why the viewer should care'
printf '  \e[32m%s\e[0m\e[36m%s\e[0m%s\n' '✓ ' 'now what    ' 'what the viewer already knows that helps'
printf '  \e[1;33m%s\e[0m\e[36m%s\e[0m%s\n' '▶ ' 'then what   ' 'the one action to take next'
```

<!-- end_slide -->

## Resources

```markdown
Project:     https://github.com/Piotr1215/replace-me
Blog post:   https://cloudrumble.net/blog/replace-me
Channel:     youtube.com/@cloud-native-corner
```

<!-- end_slide -->

# That's All Folks! 👋

```bash +exec_replace
just intro_toilet That\'s all folks!
```
