#!/bin/csh -f
# Verify Mesa's Library and Headers/Examples Installer packages separately.
set work = /tmp/OpenStepMesa342
set src = $work/src
set dist = $work/dist
set libraries = $dist/OpenStepMesa342Libraries.pkg
set headers = $dist/OpenStepMesa342Headers.pkg
set lunpack = $work/libraries-package-verify
set hunpack = $work/headers-package-verify
set installer_tar = /NextAdmin/Installer.app/installer_tar
set osmesa_member = $work/headers-package-verify-osmesa.o

foreach file ( $libraries/OpenStepMesa342Libraries.tar.Z $libraries/OpenStepMesa342Libraries.bom $libraries/OpenStepMesa342Libraries.info $libraries/OpenStepMesa342Libraries.pre_install $libraries/OpenStepMesa342Libraries.post_install $headers/OpenStepMesa342Headers.tar.Z $headers/OpenStepMesa342Headers.bom $headers/OpenStepMesa342Headers.info $headers/OpenStepMesa342Headers.pre_install )
    if (! -r $file) then
        echo "verify-mesa-package: missing $file"
        exit 2
    endif
end

if (-d $lunpack) rm -rf $lunpack
if (-d $hunpack) rm -rf $hunpack
mkdir $lunpack
mkdir $hunpack
(cd $lunpack; /usr/ucb/zcat $libraries/OpenStepMesa342Libraries.tar.Z | $installer_tar xf -)
if ($status != 0) exit 1
(cd $hunpack; /usr/ucb/zcat $headers/OpenStepMesa342Headers.tar.Z | $installer_tar xf -)
if ($status != 0) exit 1

if (! -r $lunpack/Libraries/libGL.a || ! -r $lunpack/Libraries/libGLU.a || ! -r $lunpack/Tools/OpenStepMesa342-Intel) then
    echo "verify-mesa-package: Libraries payload is incomplete"
    exit 1
endif
if (! -r $hunpack/Headers/GL/gl.h || ! -r $hunpack/Headers/GL/osmesa.h || ! -r $hunpack/Examples/OpenStep-Mesa-3.4.2/osmesa-clear.c || ! -r $hunpack/Examples/OpenStep-Mesa-3.4.2/build-osmesa-clear.csh || ! -r $hunpack/Examples/OpenStep-Mesa-3.4.2/osmesa-clear || ! -r $hunpack/Tools/OpenStepMesa342Headers-Intel) then
    echo "verify-mesa-package: Headers/Examples payload is incomplete"
    exit 1
endif
if (-e $lunpack/Headers || -e $hunpack/Libraries/libGL.a) then
    echo "verify-mesa-package: package payloads are not separated"
    exit 1
endif

ar t $lunpack/Libraries/libGL.a | grep osmesa.o > /dev/null
if ($status != 0) then
    echo "verify-mesa-package: libGL.a lacks osmesa.o"
    exit 1
endif
rm -f $osmesa_member
ar p $lunpack/Libraries/libGL.a osmesa.o > $osmesa_member
if ($status != 0) exit 1
nm $osmesa_member | grep OSMesaCreateContext > /dev/null
if ($status != 0) then
    echo "verify-mesa-package: OSMesaCreateContext missing"
    exit 1
endif

foreach binary ( $lunpack/Tools/OpenStepMesa342-Intel $hunpack/Tools/OpenStepMesa342Headers-Intel $hunpack/Examples/OpenStep-Mesa-3.4.2/osmesa-clear )
    file $binary | grep i386 > /dev/null
    if ($status != 0) then
        echo "verify-mesa-package: non-i386 binary $binary"
        exit 1
    endif
end

/usr/etc/lsbom -arch i386 -s $libraries/OpenStepMesa342Libraries.bom | grep OpenStepMesa342-Intel > /dev/null
if ($status != 0) then
    echo "verify-mesa-package: Libraries i386 BOM marker missing"
    exit 1
endif
/usr/etc/lsbom -arch m68k -s $libraries/OpenStepMesa342Libraries.bom | grep OpenStepMesa342-Intel > /dev/null
if ($status == 0) then
    echo "verify-mesa-package: Libraries marker leaked into m68k BOM"
    exit 1
endif
/usr/etc/lsbom -arch i386 -s $headers/OpenStepMesa342Headers.bom | grep OpenStepMesa342Headers-Intel > /dev/null
if ($status != 0) then
    echo "verify-mesa-package: Headers i386 BOM marker missing"
    exit 1
endif
/usr/etc/lsbom -arch m68k -s $headers/OpenStepMesa342Headers.bom | grep OpenStepMesa342Headers-Intel > /dev/null
if ($status == 0) then
    echo "verify-mesa-package: Headers marker leaked into m68k BOM"
    exit 1
endif

grep '^DefaultLocation /LocalDeveloper$' $libraries/OpenStepMesa342Libraries.info > /dev/null
if ($status != 0) exit 1
grep '^DefaultLocation /LocalDeveloper$' $headers/OpenStepMesa342Headers.info > /dev/null
if ($status != 0) exit 1
ls -l $libraries/OpenStepMesa342Libraries.pre_install $libraries/OpenStepMesa342Libraries.post_install $headers/OpenStepMesa342Headers.pre_install | grep 'r.xr.xr.x' > /dev/null
if ($status != 0) then
    echo "verify-mesa-package: Installer hooks are not executable"
    exit 1
endif
echo "verify-mesa-package: PASS split payloads, OSMesa archive, i386 BOM and hooks"
