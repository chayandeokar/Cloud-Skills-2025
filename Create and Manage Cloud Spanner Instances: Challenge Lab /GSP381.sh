#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`


# Create Spanner instance
echo "${CYAN}${BOLD}Creating Spanner instance: banking-ops-instance${RESET}"
gcloud spanner instances create banking-ops-instance \
  --config=regional-$REGION \
  --description="DrAbhishekTutorial" \
  --nodes=1

# Create database
echo "${CYAN}${BOLD}Creating database: banking-ops-db${RESET}"
gcloud spanner databases create banking-ops-db --instance=banking-ops-instance

# Create tables
echo "${CYAN}${BOLD}Creating database tables${RESET}"
gcloud spanner databases ddl update banking-ops-db --instance=banking-ops-instance \
  --ddl="CREATE TABLE Portfolio (
    PortfolioId INT64 NOT NULL,
    Name STRING(MAX),
    ShortName STRING(MAX),
    PortfolioInfo STRING(MAX))
    PRIMARY KEY (PortfolioId)"

gcloud spanner databases ddl update banking-ops-db --instance=banking-ops-instance \
  --ddl="CREATE TABLE Category (
    CategoryId INT64 NOT NULL,
    PortfolioId INT64 NOT NULL,
    CategoryName STRING(MAX),
    PortfolioInfo STRING(MAX))
    PRIMARY KEY (CategoryId)"

gcloud spanner databases ddl update banking-ops-db --instance=banking-ops-instance \
  --ddl="CREATE TABLE Product (
    ProductId INT64 NOT NULL,
    CategoryId INT64 NOT NULL,
    PortfolioId INT64 NOT NULL,
    ProductName STRING(MAX),
    ProductAssetCode STRING(25),
    ProductClass STRING(25))
    PRIMARY KEY (ProductId)"

gcloud spanner databases ddl update banking-ops-db --instance=banking-ops-instance \
  --ddl="CREATE TABLE Customer (
    CustomerId STRING(36) NOT NULL,
    Name STRING(MAX) NOT NULL,
    Location STRING(MAX) NOT NULL)
    PRIMARY KEY (CustomerId)"

# Insert sample data
echo "${CYAN}${BOLD}Inserting sample data${RESET}"
gcloud spanner databases execute-sql banking-ops-db --instance=banking-ops-instance \
  --sql='INSERT INTO Portfolio (PortfolioId, Name, ShortName, PortfolioInfo)
  VALUES 
    (1, "Banking", "Bnkg", "All Banking Business"),
    (2, "Asset Growth", "AsstGrwth", "All Asset Focused Products"),
    (3, "Insurance", "Insurance", "All Insurance Focused Products")'

gcloud spanner databases execute-sql banking-ops-db --instance=banking-ops-instance \
  --sql='INSERT INTO Category (CategoryId, PortfolioId, CategoryName)
  VALUES 
    (1, 1, "Cash"),
    (2, 2, "Investments - Short Return"),
    (3, 2, "Annuities"),
    (4, 3, "Life Insurance")'

gcloud spanner databases execute-sql banking-ops-db --instance=banking-ops-instance \
  --sql='INSERT INTO Product (ProductId, CategoryId, PortfolioId, ProductName, ProductAssetCode, ProductClass)
  VALUES 
    (1, 1, 1, "Checking Account", "ChkAcct", "Banking LOB"),
    (2, 2, 2, "Mutual Fund Consumer Goods", "MFundCG", "Investment LOB"),
    (3, 3, 2, "Annuity Early Retirement", "AnnuFixed", "Investment LOB"),
    (4, 4, 3, "Term Life Insurance", "TermLife", "Insurance LOB"),
    (5, 1, 1, "Savings Account", "SavAcct", "Banking LOB"),
    (6, 1, 1, "Personal Loan", "PersLn", "Banking LOB"),
    (7, 1, 1, "Auto Loan", "AutLn", "Banking LOB"),
    (8, 4, 3, "Permanent Life Insurance", "PermLife", "Insurance LOB"),
    (9, 2, 2, "US Savings Bonds", "USSavBond", "Investment LOB")'

# Download customer data
echo "${CYAN}${BOLD}Downloading customer data${RESET}"
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/main/Create%20and%20Manage%20Cloud%20Spanner%20Instances%3A%20Challenge%20Lab/Customer_List_500.csv

# Prepare Dataflow
echo "${CYAN}${BOLD}Preparing Dataflow service${RESET}"
gcloud services disable dataflow.googleapis.com --force
gcloud services enable dataflow.googleapis.com

# Create manifest file
echo "${CYAN}${BOLD}Creating import manifest${RESET}"
cat > manifest.json << EOF_CP
{
  "tables": [
    {
      "table_name": "Customer",
      "file_patterns": [
        "gs://$DEVSHELL_PROJECT_ID/Customer_List_500.csv"
      ],
      "columns": [
        {"column_name" : "CustomerId", "type_name" : "STRING" },
        {"column_name" : "Name", "type_name" : "STRING" },
        {"column_name" : "Location", "type_name" : "STRING" }
      ]
    }
  ]
}
EOF_CP

# Prepare GCS bucket
echo "${CYAN}${BOLD}Preparing Cloud Storage bucket${RESET}"
gsutil mb gs://$DEVSHELL_PROJECT_ID

# Create placeholder file
echo "${CYAN}${BOLD}Creating placeholder files${RESET}"
touch chayan
gsutil cp chayan gs://$DEVSHELL_PROJECT_ID/tmp/chayan

# Upload files to GCS
echo "${CYAN}${BOLD}Uploading files to Cloud Storage${RESET}"
gsutil cp Customer_List_500.csv gs://$DEVSHELL_PROJECT_ID
gsutil cp manifest.json gs://$DEVSHELL_PROJECT_ID

# Wait for operations to complete
echo "${CYAN}${BOLD}Waiting for setup to complete...${RESET}"
sleep 100

# Run Dataflow job
echo "${CYAN}${BOLD}Running Dataflow import job${RESET}"
gcloud dataflow jobs run chayan \
  --gcs-location gs://dataflow-templates-"$REGION"/latest/GCS_Text_to_Cloud_Spanner \
  --region="$REGION" \
  --staging-location gs://$DEVSHELL_PROJECT_ID/tmp/ \
  --parameters instanceId=banking-ops-instance,databaseId=banking-ops-db,importManifest=gs://$DEVSHELL_PROJECT_ID/manifest.json

# Update schema
echo "${CYAN}${BOLD}Updating database schema${RESET}"
gcloud spanner databases ddl update banking-ops-db --instance=banking-ops-instance \
  --ddl='ALTER TABLE Category ADD COLUMN MarketingBudget INT64;'

# Completion message
echo "${BG_RED}${BOLD}Lab Completed Successfully ${RESET}"
