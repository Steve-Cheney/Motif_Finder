#!/bin/bash

mkdir -p "exomesCohort/postcrispr"

# Loop over each file in the cohort subdirectory
for file in exomesCohort/precrispr/*.fasta; do
    
    file_name=$(basename "$file" ".fasta" | sed 's/_precrispr//')

    # Create an empty output file
    output="exomesCohort/postcrispr/${file_name}_postcrispr.fasta"
    > "$output"
    # Temp file to hold intermediate results
    temp_output="${output}.temp"

    sed -E 's/(.{20})(.GG)/\1A\2/g' "$file" > "$temp_output"

    # Replace output with temp file
    mv "$temp_output" "$output"

    echo -e "> Sequence Edited"
done
