#!/usr/bin/env bash

# @raycast.schemaVersion 1
# @raycast.title Open Langfuse Trace (UUID from Clipboard)
# @raycast.mode compact
# @raycast.packageName Langfuse
# @raycast.icon 🔗

set -Eeuo pipefail
IFS=$'\n\t'

die() {
  echo "Error: $*" >&2
  exit 1
}

normalize_uuid() {
  local raw="$1"
  local u

  # Strip whitespace/newlines, braces, and optional urn prefix
  u="$(printf '%s' "$raw" | tr -d '[:space:]' | tr -d '{}' )"
  u="${u#urn:uuid:}"
  u="${u#URN:UUID:}"

  # Accept canonical UUID: 8-4-4-4-12
  if [[ "$u" =~ ^[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}$ ]]; then
    printf '%s' "$u"
    return 0
  fi

  # Accept 32 hex and normalize to canonical
  if [[ "$u" =~ ^[0-9A-Fa-f]{32}$ ]]; then
    printf '%s-%s-%s-%s-%s' \
      "${u:0:8}" "${u:8:4}" "${u:12:4}" "${u:16:4}" "${u:20:12}"
    return 0
  fi

  return 1
}

trap 'die "Command failed (line $LINENO): $BASH_COMMAND"' ERR

uuid_raw="$(pbpaste || true)"
[[ -n "${uuid_raw}" ]] || die "Clipboard is empty"

uuid="$(normalize_uuid "$uuid_raw")" || die "Clipboard does not look like a UUID: $(printf '%s' "$uuid_raw" | tr -d '[:space:]')"

url="https://us.cloud.langfuse.com/project/clujx7gs90000paexu5kzpxj1/traces/${uuid}"
open "$url"
echo "Opened: $url"
