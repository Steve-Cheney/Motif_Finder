import sys
import os
import subprocess
import time

def read_clinical_data(path_to_file: str) -> dict:
    """Read in a clinical data file containing "Discoverer	Location	Diameter (mm)	Environment	Status	code_name"

        Args:
            path_to_file: String of the path to the file to read.

        Returns:
            A dict of clinical data, with the code_name as the key.
        """
    clinical_data_dict = {}
    with open(path_to_file, 'r') as file:
        # Read first line for header
        header = file.readline().strip().split('\t')
        
        for entry in file:
            values = entry.strip().split('\t')
            
            # Check if the line has the correct number values to ensure proper parsing
            if len(values) == len(header):
                code_name = values[-1]
                details = {header[i]: values[i] for i in range(len(header) - 1)}
                
                # Assign the details to the code_name in the dictionary
                clinical_data_dict[code_name] = details
            else:
                print(f"Entry skipped due to improper formatting: {entry}")
            
    return clinical_data_dict

def filter_sequenced(
        clinical_data_dict: dict, 
        match: str = "Sequenced"
        ) -> dict:
    """Take the clinical data dict and filter to match the status."

        Args:
            clinical_data_dict: The clinical data dictionary from read_clinical_data().
            match: The value to match in the Status field.

        Returns:
            A dict of clinical data, with the code_name as the key.
        """
    filtered_dict = {}

    for code_name, details in clinical_data_dict.items():
        if details.get('Status') == match:
            filtered_dict[code_name] = details

    return filtered_dict

if __name__ == "__main__":
    start_time = time.perf_counter()
    # Handle args
    if len(sys.argv) > 1:       

        if sys.argv[1] == "-h" or sys.argv[1] == "-help":
            print("""              
Usage: <clinical_data_file> <motif_list> <exome_directory>
Output: ├── exomesCohort
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

Arguments:
<clinical_data_file> - Path to the file containing clinical data.
    Format: 
        >   Discoverer\tLocation\tDiameter (mm)\tEnvironment\tStatus\tcode_name
        Note: Each value should be separated by a tab.
<motif_list> - Path to the file containing the motifs of interest.
    Format:
        >   ATCGATCG
            GGGCCCGA
            ...
<exome_directory> - Path to the directory containing your exomes of interest.
        Format:
            Files should be '.fasta' files
            """)
            sys.exit(0)
    else:
        print("Please enter arguments.\nUse -h or -help to list argument specifications.")
        sys.exit(2)

    if len(sys.argv) < 4 or len(sys.argv) > 4:
        print("Usage: <clinical_data_file> <motif_list> <exmoe_directory>\nUse -h or -help to list argument specifications.")
        sys.exit(2)

    clinical_data_file = sys.argv[1]
    motif_list = sys.argv[2]
    exome_directory = sys.argv[3]
    
    # Execute the bash scripts
    
    subprocess.call(['sh', './copyExomes.sh', clinical_data_file, exome_directory])
    subprocess.call(['sh', './createCrisprReady.sh', motif_list, exome_directory])
    subprocess.call(['sh', './identifyCrisprSite.sh', exome_directory])
    subprocess.call(['sh', './editGenome.sh', exome_directory])
    
    print("---\nSubprocesses complete!\n---")
    
    clinical_dict = read_clinical_data(clinical_data_file)
    sequenced = filter_sequenced(clinical_dict)
  
    output_file = f"{exome_directory}/exomesCohort/summary.txt"
    # Write the info to a summary file
    with open(output_file, 'w') as output_file:
        for exome in sequenced:
            discoverer = sequenced[exome]['Discoverer']
            diameter = sequenced[exome]['Diameter (mm)']
            environment = sequenced[exome]['Environment']

            if os.path.exists(f"{exome_directory}/exomesCohort/postcrispr/{exome}_postcrispr.fasta"):
                abspath = os.path.abspath(f"{exome_directory}/exomesCohort/postcrispr/{exome}_postcrispr.fasta")
                print(f"Organism {exome}, discovered by {discoverer}, has a diameter of {diameter}mm, and is from the environment {environment}\n", file=output_file)
                print("The list of genes can be found in:", abspath, file=output_file)
                print(f"The first sequence of {exome} is:", file=output_file)
                
                with open(abspath, 'r') as file:
                    # Read first 2 lines
                    print(file.readline(), file=output_file, end='')
                    print(file.readline(), file=output_file, end='')

                print("--\n", file=output_file)
    if os.path.exists(f"{exome_directory}/exomesCohort/summary.txt"):
        abspath = os.path.abspath(f"{exome_directory}/exomesCohort/summary.txt")
        print(f"Summary generated at: {abspath}")
    
    end_time = time.perf_counter()
    print(f"Process completed in {round(end_time-start_time, 3)} seconds.")
