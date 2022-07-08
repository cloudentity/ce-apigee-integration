#!/bin/bash

### Create or update a cloud secret with the contents of the specified file name

if [ "$#" -ne 2 ]; then
    echo "Usage create_update_secret SECRET_NAME FILE_WITH_SECRET_VALUE"
    exit
fi

SECRET_NAME=$1
FILE_LOC=$2

# Check if it exists
CUR_SECRET=$(gcloud secrets list --filter=$SECRET_NAME --format="(name)")

if [[ -n $CUR_SECRET ]];
then
  # Secret exists. Create a new version 
  echo "Adding new version to secret $SECRET_NAME...."
  gcloud secrets versions add "$SECRET_NAME" --data-file "$FILE_LOC"
else
  # Create a new secret
  echo "Creating secret $SECRET_NAME...."
  gcloud secrets create "$SECRET_NAME" --data-file "$FILE_LOC"
fi
echo Done