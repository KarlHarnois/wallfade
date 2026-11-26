#!/usr/bin/env bash
set -euo pipefail

uncommented=$(awk '
  BEGIN {
    in_string = 0
    after_backslash = 0
  }
  {
    kept = ""
    for (i = 1; i <= length($0); i++) {
      character = substr($0, i, 1)
      if (after_backslash) after_backslash = 0
      else if (in_string && character == "\\") after_backslash = 1
      else if (character == "\"") in_string = !in_string
      else if (!in_string && character == ";") break
      kept = kept character
    }
    print kept
  }
' project.knv || true)
versions=$(printf '%s\n' "$uncommented" | grep -o ':knave "[^"]*"' | cut -d '"' -f 2 || true)
test -n "$versions" || { echo "::error file=project.knv::project.knv records no :knave \"x.y.z\" on one line"; exit 1; }
test "$(echo "$versions" | wc -l)" -eq 1 || { echo "::error file=project.knv::project.knv records more than one :knave version"; exit 1; }
echo "KNAVE_VERSION=$versions" >> "$GITHUB_ENV"
