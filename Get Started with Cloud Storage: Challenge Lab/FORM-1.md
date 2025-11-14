export BUCKET="$(gcloud config get-value project)"

gsutil mb -p $BUCKET -c COLDLINE -l (region) gs://bucket1

gsutil retention set 30s gs://bucket2

echo "Cloud Storage Demo" > sample.txt

gsutil cp sample.txt gs://bucket3

