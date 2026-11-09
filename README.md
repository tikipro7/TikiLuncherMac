# TikiLuncherMac

ForkTikiLauncher v9 para Mac + fork tiki-v22 de Ocarina of Time.

Launcher SwiftUI para Mac que construye juegos de Switch / Switch 2 a IPA para iPhone (AltStore Classic) o a .app para Mac, con nxnative / NX2Apple, con selector de fork, presets y descarga de herramientas. Todo desde el launcher, sin abrir otra app.

## Que trae la v9

- **v9:** el launcher se revisa a sí mismo en este repo (botón "Revisar si hay versión nueva del launcher", arriba): consulta el README en main y el último commit. Si hay una v10 o más, baja el repo nuevo y recompila.
- Aplica primero el parche de memoria ya resuelto `patches/tiki-v22-mem.patch` (8d5d4f1 resuelto a mano, candidato sin compilar) antes de intentar el cherry-pick, que antes chocaba siempre.

## Que trae la v8

- Motor kid-with-sword-remake V22 para Ocarina of Time, con toggle **"Mejoras tiki (Ocarina: nota + memoria)"** prendido por defecto.
- Antes del build aplica el parche de la primera nota de ocarina e intenta el cherry-pick de memoria upstream `8d5d4f1`. Si el cherry-pick da conflicto, lo aborta, lo dice en el log y sigue con el build.
- Sin preset por defecto: no escribe env.txt si no eliges uno. El preset lo aplicas tu afuera.
- Soporte Switch 2 (.nup) y Switch 1 (.nsp/.nsz, con prod.keys), iPhone / Mac, Separate / Bundle, updates y DLC, borrado del juego tras un build bueno, y chequeo de version del fork.

## Compilar el launcher en tu Mac

```bash
cd ~/ForkTikiLauncher
xcodegen generate
xcodebuild -project ForkTikiLauncher.xcodeproj -scheme ForkTikiLauncher -configuration Release build
cp -R /Users/tiki/Library/Developer/Xcode/DerivedData/ForkTikiLauncher-ghtzqyhxhnoemhcmazbbmdwwdane/Build/Products/Release/ForkTikiLauncher.app ~/ForkTikiLauncher/build/Release/
open ~/ForkTikiLauncher/build/Release/ForkTikiLauncher.app
```

Requisitos: Mac Apple Silicon, macOS 26.6+, Xcode 27.2, Homebrew, Python 3.12, xcodegen.

## tiki-v22

Base: kid-with-sword-remake rama `v22`, commit `84aa8c3`.

- **Aplicado y verificado:** fix primera nota de ocarina, commit upstream `8feddfe` (PR seedds#1444), 4 lineas en `dm/host/hle_hid.c`, `IsOunceVibrationDeviceMounted` linea 910 en V22. Sin este fix el juego se cierra en la primera nota de Zelda's Lullaby con Impa y bloquea la quest principal.
- **Resuelto a mano, candidato SIN COMPILAR:** fix de memoria/disco upstream `8d5d4f1` (F_PUNCHHOLE, 1.84 GB devueltos en M4 Pro). Dio conflicto en 5 archivos, sobre todo `dm/host/hle_svc.c` 473-589, porque kid V22 ya divergio de upstream ahi. Se resolvio hunk por hunk conservando la maquinaria Potato de kid y la firma de upstream, sin borrar lineas de kid; el diff tiene exactamente el mismo stat que upstream (199 inserciones, 31 borrados) y `git apply --check` pasa en un clon limpio. No se pudo compilar en Linux, la Mac debe validarlo con el build. Ver `patches/tiki-v22-mem.patch` y `patches/tiki-v22-mem-NOTAS.md`.

Archivos: `patches/tiki-v22.patch` (solo el fix de la ocarina, SHA256 7611e951217e5222fc0c5d1f57ed7b3b54ef63d9300b8760073dbcb343767516), `patches/ocarina-note-fix.patch` (el mismo), `patches/tiki-v22-NOTAS.md`, `docs/codex-optimizaciones.md`.

## Importante

Este repo es solo codigo. **No incluye juegos, .nup, RomFS, IPA, prod.keys ni shaders.** Cada quien construye con su propio dump legalmente adquirido. El juego de Ocarina pide ~9 GB de heap; en iPhone 15 Pro Max (8 GB, ~6.1 GB con Increased Memory Limit) el objetivo realista es 30 fps estables, no 60.
