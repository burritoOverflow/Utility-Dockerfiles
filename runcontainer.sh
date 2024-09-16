#!/usr/bin/env bash

does_exist() {
    command -v "$1" >/dev/null 2>&1
}

usage() {
    echo "Usage: $0 [-v volume] [-i image] [-l localpath ] [-h (help)]"
}

strip_trailing_slash_if_present() {
    local input="$1"

    if [[ "$input" == */ ]]; then
        echo "${input%/}"
    else
        echo "$input"
    fi
}

# this will be a local dirpath, as those are the container names when created
# using the `buildimage` script
CONTAINER_IMAGE="" # meh this is actually a local directory path; kind of rubbish
LOCAL_DIR_PATH=""  # local path to mount in the container
VOLUME_MOUNT=""    # path in the container

# Parse arguments
while getopts "i:l:v:h" opt; do
    case ${opt} in
    i) CONTAINER_IMAGE="$OPTARG" ;;
    l) LOCAL_DIR_PATH="$OPTARG" ;;
    v) VOLUME_MOUNT="$OPTARG" ;;
    h)
        usage
        exit 0
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        usage
        exit 1
        ;;
    esac
done

# allow for tab-completion
CONTAINER_IMAGE=$(strip_trailing_slash_if_present $CONTAINER_IMAGE)

# As mentioned above, this is dirname which pertains to container name
if [ -z "$CONTAINER_IMAGE" ] || [ ! -d "$CONTAINER_IMAGE" ]; then
    # TODO be nice and spilit these cases each with a seperate message
    echo "Missing or invalid arg for local directory path (container image)"
    usage
    exit 1
fi

if [ -z "$VOLUME_MOUNT" ] || [ -z "$LOCAL_DIR_PATH" ]; then
    echo "Requires both local path and volume mount path if either arg is provided"
    usage
    exit 1
fi

# TODO this is copypasta from the build script
if does_exist podman; then
    CONTAINER_CMD="podman"
elif does_exist docker; then
    CONTAINER_CMD="docker"
else
    echo "Requires either Podman or Docker; neither found"
    exit 1
fi

echo "Using '$CONTAINER_CMD'.."

# determine if there exist a container built with this image name
EXISTS=$($CONTAINER_CMD images --format "{{.Repository}}" | grep $CONTAINER_IMAGE)

if [ ${#EXISTS[@]} -eq 0 ]; then
    echo "No container image found for '$CONTAINER_IMAGE'"
    exit 1
fi

echo "Using container image '$CONTAINER_IMAGE'; mounting local path '$LOCAL_DIR_PATH' at '$VOLUME_MOUNT'"

# as above
CLEAN_VOLUME_MOUNT=$(strip_trailing_slash_if_present $VOLUME_MOUNT)

# TODO add arg to change this.
COMMAND=/bin/bash
$CONTAINER_CMD run -it -v $LOCAL_DIR_PATH:/$CLEAN_VOLUME_MOUNT $CONTAINER_IMAGE $COMMAND
