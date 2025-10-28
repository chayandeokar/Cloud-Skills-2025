#!/bin/bash

echo -e "${GOLD_COLOR}${BOLD_TEXT}Enter the region: ${NO_COLOR}${RESET_FORMAT}"
read REGION

echo -e "${GOLD_COLOR}${BOLD_TEXT}Enter the message: ${NO_COLOR}${RESET_FORMAT}"
read MESSAGE

# Set the ZONE variable
ZONE="$(gcloud compute instances list --project=$DEVSHELL_PROJECT_ID --format='value(ZONE)')"

gcloud services enable appengine.googleapis.com

sleep 10

gcloud compute ssh --zone "$ZONE" "lab-setup" --project "$DEVSHELL_PROJECT_ID" --quiet --command "gcloud services enable appengine.googleapis.com && git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git"

git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git

cd python-docs-samples/appengine/standard_python3/hello_world

sed -i "32c\    return \"$MESSAGE\"" main.py

# Check and update the REGION variable
if [ "$REGION" == "us-west" ]; then
  REGION="us-west1"
fi

gcloud app create --service-account=$DEVSHELL_PROJECT_ID@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com --region=$REGION

echo "${TEAL_COLOR}${BOLD_TEXT}Deploying application...${RESET_FORMAT}"
gcloud app deploy --quiet

echo "${LIME_COLOR}${BOLD_TEXT}Finalizing lab setup...${RESET_FORMAT}"
gcloud compute ssh --zone "$ZONE" "lab-setup" --project "$DEVSHELL_PROJECT_ID" --quiet --command "gcloud services enable appengine.googleapis.com && git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git"

