#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <motifs_file>"
    exit 1
fi

# Assign command line arguments to variables
motifs_file="$1"


# Use grep to search for each line in the target file and motif counts
for file in "exomesCohort"/*; do
    declare -A motif_dict # create associative array (dict) for each exome cohort
    while IFS= read -r line; do
        count=$(grep -o "$line" "$file" | wc -l)
        motif_dict["$line"]="$count"
    done < "$motifs_file"
    
    echo "$file"
    #for key in "${!motif_dict[@]}"; do
    #    echo "$key: ${motif_dict[$key]}"
    #done

    # Convert the array to key value pairs and sort them in descending order
    top_three=$(for key in "${!motif_dict[@]}"; do
        echo "${motif_dict[$key]} $key"
    done | sort -rn -k1 | head -n 3)

    # Print the top three key-value pairs
    echo "Top 3 key-value pairs:"
    while read -r value key; do
        echo "$key: $value"
    done <<< "$top_three"
done