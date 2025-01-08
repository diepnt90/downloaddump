#!/bin/bash

# Path to azcopy
AZCOPY="/tools/azcopy"

# Check if azcopy exists at the specified path
if [[ ! -x "$AZCOPY" ]]; then
    echo "azcopy not found or not executable at $AZCOPY. Please check the path."
    exit 1
fi

# Prompt for download URL
read -p "Enter the download URL: " download_url
if [[ -z "$download_url" ]]; then
    echo "Download URL cannot be empty."
    exit 1
fi

# Prompt for blob URL
read -p "Enter the blob URL: " blob_url
if [[ -z "$blob_url" ]]; then
    echo "Blob URL cannot be empty."
    exit 1
fi

# Define temporary filenames
temp_file=$(mktemp --suffix=".dmp")
compressed_file="${temp_file}.gz"

# Download the file
echo "Downloading file from $download_url..."
curl -o "$temp_file" "$download_url"
if [[ $? -ne 0 ]]; then
    echo "Failed to download the file. Please check the URL and try again."
    rm -f "$temp_file"
    exit 1
fi
echo "File downloaded successfully as $temp_file."

# Compress the file
echo "Compressing the file..."
gzip -c "$temp_file" > "$compressed_file"
if [[ $? -ne 0 ]]; then
    echo "Failed to compress the file."
    rm -f "$temp_file" "$compressed_file"
    exit 1
fi
echo "File compressed successfully as $compressed_file."

# Upload the compressed file to blob storage using the specified azcopy path
echo "Uploading the compressed file to $blob_url..."
"$AZCOPY" copy "$compressed_file" "$blob_url"
if [[ $? -ne 0 ]]; then
    echo "Failed to upload the file to blob storage. Please check the blob URL and permissions."
    rm -f "$temp_file" "$compressed_file"
    exit 1
fi
echo "File uploaded successfully to $blob_url."

# Clean up temporary files
rm -f "$temp_file" "$compressed_file"
echo "Temporary files cleaned up."

echo "Script completed successfully."
