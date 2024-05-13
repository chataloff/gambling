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

echo "Pulling changes from the repository..."
git_pull_with_progress git@github.com:chataloff/gambling.git

# Prompt user for external file path
echo "Please provide the path to the external file:"
read -r external_file_path
echo "External file path: $external_file_path"

# Create a temporary file for editing
tmp_file=$(mktemp)
echo "Temporary file path: $tmp_file"

# Check if the file exists
if [ ! -f "$external_file_path" ]; then
    echo "Error: External file does not exist."
    exit 1
fi

echo "Reading external file..."
# Read external file
while IFS= read -r domain; do
    echo "Processing domain: $domain"
    # Remove matching line from list.txt
    echo "Removing domain $domain from list.txt..."
    sed -i.bak "/||$domain^ #/d" list.txt
done < "$external_file_path"

# Remove backup files created by sed
rm -f list.txt.bak

# Remove duplicate entries from list.txt
echo "Removing duplicate entries from list.txt..."
sed -i.bak -e 'G;:loop' -e '/\n\(.*\)\n\1$/!tend' -e 's/\(.*\)\n\(.*\)\n\1$/\1\n\2/;tloop' -e ':end' -e 's/^\(.*\)\n\(.*\)$/\1/;P;D' list.txt

# Remove backup files created by sed
rm -f list.txt.bak

# Start cleanup 
# Clean up external file
echo "Removing External file..."
#rm "$external_file_path"

# Add changes to Git
echo "Adding changes to Git..."
git add list.txt

# Commit changes with current date as comment
current_date=$(date +"%Y-%m-%d")
echo "Committing changes..."
git commit -m "Updated list.txt to remove entries as of $current_date"

# Push changes to remote repository
echo "Pushing changes to the remote repository..."
git_push_with_progress #origin master

# Show output/progress of git push
echo "Push completed."

