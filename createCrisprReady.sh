#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <motifs_file>"
    exit 1
fi

# Assign command line arguments to variables
motifs_file="$1"


# Loop over each file in the cohort subdirectory
for file in "exomesCohort"/*; do
    echo -n "Finding motifs "

    # Use grep to search for each line in the target file and motif counts
    declare -A motif_dict # create associative array (dict) for each exome cohort
    counter=0
    while IFS= read -r line; do
        count=$(grep -o "$line" "$file" | wc -l)
        motif_dict["$line"]="$count"
        if (( counter % 6 == 0 )); then
            echo -n "."
        fi
        counter=$((counter + 1))
    done < "$motifs_file"
    
    file_name=$(basename "$file" ".fasta")

    # Convert the array to key value pairs and sort them in descending order, then get the keys for grep
    top_three_keys=($(for key in "${!motif_dict[@]}"; do
        echo "${motif_dict[$key]} $key"
    done | sort -rn -k1 | head -n 3 | cut -d ' ' -f2))
    
    # Print top 3 keys for debugging/console
    echo -e "\nTop 3 motifs in $file_name:"
    for key in "${top_three_keys[@]}"; do
        echo "$key: ${motif_dict[$key]}"
    done
    
    # Create an empty output file
    output="exomesCohort/${file_name}_topmotifs.fasta"
    > "$output"
    # Temp file to hold intermediate results
    temp_output="${output}.temp"

    # Loop through each of the top three keys
    for motif in "${top_three_keys[@]}"; do
        # Extract the sequences containing the motif
        grep -B 1 "$motif" "$file" >> "$temp_output"
    done

    # Remove duplicate sequences/ids and '--' lines, then write to final output file
    awk '!seen[$0]++ && $0 != "--"' "$temp_output" > "$output"
    rm "$temp_output" # Remove the temporary file
    
    # Sort the fasta file by sequence id
    # Assume the format of the id is ">gene###"
    temp_output="${output}.tmp"
    awk 'BEGIN{RS=">"} NR>1 {gsub("\n", "\t"); print ">"$0}' "$output" | \
    sort -n -k1.6 | \
    awk '{sub("\t", "\n"); gsub("\t", ""); print $0}' > "$temp_output"

    # Replace output with temp file
    mv "$temp_output" "$output"

    echo -e "> Top motifs created\n--------------------\n"
done