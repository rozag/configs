#!/usr/bin/env bash
set -euo pipefail

# if you want to hard-code your GCP project:
# PROJECT=my-gcp-project
# gcloud config set project $PROJECT
PROJECT="$(gcloud config get-value project)"

gcloud container clusters list \
  --project "${PROJECT}" \
  --format="value(name,location,locationType)" \
| while read -r NAME LOCATION TYPE; do
    echo "Fetching credentials for ${NAME} (${TYPE} ${LOCATION})"
    if [[ "$TYPE" == "REGIONAL" ]]; then
      gcloud container clusters get-credentials "$NAME" \
        --project "${PROJECT}" \
        --region "$LOCATION"
    else
      gcloud container clusters get-credentials "$NAME" \
        --project "${PROJECT}" \
        --zone "$LOCATION"
    fi
  done

echo "All clusters have been added to your kubeconfig."
echo "You can now do: kubectl config get-contexts"
