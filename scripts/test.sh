#!/bin/sh

# Prompt user for domain
echo "Please enter the domain:"
read -r domain

# Remove matching line from the file
sed -i "\|^||$domain^ #\$|d" file.txt

echo "Line removed."

