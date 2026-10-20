#!/bin/sh
set -eu

HOOK="$HOME/.config/cmux/hooks/opencode-primary-sound"
MARKER='[[opencode-main-attention]] '
TEMPORARY_DIRECTORY=$(mktemp -d)
trap 'rm -rf "$TEMPORARY_DIRECTORY"' EXIT

PLAYER="$TEMPORARY_DIRECTORY/afplay"
SOUND="$TEMPORARY_DIRECTORY/sound.m4a"
INJECTION_TARGET="$TEMPORARY_DIRECTORY/interpolated"
printf '#!/bin/sh\nexit 0\n' > "$PLAYER"
chmod +x "$PLAYER"
: > "$SOUND"

assert_json_equal() {
  actual=$1
  expected=$2
  if ! jq -ne --argjson actual "$actual" --argjson expected "$expected" '$actual == $expected' >/dev/null; then
    printf 'expected: %s\nactual:   %s\n' "$expected" "$actual" >&2
    exit 1
  fi
}

run_hook() {
  input=$1
  player=$2
  sound=$3
  printf '%s' "$input" | CMUX_PRIMARY_SOUND_PLAYER="$player" CMUX_PRIMARY_SOUND_FILE="$sound" "$HOOK"
}

for title in "Done: project" "Question: project" "Permission needed: project"; do
  input=$(jq -cn --arg title "$MARKER$title" '{version:1,notification:{title:$title},effects:{sound:true,paneFlash:true}}')
  output=$(run_hook "$input" "$PLAYER" "$SOUND")
  expected=$(jq -cn --arg title "$title" '{notification:{title:$title},effects:{sound:false}}')
  assert_json_equal "$output" "$expected"
done

input=$(jq -cn --arg title "${MARKER}\$(touch $INJECTION_TARGET)" '{version:1,notification:{title:$title},effects:{sound:true,paneFlash:true}}')
output=$(run_hook "$input" "$PLAYER" "$SOUND")
expected=$(jq -cn --arg title "\$(touch $INJECTION_TARGET)" '{notification:{title:$title},effects:{sound:false}}')
assert_json_equal "$output" "$expected"
test ! -e "$INJECTION_TARGET"

for title in "Subagent done: project" "Ordinary notification"; do
  input=$(jq -cn --arg title "$title" '{version:1,notification:{title:$title},effects:{sound:true,paneFlash:true}}')
  output=$(run_hook "$input" "$PLAYER" "$SOUND")
  assert_json_equal "$output" '{}'
done

input=$(jq -cn --arg title "${MARKER}Question: project" '{version:1,notification:{title:$title},effects:{sound:true,paneFlash:true}}')
output=$(run_hook "$input" "$TEMPORARY_DIRECTORY/missing-player" "$SOUND")
assert_json_equal "$output" '{"notification":{"title":"Question: project"}}'

output=$(run_hook "$input" "$PLAYER" "$TEMPORARY_DIRECTORY/missing-sound")
assert_json_equal "$output" '{"notification":{"title":"Question: project"}}'

output=$(run_hook '{not-json' "$PLAYER" "$SOUND")
test -z "$output"
