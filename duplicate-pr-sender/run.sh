#!/bin/bash

# Define the path to the JSON file containing the list of repositories
REPO_FILE="repos.json"

# Replace with the actual script you want to execute in each repository
CHANGE_SCRIPT="changes.sh"

# Output file for pull request links
PR_LINKS_FILE="pull_request_links.txt"

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

  # Replace "test --native" with "test --graalvm"
  gsed -i 's/--native/--graalvm/g' ".github/workflows/build-with-bal-test-native.yml"

  # Commit the changes
  git commit -am "Rename --native to --graalvm"

  # Push the branch
  git push origin update

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

  # Fetch the latest changes from the base branch
  git fetch origin "$base_branch"

  # Merge the latest changes from the base branch
  git merge "origin/$base_branch"

  # Push the merged changes to the update branch
  git push origin update

  # Create a pull request
  pr_url=$(gh pr create --base "$base_branch" --head update --title "Update GraalVM workflow with new command option" --body "This PR will rename the command option in the graalVM workflow from --native to --graalvm. Fixes https://github.com/ballerina-platform/ballerina-extended-library/issues/531" | grep -m1 -o 'http.*')
  echo "$PR_LINKS_FILE"
  echo "$pr_url" >> "$PR_LINKS_FILE"

  # Navigate back to the previous directory
  cd ..

  # Remove the cloned repository
  rm -rf "$repo"

  echo "Completed processing repository: $repo"
done < "$REPO_FILE"
