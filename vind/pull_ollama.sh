#!/usr/bin/env bash
set -eo pipefail

# Add source and line number when running in debug mode: __run_with_xtrace.sh $TM_FILENAME
# Set new line and tab for word splitting
IFS=$'\n\t'

gcloud compute ssh vind-node --project=eng-sandbox-02 --zone=us-central1-a --command="ollama pull llama3.2:1b"
