#!/bin/sh

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
if [ "$#" -lt 2 ]; then
    print_help
    exit 1
fi

# Parse command line options
while getopts "ad:" option; do
    case "$option" in
        a) action="add";;
        d) action="delete";;
        *) echo "Invalid option"; print_help; exit 1;;
    esac
done

# Shift command line arguments to access remaining parameters
shift $((OPTIND - 1))

# Check if action is provided
if [ -z "$action" ]; then
    echo "Error: Action (-a or -d) is mandatory."
    print_help
    exit 1
fi

# Check if external file path is provided
if [ -z "$1" ]; then
    echo "Error: External file path is missing."
    print_help
    exit 1
fi

# Set external file path
external_file_path="$1"

# Check if the file exists
if [ ! -f "$external_file_path" ]; then
    echo "Error: External file does not exist."
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
                
                # Check if the line already exists in the list file
                if ! grep -qF "$modified_line" list.txt; then
                    echo "$modified_line"
                    echo "$modified_line" >> list.txt
                fi
            fi
        done < "$external_file_path"
        ;;
    delete)
        echo "Deleting lines..."
        # Delete the lines provided in the input file
        while IFS= read -r line; do
            if [ -n "$line" ]; then  # Skip empty lines
                sed -i "/^||$line/d" list.txt
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

