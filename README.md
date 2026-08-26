# OPENSTEP Mesa 3.4.2

An **Intel i486-only** OPENSTEP 4.2 port of Mesa 3.4.2 for static OpenGL 1.2,
GLU and OSMesa development. The package is deliberately separate from SDL2.

The public deliverable is three independently installable OPENSTEP Installer
packages: `OpenStepMesa342Libraries.pkg`, `OpenStepMesa342Headers.pkg` and
`OpenStepMesa342Demos.pkg`. They install into one user-selected development
prefix (default `/LocalDeveloper`). Libraries provides `libGL.a` and
`libGLU.a`; Headers provides `Headers/GL` and documentation; Demos provides
the rebuildable OSMesaClear and original OPENSTEP MesaView examples. MesaView
is delivered as `MesaView.app`, including its generated
`Resources/Info-nextstep.plist` and nib resources, so it can be launched by
the OPENSTEP Workspace rather than as an unbundled executable.

The Installer title explicitly identifies the Intel i486 target. The archives
contain i386 Mach-O members produced by `cc -m486`. Because Installer does not
derive architecture choices from archive members, the payload also contains a
tiny i386-only architecture marker; this makes Installer offer **i386 only**
rather than **All computers**. The pre-install hook independently rejects a
non-i386 host. Its post-install hook reruns
`ranlib` because OPENSTEP's archive index contains its archive pathname and
must be rebuilt after Installer extraction.

Mesa's OPENSTEP target places OSMesa inside `libGL.a`; there is no separate
`libOSMesa.a`. This is software rendering only. X11/GLX, GLES, EGL, Vulkan
and hardware-specific drivers are outside this release.

## The Demos VARIANT

`packaging/openstep/build-split-packages.csh` can build a second flavour of
the Demos package that carries demos from another project. It is off unless
asked for, and the released artefacts are unaffected:

- With `MESA_DEMO_OVERLAY` unset it behaves exactly as it did before that
  variable existed and produces `OpenStepMesa342Demos.pkg`, version
  `3.4.2-openstep.1`. Verified on the target after the change: 46 files in
  the BOM and no path from any other project.
- With `MESA_DEMO_OVERLAY` set to an absolute overlay tree, that tree is
  copied verbatim into the Demos payload and the package is built under
  `OpenStepMesa342DemosMGA.info` — its own name, its own description, version
  `3.4.2-openstep.1+mga.1`. `package` names a `.pkg` after the `.info` FILE,
  so the two artefacts cannot collide. Install one or the other, not both.

Be honest about the direction this points: with an overlay, this repository's
OUTPUT depends on another repository's BUILD. That is accepted for the variant
only. **The released packages still build from this repository alone**, which
is the property the arrangement exists to protect.

The variant that exists today carries the
[OPENSTEP Matrox G450 driver](https://github.com/onionmixer/openstep-matrox-remade)'s
two demo pairs, and it is published on that project's release rather than
here, because that project's overlay is what builds it.

## Build and package on OPENSTEP

Mount or otherwise make this source directory available to the target, then:

```text
csh -f build/stage-openstep-mesa342.csh /ndrv
csh -f build/build-openstep-mesa342.csh
csh -f packaging/openstep/build-split-packages.csh
csh -f packaging/openstep/verify-package.csh
```

The three final directory packages are written below
`$MESA_STAGE_PARENT/OpenStepMesa342/dist/`, which is `/tmp/...` by default. The release process wraps each directory in an
outer `.pkg.tar.gz` only after Installer install/delete and consumer tests
pass. Install Libraries and Headers at the same prefix before rebuilding or
running a demo; Demos is optional.

See [docs/PORT-NOTES.md](docs/PORT-NOTES.md) and
[docs/LINKING.md](docs/LINKING.md) for the supported scope and link order.
The current package evidence is recorded in [docs/TESTING.md](docs/TESTING.md).
