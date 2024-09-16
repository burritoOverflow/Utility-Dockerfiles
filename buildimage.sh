#!/usr/bin/env bash

set -x

does_exist() {
    command -v "$1" >/dev/null 2>&1
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory-containing-dockerfile>"
    exit 1
fi

if does_exist podman; then
    CONTAINER_CMD="podman"
elif does_exist docker; then
    CONTAINER_CMD="docker"
else
    echo "Requires either Podman or Docker; neither found"
    exit 1
fi

echo 'Using '$CONTAINER_CMD'..'

DIRECTORY=$1

if [ ! -d "$DIRECTORY" ]; then
    echo "Directory '$DIRECTORY' does not exist."
    exit 1
fi

DOCKERFILE=$(find "$DIRECTORY" -type f -name 'Dockerfile.*' | head -n 1)

if [ -z "$DOCKERFILE" ]; then
    echo "No Dockerfile found in directory '$DIRECTORY'"
    exit 1
else
    echo "Building image with Dockerfile '$DOCKERFILE'"
fi

# we'll just use the dirname as the image name
IMAGE_TAG="$(basename "$DIRECTORY")"

echo "Building Docker image '$IMAGE_TAG' from Dockerfile in '$DIRECTORY'"

$CONTAINER_CMD build -t "$IMAGE_TAG" -f "$DOCKERFILE" "$DIRECTORY"

if [ $? -eq 0 ]; then
    echo "Docker image '$IMAGE_TAG' built successfully"
    $CONTAINER_CMD images --filter=reference="$IMAGE_TAG"
else
    echo "Failed to build Docker image."
    exit 1
fi
