#!/bin/bash

old_version=$(git tag | tail -n 1)
parts=( ${old_version//./ } )
incremented=$((parts[2] + 1))
new_version="${parts[0]}.${parts[1]}.${incremented}"

echo $new_version
