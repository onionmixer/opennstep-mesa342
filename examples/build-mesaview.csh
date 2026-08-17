#!/bin/csh -f
# Rebuild the original Mesa 3.4.2 OPENSTEP MesaView application in place.
set prefix = /LocalDeveloper
if ($#argv == 1) set prefix = $argv[1]
cc -m486 -arch i386 -I. -I$prefix/Headers MesaView.m MesaView_main.m mesadraw.c vect3d.c $prefix/Libraries/libGLU.a $prefix/Libraries/libGL.a -lm -framework AppKit -framework Foundation -o MesaView
if ($status != 0) exit 1
file MesaView | grep i386 > /dev/null
if ($status != 0) then
    echo "build-mesaview: compiler did not produce i386 Mach-O"
    exit 1
endif
echo "build-mesaview: PASS ./MesaView"
