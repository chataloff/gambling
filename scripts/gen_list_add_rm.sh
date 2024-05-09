#!/usr/local/bin/bash

# ANSI color codes
RED="\[\033[0;31m\]"
NC="\[\033[0m\]" # No Color

# Function to show progress during git pull
git_pull_with_progress() {
    git pull "$@" | while read -r line; do
        echo "$line"
        echo "Pulling..."
    done
}

# Function to show progress during git push
git_push_with_progress() {
    git push "$@" | while read -r line; do
        echo "$line"
        echo "Pushing..."
    done
}

# Print help message
print_help() {
    echo "Usage: $0 [-a] [-d] <external_file_path>"
    echo "Options:"
    echo "  -a       Add entries"
    echo "  -d       Delete entries"
    echo "  <external_file_path>  Path to the external file"
}

# Check if any command-line arguments are provided
if [ "$#" -eq 0 ]; then
    print_help
    exit 0
fi

# Parse command line options
while getopts "ad:" option; do
    case "$option" in
        a) action="add";;
        d) action="delete";;
        *) echo "'$RED'Invalid option'$NC'"; print_help; exit 1;;
    esac
done

# Shift command line arguments to access remaining parameters
shift $((OPTIND - 1))

# Prompt user for external file path
echo "Please provide the path to the external file:"
read -r external_file_path

# Check if the file exists
if [ ! -f "$external_file_path" ]; then
    echo "${RED}Error: External file does not exist.${NC}"
    exit 1
fi

# Add or delete lines based on the provided action
case "$action" in
    add)
        # Add the lines from the input file
        while IFS= read -r line; do
            if [ -n "$line" ]; then  # Skip empty lines
                # Modify the line
                modified_line=$(echo "$line" | sed -e 's/.*www.//' -e 's/.*WWW.//' -e 's~http[s]*://~~g' -e 's~HTTP[S]*://~~g' -e 's/\/.*//g' -e 's/^/||/')"^"
                
                # Insert current date
                current_date=$(date +"%Y-%m-%d")
                modified_line="$modified_line  #$current_date"
                
                echo "$modified_line"
                echo "$modified_line" >> list.txt
            fi
        done < "$external_file_path"
        ;;
    delete)
        # Delete the lines provided in the input file
        while IFS= read -r line; do
            if [ -n "$line" ]; then  # Skip empty lines
                sed -i "/$line/d" list.txt
            fi
        done < "$external_file_path"
        ;;
esac

# Remove duplicates
awk '!seen[$0]++' "list.txt" > tmp_list.txt && mv tmp_list.txt list.txt

# Start cleanup 
# Clean up external file
echo "Removing External file..."
rm "$external_file_path"

# Add changes to Git
git add list.txt

# Commit changes with current date as comment
current_date=$(date +"%Y-%m-%d")
git commit -m "Updated data as of $current_date"

# Push changes to remote repository
git_push_with_progress #origin master

# Show output/progress of git push
echo "Push completed."

