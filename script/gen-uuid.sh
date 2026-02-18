#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Generate UUID v4 (Copy to Clipboard)
# @raycast.mode compact
# @raycast.packageName UUID
# @raycast.icon 🧬

set -Eeuo pipefail
IFS=$'\n\t'

die() {
  echo "Error: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing required command: $1"
}

trap 'die "Command failed (line $LINENO): $BASH_COMMAND"' ERR

require_cmd python3
require_cmd pbcopy

generated_uuid="$(python3 -c 'import uuid; print(uuid.uuid4())')"
[[ -n "$generated_uuid" ]] || die "Failed to generate UUID"

printf '%s' "$generated_uuid" | pbcopy

echo "$generated_uuid copied to clipboard"
