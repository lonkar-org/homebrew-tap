#!/usr/bin/env bash
# Point Formula/tmux-companion.rb at a published release.
#
# usage: scripts/update-formula.sh <tag> <checksums.txt> [formula]
#          <tag>            the release tag, for example v0.1.0
#          <checksums.txt>  the file published with that release
#          [formula]        default Formula/tmux-companion.rb
#
# Rewrites the four `url` lines and the four `sha256` lines, matching each
# checksum to the url above it by target triple. Every one of the four targets
# has to be in checksums.txt or the script stops without writing, so a release
# that only half uploaded cannot leave two real checksums and two zeros in the
# formula. The formula carries no `version` line, because brew reads the version
# out of the url and `brew audit` calls the second copy redundant.
#
# tmux-companion's release workflow runs this after the publish job. Run it by
# hand the same way when a release predates the automation:
#
#   gh release download v0.1.0 --repo lonkar-org/tmux-companion --pattern checksums.txt
#   scripts/update-formula.sh v0.1.0 checksums.txt
set -euo pipefail

TAG=${1:?usage: update-formula.sh <tag> <checksums.txt> [formula]}
SUMS=${2:?usage: update-formula.sh <tag> <checksums.txt> [formula]}
FORMULA=${3:-Formula/tmux-companion.rb}

BASE="https://github.com/lonkar-org/tmux-companion/releases/download"
TARGETS="aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl"

[ -f "$SUMS" ]    || { echo "no checksums file at $SUMS" >&2; exit 1; }
[ -f "$FORMULA" ] || { echo "no formula at $FORMULA" >&2; exit 1; }

# Checked before anything is written. A missing target here means the release
# is incomplete, and half a formula is worse than the placeholder.
for t in $TARGETS; do
  asset="tmux-companion-$TAG-$t.tar.gz"
  grep -q "[[:space:]]\*\{0,1\}$asset\$" "$SUMS" ||
    { echo "$asset is not listed in $SUMS" >&2; exit 1; }
done

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

awk -v tag="$TAG" -v base="$BASE" -v sums="$SUMS" '
BEGIN {
  # sha256sum writes "<sum>  <file>" and the release strips the ./ prefix, so
  # split on whitespace rather than counting spaces.
  while ((getline line < sums) > 0) {
    n = split(line, f, /[ \t]+/)
    if (n < 2) continue
    sum = f[1]; file = f[2]
    sub(/^\*/, "", file)
    by_file[file] = sum
  }
  close(sums)
}
# The url carries the old tag twice, so it gets rebuilt rather than patched,
# and the target triple in it says which checksum the next line wants.
/^[ \t]*url "/ {
  pending = ""
  if (match($0, /(aarch64|x86_64)-(apple-darwin|unknown-linux-musl)/)) {
    pending = substr($0, RSTART, RLENGTH)
    indent = $0; sub(/[^ \t].*$/, "", indent)
    $0 = indent "url \"" base "/" tag "/tmux-companion-" tag "-" pending ".tar.gz\""
    urls++
  }
  print; next
}
/^[ \t]*sha256 "/ && pending != "" {
  file = "tmux-companion-" tag "-" pending ".tar.gz"
  if (file in by_file) {
    sub(/sha256 "[^"]*"/, "sha256 \"" by_file[file] "\"")
    filled++
  }
  pending = ""
  print; next
}
{ print }
END {
  if (urls != 4 || filled != 4) {
    print "update-formula.sh: rewrote " urls " of 4 urls and " filled \
          " of 4 sha256 lines" > "/dev/stderr"
    exit 1
  }
}
' "$FORMULA" > "$tmp"

# Copied rather than moved: mktemp makes the file 0600, and a mv would hand the
# formula those permissions, which `brew style` then fails on.
cat "$tmp" > "$FORMULA"
echo "update-formula.sh: $FORMULA now points at $TAG"
