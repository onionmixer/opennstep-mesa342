#!/bin/csh -f
# Verify Mesa Libraries, Headers and Demos packages without installing them.
set work = /tmp/OpenStepMesa342
set dist = $work/dist
set libraries = $dist/OpenStepMesa342Libraries.pkg
set headers = $dist/OpenStepMesa342Headers.pkg
set demos = $dist/OpenStepMesa342Demos.pkg
set lunpack = $work/libraries-package-verify
set hunpack = $work/headers-package-verify
set dunpack = $work/demos-package-verify
set installer_tar = /NextAdmin/Installer.app/installer_tar
set osmesa_member = $work/mesa-package-verify-osmesa.o

foreach file ( $libraries/OpenStepMesa342Libraries.tar.Z $libraries/OpenStepMesa342Libraries.bom $libraries/OpenStepMesa342Libraries.info $libraries/OpenStepMesa342Libraries.pre_install $libraries/OpenStepMesa342Libraries.post_install $headers/OpenStepMesa342Headers.tar.Z $headers/OpenStepMesa342Headers.bom $headers/OpenStepMesa342Headers.info $headers/OpenStepMesa342Headers.pre_install $demos/OpenStepMesa342Demos.tar.Z $demos/OpenStepMesa342Demos.bom $demos/OpenStepMesa342Demos.info $demos/OpenStepMesa342Demos.pre_install )
    if (! -r $file) then
        echo "verify-mesa-package: missing $file"
        exit 2
    endif
end
foreach directory ( $lunpack $hunpack $dunpack )
    if (-d $directory) rm -rf $directory
    mkdir $directory
end
(cd $lunpack; /usr/ucb/zcat $libraries/OpenStepMesa342Libraries.tar.Z | $installer_tar xf -)
if ($status != 0) exit 1
(cd $hunpack; /usr/ucb/zcat $headers/OpenStepMesa342Headers.tar.Z | $installer_tar xf -)
if ($status != 0) exit 1
(cd $dunpack; /usr/ucb/zcat $demos/OpenStepMesa342Demos.tar.Z | $installer_tar xf -)
if ($status != 0) exit 1
if (! -r $lunpack/Libraries/libGL.a || ! -r $lunpack/Libraries/libGLU.a || ! -r $lunpack/Tools/OpenStepMesa342-Intel) then
    echo "verify-mesa-package: Libraries payload is incomplete"
    exit 1
endif
if (! -r $hunpack/Headers/GL/gl.h || ! -r $hunpack/Headers/GL/osmesa.h || ! -r $hunpack/Documentation/OpenStep-Mesa-3.4.2/README.OPENSTEP || ! -r $hunpack/Tools/OpenStepMesa342Headers-Intel) then
    echo "verify-mesa-package: Headers payload is incomplete"
    exit 1
endif
if (! -r $dunpack/Examples/OpenStep-Mesa-3.4.2/OSMesaClear/osmesa-clear.c || ! -r $dunpack/Examples/OpenStep-Mesa-3.4.2/OSMesaClear/build-osmesa-clear.csh || ! -r $dunpack/Examples/OpenStep-Mesa-3.4.2/OSMesaClear/osmesa-clear || ! -r $dunpack/Examples/OpenStep-Mesa-3.4.2/MesaView/MesaView.m || ! -r $dunpack/Examples/OpenStep-Mesa-3.4.2/MesaView/English.lproj/MesaView.nib/objects.nib || ! -r $dunpack/Examples/OpenStep-Mesa-3.4.2/MesaView/build-mesaview.csh || ! -r $dunpack/Examples/OpenStep-Mesa-3.4.2/MesaView/MesaView || ! -r $dunpack/Tools/OpenStepMesa342Demos-Intel) then
    echo "verify-mesa-package: Demos payload is incomplete"
    exit 1
endif
if (-e $lunpack/Headers || -e $lunpack/Examples || -e $hunpack/Libraries || -e $hunpack/Examples || -e $dunpack/Libraries || -e $dunpack/Headers) then
    echo "verify-mesa-package: payloads are not separated"
    exit 1
endif
ar t $lunpack/Libraries/libGL.a | grep osmesa.o > /dev/null
if ($status != 0) exit 1
rm -f $osmesa_member
ar p $lunpack/Libraries/libGL.a osmesa.o > $osmesa_member
if ($status != 0) exit 1
nm $osmesa_member | grep OSMesaCreateContext > /dev/null
if ($status != 0) exit 1
foreach binary ( $lunpack/Tools/OpenStepMesa342-Intel $hunpack/Tools/OpenStepMesa342Headers-Intel $dunpack/Tools/OpenStepMesa342Demos-Intel $dunpack/Examples/OpenStep-Mesa-3.4.2/OSMesaClear/osmesa-clear $dunpack/Examples/OpenStep-Mesa-3.4.2/MesaView/MesaView )
    file $binary | grep i386 > /dev/null
    if ($status != 0) then
        echo "verify-mesa-package: non-i386 binary $binary"
        exit 1
    endif
end
foreach name ( Libraries Headers Demos )
    if ("$name" == "Libraries") then
        set marker = OpenStepMesa342-Intel
    else
        set marker = OpenStepMesa342$name-Intel
    endif
    set package = $dist/OpenStepMesa342$name.pkg
    /usr/etc/lsbom -arch i386 -s $package/OpenStepMesa342$name.bom | grep $marker > /dev/null
    if ($status != 0) exit 1
    /usr/etc/lsbom -arch m68k -s $package/OpenStepMesa342$name.bom | grep $marker > /dev/null
    if ($status == 0) then
        echo "verify-mesa-package: $name marker leaked into m68k BOM"
        exit 1
    endif
end
ls -l $libraries/OpenStepMesa342Libraries.pre_install $libraries/OpenStepMesa342Libraries.post_install $headers/OpenStepMesa342Headers.pre_install $demos/OpenStepMesa342Demos.pre_install | grep 'r.xr.xr.x' > /dev/null
if ($status != 0) exit 1
echo "verify-mesa-package: PASS separated payloads, OSMesa archive, i386 BOM and hooks"
