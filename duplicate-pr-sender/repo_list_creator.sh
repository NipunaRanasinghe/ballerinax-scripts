#!/bin/bash

# GitHub organization and search keyword
ORG_NAME="ballerina-platform"
SEARCH_KEYWORD="ballerinax-"

# Output file
OUTPUT_FILE="repos.json"

# GitHub API URL
API_URL="https://api.github.com/orgs/$ORG_NAME/repos"

# Fetch the repositories using GitHub API
response=$(curl -s "$API_URL")

# Check if the request was successful
if [[ $response == *"Not Found"* ]]; then
  echo "Organization '$ORG_NAME' not found."
  exit 1
fi

# Extract the repository names containing the search keyword
repo_names=()
while IFS= read -r line; do
  name=$(echo "$line" | grep -o "\"name\": *\"[^\"]*\"" | grep -o "\"[^\"]*\"")
  if [[ $name == *"$SEARCH_KEYWORD"* ]]; then
    repo_names+=("${name//\"/}")
  fi
done <<< "$response"

# Create the output file with the repository names
printf '%s\n' "${repo_names[@]}" > "$OUTPUT_FILE"

echo "The '$OUTPUT_FILE' file has been created with the list of repositories containing '$SEARCH_KEYWORD'."
