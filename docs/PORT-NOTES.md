# Port notes

- Target: Intel i486 only, OPENSTEP 4.2. The static libraries are i386-only;
  `Tools/OpenStepMesa342-Intel` is an i386 Mach-O marker that makes the
  Installer architecture panel offer i386 rather than `All computers`.
  `OpenStepMesa342.pre_install` also refuses non-i386 hosts. m68k, hppa and
  sparc are unsupported.
- Upstream: Mesa 3.4.2, using its documented `make openstep` target.
- Build command: `make CC='cc -m486' openstep`.
- Delivered libraries: static `libGL.a` and `libGLU.a`.
- OSMesa is a member of `libGL.a`; no `libOSMesa.a` is supplied.
- Delivered headers: `gl.h`, `glext.h`, `glu.h`, `glu_mangle.h`, `osmesa.h`.
- Scope: software OpenGL 1.2 fixed-function/GLU/OSMesa.
- Not supplied: GLX/X11, GLUT, platform-specific Mesa drivers, GLES, EGL,
  Vulkan or any LLVM-based renderer.
