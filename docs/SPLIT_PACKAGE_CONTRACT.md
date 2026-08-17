# Split-package source-control rule

Mesa is released as `OpenStepMesa342Libraries.pkg` and
`OpenStepMesa342Headers.pkg`. Every release commit must include their `.info`
metadata, build scripts, verify scripts, Installer hooks, architecture marker,
example source and example build script. The generated target `.pkg`
directories and `/tmp/OpenStepMesa342` stage are artifacts and are rebuilt on
OPENSTEP from those committed sources.

Both packages carry a separate tiny i386 Mach-O marker. The Headers package
must not rely on its example binary alone for Installer architecture selection:
its own marker makes the package unavailable on m68k machines.
