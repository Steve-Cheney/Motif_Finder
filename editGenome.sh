#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <exome_directory>"
    exit 1
fi

exome_directory="$1"

mkdir -p "$exome_directory/exomesCohort/postcrispr"

# Loop over each file in the cohort subdirectory
for file in $exome_directory/exomesCohort/precrispr/*.fasta; do
    
    file_name=$(basename "$file" ".fasta" | sed 's/_precrispr//')

    # Create an empty output file
    output="$exome_directory/exomesCohort/postcrispr/${file_name}_postcrispr.fasta"
    > "$output"
    # Temp file to hold intermediate results
    temp_output="${output}.temp"

    sed -E 's/(.{20})(.{1}GG)/\1A\2/g' "$file" > "$temp_output"

    # Replace output with temp file
    mv "$temp_output" "$output"

    echo -e "> Sequence Edited"
done
