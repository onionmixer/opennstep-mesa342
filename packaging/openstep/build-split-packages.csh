#!/bin/csh -f
# Produce independently installable Mesa Libraries, Headers and Demos packages.
set root = /tmp/OpenStepMesa342
set src = $root/src
set mesa = $src/Mesa-3.4.2
set lpay = $root/libraries-payload
set hpay = $root/headers-payload
set dpay = $root/demos-payload
set demoprefix = $root/demo-build-prefix
set dst = $root/dist
set linf = $src/packaging/openstep/OpenStepMesa342Libraries.info
set hinf = $src/packaging/openstep/OpenStepMesa342Headers.info
set dinf = $src/packaging/openstep/OpenStepMesa342Demos.info
set pre = $src/packaging/openstep/OpenStepMesa342.pre_install
set hpre = $src/packaging/openstep/OpenStepMesa342Headers.pre_install
set dpre = $src/packaging/openstep/OpenStepMesa342Demos.pre_install
set post = $src/packaging/openstep/OpenStepMesa342.post_install
set marksrc = $src/packaging/openstep/installer-architecture-marker.c
set pkgtool = /NextAdmin/Installer.app/package
foreach file ( $linf $hinf $dinf $pre $hpre $dpre $post $marksrc )
    if (! -r $file) exit 2
end
csh -f $src/build/build-openstep-mesa342.csh
if ($status != 0) exit 1
if (-d $lpay) rm -rf $lpay
if (-d $hpay) rm -rf $hpay
if (-d $dpay) rm -rf $dpay
if (-d $demoprefix) rm -rf $demoprefix
if (-d $dst) rm -rf $dst

/bin/mkdirs $lpay/Libraries
/bin/mkdirs $lpay/Tools
cp $mesa/lib/libGL.a $mesa/lib/libGLU.a $lpay/Libraries/
cc -m486 -o $lpay/Tools/OpenStepMesa342-Intel $marksrc
if ($status != 0) exit 1
chmod 555 $lpay/Tools/OpenStepMesa342-Intel

/bin/mkdirs $hpay/Headers/GL
/bin/mkdirs $hpay/Documentation/OpenStep-Mesa-3.4.2
/bin/mkdirs $hpay/Tools
cc -m486 -o $hpay/Tools/OpenStepMesa342Headers-Intel $marksrc
if ($status != 0) exit 1
chmod 555 $hpay/Tools/OpenStepMesa342Headers-Intel
cp $mesa/include/GL/gl.h $mesa/include/GL/glext.h $mesa/include/GL/glu.h $mesa/include/GL/glu_mangle.h $mesa/include/GL/osmesa.h $hpay/Headers/GL/
cp $mesa/docs/README.OpenStep $hpay/Documentation/OpenStep-Mesa-3.4.2/README.OPENSTEP
cp $src/COPYRIGHT $src/COPYING $src/docs/PORT-NOTES.md $src/docs/LINKING.md $src/docs/RELEASE-MANIFEST.txt $hpay/Documentation/OpenStep-Mesa-3.4.2/

# Build demo binaries against a combined private prefix, exactly as an
# installed consumer will see Libraries and Headers at one destination.
/bin/mkdirs $demoprefix/Libraries
/bin/mkdirs $demoprefix/Headers
cp $lpay/Libraries/libGL.a $lpay/Libraries/libGLU.a $demoprefix/Libraries/
cp -R $hpay/Headers/GL $demoprefix/Headers/
ranlib $demoprefix/Libraries/libGL.a $demoprefix/Libraries/libGLU.a
if ($status != 0) then
    echo "build-mesa-split: cannot refresh private demo-prefix archive indexes"
    exit 1
endif

# Keep the original Installer tar path below its legacy 100-character limit.
# The full product/version remains in the package metadata and documentation.
/bin/mkdirs $dpay/Examples/Mesa342
/bin/mkdirs $dpay/Examples/Mesa342/OSMesaClear
/bin/mkdirs $dpay/Examples/Mesa342/MesaView
/bin/mkdirs $dpay/Tools
cc -m486 -o $dpay/Tools/OpenStepMesa342Demos-Intel $marksrc
if ($status != 0) exit 1
chmod 555 $dpay/Tools/OpenStepMesa342Demos-Intel
cp $src/examples/osmesa-clear.c $src/examples/build-osmesa-clear.csh $dpay/Examples/Mesa342/OSMesaClear/
cc -m486 -arch i386 -I$mesa/include $src/examples/osmesa-clear.c -L$mesa/lib -lGLU -lGL -lm -o $dpay/Examples/Mesa342/OSMesaClear/osmesa-clear
if ($status != 0) exit 1
chmod 555 $dpay/Examples/Mesa342/OSMesaClear/osmesa-clear $dpay/Examples/Mesa342/OSMesaClear/build-osmesa-clear.csh
cp $src/examples/build-mesaview.csh $dpay/Examples/Mesa342/MesaView/
cp $mesa/OpenStep/MesaView/PB.project $mesa/OpenStep/MesaView/MesaView.m $mesa/OpenStep/MesaView/MesaView_main.m $mesa/OpenStep/MesaView/MesaView.h $mesa/OpenStep/MesaView/mesadraw.c $mesa/OpenStep/MesaView/mesadraw.h $mesa/OpenStep/MesaView/vect3d.c $mesa/OpenStep/MesaView/vect3d.h $dpay/Examples/Mesa342/MesaView/
cp -R $mesa/OpenStep/MesaView/English.lproj $dpay/Examples/Mesa342/MesaView/
(cd $dpay/Examples/Mesa342/MesaView; csh -f build-mesaview.csh $demoprefix)
if ($status != 0) exit 1
chmod 555 $dpay/Examples/Mesa342/MesaView/MesaView.app/MesaView $dpay/Examples/Mesa342/MesaView/build-mesaview.csh
foreach demo ( $dpay/Examples/Mesa342/OSMesaClear/osmesa-clear $dpay/Examples/Mesa342/MesaView/MesaView.app/MesaView )
    file $demo | grep i386 > /dev/null
    if ($status != 0) then
        echo "build-mesa-split: demo is not i386 Mach-O: $demo"
        exit 1
    endif
end

/bin/mkdirs $dst
$pkgtool $lpay $linf -d $dst
if ($status != 0) exit 1
$pkgtool $hpay $hinf -d $dst
if ($status != 0) exit 1
$pkgtool $dpay $dinf -d $dst
if ($status != 0) exit 1
cp $pre $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.pre_install
cp $post $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.post_install
cp $hpre $dst/OpenStepMesa342Headers.pkg/OpenStepMesa342Headers.pre_install
cp $dpre $dst/OpenStepMesa342Demos.pkg/OpenStepMesa342Demos.pre_install
chmod 555 $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.pre_install $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.post_install $dst/OpenStepMesa342Headers.pkg/OpenStepMesa342Headers.pre_install $dst/OpenStepMesa342Demos.pkg/OpenStepMesa342Demos.pre_install
if ($status != 0) exit 1
echo "build-mesa-split: PASS Libraries, Headers and Demos packages in $dst"
