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

# Pull changes from the repository with progress
git_pull_with_progress git@github.com:chataloff/gambling.git

# Prompt user for external file path
echo "Please provide the path to the external file:"
read -r external_file_path

# Create a temporary file for editing
tmp_file=$(mktemp)

# Check if the file exists
if [ ! -f "$external_file_path" ]; then
    echo "Error: External file does not exist."
    exit 1
fi

# Read external file
while IFS= read -r domain; do
    # Remove matching line from link.txt
    awk -v domain="$domain" '!index($0, "||" domain "^ #")' link.txt > "$tmp_file" && mv "$tmp_file" link.txt
done < "$external_file_path"

# Start cleanup 
# Clean up external file
echo "Removing External file..."
#rm "$external_file_path"

# Add changes to Git
git add link.txt

# Commit changes with current date as comment
current_date=$(date +"%Y-%m-%d")
git commit -m "Updated link.txt to remove entries as of $current_date"

# Push changes to remote repository
git_push_with_progress #origin master

# Show output/progress of git push
echo "Push completed."
