#!/bin/bash
set -e


workflow_name=$1
num_workflows=$2

batch_id=$(date +%s)

echo "Starting batch ID: $batch_id"
for i in $(seq 1 $num_workflows); do
  echo "Starting workflow run$i"
  gh workflow run "$workflow_name" --ref aym/fix-scenario-tests 
done

sleep 3

gh run list --workflow "$workflow_name" --limit $num_workflows

