# OPENSTEP Mesa 3.4.2 Demos notice

`OpenStepMesa342Demos.pkg` installs its examples below
`/LocalDeveloper/Examples/Mesa342/`.  Install the Mesa Libraries and Headers
packages at the same prefix first.  All binaries are target-built i386
executables; source and rebuild scripts are included with every demo.

| Demo | Type | What it verifies | How it ends |
| --- | --- | --- | --- |
| `OSMesaClear/osmesa-clear` | off-screen Mesa | OSMesa context creation, current-buffer binding, GL clear and error-free teardown | automatically, exit status 0 on success |
| `MesaView/MesaView.app` | original OPENSTEP AppKit Mesa application | AppKit nib loading, windowed fixed-function OpenGL/GLU rendering and the original MesaView controller | close its window |

MesaView is a complete OPENSTEP application bundle.  Launch
`MesaView/MesaView.app/MesaView` through the Workspace/GCD session, not the
old unbundled executable path.  The package includes the original source,
`PB.project`, source nib and a generated
`MesaView.app/Resources/Info-nextstep.plist`; the latter is required for
`NSApplicationMain` to load `MesaView.nib`.

The shorter `Examples/Mesa342/` payload path is intentional.  It keeps the
complete bundle's nib resource paths within the historical Installer tar
limit, so the native `installer_tar` can extract the package correctly.

Rebuild the examples in their own directories with:

```text
csh -f build-osmesa-clear.csh /LocalDeveloper
csh -f build-mesaview.csh /LocalDeveloper
```
