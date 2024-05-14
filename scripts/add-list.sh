# Remove empty lines from the source file
grep -v '^[[:space:]]*$' "$external_file_path" > temp_source.txt

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
done < temp_source.txt

# Clean up temporary source file
rm temp_source.txt

# Rename temporary list file to the final destination file
mv temp_list.txt list.txt

