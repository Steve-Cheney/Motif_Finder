import sys
import subprocess

def read_file(path_to_file: str) -> dict:
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



if __name__ == "__main__":
    # Handle args
    if len(sys.argv) > 1:       

        if sys.argv[1] == "-h" or sys.argv[1] == "-help":
            print("Usage: <clinical_data_file> <motif_list> <exome_directory>\n")
            print("---\nclinical_data_file format: \n> Discoverer\tLocation\tDiameter (mm)\tEnvironment	Status\tcode_name")
            print(">> Each value should be separated by a tab")
            sys.exit(0)
    else:
        print("Please enter arguments.\nUse -h or -help to list argument specifications.")
        sys.exit(2)

    if len(sys.argv) < 4 or len(sys.argv) > 4:
        print("Usage: <clinical_data_file> <motif_list> <exmoe_directory>")
        sys.exit(2)

    clinical_data_file = sys.argv[1]
    motif_list = sys.argv[2]
    exome_directory = sys.argv[3]

    subprocess.call(['sh', './copyExomes.sh', clinical_data_file, exome_directory])
    subprocess.call(['sh', './createCrisprReady.sh', motif_list, exome_directory])
    subprocess.call(['sh', './identifyCrisprSite.sh', exome_directory])
    subprocess.call(['sh', './editGenome.sh', exome_directory])
    print("---\nSubprocesses complete!\n---")


