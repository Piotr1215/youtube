#!/usr/bin/env -S just --justfile

# Variables will be overriden by the prepare recipe
presentation_title               := "Change Title"
demo_title                       := "Let's talk"
free_text                        := "Free text"
replace                          := if os() == "linux" { "sed -i"} else { "sed -i '' -e" }
diagrams                         := invocation_directory() + "/diagrams"


# show all the justfile recipes
default:
  @just --list

# run graphasy diagram
plantuml diagram:
  #!/usr/bin/env bash  
  export diagram="{{diagram}}"
  if command -v plantuml &>/dev/null; then
          java -jar /usr/local/bin/plantuml.jar {{diagrams}}/"$diagram".puml -utxt
          mv {{diagrams}}/"$diagram".utxt /tmp/"$diagram".utxt
          cat /tmp/"$diagram".utxt
  else
          echo " "
  fi

# run graphasy diagram
digraph diagram:
  #!/usr/bin/env bash  
  export diagram="{{diagram}}"
  if command -v graph-easy &>/dev/null; then
          graph-easy {{diagrams}}/"$diagram".dot --as=boxart > {{diagrams}}/"$diagram".txt
          cat {{diagrams}}/"$diagram".txt
  else
          echo " "
  fi


# run the presentation
present: 
  @cd {{invocation_directory()}}; slides slides.md

# show freetext
freetext *free_text:
  #!/usr/bin/env bash
  export title="{{free_text}}"
  if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
      echo "$title" | figlet -f pagga | boxes -d peek
  else
      echo "$title"
  fi

# show ending ascii
demo *demo_title:
  #!/usr/bin/env bash
  export title="{{demo_title}}"
  if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
      echo "$title" | figlet -f pagga | boxes -d peek
  else
      echo "$title"
  fi

# show intro ascii using figlet
intro *pres_title:
  #!/usr/bin/env bash
  export title="{{pres_title}}"

  if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
    echo "$title" | figlet -f future | boxes -d peek
  else
    echo "$title"
  fi

# show intro ascii using toilet
intro_toilet *pres_title:
  #!/usr/bin/env bash
  export title="{{pres_title}}"
  if command -v toilet &>/dev/null && command -v boxes &>/dev/null; then
    echo "$title" | toilet -f mono9 -w 200 --filter border
  else
    echo "$title"
  fi