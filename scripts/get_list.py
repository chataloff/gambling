import os
import subprocess
from datetime import date

# Function to show progress during git pull
def git_pull_with_progress(repo_url):
    process = subprocess.Popen(['git', 'pull', repo_url], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.decode().strip())
        print("Pulling...")

# Function to show progress during git push
def git_push_with_progress():
    process = subprocess.Popen(['git', 'push'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(process.stdout.readline, b''):
        print(line.decode().strip())
        print("Pushing...")

# Pull changes from the repository with progress
repo_url = "<repository_url>"
git_pull_with_progress(repo_url)

# Prompt user for external file path
external_file_path = input("Please provide the path to the external file: ")

# Check if the file exists
if not os.path.isfile(external_file_path):
    print("Error: External file does not exist.")
    exit(1)

# Read external file
with open(external_file_path, 'r') as file:
    lines = file.readlines()

# Modify lines
modified_lines = []
for line in lines:
    # Replace HTTP:// and https:// with "||"
    modified_line = line.replace("HTTP://", "||").replace("https://", "||")
    # Remove "/" and reset from the end of each line
    modified_line = modified_line.rstrip("/")
    # Add "^" at the end of each line
    modified_line += "^"
    # Insert current date in format "!$date"
    current_date = date.today().strftime("%Y-%m-%d")
    modified_line = f"!{current_date} {modified_line}"
    modified_lines.append(modified_line)

# Write modified lines to cloned file
cloned_file_path = "cloned_file.txt"
with open(cloned_file_path, 'w') as file:
    file.write('\n'.join(modified_lines))

# Add changes to Git
subprocess.run(['git', 'add', cloned_file_path])

# Commit changes with current date as comment
current_date = date.today().strftime("%Y-%m-%d")
commit_message = f"Updated data as of {current_date}"
subprocess.run(['git', 'commit', '-m', commit_message])

# Push changes to remote repository
git_push_with_progress()

# Show output/progress of git push
print("Push completed.")

