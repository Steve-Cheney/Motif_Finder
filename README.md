# Motif Finder

This script, `Motif_Finder`, processes genetic data, executes a series of CRISPR-related subprocesses, and generates a summary of sequenced CRISPR candidates.

## Overview

The script performs the following functions:

1. Reads clinical data from a specified file.
2. Executes a series of bash scripts for CRISPR-related data processing to identify target exomes.
3. Filters the data based on the 'Status' field.
4. Generates a summary file containing details about the sequenced organisms.

## Usage

```bash
python3 exomeReport.py <clinical_data_file> <motif_list> <exome_directory>
```

- If you have syntax errors while running the script, please see the help section below. It is required to use `python3` to run this script.

### Arguments

- `<clinical_data_file>`: Path to the file containing clinical data.
    - Format: `Discoverer\tLocation\tDiameter (mm)\tEnvironment\tStatus\tcode_name`
    - Note: Each value should be separated by a tab.
    
- `<motif_list>`: Path to the file containing the motifs of interest.
    - Format:
        ```
        ATCGATCG
        GGGCCCGA
        ...
        ```
        
- `<exome_directory>`: Path to the directory containing your exomes of interest.
    - Format: Files should be '.fasta' files

### Helper Functions

- `read_clinical_data(path_to_file: str) -> dict`:
    - Reads in a clinical data file and returns a dictionary with the `code_name` as the key.
    
- `filter_sequenced(clinical_data_dict: dict, match: str = "Sequenced") -> dict`:
    - Filters the clinical data dictionary to match the status.

### Output

- Generates the following folder structure:

```
<exome_directory>
    ├── exomesCohort
    │   ├── postcrispr
    |   |   ├── <exome>_postcrispr.fasta
    |   |   └── ...    
    │   ├── precrispr
    |   |   ├── <exome>_precrispr.fasta
    |   |   └── ...    
    │   ├── topMotifs
    |   |   ├── <exome>_topmotifs.fasta
    |   |   └── ...    
    │   └── summary.txt - A summary of the sequenced CRISPR candidates
```

- Generates a summary file at `<exome_directory>/exomesCohort/summary.txt`.
- The summary file includes details about the organism, the discoverer, diameter, environment, and the first sequences from the associated `.fasta` file.

### Notes

- Ensure that the bash scripts (`copyExomes.sh`, `createCrisprReady.sh`, `identifyCrisprSite.sh`, `editGenome.sh`) are present in the same directory as the Python script and are executable.

- If you cannot successfully execute the bash scripts through the python script, please run the following command before running the script.

```bash
cd <path_to_Motif_Finder>
chmod +x copyExomes.sh createCrisprReady.sh editGenome.sh identifyCrisprSite.sh
```

### Help

Use `-h` or `-help` for usage information.

```
python exomeReport.py -h
```

- Use `python3` to run the python script, and not `python` due to Python3 function formatting.
