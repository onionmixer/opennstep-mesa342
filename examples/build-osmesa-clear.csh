#!/bin/csh -f
set prefix = /LocalDeveloper
if ($#argv == 1) set prefix = $argv[1]
cc -m486 -I$prefix/Headers osmesa-clear.c -L$prefix/Libraries -lGLU -lGL -lm -o osmesa-clear
if ($status != 0) exit 1
echo "build-osmesa-clear: PASS ./osmesa-clear"
