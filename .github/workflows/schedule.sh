#!/bin/bash -eux

file=.github/cache/file

[[ -f $file ]] || install -m 644 -D /dev/null $file

eval "$(cat $file)"
new=$(wget -qO- https://api.github.com/repos/actions/runner/releases/latest | sed 's/^ *"tag_name": "v\(.*\)",$/\1/p' -n)

if ! [[ "${cache:-}" == "$new" ]]; then
  curl -fSso /dev/null -X POST $trigger
  echo "cache=$new" > $file
fi
