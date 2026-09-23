#!/usr/bin/env bash
# Point Formula/tmux-companion.rb at a published release.
#
# usage: scripts/update-formula.sh <tag> <checksums.txt> [formula]
#          <tag>            the release tag, for example v0.1.0
#          <checksums.txt>  the file published with that release
#          [formula]        default Formula/tmux-companion.rb
#
# Rewrites the `version` line and the four `sha256` lines, matching each
# checksum to the `url` line above it by target triple. Every one of the four
# targets has to be in checksums.txt or the script stops without writing, so a
# release that only half uploaded cannot leave two real checksums and two
# zeros in the formula.
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

TARGETS="aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl"

[ -f "$SUMS" ]    || { echo "no checksums file at $SUMS" >&2; exit 1; }
[ -f "$FORMULA" ] || { echo "no formula at $FORMULA" >&2; exit 1; }

# The tag carries the leading v, the formula's version does not.
VERSION=${TAG#v}

# Checked before anything is written. A missing target here means the release
# is incomplete, and half a formula is worse than the placeholder.
for t in $TARGETS; do
  asset="tmux-companion-$TAG-$t.tar.gz"
  grep -q "[[:space:]]\*\{0,1\}$asset\$" "$SUMS" ||
    { echo "$asset is not listed in $SUMS" >&2; exit 1; }
done

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

awk -v version="$VERSION" -v tag="$TAG" -v sums="$SUMS" '
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
# The version line, placeholder marker and all.
/^[ \t]*version "/ {
  sub(/version "[^"]*".*$/, "version \"" version "\"")
  print; next
}
# Remember which target the url above this sha256 line is for.
/^[ \t]*url "/ {
  # The url interpolates #{version}, so the triple is the only stable thing to
  # match on, and the asset name gets rebuilt from the tag below.
  pending = ""
  if (match($0, /(aarch64|x86_64)-(apple-darwin|unknown-linux-musl)/))
    pending = substr($0, RSTART, RLENGTH)
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
  if (filled != 4) {
    print "update-formula.sh: filled " filled " of 4 sha256 lines" > "/dev/stderr"
    exit 1
  }
}
' "$FORMULA" > "$tmp"

# Copied rather than moved: mktemp makes the file 0600, and a mv would hand the
# formula those permissions, which `brew style` then fails on.
cat "$tmp" > "$FORMULA"
echo "update-formula.sh: $FORMULA now points at $TAG"
