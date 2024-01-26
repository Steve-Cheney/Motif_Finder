#!/bin/bash

mkdir -p "exomesCohort/precrispr"

# Loop over each file in the cohort subdirectory
for file in exomesCohort/topMotifs/*.fasta; do
    
    file_name=$(basename "$file" ".fasta" | sed 's/_topmotifs//')

    # Create an empty output file
    output="exomesCohort/precrispr/${file_name}_precrispr.fasta"
    > "$output"
    # Temp file to hold intermediate results
    temp_output="${output}.temp"

    awk '
    BEGIN { RS=">"; ORS="" }
    NR > 1 {
        header = $1;   # Save header
        sub(/[^\n]+\n/, "");  # Remove header from the sequence
        if (match($0, /.{20}[A-Za-z]GG/)) { # Match any 20 chars before the NGG sequence
            print ">"header"\n"$0;  # Print the header and sequence if pattern matches
        }
    }' "$file" > "$temp_output"

    # Replace output with temp file
    mv "$temp_output" "$output"

    echo -e "> Precrispr seqs found"
done
