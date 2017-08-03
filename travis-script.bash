#!/bin/bash
set -euo pipefail
# Used by travis to trigger deployments or builds
# Keeping this here rather than make travis.yml too complex

ACTION="${1}"
PUSH=''
if [[ ${ACTION} == 'build' ]]; then
    if [[ ${TRAVIS_PULL_REQUEST} == 'false' ]]; then
        PUSH='--push'
        # Assume we're in master and have secrets!
        docker login -u $DOCKER_USERNAME -p "$DOCKER_PASSWORD" quay.io
    fi

    ./build.py --commit-range ${TRAVIS_COMMIT_RANGEA} ${PUSH}
elif [[ ${ACTION} == 'deploy' ]]; then
    curl \
        -d crypt-key="${GIT_CRYPT_KEY}" \
        -d release=prod \
        -d commit=${TRAVIS_COMMIT} \
        -d repo=https://github.com/yuvipanda/paws \
        -H 'Authorization: Bearer ${DEPLOY_HOOK_KEY}' \
        https://paws-deploy-hook.tools.wmflabs.org/deploy
fi
