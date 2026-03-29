#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Open Langfuse Trace (ID from Clipboard)
# @raycast.mode compact
# @raycast.packageName Langfuse
# @raycast.icon 🔗

set -Eeuo pipefail
IFS=$'\n\t'

die() {
  echo "Error: $*" >&2
  exit 1
}

trap 'die "Command failed (line $LINENO): $BASH_COMMAND"' ERR

trace_id="$(pbpaste || true)"
[[ -n "${trace_id}" ]] || die "Clipboard is empty"

url="https://us.cloud.langfuse.com/project/clujx7gs90000paexu5kzpxj1/traces/${trace_id}"
open "$url"
echo "Opened: $url"
