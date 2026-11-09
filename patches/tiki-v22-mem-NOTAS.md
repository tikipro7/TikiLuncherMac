# tiki-v22-mem — Cherry-pick de memoria 8d5d4f1 resuelto a mano sobre kid V22

Fecha: 9 nov 2026. Hecho en Simular Box (`main`, Ubuntu 24.04 x86_64),
rama `tiki-v22-mem`, HEAD `040f685`, en `/workspace/src/tiki-v22`.
Base: `tiki-v22` (HEAD `6eab51a`: kid V22 `84aa8c3` + fix primera nota de
ocarina `8feddfe`, línea 910 de `hle_hid.c`).

## Resultado: RESUELTO (candidato SIN COMPILAR)

El cherry-pick de `8d5d4f1b04610fef5a96521c72a4263d68794959` ("Guest files
give the disk back what the game gives back...", PR seedds#1492) se
resolvió hunk por hunk y se commiteó. El diff `tiki-v22..tiki-v22-mem`
es **7 archivos, 199 inserciones, 31 borrados — exactamente el mismo
stat que el commit upstream original** (y en `hle_svc.c` las cuentas
+/- son idénticas a las de upstream: 157+/26-). Ninguna línea de kid
fue borrada: las 26 líneas borradas son todas del padre upstream
(comentarios viejos, `MIN_FREE` 5G, llamadas de 2 args a
`guest_release`).

## Cómo se resolvió cada conflicto

### 1. `dm/host/hle_svc.c` — el núcleo (conflicto líneas 473-589)
La causa real del conflicto: kid insertó toda su maquinaria Potato
(`anon_move` / `dm_guest_pool_anon` / `anon_release`, ~106 líneas)
justo antes de `guest_release`, y upstream cambió en ese mismo punto
el comentario final y la firma de `guest_release`.
Resolución, sin tocar la lógica de ninguno de los dos lados:
- Comentario: se tomó el de upstream (los bloques se perforan con
  `guest_file_punch`; alias solo se marca para el sweep) y se
  conservó íntegro el comentario + código anon de kid.
- Firma: la de upstream, `static int guest_release(uintptr_t lo,
  uintptr_t hi, int alias)`.
- Los dos callers ya venían auto-fusionados con 3 args (heap `0`,
  alias `1`), así que no hubo que tocarlos.
- El cuerpo fusionado ya llamaba a `anon_release(lo, hi)` (kid) y a
  `guest_file_punch` / marcado `g_alias_rel` (upstream): ambos
  conviven, el release de un pool anon mapea sus archivos de vuelta
  antes del punch.
- Verificado: `guest_file_punch` 6 ocurrencias, `guest_file_sweep` 4,
  `g_gf_punch` 9, `g_alias_rel` 8 — iguales que en upstream nuevo.
  `g_gf_punched`, `g_alias_rel`/`g_alias_aged` declarados y con
  calloc; `g_gf_punch` default 1 con `DM_GUEST_FILE_PUNCH`;
  `DM_GUEST_FILE_MIN_FREE` default ahora **2G** (antes 5G).
  Sin definiciones duplicadas, sin marcadores, `git diff --check` OK,
  llaves balanceadas (0).

### 2. `dm/host/tests/t_svc_memory.c`
El test nuevo `file_sweep` de upstream se insertó **byte a byte
idéntico** tras `file_rule()` (verificado por comparación directa) y
se añadió `file_sweep();` a la lista de `main()`. Funciona contra el
`hle_svc.c` fusionado porque el test incluye `../hle_svc.c`
directamente: `g_gf_punched`, `g_gf_tab` y `guest_file_sweep` son
visibles como estáticos. No hubo que inventar ninguna declaración.

### 3. `docs/reference/memory.md`
- Frase del `Fix` reescrita con el texto de upstream: los bloques se
  perforan, `DM_GUEST_FILE_MIN_FREE` default 2 GB de hueco tras las
  páginas sucias.
- Sección nueva de upstream insertada íntegra tras el `Found on:`
  de Mario Kart World: "Guest files keep the blocks of memory the
  game gave back" (síntoma, causa, fix, por qué parar, resultado
  7.80 → 5.98 GB en M4 Pro, found on iPad Pro M5).

### 4. `docs/agents/symptoms.md`
Bala nueva de upstream insertada tras la bala del jetsam en iPhone
(la del síntoma en iPad: 5.0 GB libres, 6.6 GB de archivos). Texto
verbatim de upstream.

### 5. `dm/games/0400486024DEC000/README.md`
Kid reescribió este archivo entero, así que la bala nueva de
upstream se añadió al final de su lista "Found on this game" (la
misma sección, sin borrar nada de kid).

### 6-7. Auto-fusionados (sin conflicto)
`dm/host/tests/Makefile` (link con `-framework CoreFoundation` para
`t_heap_size` y los tests de memoria) y `docs/env_switches.tsv`
(`MIN_FREE` default 2G, filas nuevas `DM_GUEST_FILE_PUNCH` y
`DM_GUEST_FILE_SCAN`).

## Qué se conservó de kid
Toda la maquinaria Potato de `hle_svc.c` (pools anon, `DM_POOL_ANON`,
`DM_POOL_ANON_MAX_MB`, `pa_fault`/`pa_prep`, `anon_release`), todo el
texto de kid en los docs (incluido su README de Ocarina reescrito y
sus `Found on:` propios), y el fix de la ocarina (`6eab51a` intacto
debajo).

## Verificación hecha en el box
- `git cherry-pick --continue` completado; HEAD `040f685`, autor
  original seedds preservado, árbol limpio, rama `tiki-v22-mem`.
- `git diff --cached --stat` = stat de upstream (199+/31-).
- `git bundle verify` OK; el bundle solo exige V22 `84aa8c3` (trae
  los dos commits: ocarina + memoria).
- `git apply --check` del parche exportado sobre un clon limpio en
  `6eab51a`: **OK**, y tras aplicar, `grep -c guest_file_punch` = 6.

## ⚠️ CANDIDATO SIN COMPILAR — leer antes de usar
- **No se pudo compilar en el box** (Linux x86_64, sin Xcode/Metal/
  clang para Objective-C; tampoco corre el juego). La sintaxis se
  verificó solo por inspección, cuentas de símbolos, `diff --check`
  y balance de llaves. El test `file_sweep` no se ejecutó.
- **La Mac debe validar con el build.** Si el build de
  ForkTikiLauncher falla en `hle_svc.c` o el test `t_svc_memory`
  falla, abortar este parche y esperar a V23 de kid (o resolver el
  error concreto en la Mac, donde el compilador dice la línea).
- Duda conocida (no bloqueante, pero a vigilar en el log): el test
  `file_sweep` espera que el sweep perfore 7 de 8 páginas del alias
  y que lean 0 al remapear; depende de que el `alias_initialize` de
  kid siga poniendo a cero lo perforado, como dice su comentario.
  Si el test falla ahí, el problema es esa interacción, no el resto
  del fix.
- El comportamiento cambia respecto a V22: `DM_GUEST_FILE_MIN_FREE`
  pasa de 5 GB a 2 GB por defecto, y los bloques liberados ya no se
  quedan en disco (se perforan). `DM_GUEST_FILE_PUNCH=0` vuelve al
  comportamiento anterior.

## Archivos de esta entrega
- `tiki-v22-mem.patch` — diff `6eab51a..040f685`. SHA256
  `23be66f058abbe264d40977a0fba5fe012936d20d455db77d97246c031c77922`
  (420 líneas). Aplica limpio sobre `tiki-v22` (`6eab51a`).
- `tiki-v22-mem.bundle` — bundle git con `040f685` (rama
  `tiki-v22-mem`). SHA256
  `2ca4ed1528d42b2ced07b64ec0081cd48d1c27ea284835afb655afde849a7448`
  (12,435 bytes). Solo exige V22 `84aa8c3`; trae ocarina + memoria.
- `tiki-v22-mem-NOTAS.md` — este archivo.
- En el box: `/workspace/src/tiki-v22`, rama `tiki-v22-mem`, HEAD
  `040f685`, árbol limpio. Log: `/workspace/dkb-fork.log`.

## Cómo usarlo en la Mac de Luis
Opción A (parche, sobre el motor kid V22 con el fix de ocarina):
```bash
cd ~/ForkTikiLauncher/engines/kid-with-sword-remake
git checkout tiki-v22        # debe ser 6eab51a
git apply /ruta/a/tiki-v22-mem.patch
grep -n guest_file_punch dm/host/hle_svc.c   # debe dar líneas
```
Opción B (bundle, desde V22 pelado):
```bash
cd ~/ForkTikiLauncher/engines/kid-with-sword-remake
git checkout v22             # debe ser 84aa8c3
git fetch /ruta/a/tiki-v22-mem.bundle tiki-v22-mem:tiki-v22-mem
git checkout tiki-v22-mem    # debe ser 040f685
```
Después: build con ForkTikiLauncher (Potato on, 30 fps, render 0.25,
Separate), ~2 h. El build es la validación: si compila, el fix de
memoria está dentro; si falla en `hle_svc.c`, abortar y esperar a V23.
Nota: ForkTikiLauncher v8 intenta el cherry-pick solo y lo aborta al
chocar; con este parche ya aplicado, ese intento debe saltarse (el
grep de `guest_file_punch` ya da líneas) o dará conflicto de nuevo
si se reintenta sobre el árbol ya parcheado.

## Sin perfil ni env.txt nuevos
Como pidió Luis: este fork es solo código interno. El perfil y el env
los aplica él afuera en su Mac.
