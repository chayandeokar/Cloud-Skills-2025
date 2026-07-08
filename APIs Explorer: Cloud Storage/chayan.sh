gsutil mb gs://$DEVSHELL_PROJECT_ID
gsutil mb gs://$DEVSHELL_PROJECT_ID-2

curl -# -LO raw.githubusercontent.com/GoogleCloudPlatform/cloud-storage-samples/main/sample-files/demo-image1.png
curl -# -LO raw.githubusercontent.com/GoogleCloudPlatform/cloud-storage-samples/main/sample-files/demo-image2.png
curl -# -LO raw.githubusercontent.com/GoogleCloudPlatform/cloud-storage-samples/main/sample-files/demo-image1-copy.png

gsutil cp demo-image1.png gs://$DEVSHELL_PROJECT_ID/demo-image1.png
gsutil cp demo-image2.png gs://$DEVSHELL_PROJECT_ID/demo-image2.png
gsutil cp demo-image1-copy.png gs://$DEVSHELL_PROJECT_ID-2/demo-image1-copy.png
