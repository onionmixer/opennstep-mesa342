#!/bin/csh -f
# Build the historical Mesa OPENSTEP static-library target in private storage.

set stage_root = /tmp/OpenStepMesa342
set mesa_root = $stage_root/src/Mesa-3.4.2
set lib_root = $mesa_root/lib

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
