#!/bin/bash

# Check if the input CSV file is provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input.csv>"
    exit 1
fi

input_csv=$1

# Ask the user what format they want the CSV to be converted to
echo "Which format do you want to convert the CSV to?"
echo "1. JSON"
echo "2. XML"
echo "3. Both JSON and XML"
read -p "Enter your choice (1/2/3): " choice

case $choice in
    1)
        # Convert to JSON only
        ./c2j < "$input_csv"
        echo "CSV to JSON conversion completed, output stored in output.json"
        ;;
    2)
        # Convert to JSON first, then to XML, and remove the JSON file
        ./c2x < "$input_csv"
        echo "CSV to XML conversion completed, output stored in output.xml"
        ;;
    3)
        # Convert to both JSON and XML and keep both files
        ./c2j < "$input_csv"
        echo "CSV to JSON conversion completed, output stored in output.json"
        ./c2x < "$input_csv"
        echo "CSV to XML conversion completed, output stored in output.xml"
        ;;
    *)
        echo "Invalid choice. Please run the script again and choose 1, 2, or 3."
        exit 1
        ;;
esac
