#!/bin/csh -f
set root = /tmp/OpenStepMesa342
set src = $root/src
set mesa = $src/Mesa-3.4.2
set lpay = $root/libraries-payload
set hpay = $root/headers-payload
set dst = $root/dist
set linf = $src/packaging/openstep/OpenStepMesa342Libraries.info
set hinf = $src/packaging/openstep/OpenStepMesa342Headers.info
set pre = $src/packaging/openstep/OpenStepMesa342.pre_install
set hpre = $src/packaging/openstep/OpenStepMesa342Headers.pre_install
set post = $src/packaging/openstep/OpenStepMesa342.post_install
set pkgtool = /NextAdmin/Installer.app/package
foreach file ( $linf $hinf $pre $hpre $post )
    if (! -r $file) exit 2
end
csh -f $src/build/build-openstep-mesa342.csh
if ($status != 0) exit 1
if (-d $lpay) rm -rf $lpay
if (-d $hpay) rm -rf $hpay
if (-d $dst) rm -rf $dst
/bin/mkdirs $lpay/Libraries
/bin/mkdirs $lpay/Tools
cp $mesa/lib/libGL.a $mesa/lib/libGLU.a $lpay/Libraries/
cc -m486 -o $lpay/Tools/OpenStepMesa342-Intel $src/packaging/openstep/installer-architecture-marker.c
if ($status != 0) exit 1
chmod 555 $lpay/Tools/OpenStepMesa342-Intel
/bin/mkdirs $hpay/Headers/GL
/bin/mkdirs $hpay/Documentation/OpenStep-Mesa-3.4.2
/bin/mkdirs $hpay/Examples/OpenStep-Mesa-3.4.2
/bin/mkdirs $hpay/Tools
cc -m486 -o $hpay/Tools/OpenStepMesa342Headers-Intel $src/packaging/openstep/installer-architecture-marker.c
if ($status != 0) exit 1
chmod 555 $hpay/Tools/OpenStepMesa342Headers-Intel
cp $mesa/include/GL/gl.h $mesa/include/GL/glext.h $mesa/include/GL/glu.h $mesa/include/GL/glu_mangle.h $mesa/include/GL/osmesa.h $hpay/Headers/GL/
cp $mesa/docs/README.OpenStep $hpay/Documentation/OpenStep-Mesa-3.4.2/README.OPENSTEP
cp $src/COPYRIGHT $src/COPYING $src/docs/PORT-NOTES.md $src/docs/LINKING.md $src/docs/RELEASE-MANIFEST.txt $hpay/Documentation/OpenStep-Mesa-3.4.2/
cp $src/examples/* $hpay/Examples/OpenStep-Mesa-3.4.2/
cc -m486 -I$mesa/include $src/examples/osmesa-clear.c -L$mesa/lib -lGLU -lGL -lm -o $hpay/Examples/OpenStep-Mesa-3.4.2/osmesa-clear
if ($status != 0) exit 1
chmod 555 $hpay/Examples/OpenStep-Mesa-3.4.2/osmesa-clear $hpay/Examples/OpenStep-Mesa-3.4.2/build-osmesa-clear.csh
/bin/mkdirs $dst
$pkgtool $lpay $linf -d $dst
if ($status != 0) exit 1
$pkgtool $hpay $hinf -d $dst
if ($status != 0) exit 1
cp $pre $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.pre_install
cp $post $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.post_install
cp $hpre $dst/OpenStepMesa342Headers.pkg/OpenStepMesa342Headers.pre_install
chmod 555 $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.pre_install $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.post_install $dst/OpenStepMesa342Headers.pkg/OpenStepMesa342Headers.pre_install
if ($status != 0) exit 1
echo "build-mesa-split: PASS $dst/OpenStepMesa342Libraries.pkg $dst/OpenStepMesa342Headers.pkg"
