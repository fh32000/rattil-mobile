#!/bin/bash

# Configuration
DOCS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${DOCS_DIR}/MERGED_DOCS.txt"

# Remove the output file if it already exists to start fresh
if [ -f "$OUTPUT_FILE" ]; then
    rm "$OUTPUT_FILE"
fi

echo "Merging documentation files into $OUTPUT_FILE..."

# Find all files in the docs directory, excluding the output file itself
find "$DOCS_DIR" -type f ! -name "MERGED_DOCS.txt" ! -name "merge_docs.sh" | while read -r file; do
    # Get relative path for cleaner output
    relative_path="${file#"$DOCS_DIR/"}"
    
    echo "Processing: $relative_path"
    
    # Write file separator and header
    echo "================================================================================" >> "$OUTPUT_FILE"
    echo "START OF FILE: $relative_path" >> "$OUTPUT_FILE"
    echo "================================================================================" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Append the file content
    cat "$file" >> "$OUTPUT_FILE"
    
    # Write empty lines and footer
    echo "" >> "$OUTPUT_FILE"
    echo "================================================================================" >> "$OUTPUT_FILE"
    echo "END OF FILE: $relative_path" >> "$OUTPUT_FILE"
    echo "================================================================================" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

echo "Done! All files merged into: $OUTPUT_FILE"
