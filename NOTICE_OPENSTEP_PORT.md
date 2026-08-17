# OPENSTEP port notice

This repository contains a port packaging layer around the pristine Mesa
3.4.2 source tree in `upstream/Mesa-3.4.2`. Target-specific staging,
packaging and verification files live outside that directory.

The source baseline is the official `MesaLib-3.4.2.tar.gz`, SHA-256
`b02b5f77321175820b9955b07979d9f8c5d52e146eecc719844380ef2849ddd6`.
The included source tree was recursively compared against a fresh extraction
of that archive on 2026-08-17.

The port builds Mesa's historical `openstep` target with `cc -m486`. It does
not claim to be a licensed OpenGL implementation and does not add X11/GLX,
LLVM, GLES, EGL, Vulkan or hardware acceleration.
