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

# Check if the file exists
if [ ! -f "$external_file_path" ]; then
    echo "Error: External file does not exist."
    exit 1
fi

# Modify the content of the source file and remove empty lines
while IFS= read -r line; do
    if [ -n "$line" ]; then  # Skip empty lines
        # Modify the line
        modified_line=$(echo "$line" | sed -e 's/.*www.//' -e 's/.*WWW.//' -e 's~http[s]*://~~g' -e 's~HTTP[S]*://~~g' -e 's/\/.*//g' -e 's/^/||/')"^^"
        
        # Insert current date
        current_date=$(date +"%Y-%m-%d")
        modified_line="$modified_line  #$current_date"
        
        echo "$modified_line"
    fi
done < "$external_file_path" > list.txt

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

