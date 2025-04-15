#!/bin/bash

# Define the directory to search
HTML_DIRECTORY="/Users/rs162/Documents/OPX/k12-contents-raise/html"
CSV_DIRECTORY="/Users/rs162/Documents"
CONTENT_MAP_FILE="course_contentsmap.csv"

# Define the keywords to search for
KEYWORDS=("to answer questions" "for questions" "situation" "following" "scenario" "write an equation" "constraint" "for #" "translate" "in problems")

# Generate the output file name based on the first two keywords
OUTPUT_FILE="final_keyword_search_results_${KEYWORDS[0]}_${KEYWORDS[1]}.csv"
TEMP_FILE="keyword_search_results.csv"

# Write the header to the temporary CSV file
echo "Keywords,File" > "$TEMP_FILE"

# Find HTML files and search for the keywords (case-insensitive)
find "$HTML_DIRECTORY" -type f -name "*.html" | while read -r FILE; do
    FILENAME=$(basename "$FILE" .html) # Extract only the filename without extension
    FILE_CONTENT=$(cat "$FILE" | tr '[:upper:]' '[:lower:]') # Read file content and convert to lowercase
    MATCHED_KEYWORDS=()
    
    for KEYWORD in "${KEYWORDS[@]}"; do
        if echo "$FILE_CONTENT" | grep -iq "$KEYWORD"; then
            MATCHED_KEYWORDS+=("$KEYWORD")
        fi
    done

    if [ ${#MATCHED_KEYWORDS[@]} -gt 0 ]; then # Check if any keywords are found
        KEYWORDS_STRING=$(IFS=,; echo "${MATCHED_KEYWORDS[*]}")
        echo "\"$KEYWORDS_STRING\",\"$FILENAME\"" >> "$TEMP_FILE"
    fi
done

echo "Search complete. Results saved to $TEMP_FILE."

# Python script to join CSV files and create the final output
python3 <<EOF
import pandas as pd

# Load the search results CSV
search_results = pd.read_csv("$TEMP_FILE", quotechar='"')

# Load the course contents map CSV
course_contents = pd.read_csv("$CSV_DIRECTORY/$CONTENT_MAP_FILE")

# Merge the dataframes on the filename and content_id
merged_df = pd.merge(search_results, course_contents, left_on='File', right_on='content_id')

# Select and rename the required columns
final_df = merged_df[['Keywords', 'section', 'activity_name', 'lesson_page', 'url']]

# Save the final results to a new CSV file
final_df.to_csv("$OUTPUT_FILE", index=False)
EOF

# Cleanup temporary file
rm "$TEMP_FILE"

echo "Search and join complete. Results saved to $OUTPUT_FILE."
