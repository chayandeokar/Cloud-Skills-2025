#!/bin/bash


# Get user input for required variables
echo "${CYAN}${BOLD}➤ Please provide the following configuration values:${RESET}"
read -p "${YELLOW}Enter your zone (e.g., us-central1-a): ${RESET}" ZONE
read -p "${YELLOW}Enter monolith identifier (e.g., monolith): ${RESET}" MON_IDENT
read -p "${YELLOW}Enter cluster name (e.g., fancy-cluster): ${RESET}" CLUSTER
read -p "${YELLOW}Enter orders service identifier (e.g., orders): ${RESET}" ORD_IDENT
read -p "${YELLOW}Enter products service identifier (e.g., products): ${RESET}" PROD_IDENT
read -p "${YELLOW}Enter frontend identifier (e.g., frontend): ${RESET}" FRONT_IDENT

# Export variables
export ZONE
export MON_IDENT
export CLUSTER
export ORD_IDENT
export PROD_IDENT
export FRONT_IDENT
export PROJECT_ID=$(gcloud config get-value project)

echo
echo "${GREEN}✓ Configuration set:${RESET}"
echo "Zone: $ZONE"
echo "Monolith: $MON_IDENT"
echo "Cluster: $CLUSTER"
echo "Orders: $ORD_IDENT"
echo "Products: $PROD_IDENT"
echo "Frontend: $FRONT_IDENT"
echo "Project: $PROJECT_ID"
echo

# Initialize project settings
echo "${CYAN}${BOLD}➤ Configuring Project Settings${RESET}"
gcloud config set compute/zone $ZONE
gcloud services enable cloudbuild.googleapis.com container.googleapis.com
echo "${GREEN}✓ Project configuration completed${RESET}"
echo

# Clone repository and setup
echo "${CYAN}${BOLD}➤ Setting Up Application${RESET}"
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh
echo "${GREEN}✓ Application setup completed${RESET}"
echo

# Build and deploy monolith
echo "${CYAN}${BOLD}➤ Deploying Monolith Application${RESET}"
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${PROJECT_ID}/${MON_IDENT}:1.0.0 .
gcloud container clusters create $CLUSTER --num-nodes 3
kubectl create deployment $MON_IDENT --image=gcr.io/${PROJECT_ID}/$MON_IDENT:1.0.0
kubectl expose deployment $MON_IDENT --type=LoadBalancer --port 80 --target-port 8080
echo "${GREEN}✓ Monolith deployed${RESET}"
echo

# Build and deploy microservices
echo "${CYAN}${BOLD}➤ Deploying Microservices${RESET}"
cd ~/monolith-to-microservices/microservices/src/orders
gcloud builds submit --tag gcr.io/${PROJECT_ID}/$ORD_IDENT:1.0.0 .

cd ~/monolith-to-microservices/microservices/src/products
gcloud builds submit --tag gcr.io/${PROJECT_ID}/$PROD_IDENT:1.0.0 .

kubectl create deployment $ORD_IDENT --image=gcr.io/${PROJECT_ID}/$ORD_IDENT:1.0.0
kubectl expose deployment $ORD_IDENT --type=LoadBalancer --port 80 --target-port 8081

kubectl create deployment $PROD_IDENT --image=gcr.io/${PROJECT_ID}/$PROD_IDENT:1.0.0
kubectl expose deployment $PROD_IDENT --type=LoadBalancer --port 80 --target-port 8082
echo "${GREEN}✓ Microservices deployed${RESET}"
echo

# Deploy frontend
echo "${CYAN}${BOLD}➤ Deploying Frontend Service${RESET}"
cd ~/monolith-to-microservices/react-app
cd ~/monolith-to-microservices/microservices/src/frontend
gcloud builds submit --tag gcr.io/${PROJECT_ID}/$FRONT_IDENT:1.0.0 .
kubectl create deployment $FRONT_IDENT --image=gcr.io/${PROJECT_ID}/$FRONT_IDENT:1.0.0
kubectl expose deployment $FRONT_IDENT --type=LoadBalancer --port 80 --target-port 8080
echo "${GREEN}✓ Frontend deployed${RESET}"
echo
