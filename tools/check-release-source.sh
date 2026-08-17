#!/bin/sh
# Read-only host gate for the Mesa repository's package source contract.

set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

require_file() {
    if [ ! -f "$1" ]; then
        echo "check-release-source: missing $1" >&2
        exit 1
    fi
}

for file in \
    "$root/README.md" \
    "$root/NOTICE_OPENSTEP_PORT.md" \
    "$root/COPYRIGHT" \
    "$root/COPYING" \
    "$root/docs/TESTING.md" \
    "$root/docs/SPLIT_PACKAGE_CONTRACT.md" \
    "$root/upstream/Mesa-3.4.2/Make-config" \
    "$root/upstream/Mesa-3.4.2/docs/README.OpenStep" \
    "$root/upstream/Mesa-3.4.2/docs/COPYRIGHT" \
    "$root/upstream/Mesa-3.4.2/docs/COPYING" \
    "$root/packaging/openstep/OpenStepMesa342.info" \
    "$root/packaging/openstep/OpenStepMesa342.pre_install" \
    "$root/packaging/openstep/OpenStepMesa342.post_install" \
    "$root/packaging/openstep/OpenStepMesa342Libraries.info" \
    "$root/packaging/openstep/OpenStepMesa342Headers.info" \
    "$root/packaging/openstep/OpenStepMesa342Demos.info" \
    "$root/packaging/openstep/OpenStepMesa342Headers.pre_install" \
    "$root/packaging/openstep/OpenStepMesa342Demos.pre_install" \
    "$root/packaging/openstep/installer-architecture-marker.c" \
    "$root/packaging/openstep/build-split-packages.csh" \
    "$root/packaging/openstep/PAYLOAD_MANIFEST.txt" \
    "$root/packaging/openstep/build-package.csh" \
    "$root/packaging/openstep/verify-package.csh" \
    "$root/build/stage-openstep-mesa342.csh" \
    "$root/build/build-openstep-mesa342.csh" \
    "$root/test/openstep/package-mesa-consumer.c" \
    "$root/test/openstep/build-package-mesa-consumer.csh" \
    "$root/examples/osmesa-clear.c" \
    "$root/examples/build-osmesa-clear.csh" \
    "$root/examples/build-mesaview.csh"
do
    require_file "$file"
done

if ! cmp -s "$root/COPYRIGHT" "$root/upstream/Mesa-3.4.2/docs/COPYRIGHT" || \
   ! cmp -s "$root/COPYING" "$root/upstream/Mesa-3.4.2/docs/COPYING"; then
    echo "check-release-source: root license copies differ from upstream" >&2
    exit 1
fi

for info in \
    "$root/packaging/openstep/OpenStepMesa342Libraries.info" \
    "$root/packaging/openstep/OpenStepMesa342Headers.info" \
    "$root/packaging/openstep/OpenStepMesa342Demos.info"
do
    for field in Title Version Description DefaultLocation Relocatable Application UseUserMask DiskName DeleteWarning
    do
        if ! awk -v field="$field" '$1 == field && length($0) > length(field) { found = 1 } END { exit(found ? 0 : 1) }' "$info"; then
            echo "check-release-source: missing $field in $info" >&2
            exit 1
        fi
    done
    if ! grep -qx 'DefaultLocation /LocalDeveloper' "$info" || \
       ! grep -qx 'Relocatable YES' "$info" || \
       ! grep -qx 'Application NO' "$info"; then
        echo "check-release-source: Installer metadata policy changed in $info" >&2
        exit 1
    fi
done

if ! grep -q 'Intel i486' "$root/packaging/openstep/OpenStepMesa342.info" || \
   ! grep -q 'Intel i486' "$root/packaging/openstep/OpenStepMesa342Headers.info" || \
   ! grep -q '/usr/bin/arch' "$root/packaging/openstep/OpenStepMesa342.pre_install" || \
   ! grep -q 'ranlib' "$root/packaging/openstep/OpenStepMesa342.post_install" || \
   ! grep -q 'OpenStepMesa342Headers-Intel' "$root/packaging/openstep/build-split-packages.csh"; then
    echo "check-release-source: Intel archive contract is incomplete" >&2
    exit 1
fi

for item in \
    Headers/GL/gl.h \
    Headers/GL/glext.h \
    Headers/GL/glu.h \
    Headers/GL/glu_mangle.h \
    Headers/GL/osmesa.h \
    Libraries/libGL.a \
    Libraries/libGLU.a \
    Tools/OpenStepMesa342-Intel
do
    if ! grep -qx "$item" "$root/packaging/openstep/PAYLOAD_MANIFEST.txt"; then
        echo "check-release-source: payload manifest lacks $item" >&2
        exit 1
    fi
done

echo "check-release-source: PASS Mesa source, licenses and Installer contract"
