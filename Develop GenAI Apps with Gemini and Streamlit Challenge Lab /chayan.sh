#!/bin/bash
# Define color variables

# Step 1: Enable Cloud Run API
gcloud services enable run.googleapis.com

# Step 2: Clone the repository
git clone https://github.com/GoogleCloudPlatform/generative-ai.git

# Step 3: Navigate to the required directory
cd generative-ai/gemini/sample-apps/gemini-streamlit-cloudrun

# Step 4: Remove existing files
rm -rf Dockerfile chef.py requirements.txt

# Step 5: Download required files from updated URLs
wget https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/main/Develop%20GenAI%20Apps%20with%20Gemini%20and%20Streamlit%20Challenge%20Lab/chef.py
wget https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/main/Develop%20GenAI%20Apps%20with%20Gemini%20and%20Streamlit%20Challenge%20Lab/Dockerfile
wget https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/main/Develop%20GenAI%20Apps%20with%20Gemini%20and%20Streamlit%20Challenge%20Lab/requirements.txt

# Step 6: Upload chef.py to the Cloud Storage bucket
gcloud storage cp chef.py gs://$DEVSHELL_PROJECT_ID-generative-ai/

# Step 7: Set project and region variables
GCP_PROJECT=$(gcloud config get-value project)
GCP_REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Step 8: Create a virtual environment and install dependencies
python3 -m venv gemini-streamlit
source gemini-streamlit/bin/activate
python3 -m pip install -r requirements.txt

# Step 9: Start Streamlit application
nohup streamlit run chef.py \
  --browser.serverAddress=localhost \
  --server.enableCORS=false \
  --server.enableXsrfProtection=false \
  --server.port 8080 > streamlit.log 2>&1 &

# Step 10: Create Artifact Repository
AR_REPO='chef-repo'
SERVICE_NAME='chef-streamlit-app' 
gcloud artifacts repositories create "$AR_REPO" --location="$GCP_REGION" --repository-format=Docker

# Step 11: Submit Cloud Build
gcloud builds submit --tag "$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$AR_REPO/$SERVICE_NAME"

# Step 12: Deploy Cloud Run Service
gcloud run deploy "$SERVICE_NAME" \
  --port=8080 \
  --image="$GCP_REGION-docker.pkg.dev/$GCP_PROJECT/$AR_REPO/$SERVICE_NAME" \
  --allow-unauthenticated \
  --region=$GCP_REGION \
  --platform=managed  \
  --project=$GCP_PROJECT \
  --set-env-vars=GCP_PROJECT=$GCP_PROJECT,GCP_REGION=$GCP_REGION

# Step 13: Get Cloud Run Service URL
CLOUD_RUN_URL=$(gcloud run services describe "$SERVICE_NAME" --region="$GCP_REGION" --format='value(status.url)')

echo
echo "${YELLOW}${BOLD}Streamlit running at: ${RESET}""http://localhost:8080"
echo
echo "${MAGENTA}${BOLD}Cloud Run Service is available at: ${RESET}""$CLOUD_RUN_URL"
echo

