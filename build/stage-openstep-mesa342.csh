#!/bin/csh -f
# Copy only source and release metadata needed for a private target build.

if ($#argv != 1) then
    echo "usage: stage-openstep-mesa342.csh /mounted/source/root"
    exit 2
endif

set source_root = $argv[1]/opennstep-mesa342
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
    echo "stage-openstep-mesa342: MESA_STAGE_PARENT must be an absolute path"
    exit 2
endsw
set stage_root = "$MESA_STAGE_PARENT/OpenStepMesa342"
set stage_source = $stage_root/src

if (! -r $source_root/upstream/Mesa-3.4.2/Make-config || ! -r $source_root/packaging/openstep/build-split-packages.csh || ! -r $source_root/packaging/openstep/OpenStepMesa342Libraries.info || ! -r $source_root/packaging/openstep/OpenStepMesa342Headers.info || ! -r $source_root/packaging/openstep/OpenStepMesa342Demos.info || ! -r $source_root/packaging/openstep/OpenStepMesa342.pre_install || ! -r $source_root/packaging/openstep/OpenStepMesa342Headers.pre_install || ! -r $source_root/packaging/openstep/OpenStepMesa342Demos.pre_install || ! -r $source_root/packaging/openstep/OpenStepMesa342.post_install || ! -r $source_root/examples/osmesa-clear.c || ! -r $source_root/examples/build-mesaview.csh || ! -r $source_root/build/build-openstep-mesa342.csh || ! -r $source_root/test/openstep/build-package-mesa-consumer.csh) then
    echo "stage-openstep-mesa342: source root is incomplete: $source_root"
    exit 2
endif

if (-d "$stage_root") rm -rf "$stage_root"
mkdir "$stage_root"
mkdir "$stage_source"
cp -R $source_root/upstream/Mesa-3.4.2 $stage_source/
cp -R $source_root/build $stage_source/
cp -R $source_root/packaging $stage_source/
cp -R $source_root/docs $stage_source/
cp -R $source_root/examples $stage_source/
cp -R $source_root/test $stage_source/
cp $source_root/NOTICE_OPENSTEP_PORT.md $stage_source/
cp $source_root/COPYRIGHT $stage_source/
cp $source_root/COPYING $stage_source/
if ($status != 0) then
    echo "stage-openstep-mesa342: copy failed"
    exit 1
endif

#
# A mark that every copy above finished.
#
# The status check only sees the last one, so an earlier failure is invisible
# to it.  Under /tmp the next restart swept a half-copied tree away; anywhere
# that survives, it would sit there waiting to be believed by a build that
# only looks for Make-config.  Written last, and the build refuses without it.
#
echo "staged" > "$stage_root/.stage-complete"

echo "stage-openstep-mesa342: PASS $stage_source"
