#!/bin/bash
set -e

# keep the container alive in the background or in forground
if [[ $1 == "-d" ]]; then
  echo "Sysbench container running ..."
  while true; do sleep 1000; done
fi