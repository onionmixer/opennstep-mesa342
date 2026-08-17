#!/bin/csh -f
# Build and run using only files installed by OpenStepMesa342.pkg.

if ($#argv != 1) then
    echo "usage: build-package-mesa-consumer.csh /installed/package/prefix"
    exit 2
endif

set prefix = $argv[1]
set test_source = /tmp/OpenStepMesa342/src/test/openstep/package-mesa-consumer.c
set test_binary = /tmp/OpenStepMesa342/package-mesa-consumer

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
