#!/bin/bash

# Define the directories and files
HTML_DIRECTORY="/Users/rs162/Documents/OPX/k12-contents-raise/html"
CSV_DIRECTORY="/Users/rs162/Documents"
CONTENT_MAP_FILE="course_contentsmap.csv"
INPUT_CSV="k12_url_resource.csv"

# Define the output file names
PDF_TEMP_FILE="pdf_search_results_temp.csv"
OUTPUT_FILE="final_pdf_search_results.csv"
SEARCH_RESULTS_TEMP="search_results_temp.csv"

# Step 1: Read the input CSV file and extract PDF URLs and names
echo "Reading input CSV file: $INPUT_CSV..."

# Print the first few rows of the input CSV for debugging
head -n 10 "$INPUT_CSV"

# Count total rows in the input CSV
echo "Number of rows in input CSV: $(wc -l < "$INPUT_CSV")"

awk -F',' 'NR > 1 && $1 ~ /\.pdf$/ {print $3 "," $1}' "$INPUT_CSV" > "$PDF_TEMP_FILE"

echo "PDF URLs and names extracted to $PDF_TEMP_FILE. Review this file for accuracy."

# Print the first few rows of the filtered file for debugging
echo "Filtered PDF rows (head):"
head -n 10 "$PDF_TEMP_FILE"

# Count total rows in the filtered CSV
echo "Number of rows in filtered PDF CSV: $(wc -l < "$PDF_TEMP_FILE")"

# Step 2: Search for PDF URLs in HTML files
echo "Searching for PDF URLs in HTML files..."
echo "URL,Name,File" > "$SEARCH_RESULTS_TEMP"

while IFS=, read -r URL NAME; do
    # Skip the header line
    if [ "$URL" == "URL of PDF" ]; then
        continue
    fi

    # Search in HTML files
    find "$HTML_DIRECTORY" -type f -name "*.html" | while read -r FILE; do
        if grep -q "$URL" "$FILE"; then
            FILENAME=$(basename "$FILE" .html) # Get filename without extension
            echo "$URL,$NAME,$FILENAME" >> "$SEARCH_RESULTS_TEMP"
        fi
    done
done < "$PDF_TEMP_FILE"

echo "Search complete. Intermediate results saved to $SEARCH_RESULTS_TEMP."

# Step 3: Merge with course contents map CSV
python3 <<EOF
import pandas as pd

# Define file paths inside Python
search_results_file = "$SEARCH_RESULTS_TEMP"
course_contents_file = "$CSV_DIRECTORY/$CONTENT_MAP_FILE"
output_file = "$OUTPUT_FILE"

# Load the search results CSV
search_results = pd.read_csv(search_results_file)

# Load the course contents map CSV
course_contents = pd.read_csv(course_contents_file)

# Merge the dataframes on the filename and content_id
merged_df = pd.merge(search_results, course_contents, left_on='File', right_on='content_id')

# Select and rename the required columns, ensuring 'visible' exists
if "visible" not in merged_df.columns:
    print("Warning: 'visible' column not found in course contents map.")
    merged_df["visible"] = "N/A"  # Fill missing column with "N/A"

# Select the required columns
final_df = merged_df[['URL', 'visible', 'Name', 'section', 'activity_name', 'lesson_page', 'url']]

# Save the final results to a new CSV file
final_df.to_csv(output_file, index=False)

print(f"Search and join complete. Results saved to {output_file}")
EOF

# Cleanup temporary files
rm "$PDF_TEMP_FILE" "$SEARCH_RESULTS_TEMP"

echo "Process completed successfully!"
