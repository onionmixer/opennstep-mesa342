#!/bin/csh -f
# Build and run using only files installed by OpenStepMesa342.pkg.

if ($#argv != 1) then
    echo "usage: build-package-mesa-consumer.csh /installed/package/prefix"
    exit 2
endif

set prefix = $argv[1]
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
    echo "build-package-mesa-consumer: MESA_STAGE_PARENT must be an absolute path"
    exit 2
endsw
set stage_root = "$MESA_STAGE_PARENT/OpenStepMesa342"
set test_source = "$stage_root/src/test/openstep/package-mesa-consumer.c"
set test_binary = "$stage_root/package-mesa-consumer"

foreach file ( $prefix/Headers/GL/gl.h $prefix/Headers/GL/glu.h $prefix/Headers/GL/osmesa.h $prefix/Libraries/libGL.a $prefix/Libraries/libGLU.a )
    if (! -r $file) then
        echo "build-package-mesa-consumer: package file missing: $file"
        exit 2
    endif
end
if (! -r $test_source) then
    echo "build-package-mesa-consumer: stage source missing"
    exit 2
endif

cc -m486 -I$prefix/Headers $test_source -L$prefix/Libraries -lGLU -lGL -lm -o $test_binary
if ($status != 0) exit 1
$test_binary
if ($status != 0) exit 1
echo "build-package-mesa-consumer: PASS $prefix"
