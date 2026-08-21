#!/bin/csh -f
# Build the historical Mesa OPENSTEP static-library target in private storage.

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
    echo "build-openstep-mesa342: MESA_STAGE_PARENT must be an absolute path"
    exit 2
endsw
set stage_root = "$MESA_STAGE_PARENT/OpenStepMesa342"
set mesa_root = $stage_root/src/Mesa-3.4.2
set lib_root = $mesa_root/lib

#
# Refuse a tree that was never finished being staged.  See the mark written at
# the end of stage-openstep-mesa342.csh: without it a half-copied tree looks
# buildable, because everything below only asks for Make-config.
#
if (! -r "$stage_root/.stage-complete") then
    echo "build-openstep-mesa342: $stage_root was not staged completely"
    echo "build-openstep-mesa342: run stage-openstep-mesa342.csh first"
    exit 2
endif

if (! -r $mesa_root/Make-config || ! -x $mesa_root/bin/mklib.openstep) then
    echo "build-openstep-mesa342: run stage-openstep-mesa342.csh first"
    exit 2
endif

cd $mesa_root
make CC='cc -m486' openstep
if ($status != 0) exit 1

if (! -r $lib_root/libGL.a || ! -r $lib_root/libGLU.a) then
    echo "build-openstep-mesa342: expected libGL.a and libGLU.a"
    exit 1
endif
ar t $lib_root/libGL.a | grep osmesa.o
if ($status != 0) then
    echo "build-openstep-mesa342: libGL.a lacks osmesa.o"
    exit 1
endif
nm $mesa_root/src/OSmesa/osmesa.o | grep OSMesaCreateContext
if ($status != 0) then
    echo "build-openstep-mesa342: OSMesaCreateContext missing"
    exit 1
endif

echo "build-openstep-mesa342: PASS $lib_root/libGL.a $lib_root/libGLU.a"
