# Packaging test record

## 2026-08-17 — initial native package build (superseded package layout)

1. A clean private target stage built Mesa with:

   ```text
   make CC='cc -m486' openstep
   ```

2. The target generated `libGL.a` and `libGLU.a`; `libGL.a` contains
   `osmesa.o` and that object exports `OSMesaCreateContext`.
3. `/NextAdmin/Installer.app/package` generated `OpenStepMesa342.pkg` with
   `.tar.Z`, binary `.bom`, `.info` and `.sizes` files. The correct way to
   inspect that binary BOM is `/usr/etc/lsbom -s`, not text `grep`.
4. `file` reported the installed `osmesa.o` as `Mach-O relocatable (for
   architecture i386)`. The release is therefore Intel i486-only.
5. Installer successfully created a receipt and installed the package at
   `/LocalDeveloper`. Its initial archive indexes were stale after extraction:
   OPENSTEP `ld` reported that both `libGL.a` and `libGLU.a` needed `ranlib`.
   This happens because the historical archive index keeps the archive
   pathname. `OpenStepMesa342.post_install` now reruns `ranlib` on both
   archives in the user-selected prefix.
6. After executing that hook, a new consumer compiled exclusively with
   `-I/LocalDeveloper/Headers -L/LocalDeveloper/Libraries -lGLU -lGL -lm`
   passed OSMesa context creation, GL 1.2 clear/query and GLU lookup:

   ```text
   package-mesa-consumer: PASS GL_VERSION=1.2 Mesa 3.4.2 GLU=no error
   ```

This initial monolithic package record is retained as the evidence that found
the archive-index issue.  It is superseded by the split-package evidence
below.

## 2026-08-17 — Installer architecture selection correction

Installer derives its architecture-selection BOM from ordinary Mach-O payload
files; it does not inspect the i386 object members inside Mesa's static
archives. That is why the initial archive-only package showed `All computers`
despite its libraries being i386-only.

The package build now compiles `Tools/OpenStepMesa342-Intel` from
`packaging/openstep/installer-architecture-marker.c` with `cc -m486`. A target
probe proved that `lsbom -arch i386` includes this marker while
`lsbom -arch m68k` and `-arch hppa` do not. The only selectable architecture
is therefore i386; `OpenStepMesa342.pre_install` separately rejects a
non-i386 machine.

## 2026-08-17 — Libraries, Headers and Demos package split

1. `packaging/openstep/build-split-packages.csh` built the independent
   `OpenStepMesa342Libraries.pkg`, `OpenStepMesa342Headers.pkg` and
   `OpenStepMesa342Demos.pkg` directories from a clean target build.
2. `packaging/openstep/verify-package.csh` passed the separated-payload,
   OSMesa archive, i386 BOM and hook checks.  Libraries contains only
   `libGL.a`, `libGLU.a` and its architecture marker; Headers contains the GL
   header closure and documentation; Demos contains the example source,
   scripts and i386 binaries.
3. All three packages were installed at `/LocalDeveloper` together with the
   corresponding SDL2 three-package set.  Installed demo source was rebuilt
   into fresh `/tmp` output locations using only `/LocalDeveloper/Headers` and
   `/LocalDeveloper/Libraries`: `build-osmesa-clear.csh` and
   `build-mesaview.csh` both passed and produced i386 Mach-O executables.

The remaining verification is runtime execution and Installer deletion
isolation; neither is claimed by this record.
