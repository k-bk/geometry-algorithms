#!/bin/bash
# Updates packages given as github links

arg=$( echo $1 | sed 's|^/||' )
user=$( echo $arg | cut -f1 -d/ )
repo=$( echo $arg | cut -f2 -d/)
branch=$( echo $arg | cut -f3 -d/)
file=$( echo $arg | cut -f4 -d/)

url="https://api.github.com/repos/$user/$repo/commits/$branch?path=$file"
raw_url="https://raw.githubusercontent.com/$user/$repo/$branch/$file"

if [[ -f $file ]]; then
    remote_timestamp=$( curl -s -I $url | grep "Last-Modified:" | sed 's/Last-Modified://' | date -f - +%s )
    local_timestamp=$(stat -c%Y $file)
    if [[ $local_timestamp -ge $remote_timestamp ]]; then
        echo "✔ $file"
        exit 0
    fi
fi

echo "✘ $file"
curl --progress-bar $raw_url -o $file
exit 0
