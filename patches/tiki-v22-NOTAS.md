# tiki-v22 — Fork mejorado de Ocarina partiendo de kid V22
Fecha: 9 nov 2026. Hecho en Simular Box (`main`, Ubuntu 24.04 x86_64),
carpeta `/workspace/src/tiki-v22` (copia de `/workspace/src/oot-fix`,
sin tocar el trabajo de Bananza ni `/workspace/src/oot-fix`).

## Base
- kid-with-sword-remake, rama `v22`, commit `84aa8c3`
  ("docs: V18 to V22 in the build table").
- Rama local en el box: `tiki-v22`, HEAD `6eab51a`.
- Verificación de base: `git merge-base --is-ancestor 84aa8c3 HEAD` → sí.

## Qué se aplicó (1 de 2)
### a) Fix primera nota de ocarina — APLICADO y verificado
- Commit real upstream: `8feddfeeb6268923d66b64a6e15efeb9b2901cf9`
  (PR seedds#1444). **NO** `b1d7c70` / `6121fd7` (verificado antes:
  `b1d7c70` no toca `hle_hid.c`, `6121fd7` solo añade
  `FinalizeSensorFusion`).
- Cambio: 4 líneas en `dm/host/hle_hid.c`, tras
  `IsVibrationDeviceMounted` (línea 906 en V22). Reusa `vib_targets`.
- Verificación en el box:
  `grep -n IsOunceVibrationDeviceMounted dm/host/hle_hid.c` →
  **línea 910**, `h_hid_VibMountedOunce`.
- Commit en la rama: `6eab51a` — "Ocarina: puentea
  nn::hid::IsOunceVibrationDeviceMounted (PR seedds#1444, commit 8feddfe)".
- El diff `v22..tiki-v22` es solo este fix (1 archivo, 4 inserciones)
  y es byte a byte igual al parche ya verificado
  `ocarina-note-fix.patch` (SHA256
  `7611e951217e5222fc0c5d1f57ed7b3b54ef63d9300b8760073dbcb343767516`).

## Qué NO se pudo aplicar (1 de 2)
### b) Memoria/disco upstream 8d5d4f1 — CONFLICTO, abortado, sin parche inventado
- Commit: `8d5d4f1b04610fef5a96521c72a4263d68794959` — "Guest files give
  the disk back what the game gives back, and stop on the room left
  after dirty pages (2 GB, counting purgeable space)" (PR #1492).
  7 archivos, 199 inserciones, 31 borrados; el núcleo es
  `dm/host/hle_svc.c` (184 líneas).
- El commit existe en el box (está en el clon de nxnative main,
  HEAD `04811a6`, que lo tiene como ancestro). El cherry-pick se
  intentó de verdad y **dio conflicto en 5 archivos**; se abortó con
  `git cherry-pick --abort` y el árbol quedó limpio en `6eab51a`.
- Conflictos exactos (líneas de los marcadores `<<<<<<<` / `=======` /
  `>>>>>>>` en el árbol en conflicto):
  - `dm/games/0400486024DEC000/README.md`: líneas 140–153 (1 hunk)
  - `dm/host/hle_svc.c`: líneas 473–589 (1 hunk grande, ~110 líneas:
    el núcleo del fix, F_PUNCHHOLE / `guest_file_punch`)
  - `dm/host/tests/t_svc_memory.c`: líneas 558–566 (1 hunk)
  - `docs/agents/symptoms.md`: líneas 151–156 (1 hunk)
  - `docs/reference/memory.md`: líneas 460–473 (1 hunk)
  - Sin conflicto (auto-merge): `dm/host/tests/Makefile`,
    `docs/env_switches.tsv`.
- Por qué choca: kid V22 ya divergió de upstream main en `hle_svc.c`
  (su propia gestión de memoria/pools en archivos de Potato). Tanto el
  padre de `8d5d4f1` como kid V22 tienen 16 líneas `guest_file` en ese
  archivo, pero el código alrededor cambió lo suficiente para que el
  hunk de 184 líneas no aplique limpio.
- Verificación tras el abort: `grep -c guest_file_punch
  dm/host/hle_svc.c` → **0**. El fix **NO** está en `tiki-v22`.
- No se inventó un parche a mano: resolver ese hunk a mano sin poder
  compilarlo (el box no tiene Xcode/Metal/clang para Objective-C)
  sería falsa seguridad. Lo correcto es resolverlo en la Mac, donde el
  build valida que compila, o esperar a que kid lo integre en V23.

## Archivos de esta entrega
- `~/workspace/oot-ultra-potato/tiki-v22.patch` — diff `84aa8c3..tiki-v22`
  (solo el fix de la ocarina). SHA256
  `7611e951217e5222fc0c5d1f57ed7b3b54ef63d9300b8760073dbcb343767516`.
- `~/workspace/oot-ultra-potato/tiki-v22.bundle` — bundle git con el
  commit `6eab51a` (rama `tiki-v22`). SHA256
  `8d920b8dc5a6fbcc5a30b81b18523f21a0fb57ed9e4a3e790d85239f6ac33a61`,
  1,036 bytes. **OJO: no es autocontenido** — solo trae el commit
  nuevo y exige como prerrequisito `84aa8c3` (V22). Solo sirve para
  traerlo a un repo que YA tiene V22 (ver comandos abajo). Clonar
  desde cero con el bundle falla con "Repository lacks these
  prerequisite commits: 84aa8c3" — eso es normal, no es un error del
  bundle.
- `~/workspace/oot-ultra-potato/tiki-v22-NOTAS.md` — este archivo.
- En el box: `/workspace/src/tiki-v22` (rama `tiki-v22`, HEAD
  `6eab51a`, árbol limpio). Log: `/workspace/dkb-fork.log`.

## Cómo usarlo en la Mac de Luis
ForkTikiLauncher **v8 ya hace esto automáticamente**: con el toggle
"Mejoras tiki" prendido (default ON), antes del build aplica el parche
de la ocarina y hace el cherry-pick de `8d5d4f1`; si el cherry-pick da
conflicto lo aborta y lo dice en el log, y sigue con el build. Por eso
este bundle es la base para futuras mejoras, no un paso obligatorio.

Para traer la rama a mano en el motor kid V22 de la Mac:
```bash
cd ~/ForkTikiLauncher/engines/kid-with-sword-remake
git checkout v22        # debe ser 84aa8c3
git fetch /ruta/a/tiki-v22.bundle tiki-v22:tiki-v22
git checkout tiki-v22
grep -n IsOunceVibrationDeviceMounted dm/host/hle_hid.c
# debe dar la línea 910 con h_hid_VibMountedOunce
```
O solo el parche (mismo resultado, sin la rama):
```bash
git checkout v22
git apply ~/workspace/oot-ultra-potato/tiki-v22.patch
grep -n IsOunceVibrationDeviceMounted dm/host/hle_hid.c
```

Para intentar `8d5d4f1` a mano en la Mac (donde el build valida):
```bash
git remote add upstream https://github.com/seedds/nxnative.git 2>/dev/null || true
git fetch upstream main
git cherry-pick 8d5d4f1b04610fef5a96521c72a4263d68794959
# Si da conflicto, resolver SOLO en dm/host/hle_svc.c (hunk 473-589 en
# el intento del box) y en los 4 archivos de docs/tests listados
# arriba; luego: git add -A && git cherry-pick --continue
# Si no se puede resolver,: git cherry-pick --abort y esperar a V23.
grep -n guest_file_punch dm/host/hle_svc.c  # debe dar líneas
```

## Qué sigue para Mac / iPhone
1. Reconstruir Ocarina con `tiki-v22` (ForkTikiLauncher v8, Potato on,
   30 fps, render 0.25, Separate), ~2 h. El build valida que el fix de
   la ocarina compila.
2. Instalar con AltStore Classic y probar en Impa: tocar la ocarina y
   dar la primera nota de Zelda's Lullaby. Si ya no se cierra, el fix
   funciona.
3. `8d5d4f1` sigue pendiente: o se resuelve el conflicto en la Mac, o
   se espera a V23 de kid. Sin él, el juego sigue parándose solo con
   menos de 5 GB libres (nota de V22).
4. No se pudo probar nada en el box: Linux x86_64 sin Xcode/Metal, no
   compila el juego ni un IPA, y no corre el juego. La prueba real es
   solo en el iPhone de Luis.

## Sin perfil ni env.txt nuevos
Como pidió Luis: este fork es solo código interno. El perfil y el env
los aplica él afuera en su Mac.
