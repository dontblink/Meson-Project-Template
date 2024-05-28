#!/bin/bash

# Function to exclude specified directories and files
exclude_items() {
    local source_dir="$1"
    shift
    local excludes=("$@")

    # Prepare the exclusion pattern
    local exclusion_pattern=""
    for exclude in "${excludes[@]}"; do
        exclusion_pattern+=" ! -path '*$exclude*' "
    done

    # Find files and directories excluding specified ones
    find "$source_dir" -type f $exclusion_pattern -print
}

# Function to create test directories and files
create_test_files() {
    local source_dir="$1"
    local test_dir="$2"

    # Create test directory if it doesn't exist
    mkdir -p "$test_dir"

    # Loop through files in source directory
    while IFS= read -r file; do
        if [ -d "$file" ]; then
            # If it's a directory, create corresponding directory in test directory
            subdir="${file#$source_dir}"
            mkdir -p "$test_dir$subdir"
        elif [[ "$file" == *.c ]]; then
            # If it's a .c file, create a test file with test_ prefix
            filename=$(basename "$file")
            cp "$file" "$test_dir/test_$filename"
        fi
    done < <(exclude_items "$source_dir" "${excludes[@]}")
}

# Main script

# Check for correct number of arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <source_dir> <test_dir> [exclude1] [exclude2] ..."
    exit 1
fi

source_dir="$1"
test_dir="$2"

# Shift the first two arguments
shift 2

# Check if any excludes were provided
if [ "$#" -eq 0 ]; then
    echo "No excludes provided. Proceeding without exclusions."
    excludes=()
else
    # Create array of excluded items
    excludes=("$@")
fi

# Create test directories and files
create_test_files "$source_dir" "$test_dir"
