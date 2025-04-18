import os
import glob
from datetime import datetime
from pathlib import Path
import math

# Define the base directory and locations
base_dir = "all_runs/policy_testing"
policies = ["ConstructionVatReduction",
    "ConstructionLicensingSimplification",
    "NonResidentsProhibition",
    "Baseline",
    "ReducedRentTax",
    "RentsIncreaseCeiling",
]
# policies = ["Baseline"]
locations=["Amadora", "Cascais", "Lisboa", "Loures", "Mafra",
           "Odivelas", "Oeiras", "Sintra", "VilaFrancaDeXira",
           "Alcochete", "Almada", "Barreiro", "Moita", "Montijo",
           "Palmela", "Seixal", "Sesimbra", "Setubal"]

# locations=["Amadora", "Cascais", "Oeiras", "Odivelas", "Setubal"]
# output_dir = "results/csvs/location_validation"
output_dir = "results/csvs"

def parse_folder_datetime(folder_name):
    """
    Extract datetime from folder name formatted as:
    NHH_%d_NSTEPS_%d_%s_%s_%s_T%s_%s
    Returns datetime object or None if invalid format
    """
    parts = folder_name.split('_')
    try:
        # Extract date/time components (year, month, day, hour, minute)
        year = int(parts[4])
        month = int(parts[5])
        day = int(parts[6])
        hour = int(parts[7][1:])  # Remove 'T' prefix from hour
        minute = int(parts[8])
        
        return datetime(year, month, day, hour, minute)
    except (IndexError, ValueError, TypeError):
        return None

def get_sorted_folders(root_path):
    """Return folders sorted by embedded datetime, most recent first"""
    folders = []
    
    for folder in Path(root_path).iterdir():
        if folder.is_dir():
            dt = parse_folder_datetime(folder.name)
            if dt:  # Only consider folders with valid datetime format
                folders.append((dt, folder))
    
    # Sort descending by datetime
    return sorted(folders, key=lambda x: x[0], reverse=True)

def get_recent_folder(root_path):
    """Get the most recent folder based on embedded datetime"""
    sorted_folders = get_sorted_folders(root_path)
    return sorted_folders[0][1] if sorted_folders else None

def mergeCsvs(csv_file):

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

    for policy in policies:
        # Collect all data.csv files from the most recent folders
        csv_files = []
        for location in locations:
            policy_location_dir = os.path.join(base_dir, policy, location)
            try:
                recent_folder = get_recent_folder(policy_location_dir)
            except FileNotFoundError:
                continue
            if recent_folder:
                data_csv_path = os.path.join(recent_folder, csv_file)
                if os.path.exists(data_csv_path):
                    csv_files.append(data_csv_path)

        # Merge the CSV files into output.csv
        if csv_files:
            output_file = "%s/%s_%s.csv" % (output_dir, csv_file[:-4], policy)
            merge_csv_files(csv_files, output_file)
            print(f"Merged CSV files into {output_file}")
        else:
            print("No %s files found to merge." % csv_file)

def mergeCsvsAndConvertQuarterlyToYearly(csv_file):
    if "Quarterly" not in csv_file:
        print("This function is only for quarterly files not for %s" % csv_file)
        return
    mergeCsvs(csv_file)
    output_metric = "Yearly%s" % (csv_file[9:-4])
    for policy in policies:
        input_file = "%s/%s_%s.csv" % (output_dir, csv_file[:-4], policy)
        output_file = "%s/%s_%s.csv" % (output_dir, output_metric, policy)
        convert_quarterlyCsvToYeary(input_file, output_file)

def convert_quarterlyCsvToYeary(input_file, output_file, aggregate = True):
    # Read the quarterly data
    lines = []
    with open(input_file, 'r', encoding='utf-8') as infile:
        lines = infile.readlines()
    output_lines = ["-" + ",".join([str(year) for year in range(2021, math.ceil(len(lines[0].split(",")) / 4) + 2021 + 1)])]
    for line in lines[1:]:
        values = line.split(",")[1:-1]
        values = [float(value) for value in values]
        divisor = 1 if aggregate else 4
        yearly_values = [sum(values[i:i+4]) / divisor for i in range(0, len(values), 4)]
        output_lines.append(line.split(",")[0] + "," + ",".join([str(value) for value in yearly_values]))
    # Write the yearly data to a new CSV file
    with open(output_file, 'w', encoding='utf-8') as outfile:
        outfile.write("\n".join(output_lines))
        print(f"Converted Quarterly file {input_file} to yearly file {output_file}")

# sed -i '/Oeiras/!d' results/csvs/*.csv

# mergeCsvs("QuarterLyHousePrices.csv")
# mergeCsvs("SemiAnuallyRentsOfNewContracts.csv")

mergeCsvs("YearlyHousePrices.csv")
mergeCsvs("YearlyOldHousesPrices.csv")
mergeCsvs("YearlyRecentlyBuildPrices.csv")
mergeCsvsAndConvertQuarterlyToYearly("QuarterlyNumberOfTransactions.csv")
mergeCsvsAndConvertQuarterlyToYearly("QuarterlyNumberOfNewContracts.csv")
mergeCsvs("YearlyRentsOfNewContracts.csv")

