# Linking an OPENSTEP Mesa consumer

Install `OpenStepMesa342Libraries.pkg` and `OpenStepMesa342Headers.pkg` into
the same prefix, normally `/LocalDeveloper`, then compile using only that
installed prefix:

```text
cc -m486 -I<prefix>/Headers program.c -L<prefix>/Libraries -lGL -lm
```

An application using GLU must put GLU before GL in static-link order:

```text
cc -m486 -I<prefix>/Headers program.c -L<prefix>/Libraries -lGLU -lGL -lm
```

For an AppKit presentation layer, append the needed OPENSTEP frameworks after
the static libraries. Do not add X11/GLX libraries: they are not part of this
package.
