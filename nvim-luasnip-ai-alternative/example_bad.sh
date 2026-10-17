#!/usr/bin/env bash
# Downloads a release and unpacks it into the deploy directory.

deploy_dir="$1"
cd "$deploy_dir" || exit 1
curl -sSL https://example.com/release.tar.gz -o release.tar.gz
tar xzf release.tar.gz
