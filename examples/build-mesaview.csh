#!/bin/csh -f
# Rebuild the original Mesa 3.4.2 OPENSTEP MesaView application bundle in place.
set prefix = /LocalDeveloper
if ($#argv == 1) set prefix = $argv[1]
set app = MesaView.app
set resources = $app/Resources

if (! -r PB.project || ! -d English.lproj/MesaView.nib) then
    echo "build-mesaview: missing original ProjectBuilder resources"
    exit 2
endif
if (-d $app) rm -rf $app
/bin/mkdirs $resources/English.lproj
/usr/lib/mergeInfo PB.project -o $resources/Info-nextstep.plist
if ($status != 0) exit 1
cp -R English.lproj/MesaView.nib $resources/English.lproj/
if ($status != 0) exit 1
cc -m486 -arch i386 -I. -I$prefix/Headers MesaView.m MesaView_main.m mesadraw.c vect3d.c $prefix/Libraries/libGLU.a $prefix/Libraries/libGL.a -lm -framework AppKit -framework Foundation -o $app/MesaView
if ($status != 0) exit 1
file $app/MesaView | grep i386 > /dev/null
if ($status != 0) then
    echo "build-mesaview: compiler did not produce i386 Mach-O"
    exit 1
endif
echo "build-mesaview: PASS ./$app/MesaView"
