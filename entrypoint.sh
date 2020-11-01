#!/bin/sh

set -eu

echo "$SKICKA_CONFIG" > $HOME/.skicka.config && chmod 600 $HOME/.skicka.config
echo "$SKICKA_TOKENCACHE_JSON" > $HOME/.skicka.tokencache.json

if [ -n "$DOWNLOAD_FROM" ]; then
    echo 'Input download-from has been specified. This action will run the download.'
    skicka -no-browser-auth download -ignore-times "$DOWNLOAD_FROM" "$DOWNLOAD_TO"
elif [ -n "$UPLOAD_TO" ]; then
    echo 'Input upload-to has been specified. This action will run the upload.'
    skicka -no-browser-auth upload -ignore-times "$UPLOAD_FROM" "$UPLOAD_TO"

    # Remove outdated
    if [ $REMOVE_OUTDATED == "true" ]; then
        # This command will download files that don't exist locally,
        # and remove files from downloaded files list.
        skicka -verbose download -ignore-times "$UPLOAD_TO" "$UPLOAD_FROM" 2>&1 | \
            sed "/Downloaded and wrote/!d" | \
            sed -E "s/.*bytes to //" | \
            xargs -I{} skicka rm "$UPLOAD_FROM{}" || true
    elif [ $REMOVE_OUTDATED != "false" ]; then
        echo '$REMOVE_OUTDATED must be "true" or "false".'
        exit 1
    fi
else
    echo 'Neither input download-from nor upload-to has been specified.'
    echo 'You need to specify which one.'
    exit 1
fi
