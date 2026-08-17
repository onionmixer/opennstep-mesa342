# OPENSTEP Mesa 3.4.2 — openstep.1

First public OPENSTEP 4.2 Intel i486 release of Mesa 3.4.2's documented
OPENSTEP software-rendering target.

## Installer packages

Install all selected packages at the same relocatable prefix, normally
`/LocalDeveloper`.

- `OpenStepMesa342Libraries.pkg` — static `libGL.a` and `libGLU.a`; OSMesa is
  part of `libGL.a`.
- `OpenStepMesa342Headers.pkg` — GL, GLU and OSMesa headers with development
  documentation.
- `OpenStepMesa342Demos.pkg` — OSMesaClear and the original OPENSTEP
  `MesaView.app`, each with source, rebuild script and i386 executable.

The release archive contains one outer `.pkg.tar.gz` file for each Installer
directory package. Extract it, then open the contained `.pkg` with
OPENSTEP Installer.

## Verification included in this release

- Native package verification checks split payloads, `osmesa.o` in `libGL.a`,
  i386 BOM visibility and archive-index repair hooks.
- Installed OSMesaClear completed with exit status 0.
- Installed MesaView was visibly rendered through GCD, closed cleanly, then
  rebuilt from its installed source and visibly rendered again. See
  [docs/TESTING.md](docs/TESTING.md).

## Scope and limitations

- CPU-only software OpenGL 1.2 fixed-function rendering, GLU and OSMesa.
- No GPU acceleration, GLX/X11, GLUT, EGL, GLES, Vulkan or LLVM renderer.
- MesaView is a complete AppKit bundle at `Examples/Mesa342/MesaView/MesaView.app`.
