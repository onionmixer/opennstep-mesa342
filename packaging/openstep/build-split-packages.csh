#!/bin/csh -f
# Produce independently installable Mesa Libraries, Headers and Demos packages.
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
    echo "build-split-packages: MESA_STAGE_PARENT must be an absolute path"
    exit 2
endsw
set root = "$MESA_STAGE_PARENT/OpenStepMesa342"
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

# THE DEMOS OVERLAY.  The Matrox G450 driver project builds a teapot demo
# whose two binaries belong in a Demos package, and the operator asked for
# them there.  This repository is released, so its own Demos package must
# keep building from this repository alone: with no overlay, everything
# below behaves exactly as it did before this variable existed.
#
# Given an overlay, the tree is copied verbatim into the Demos payload and
# the package is built under a DIFFERENT .info -- different name, different
# version, different description -- so the two artefacts never share an
# identity and neither can be mistaken for the other.
#
# The name is 17 characters because this csh refuses a variable name of 19
# or more; 18 was measured to work and 19 not.
#
# An empty value is refused rather than treated as absent: this csh answers
# -d on an empty string with TRUE, so an empty overlay would be "found" and
# would copy nothing while still switching the package identity.
#
# The block form is not a style choice.  csh substitutes the variables on a
# ONE-LINE `if` before it evaluates the condition, so
#     if ($?MESA_DEMO_OVERLAY) set dovl = "$MESA_DEMO_OVERLAY"
# dies with "MESA_DEMO_OVERLAY: Undefined variable." in exactly the case the
# guard was written to handle.  Measured: the no-overlay build stopped there.
#
set dovl = ""
if ($?MESA_DEMO_OVERLAY) then
    set dovl = "$MESA_DEMO_OVERLAY"
endif
if ("$dovl" != "") then
    switch ("$dovl")
    case /*:
        breaksw
    default:
        echo "build-mesa-split: MESA_DEMO_OVERLAY must be an absolute path"
        exit 2
    endsw
    if (! -d "$dovl/Examples") then
        echo "build-mesa-split: no Examples in overlay $dovl"
        exit 2
    endif
    set dinf = $src/packaging/openstep/OpenStepMesa342DemosMGA.info
endif
set pre = $src/packaging/openstep/OpenStepMesa342.pre_install
set hpre = $src/packaging/openstep/OpenStepMesa342Headers.pre_install
set dpre = $src/packaging/openstep/OpenStepMesa342Demos.pre_install
# `package` names the .pkg after the .info FILE, not after its Title, so the
# variant produces OpenStepMesa342DemosMGA.pkg.  Everything downstream that
# names the Demos package by hand has to follow that, which is what dname is
# for.  The overlay block above ran before dpre existed, so the variant's own
# pre_install is selected here.
set dname = OpenStepMesa342Demos
if ("$dovl" != "") then
    set dpre = $src/packaging/openstep/OpenStepMesa342DemosMGA.pre_install
    set dname = OpenStepMesa342DemosMGA
endif
set post = $src/packaging/openstep/OpenStepMesa342.post_install
set marksrc = $src/packaging/openstep/installer-architecture-marker.c
set pkgtool = /NextAdmin/Installer.app/package
# This used to `exit 2` in silence, which reads as "nothing happened" -- and
# with MESA_STAGE_PARENT pointing at a parent that holds no stage, ALL of
# these are missing at once and the build ends without a word.  Say which.
foreach file ( $linf $hinf $dinf $pre $hpre $dpre $post $marksrc )
    if (! -r $file) then
        echo "build-mesa-split: missing input: $file"
        echo "build-mesa-split: is MESA_STAGE_PARENT ($MESA_STAGE_PARENT) the parent of a staged tree?"
        exit 2
    endif
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
# The overlay goes in after the stock demos, so a broken overlay cannot
# damage what this repository builds on its own.
if ("$dovl" != "") then
    (cd $dovl; tar cf - .) | (cd $dpay; tar xf - )
    if ($status != 0) exit 1
    foreach f ( teapot_sw teapot_hybrid README_teapot.md NOTICE COPYRIGHT )
        if (! -r $dpay/Examples/Mesa342/Teapot/$f) then
            echo "build-mesa-split: overlay is missing $f"
            exit 1
        endif
    end
    echo "build-mesa-split: overlay staged from $dovl"
endif

foreach demo ( $dpay/Examples/Mesa342/OSMesaClear/osmesa-clear $dpay/Examples/Mesa342/MesaView/MesaView.app/MesaView )
    file $demo | grep i386 > /dev/null
    if ($status != 0) then
        echo "build-mesa-split: demo is not i386 Mach-O: $demo"
        exit 1
    endif
end
if ("$dovl" != "") then
    foreach demo ( $dpay/Examples/Mesa342/Teapot/teapot_sw $dpay/Examples/Mesa342/Teapot/teapot_hybrid )
        file $demo | grep i386 > /dev/null
        if ($status != 0) then
            echo "build-mesa-split: demo is not i386 Mach-O: $demo"
            exit 1
        endif
    end
endif

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
cp $dpre $dst/$dname.pkg/$dname.pre_install
chmod 555 $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.pre_install $dst/OpenStepMesa342Libraries.pkg/OpenStepMesa342Libraries.post_install $dst/OpenStepMesa342Headers.pkg/OpenStepMesa342Headers.pre_install $dst/$dname.pkg/$dname.pre_install
if ($status != 0) exit 1
echo "build-mesa-split: PASS Libraries, Headers and $dname packages in $dst"
