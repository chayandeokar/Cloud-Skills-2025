```
export REGION=$REGION

gcloud services enable datacatalog.googleapis.com

gcloud services enable bigqueryconnection.googleapis.com

bq mk --connection --location=$REGION --project_id=$DEVSHELL_PROJECT_ID \
    --connection_type=CLOUD_RESOURCE customer_data_connection

CLOUD=$(bq show --connection $DEVSHELL_PROJECT_ID.$REGION.customer_data_connection | grep "serviceAccountId" | awk '{gsub(/"/, "", $8); print $8}')
NEWs="${CLOUD%?}"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:$NEWs" \
    --role="roles/storage.objectViewer"

```
