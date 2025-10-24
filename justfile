#!/usr/bin/env -S just --justfile

# Variables will be overriden by the prepare recipe
replace                          := if os() == "linux" { "sed -i"} else { "sed -i '' -e" }
diagrams                         := invocation_directory() + "/diagrams"


# show all the justfile recipes
default:
  @just --list

# list all youtbube videos
list_videos:
  /home/decoder/dev/dotfiles/scripts/__get_youtube_videos.py --date

# crate tmux demo sesison
tmux_demo:
  tmux new-session -d -s demo

# start a new folder with template structure
start folder_name title="":
  #!/usr/bin/env bash
  mkdir -p "{{folder_name}}/diagrams"
  
  cp slides_template.md "{{folder_name}}/presentation.md"
  chmod +x "{{folder_name}}/presentation.md"
  
  # Replace title if provided
  if [ -n "{{title}}" ]; then
    sed -i 's/Replace Me/{{title}}/g' "{{folder_name}}/presentation.md"
  fi
  
  echo "Created new folder structure in: {{folder_name}}"
  cd "{{folder_name}}"

# run plantuml diagram
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
  @cd {{invocation_directory()}}; KUBECONFIG=/home/decoder/dev/homelab/kubeconfig presenterm -Xx presentation.md

# show freetext
freetext *free_text:
  #!/usr/bin/env bash
  export title="{{free_text}}"
  if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
      echo "$title" | figlet -f pagga -w 200 | boxes -d peek
  else
      echo "$title"
  fi

# show intro ascii using figlet
intro *pres_title:
  #!/usr/bin/env bash
  export title="{{pres_title}}"

  if command -v figlet &>/dev/null && command -v boxes &>/dev/null; then
    echo "$title" | figlet -f future -w 200 | boxes -d peek
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
