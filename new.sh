#!/usr/bin/env bash

NEW_SYNTAX="./new.sh YYYY.MM.DD <pastebin-url> <image-url>"

if (( $# == 2 || $# == 3 )); then
    NEW_DATE=$1
    NEW_PASTEBIN_URL=$2
    NEW_IMAGE_URL=$3
else
    echo "syntax: ${NEW_SYNTAX}"
    exit 1
fi

# Validate date input
#
if NEW_HR_DATE=$(date -j -f "%Y.%m.%d" "${NEW_DATE}" +'%d %B %Y' 2> /dev/null); then
    echo "Got date: ${NEW_HR_DATE}"
else
    echo "syntax: ${NEW_SYNTAX}"
    exit 1
fi

# Get image (if there is one)
#
if [[ ! -n ${NEW_IMAGE_URL} ]]; then
    echo "No image"
elif ! wget -O "/tmp/${NEW_DATE}.png" "${NEW_IMAGE_URL}" 2> /dev/null; then
    echo "Error downloading image"
    exit 1
fi

# Get Pastebin data
#
echo "Got Pastebin path: ${NEW_PASTEBIN_URL}"

NEW_RAW_PASTEBIN_URL="https://pastebin.com/raw/"$(echo "${NEW_PASTEBIN_URL}" | sed 's|.*/||')

echo "Raw Pastebin URL: ${NEW_RAW_PASTEBIN_URL}"

if ! wget -O "/tmp/${NEW_DATE}.md" "${NEW_RAW_PASTEBIN_URL}" 2> /dev/null; then
    echo "Error downloading raw Pastebin contents"
    exit 1
fi

# If we got here, we have all the parts
# Do the thing

if [[ -n ${NEW_IMAGE_URL} ]]; then
    mv "/tmp/${NEW_DATE}.png" images/
    echo -e '![Our Board](images/'"${NEW_DATE}"'.png)\n' > "${NEW_DATE}.md"
fi

cat "/tmp/${NEW_DATE}.md" >> "${NEW_DATE}.md"
rm "/tmp/${NEW_DATE}.md"

echo "* [${NEW_HR_DATE}](${NEW_DATE}.md)" >> README.md

echo "Done!"