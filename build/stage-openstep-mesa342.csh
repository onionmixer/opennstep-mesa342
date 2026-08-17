#!/bin/csh -f
# Copy only source and release metadata needed for a private target build.

if ($#argv != 1) then
    echo "usage: stage-openstep-mesa342.csh /mounted/source/root"
    exit 2
endif

set source_root = $argv[1]/opennstep-mesa342
set stage_root = /tmp/OpenStepMesa342
set stage_source = $stage_root/src

if (! -r $source_root/upstream/Mesa-3.4.2/Make-config || ! -r $source_root/packaging/openstep/build-split-packages.csh || ! -r $source_root/packaging/openstep/OpenStepMesa342Libraries.info || ! -r $source_root/packaging/openstep/OpenStepMesa342Headers.info || ! -r $source_root/packaging/openstep/OpenStepMesa342.pre_install || ! -r $source_root/packaging/openstep/OpenStepMesa342Headers.pre_install || ! -r $source_root/packaging/openstep/OpenStepMesa342.post_install || ! -r $source_root/examples/osmesa-clear.c || ! -r $source_root/build/build-openstep-mesa342.csh || ! -r $source_root/test/openstep/build-package-mesa-consumer.csh) then
    echo "stage-openstep-mesa342: source root is incomplete: $source_root"
    exit 2
endif

if (-d $stage_root) rm -rf $stage_root
mkdir $stage_root
mkdir $stage_source
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

echo "stage-openstep-mesa342: PASS $stage_source"
