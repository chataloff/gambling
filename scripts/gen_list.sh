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

# Read external file
while IFS= read -r line; do
    # Remove www from the URL
    modified_line=$(echo "$line" | sed 's/.*www.//; s/.*WWW.//')

    # Remove HTTP:// and https:// 
    modified_line=$(echo "$modified_line" | sed 's~http[s]*://~~g; s~HTTP[S]*://~~g')

    # Remove "/" and reset from the end of each line
    modified_line=$(echo "$modified_line" | sed 's/\/.*//g')
    
    # Add || at the beggining of the line 
    modified_line=$(echo "$modified_line" | sed 's/^/||/') 
   
    # Add "^" at the end of each line
    modified_line="${modified_line}^"
    
    # Insert current date in format "!$date"
    current_date=$(date +"%Y-%m-%d")
    modified_line="$modified_line  #$current_date"
    
    # Insert the modified line into the cloned file
    echo "$modified_line" >> temp_list.txt
done < "$external_file_path"

# Remove empty lines
grep -v '^[[:space:]]*$' temp_list.txt > list.txt

# Start cleanup 
# Clean up temporary file
rm temp_list.txt
echo "Removing External file..."
rm  "$external_file_path"

# Removing duplicates
awk '!seen[$0]++' "list.txt" > tmp_list.txt && mv tmp_list.txt list.txt

# Add changes to Git
git add list.txt

# Commit changes with current date as comment
current_date=$(date +"%Y-%m-%d")
git commit -m "Updated data as of $current_date"

# Push changes to remote repository
git_push_with_progress #origin master

# Show output/progress of git push
echo "Push completed."

