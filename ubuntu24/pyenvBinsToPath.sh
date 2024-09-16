#!/bin/bash

# kind of a hack, but an easy enough approach to adding `/.pyenv/bin/yt-dlp` to PATH
# source this in the running container
for pyenv_version_bin in /.pyenv/versions/*/bin; do
    if [ -d "$pyenv_version_bin" ]; then
        export PATH="$pyenv_version_bin:$PATH"
        echo '"$pyenv_version_bin" added to PATH'
    fi
done

echo $PATH
