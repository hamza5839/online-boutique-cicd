#!/usr/bin/env bash
set -euo pipefail

for file in Dockerfile go.mod go.sum; do
    if [[ ! -f "app/frontend/$file" ]]; then
        printf 'Missing required file: %s\n' "$file" >&2
        exit 1
    fi
done

printf 'Required frontend files found\n'

if ! grep -q 'AS builder' app/frontend/Dockerfile; then
    printf 'Dockerfile builder stage not found\n' >&2
    exit 1
fi

printf 'Building the testing image\n'
docker build --target builder -t frontend:test app/frontend

printf 'Running Go tests\n'
docker run --rm frontend:test go test -v ./... 2>&1 |
    tee test-report.txt
