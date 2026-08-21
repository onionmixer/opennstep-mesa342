#!/bin/csh -f
# Build a native OPENSTEP Installer package from a clean private Mesa build.

#
# Where the staging tree lives.  A PARENT, never the tree itself: this script
# removes that tree before copying, and a variable naming the tree outright
# would be a variable naming anything at all to delete.  Whatever is set here,
# the only thing that can be removed is a directory called OpenStepMesa342.
#
# Unset means /tmp, exactly as before.  /tmp is emptied at boot, which is fine
# for a one-off build and wasteful when the same tree is wanted after a
# restart; pointing this somewhere that survives is the whole reason it exists.
#
# Empty is refused rather than defaulted: this csh answers -d on an empty
# string with true, so an empty value would walk straight into the removal.
#
#
# The names are short because they have to be: this csh refuses a variable
# name longer than 18 characters with "Variable syntax." and nothing else.
# Measured on the machine -- 18 works, 19 does not.
#
if (! $?MESA_STAGE_PARENT) setenv MESA_STAGE_PARENT /tmp
switch ("$MESA_STAGE_PARENT")
case /*:
    breaksw
default:
    echo "build-package: MESA_STAGE_PARENT must be an absolute path"
    exit 2
endsw
set stage_root = "$MESA_STAGE_PARENT/OpenStepMesa342"
set source_root = $stage_root/src
set mesa_root = $source_root/Mesa-3.4.2
set payload = $stage_root/payload
set dist = $stage_root/dist
set info = $source_root/packaging/openstep/OpenStepMesa342.info
set pre_install = $source_root/packaging/openstep/OpenStepMesa342.pre_install
set post_install = $source_root/packaging/openstep/OpenStepMesa342.post_install
set arch_src = $source_root/packaging/openstep/installer-architecture-marker.c
set arch_bin = $payload/Tools/OpenStepMesa342-Intel
set manifest = $source_root/packaging/openstep/PAYLOAD_MANIFEST.txt
set package_tool = /NextAdmin/Installer.app/package

if (! -x $package_tool) then
    echo "build-package: missing $package_tool"
    exit 2
endif
if (! -r $info) then
    echo "build-package: run stage-openstep-mesa342.csh first"
    exit 2
endif
if (! -r $pre_install) then
    echo "build-package: run stage-openstep-mesa342.csh first"
    exit 2
endif
if (! -r $post_install) then
    echo "build-package: run stage-openstep-mesa342.csh first"
    exit 2
endif
if (! -r $arch_src) then
    echo "build-package: run stage-openstep-mesa342.csh first"
    exit 2
endif
if (! -r $manifest) then
    echo "build-package: run stage-openstep-mesa342.csh first"
    exit 2
endif

csh -f $source_root/build/build-openstep-mesa342.csh
if ($status != 0) exit 1

if (-d $payload) rm -rf $payload
if (-d $dist) rm -rf $dist
/bin/mkdirs $payload/Headers/GL
/bin/mkdirs $payload/Libraries
/bin/mkdirs $payload/Tools
/bin/mkdirs $payload/Documentation/OpenStep-Mesa-3.4.2

foreach header ( gl.h glext.h glu.h glu_mangle.h osmesa.h )
    cp $mesa_root/include/GL/$header $payload/Headers/GL/
    if ($status != 0) exit 1
end
cp $mesa_root/lib/libGL.a $payload/Libraries/
cp $mesa_root/lib/libGLU.a $payload/Libraries/
cc -m486 -o $arch_bin $arch_src
if ($status != 0) then
    echo "build-package: cannot build i386 Installer architecture marker"
    exit 1
endif
chmod 555 $arch_bin
cp $mesa_root/docs/README.OpenStep $payload/Documentation/OpenStep-Mesa-3.4.2/README.OPENSTEP
cp $source_root/COPYRIGHT $payload/Documentation/OpenStep-Mesa-3.4.2/
cp $source_root/COPYING $payload/Documentation/OpenStep-Mesa-3.4.2/
cp $source_root/docs/PORT-NOTES.md $payload/Documentation/OpenStep-Mesa-3.4.2/
cp $source_root/docs/LINKING.md $payload/Documentation/OpenStep-Mesa-3.4.2/
cp $source_root/docs/RELEASE-MANIFEST.txt $payload/Documentation/OpenStep-Mesa-3.4.2/
if ($status != 0) exit 1

/bin/mkdirs $dist
$package_tool $payload $info -d $dist
if ($status != 0) exit 1

if (! -d $dist/OpenStepMesa342.pkg) then
    echo "build-package: package output missing"
    exit 1
endif
cp $pre_install $dist/OpenStepMesa342.pkg/OpenStepMesa342.pre_install
cp $post_install $dist/OpenStepMesa342.pkg/OpenStepMesa342.post_install
chmod 555 $dist/OpenStepMesa342.pkg/OpenStepMesa342.pre_install $dist/OpenStepMesa342.pkg/OpenStepMesa342.post_install
if ($status != 0) then
    echo "build-package: could not install post_install hook"
    exit 1
endif
echo "build-package: PASS $dist/OpenStepMesa342.pkg"
