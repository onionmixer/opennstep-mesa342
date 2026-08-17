# Packaging test record

## 2026-08-17 — initial native package build

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

The next gate is a fresh Installer install of the rebuilt package containing
the post-install hook, followed by the same consumer without any manual
`ranlib` command.

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
