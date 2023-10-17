 #!/bin/bash

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
