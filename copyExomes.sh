#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <data_file> <exome_directory>"
    exit 1
fi

# Assign command line arguments to variables
data_file="$1"
exome_directory="$2"

cohort_names=""
# Read each line of the file
while IFS= read -r line; do
    # Get diameter of the line
    diam_str=$(echo "$line" | cut -f3)
    # Convert to int
    diam=$((diam_str + 0)) 
    
    # Check if 20 >= diam <= 30 and append to string
    if [ "$diam" -ge 20 ] && [ "$diam" -le 30 ]; then
        cohort_names+=$(echo "$line" | cut -f6)$'.fasta\n'
    fi
done < <(tail -n +2 "$data_file") # Skip headers

# Remove exta newline
cohort_names=${cohort_names%$'\n'}

echo "Cohort identified"

# Copy files over to new directory
mkdir -p "exomesCohort"

for file in $cohort_names; do
    if [ -f "$exome_directory/$file" ]; then
        cp "$exome_directory/$file" "exomesCohort/"
    else
        echo "File <'$file'> not found."
    fi
done

echo "Exomes Cohort created"
