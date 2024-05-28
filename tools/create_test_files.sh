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

        # Check if the file directory or any parent directory is excluded
        excluded=false
        for exclude_dir in "${exclude_dirs[@]}"; do
            # Ensure the excluded directory is within the source directory
            if [[ "$file_dir" == "$source_dir/$exclude_dir" || "$file_dir" == "$source_dir/$exclude_dir"/* ]]; then
                excluded=true
                break
            fi
        done

        # Continue with processing if not excluded
        if [ "$excluded" = false ]; then
            # Remove the source directory path from the file path
            relative_path=${file#$source_dir/}

            # Check if the file should be excluded by filename
            filename=$(basename "$file")
            if [[ " ${exclude_files[@]} " =~ " $filename " ]]; then
                echo "Excluding file: $filename"
                continue
            fi

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
    echo "Usage: $0 <source_dir> <test_dir> [-d <exclude_dir1> <exclude_dir2> ...] [-f <exclude_file1> <exclude_file2> ...]"
    exit 1
fi

source_dir="$1"
test_dir="$2"
shift 2

exclude_dirs=()
exclude_files=()

# Parse optional arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d) 
            shift
            while [ $# -gt 0 ] && [[ ! "$1" =~ ^- ]]; do
                dir="$1"
                # Ensure the excluded directory is within the source directory
                if [ ! -d "$source_dir/$dir" ]; then
                    echo "Directory $dir does not exist within $source_dir."
                    exit 1
                fi
                exclude_dirs+=("$dir")
                shift
            done
            ;;
        -f) 
            shift
            while [ $# -gt 0 ] && [[ ! "$1" =~ ^- ]]; do
                exclude_files+=("$1")
                shift
            done
            ;;
        *)
            echo "Invalid option: $1" >&2
            exit 1
            ;;
    esac
done

# Create test directories and files
create_test_files "$source_dir" "$test_dir" "${exclude_dirs[@]}"
