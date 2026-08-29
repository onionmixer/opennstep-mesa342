#!/bin/bash
# Turn the three finished .pkg directories into the release assets, on the
# HOST.
#
#   sh .../packaging/openstep/make-release-assets.sh <pkg-tar-dir> [outdir]
#
# WHY THIS EXISTS.  The three packages this repository publishes were
# archived by hand the first time, and a release that cannot be rebuilt from
# a script is a release nobody can reproduce -- which is what was noticed
# when the published one turned out to predate ten commits of OSMesa work.
# The recipe is the Matrox project's, deliberately: these are sibling
# releases and the asset names, the compression and the two checks below
# already agreed, so the script agrees too rather than inventing a second
# convention.
#
# The target side writes one plain tar per package; this side only compresses
# and names, so it needs no OPENSTEP and touches nothing on the machine.
set -euo pipefail

src="${1:?usage: make-release-assets.sh <pkg-tar-dir> [outdir]}"
root=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
dest="${2:-$root/release-assets}"
version=3.4.2-openstep.1

declare -A NAMES=(
  [OpenStepMesa342Libraries]="OpenStep-Mesa-${version}-i486-Libraries"
  [OpenStepMesa342Headers]="OpenStep-Mesa-${version}-i486-Headers"
  [OpenStepMesa342Demos]="OpenStep-Mesa-${version}-i486-Demos"
)

for n in "${!NAMES[@]}"; do
    [[ -f "$src/$n.pkg.tar" ]] || {
        echo "make-release-assets: missing $src/$n.pkg.tar" >&2
        exit 1
    }
done

rm -rf "$dest"
mkdir -p "$dest"
for n in "${!NAMES[@]}"; do
    out="$dest/${NAMES[$n]}.pkg.tar.gz"
    gzip -9 -c "$src/$n.pkg.tar" > "$out"
    # Taken once into a variable rather than piped into two greps: under
    # pipefail a `grep -q` that exits early kills the tar upstream with
    # SIGPIPE, and the shell reports that as a failure of the whole check.
    listing=$(tar tzvf "$out")
    # An asset that unpacks to nothing is worse than a missing one.
    grep "$n.pkg/$n.tar.Z" <<<"$listing" > /dev/null
    # The executable bit on pre_install has to survive the round trip, or
    # Installer runs nothing and reports success.
    grep "$n.pre_install" <<<"$listing" | grep 'r-x' > /dev/null
    echo "  ${NAMES[$n]}.pkg.tar.gz  $(stat -c%s "$out") bytes"
done

( cd "$dest" && sha256sum *.pkg.tar.gz > SHA256SUMS )
echo "make-release-assets: PASS $dest"
