#!/usr/bin/env bash
set -euo pipefail

# Presentation Format Migration Helper
# Converts slides.md to presentation.md format

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

function success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

function warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

function info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

# Check what format a folder uses
function check_format() {
    local folder="$1"

    if [[ ! -d "$folder" ]]; then
        error "Folder does not exist: $folder"
        return 1
    fi

    local has_slides=false
    local has_presentation=false

    [[ -f "$folder/slides.md" ]] && has_slides=true
    [[ -f "$folder/presentation.md" ]] && has_presentation=true

    echo "Format check for: $folder"

    if $has_slides && $has_presentation; then
        warning "Both formats exist (slides.md and presentation.md)"
        echo "  - slides.md: EXISTS"
        echo "  - presentation.md: EXISTS"
        return 2
    elif $has_presentation; then
        success "Using NEW format (presentation.md)"
        return 0
    elif $has_slides; then
        info "Using OLD format (slides.md)"
        return 0
    else
        warning "No presentation files found"
        return 1
    fi
}

# Migrate a single folder
function migrate_presentation() {
    local folder="$1"

    if [[ ! -d "$folder" ]]; then
        error "Folder does not exist: $folder"
        return 1
    fi

    local slides_file="$folder/slides.md"
    local presentation_file="$folder/presentation.md"
    local backup_file="$folder/slides.md.bak"

    # Check if slides.md exists
    if [[ ! -f "$slides_file" ]]; then
        error "No slides.md found in $folder"
        return 1
    fi

    # Check if presentation.md already exists
    if [[ -f "$presentation_file" ]]; then
        error "presentation.md already exists in $folder (already migrated?)"
        return 1
    fi

    # Check if backup already exists
    if [[ -f "$backup_file" ]]; then
        error "Backup file already exists: $backup_file"
        return 1
    fi

    info "Migrating $folder/slides.md to presentation.md..."

    # Create backup
    cp "$slides_file" "$backup_file"
    success "Created backup: $backup_file"

    # Perform migration
    local temp_file
    temp_file=$(mktemp)

    # Process the file
    awk '
    BEGIN {
        in_frontmatter = 0
        frontmatter_count = 0
    }

    # Detect YAML frontmatter
    /^---$/ {
        if (NR == 1) {
            in_frontmatter = 1
            frontmatter_count++
            next
        } else if (in_frontmatter && frontmatter_count == 1) {
            in_frontmatter = 0
            frontmatter_count++
            next
        }
    }

    # Skip frontmatter lines
    in_frontmatter { next }

    # Replace --- slide separators with <!-- end_slide -->
    # But only if they are on their own line and not part of frontmatter
    /^---$/ && !in_frontmatter {
        print "<!-- end_slide -->"
        print ""
        next
    }

    # Update theme references from ../theme.json to theme.json
    /theme: \.\.\/theme\.json/ {
        gsub(/\.\.\/theme\.json/, "theme.json")
    }

    # Print all other lines
    { print }
    ' "$slides_file" > "$temp_file"

    # Move temp file to presentation.md
    mv "$temp_file" "$presentation_file"

    # Copy permissions from original
    chmod --reference="$slides_file" "$presentation_file"

    success "Created $folder/presentation.md"
    info "Original file backed up as slides.md.bak"

    return 0
}

# Show migration status for all videos
function migration_status() {
    local base_dir="${1:-.}"

    echo "Migration Status Report"
    echo "======================"
    echo ""

    local old_format=0
    local new_format=0
    local both_formats=0

    echo "OLD FORMAT (slides.md only):"
    echo "----------------------------"
    while IFS= read -r slides_file; do
        local dir
        dir=$(dirname "$slides_file")
        if [[ ! -f "$dir/presentation.md" ]]; then
            echo "  $dir"
            old_format=$((old_format + 1))
        fi
    done < <(find "$base_dir" -name "slides.md" -type f | sort)

    echo ""
    echo "NEW FORMAT (presentation.md only):"
    echo "----------------------------------"
    while IFS= read -r presentation_file; do
        local dir
        dir=$(dirname "$presentation_file")
        if [[ ! -f "$dir/slides.md" ]]; then
            echo "  $dir"
            new_format=$((new_format + 1))
        fi
    done < <(find "$base_dir" -name "presentation.md" -type f | sort)

    echo ""
    echo "BOTH FORMATS (needs cleanup):"
    echo "------------------------------"
    while IFS= read -r slides_file; do
        local dir
        dir=$(dirname "$slides_file")
        if [[ -f "$dir/presentation.md" ]]; then
            echo "  $dir"
            both_formats=$((both_formats + 1))
        fi
    done < <(find "$base_dir" -name "slides.md" -type f | sort)

    echo ""
    echo "SUMMARY:"
    echo "--------"
    echo "  Old format (slides.md only):     $old_format"
    echo "  New format (presentation.md):    $new_format"
    echo "  Both formats (needs cleanup):    $both_formats"
    echo ""

    if ((old_format > 0)); then
        info "Run 'just migrate-all' to migrate all old format presentations"
    fi

    if ((both_formats > 0)); then
        warning "$both_formats folders have both formats - manual cleanup recommended"
    fi
}

# Migrate all videos
function migrate_all() {
    local base_dir="${1:-.}"

    info "Finding all videos with old format (slides.md)..."

    local count=0
    local success_count=0
    local fail_count=0
    local skip_count=0

    while IFS= read -r slides_file; do
        local dir
        dir=$(dirname "$slides_file")

        # Skip if presentation.md already exists
        if [[ -f "$dir/presentation.md" ]]; then
            warning "Skipping $dir (presentation.md already exists)"
            skip_count=$((skip_count + 1))
            continue
        fi

        count=$((count + 1))
        echo ""
        echo "[$count] Migrating: $dir"

        if migrate_presentation "$dir"; then
            success_count=$((success_count + 1))
        else
            fail_count=$((fail_count + 1))
        fi
    done < <(find "$base_dir" -name "slides.md" -type f | sort)

    echo ""
    echo "Migration Complete!"
    echo "==================="
    echo "  Total processed:  $count"
    echo "  Successful:       $success_count"
    echo "  Failed:           $fail_count"
    echo "  Skipped:          $skip_count"
}

# Main command dispatcher
function main() {
    local command="${1:-}"

    case "$command" in
        check-format)
            if [[ -z "${2:-}" ]]; then
                error "Usage: $0 check-format <folder>"
                exit 1
            fi
            check_format "$2"
            ;;
        migrate)
            if [[ -z "${2:-}" ]]; then
                error "Usage: $0 migrate <folder>"
                exit 1
            fi
            migrate_presentation "$2"
            ;;
        migrate-all)
            migrate_all "${2:-.}"
            ;;
        status)
            migration_status "${2:-.}"
            ;;
        *)
            echo "Usage: $0 {check-format|migrate|migrate-all|status} [args]"
            echo ""
            echo "Commands:"
            echo "  check-format <folder>  - Check which format a folder uses"
            echo "  migrate <folder>       - Migrate a single folder to new format"
            echo "  migrate-all [dir]      - Migrate all folders in directory (default: .)"
            echo "  status [dir]           - Show migration status report (default: .)"
            exit 1
            ;;
    esac
}

main "$@"
