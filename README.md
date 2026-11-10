# TikiLuncherMac

ForkTikiLauncher v34 para Mac + fork tiki-v22 de Ocarina of Time.

Launcher SwiftUI para Mac que construye juegos de Switch / Switch 2 a IPA para iPhone (AltStore Classic) o a .app para Mac, con nxnative / NX2Apple, con selector de fork, presets y descarga de herramientas. Todo desde el launcher, sin abrir otra app.

## Que trae la v24

- **v24: destino del build en disco externo.** En Paso 4 · Compilar, sección "Destino del build": elige Disco interno (`~/ForkTikiLauncher/builds`) o Disco externo (botón "Elegir carpeta en disco externo…", ej. `/Volumes/Disco Externo/ForkTikiLauncher/builds`). El build, el IPA y el `RomFS.img` van a esa carpeta, y el cálculo de espacio libre mide ESE disco, no el interno. La ruta se guarda y no se pierde al cerrar la app. ⚠️ El disco debe estar conectado TODO el build, no desconectarlo, y formateado APFS o exFAT. Si no está conectado, el build no arranca y lo dice en el log. Para Luis: con solo 35 GB libres en su Mac M1, el build de Ocarina (~100 GB) ya cabe si el disco externo tiene espacio.

## Que trae la v23

- **v23: 'sin juego específico' ya no se decide solo por el nombre.** Ahora también lee la descripción de GitHub, y busca el juego ahí: Ocarina, Bananza, Mario Kart, Pokopia, Tomodachi, TOTK, BOTW, etc. Si GitHub dice el juego, la app lo dice.

## Que trae la v22

- **v22: cada fork dice para qué juego es, en español.** Ya no solo sale 'usuario/nxnative ★0'. Ahora dice: kid = Ocarina, horizon = Bananza / Mario Kart / Pokopia, pokopia = Pokopia, etc. Los forks con 0 estrellas y sin descripción son solo copias del motor original, sin juego específico.
- **v22: arreglo de 'git pull falló (código 1)'.** El fork local tenía cambios sin guardar (mejoras tiki / perfil), y git pull se negaba. Ahora actualiza con --autostash, y si falla hace reset a lo último de GitHub; las mejoras tiki se vuelven a aplicar al compilar.

## Que trae la v21

- **v21: el botón de actualizar ya usa la API de GitHub, no raw.** Raw se quedaba en caché y siempre bajaba la versión vieja. Ahora baja la última de verdad.

## Que trae la v20

- **v20: errores corregidos en revisión.** Picker de Fork ya no queda en blanco si el fork elegido no estaba en la lista filtrada; cargar todos los forks usa `python3` en vez de una ruta que no existe en otras Macs; auto-actualizar ya no depende del log (que llegaba tarde) sino de un archivo marcador; la barra de progreso ya no confunde `[RED]` con un paso `[x/6]`.

## Que trae la v19

- **v19: nombres de forks traducidos y solo el más actualizado.** Por defecto solo se muestra el mejor fork para tu juego, en español claro. Si quieres ver todos, apaga el toggle.

## Que trae la v18

- **v18: todo más entendible para quien la usa por primera vez.** Tarjeta de bienvenida con 3 pasos simples, modo principiante que esconde lo avanzado, y “¿Qué es esto?” en cada sección. Incluye el arreglo v17 de xcodegen en segundo plano.

## Que trae la v17

- **v17: arreglo `xcodegen: command not found`.** El actualizador en segundo plano no tenía el PATH de Homebrew. Ahora exporta `/opt/homebrew/bin` y usa xcodegen con ruta completa.

## Que trae la v16

- **v16: arreglo del bucle de actualizar.** La v15 se cerraba y abría en bucle porque el parseo de la versión fallaba. Ahora la app ya NO se actualiza sola al abrir, solo cuando le das al botón "Revisar / actualizar launcher ahora".

## Que trae la v15

- **v15: en Fork salen todos los disponibles de GitHub.** Botón "Cargar todos los forks de GitHub" trae hasta 100 forks de nxnative + los de kid, y los mete en la lista. Ya no son solo 4.

## Que trae la v14

- **v14: la app reconoce tu juego sola.** Al elegir el juego, te dice en una tarjeta verde si hay fork para ese juego, cuál es y qué mejora se le puede aplicar al compilar. Botón "Usar este fork" lo elige y lo descarga solo. Si no hay fork específico, te ofrece la optimización universal Switch 2.

## Que trae la v13

- **v13: auto-actualización de verdad.** La v10-v12 intentaba reemplazar la app mientras corría y macOS no dejaba, por eso tenías que venir a descargar y compilar. Ahora, si hay versión nueva, la app se cierra sola, un actualizador aparte recompila y abre la app nueva solo. La primera vez a v13 sí es a mano una vez, con `bash actualizar.sh`.

## Que trae la v12

- **v12: optimizado no solo Ocarina.** Buscar forks en GitHub para cualquier juego (Bananza, Pokopia, Mario Kart…), y optimización universal Switch 2: perfil genérico (tex_release 2, Potato, Metal 4, render 0.5) para cualquier juego por Title ID, con backup. Ver `docs/fork-generico-sw2.md`.

## Que trae la v11

- **v11: interfaz nueva, más bonita y más entendible.** Tarjetas por paso, números grandes 1-2-3-4, botones con icono, botón verde grande para Compilar, y textos cortos en español claro.

## Que trae la v10

- **v10: auto-actualización.** Al abrir la app, sola consulta este repo; si el README dice una versión mayor que v10, baja sola el App.swift nuevo, recompila y deja la app nueva en build/Release. Solo cierra esta app y abre la nueva. Si no hay nada nuevo, no hace nada.

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
