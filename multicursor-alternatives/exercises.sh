#!/usr/bin/env bash

# Multicursor Alternatives - Exercise Runner
# Uses costam as working file, compares to .solution files

EXERCISES_DIR="exercises"
WORK_FILE="costam"

if [ ! -d "$EXERCISES_DIR" ]; then
    echo "Error: exercises/ directory not found"
    exit 1
fi

# Get all .before files (paired with .solution)
before_files=($(ls "$EXERCISES_DIR"/*.before 2>/dev/null | sort))

if [ ${#before_files[@]} -eq 0 ]; then
    echo "No exercises found in $EXERCISES_DIR/"
    exit 1
fi

total=${#before_files[@]}
current=1

trap "echo 'Exiting...'; exit 0" SIGINT

show_result() {
    clear
    local base="${before_file%.before}"
    local name=$(basename "$base")
    local solution="${base}.solution"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Exercise $current of $total: $name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Edit: $WORK_FILE"
    echo "Goal: Match $solution"
    echo ""

    if diff -q "$WORK_FILE" "$solution" >/dev/null 2>&1; then
        echo 'SUCCESS!' | figlet -f small | lolcat 2>/dev/null || echo '=== SUCCESS ==='
        echo ""
        echo "Exercise \"$name\" completed!"
        sleep 1
        return 1  # Signal auto-advance
    else
        echo "--- Current vs Solution ---"
        diff -u "$WORK_FILE" "$solution" | diff-so-fancy 2>/dev/null || diff -u "$WORK_FILE" "$solution"
    fi

    echo ""
    echo "Press n=next, p=prev, r=reset, Ctrl+C=quit"
}

while true; do
    if [ $current -gt $total ]; then
        echo "No more exercises."
        break
    elif [ $current -lt 1 ]; then
        current=1
    fi

    before_file="${before_files[$current - 1]}"
    base="${before_file%.before}"
    solution="${base}.solution"

    if [ ! -f "$solution" ]; then
        echo "Warning: No solution for $(basename "$base"), skipping"
        ((current++))
        continue
    fi

    # Always copy .before to working file when starting an exercise
    cp "$before_file" "$WORK_FILE"

    show_result
    if [ $? -eq 1 ]; then
        # Auto-advance on success
        ((current++))
        if [ $current -le $total ]; then
            cp "${before_files[$current - 1]}" "$WORK_FILE" 2>/dev/null || true
        fi
        continue
    fi

    inotifywait -qe modify "$WORK_FILE" &
    inotify_pid=$!

    while true; do
        read -t 0.1 -n 1 key

        if [ "$key" = 'n' ]; then
            ((current++))
            cp "${before_files[$current - 1]}" "$WORK_FILE" 2>/dev/null || true
            break
        elif [ "$key" = 'p' ]; then
            ((current--))
            if [ $current -ge 1 ]; then
                cp "${before_files[$current - 1]}" "$WORK_FILE" 2>/dev/null || true
            fi
            break
        elif [ "$key" = 'r' ]; then
            cp "$before_file" "$WORK_FILE"
            show_result
            if [ $? -eq 1 ]; then
                ((current++))
                if [ $current -le $total ]; then
                    cp "${before_files[$current - 1]}" "$WORK_FILE" 2>/dev/null || true
                fi
                break
            fi
            inotifywait -qe modify "$WORK_FILE" &
            inotify_pid=$!
        fi

        # Check if file modified
        if ! kill -0 $inotify_pid 2>/dev/null; then
            show_result
            if [ $? -eq 1 ]; then
                ((current++))
                if [ $current -le $total ]; then
                    cp "${before_files[$current - 1]}" "$WORK_FILE" 2>/dev/null || true
                fi
                break
            fi
            inotifywait -qe modify "$WORK_FILE" &
            inotify_pid=$!
        fi
    done

    kill $inotify_pid 2>/dev/null || true
done

clear
echo "ALL DONE!" | figlet -f small | lolcat 2>/dev/null || echo "=== ALL DONE ==="
