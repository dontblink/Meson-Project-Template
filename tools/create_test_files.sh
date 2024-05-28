#!/bin/bash

# Function to create test directories and files
create_test_files() {
    local source_dir="$1"
    local test_dir="$2"
    local exclude_dirs=("${@:3}")

    # Create test directory if it doesn't exist
    mkdir -p "$test_dir"

    # Loop through files in source directory
    while IFS= read -r -d '' file; do
        # Get the directory of the file
        file_dir=$(dirname "$file")

        # Check if the file directory is excluded
        excluded=false
        for exclude_dir in "${exclude_dirs[@]}"; do
            if [[ "$file_dir" == *"$exclude_dir"* ]]; then
                excluded=true
                break
            fi
        done

        if [ "$excluded" = false ]; then
            # Remove the source directory path from the file path
            relative_path=${file#$source_dir/}

            # Create corresponding directory structure in test directory
            mkdir -p "$test_dir/$(dirname "$relative_path")"

            # Generate new file name with "test_" prefix
            new_file="$test_dir/$(dirname "$relative_path")/test_$(basename "$file")"

            # Create new file with "test_" prefix
            touch "$new_file"
            echo "Created new file: $new_file"
        fi
    done < <(find "$source_dir" -type f -name "*.c" -print0)
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
    exclude_dirs=()
else
    # Create array of excluded directories
    exclude_dirs=("$@")
    echo "Excluding directories: ${exclude_dirs[*]}"
fi

# Create test directories and files
create_test_files "$source_dir" "$test_dir" "${exclude_dirs[@]}"
