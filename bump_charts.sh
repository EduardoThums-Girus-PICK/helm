#!/usr/bin/env bash

for chart in $(find ./charts -type f -name Chart.yaml); do

    current_version=$(yq '.version' "$chart")

    IFS='.' read -r -a parts <<< "$current_version"
    major=${parts[0]}
    minor=${parts[1]}
    patch=${parts[2]}
    patch=$((patch + 1))

    new_version="$major.$minor.$patch"

    message=echo "Bumping $(yq '.name' $chart) chart version from $current_version to $new_version"
    echo $message
    echo "COMMIT_MESSAGE=$message" >> $GITHUB_ENV

    yq eval ".version = \"$new_version\"" -i "$chart"

done
