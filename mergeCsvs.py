import os
import glob
from datetime import datetime

# Define the base directory and locations
base_dir = "all_runs/location_runs"
locations=["Amadora", "Cascais", "Lisboa", "Loures", "Mafra",
           "Odivelas", "Oeiras", "Sintra", "VilaFrancaDeXira",
           "Alcochete", "Almada", "Barreiro", "Moita", "Montijo",
           "Palmela", "Seixal", "Sesimbra", "Setubal"]
def mergeCsvs(csv_file):

    # Function to get the most recently modified folder in a directory
    def get_recent_folder(directory):
        folders = [os.path.join(directory, f) for f in os.listdir(directory) if os.path.isdir(os.path.join(directory, f))]
        if not folders:
            return None
        return max(folders, key=os.path.getmtime)

    # Function to merge CSV files
    def merge_csv_files(csv_files, output_file):
        with open(output_file, 'w', encoding='utf-8') as outfile:
            # Write the header from the first file
            with open(csv_files[0], 'r', encoding='utf-8') as infile:
                header = infile.readline()
                outfile.write(header)
            
            # Append the rest of the files (skip the header for each file)
            for csv_file in csv_files:
                with open(csv_file, 'r', encoding='utf-8') as infile:
                    next(infile)  # Skip the header
                    for line in infile:
                        outfile.write(line)

    # Collect all data.csv files from the most recent folders
    csv_files = []
    for location in locations:
        location_dir = os.path.join(base_dir, location)
        recent_folder = get_recent_folder(location_dir)
        if recent_folder:
            data_csv_path = os.path.join(recent_folder, csv_file)
            if os.path.exists(data_csv_path):
                csv_files.append(data_csv_path)

    # Merge the CSV files into output.csv
    if csv_files:
        output_file = "%s_merged.csv" % csv_file[:-4]
        merge_csv_files(csv_files, output_file)
        print(f"Merged CSV files into {output_file}")
    else:
        print("No %s files found to merge." % csv_file)

mergeCsvs("QuarterLyHousePrices.csv")
mergeCsvs("SemiAnuallyRentsOfNewContracts.csv")