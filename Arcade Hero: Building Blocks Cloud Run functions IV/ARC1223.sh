#!/bin/bash

# Colors for terminal output
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
YELLOW="\033[33m"
BLUE="\033[34m"
GREEN="\033[32m"

echo -e "${GREEN}${BOLD}Starting Execution${RESET}"

# Step 1: Set environment variables
echo -e "${CYAN}${BOLD}Setting environment variables...${RESET}"
export PROJECT_ID=$(gcloud config get-value project)
export REGION="us-central1"
export FUNCTION_NAME="cf-nodejs"

# Step 2: Create source code for the Cloud Function
echo -e "${YELLOW}${BOLD}Creating sample Node.js function...${RESET}"
mkdir -p cloud-function
cat > cloud-function/index.js <<EOF
exports.helloWorld = (req, res) => {
  res.send('Hello from Cloud Function!');
};
EOF

cat > cloud-function/package.json <<EOF
{
  "name": "cf-nodejs",
  "version": "1.0.0",
  "main": "index.js"
}
EOF

# Step 3: Deploy the Cloud Function (2nd Gen)
echo -e "${BLUE}${BOLD}Deploying Cloud Function: ${FUNCTION_NAME}...${RESET}"
gcloud functions deploy ${FUNCTION_NAME} \
  --gen2 \
  --runtime=nodejs20 \
  --region=${REGION} \
  --source=cloud-function \
  --entry-point=helloWorld \
  --trigger-http \
  --max-instances=5 \
  --allow-unauthenticated

echo -e "${GREEN}${BOLD}Deployment complete!${RESET}"

# Function to display a random congratulatory message
function random_congrats() {
  MESSAGES=(
    "${GREEN}Congratulations! Cloud Function deployed successfully!${RESET}"
    "${CYAN}Awesome job! Your function is live and ready!${RESET}"
    "${YELLOW}Well done! You've mastered function deployment!${RESET}"
    "${BLUE}Success! Another step forward in cloud development!${RESET}"
  )
  RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
  echo -e "${BOLD}${MESSAGES[$RANDOM_INDEX]}"
}

# Display a random congratulatory message
random_congrats

echo -e "\n"  # Adding one blank line

# Remove unwanted files from home directory
cd ~
remove_files() {
  for file in *; do
    if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
      if [[ -f "$file" ]]; then
        rm "$file"
        echo "File removed: $file"
      fi
    fi
  done
}
remove_files
