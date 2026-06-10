#!/bin/bash

clear

echo "${YELLOW_TEXT}${BOLD_TEXT}👤 Listing Active GCP Accounts...${RESET_FORMAT}"
gcloud auth list

export DEVSHELL_PROJECT_ID=$(gcloud config get-value project)
export PROJECT_ID=$DEVSHELL_PROJECT_ID

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Apply configuration
gcloud config set compute/zone $ZONE --quiet
gcloud config set compute/region $REGION --quiet

echo
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Project ID:${RESET_FORMAT} ${CYAN_TEXT}$PROJECT_ID${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Region:${RESET_FORMAT} ${CYAN_TEXT}$REGION${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Zone:${RESET_FORMAT} ${CYAN_TEXT}$ZONE${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}⚡ Cloud Environment Initialized Successfully${RESET_FORMAT}"


echo "${YELLOW_TEXT}${BOLD_TEXT}👤 Creating Service Account: my-sa-123${RESET_FORMAT}"

gcloud iam service-accounts create my-sa-123 \
    --display-name="My Service Account" \
    --quiet

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}🔑 Granting Editor Role...${RESET_FORMAT}"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:my-sa-123@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor" \
    --quiet

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}👤 Creating BigQuery Service Account...${RESET_FORMAT}"

gcloud iam service-accounts create bigquery-qwiklab \
    --display-name="bigquery-qwiklab" \
    --quiet

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}🔑 Assigning BigQuery Roles...${RESET_FORMAT}"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:bigquery-qwiklab@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataViewer" \
    --quiet

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:bigquery-qwiklab@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/bigquery.user" \
    --quiet


echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}=== COMPUTE ENGINE VM SETUP ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}💻 Creating VM Instance...${RESET_FORMAT}"

gcloud compute instances create bigquery-instance \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --service-account=bigquery-qwiklab@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --quiet

echo
echo "${BLUE_TEXT}${BOLD_TEXT}⏳ Waiting for VM Initialization...${RESET_FORMAT}"

spinner="/-\|"

messages=(
"Preparing VM..."
"Installing Components..."
"Subscribe to Dr. Abhishek 🔥"
"Launching BigQuery Services..."
)

for i in {1..20}; do
    msg=${messages[$((i % ${#messages[@]}))]}
    printf "\r${CYAN_TEXT}${BOLD_TEXT}[${spinner:i%4:1}] $msg${RESET_FORMAT}"
    sleep 1
done

printf "\n"

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}=== PREPARING BIGQUERY SCRIPT ===${RESET_FORMAT}"
echo

cat > cp_disk.sh << 'EOF'
#!/bin/bash

echo "Updating packages..."
sudo apt-get update -y

echo "Installing dependencies..."
sudo apt-get install -y python3 python3-pip python3-venv git

echo "Creating Python virtual environment..."
python3 -m venv myvenv

source myvenv/bin/activate

echo "Upgrading pip..."
pip install --upgrade pip

echo "Installing BigQuery libraries..."
pip install google-cloud-bigquery pyarrow pandas db-dtypes


echo "Creating Python query file..."

cat > query.py << 'PYEOF'
from google.auth import compute_engine
from google.cloud import bigquery

credentials = compute_engine.Credentials(
    service_account_email='YOUR_SERVICE_ACCOUNT'
)

query = '''
SELECT
  year,
  COUNT(1) AS num_babies
FROM
  publicdata.samples.natality
WHERE
  year > 2000
GROUP BY
  year
ORDER BY
  year
'''

client = bigquery.Client(
    project='PROJECT_ID',
    credentials=credentials
)

print("Executing Query...\n")

df = client.query(query).to_dataframe()

print(df.to_string(index=False))
PYEOF

# Replace Variables

sed -i "s/PROJECT_ID/$(gcloud config get-value project)/g" query.py

sed -i "s/YOUR_SERVICE_ACCOUNT/bigquery-qwiklab@$(gcloud config get-value project).iam.gserviceaccount.com/g" query.py

echo
echo "Running BigQuery Query..."
echo

python3 query.py

EOF


echo
echo "${YELLOW_TEXT}${BOLD_TEXT}📤 Copying Script to VM...${RESET_FORMAT}"


gcloud compute scp cp_disk.sh bigquery-instance:/tmp \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --quiet

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}🚀 Executing Script on VM...${RESET_FORMAT}"


gcloud compute ssh bigquery-instance \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --quiet \
    --command="chmod +x /tmp/cp_disk.sh && /tmp/cp_disk.sh"

