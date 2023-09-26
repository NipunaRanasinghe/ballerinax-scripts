#!/bin/bash

# Define the path to the JSON file containing the list of repositories
REPO_FILE="repos.json"

# Output file for pull request links
PR_LINKS_FILE="/Users/nino/Desktop/repos/ballerinax-scripts/duplicate-pr-sender/pull_request_links.txt"

# Read the repository names from the JSON file
while IFS= read -r repo; do
  echo "Processing repository: $repo"

  # Clone the repository
  git clone "https://github.com/ballerina-platform/${repo}.git"

  # Enter the repository directory
  cd "$repo" || exit 1

  # Create a new branch
  git checkout -b update

  # checkout the file
  git checkout ".github/workflows/build-with-bal-test-native.yml"

  # Check if 'main' branch exists
  main_branch_exists=$(git ls-remote --exit-code --heads origin main >/dev/null 2>&1; echo $?)
  if [[ $main_branch_exists -eq 0 ]]; then
    base_branch="main"
  else
    # Check if 'master' branch exists
    master_branch_exists=$(git ls-remote --exit-code --heads origin master >/dev/null 2>&1; echo $?)
    if [[ $master_branch_exists -eq 0 ]]; then
      base_branch="master"
    else
      echo "Neither 'main' nor 'master' branch found in the repository. Skipping pull request creation."
      cd ..
      rm -rf "$repo"
      continue
    fi
  fi

  # Specify the path to your workflow YAML file
  workflow_file=".github/workflows/build-with-bal-test-native.yml"

  old_values="version: \'latest\'"
  new_values="java-version: \'17\'"
  # Use sed to replace the old values with the new values in the workflow file
  sed -i "" "s|$old_values|$new_values|g" "$workflow_file"

  old_values="java-version: \'11\'"
  new_values="distribution: \'graalvm-community\'"
  # Use sed to replace the old values with the new values in the workflow file
  sed -i "" "s|$old_values|$new_values|g" "$workflow_file"

  old_values="components: \'native-image\'"
  new_values="set-java-home: false"
  # Use sed to replace the old values with the new values in the workflow file
  sed -i "" "s|$old_values|$new_values|g" "$workflow_file"

  # Commit the changes
  git commit -am "Update GraalVM version"

  # Push the branch
  git push origin update

  # Fetch the latest changes from the base branch
  git fetch origin "$base_branch"

  # Merge the latest changes from the base branch
  git merge "origin/$base_branch"

  # Push the merged changes to the update branch
  git push origin update

  # Create a pull request
  pr_url=$(gh pr create --base "$base_branch" --head update --title "Update GraalVM version in workflows" --body "Related to https://github.com/ballerina-platform/ballerina-extended-library/issues/592" | grep -m1 -o 'http.*')
  echo "$pr_url"
  echo "$PR_LINKS_FILE"
  echo "$pr_url" >> "$PR_LINKS_FILE"

  # Navigate back to the previous directory
  cd ..

  # Remove the cloned repository
  rm -rf "$repo"

  echo "Completed processing repository: $repo"
done < "$REPO_FILE"
