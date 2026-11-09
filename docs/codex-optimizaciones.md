# Ocarina — optimizaciones más allá de Potato (revisión con Codex intentada, manual verificada)
Fecha: 9 nov 2026. Hecho en Simular Box (`main`, Ubuntu 24.04 x86_64).
Base: kid-with-sword-remake V22 (`84aa8c3`) + fix ocarina (`6eab51a`),
en `/workspace/src/oot-fix`. Upstream comparado: seedds/nxnative main
`04811a6` (10 nov 2026), en `/workspace/src/nxnative`.

## 1. Codex NO corrió — dilo claro
- Codex CLI existe: local `0.164.0-alpha.9` (`/opt/hatch-image/bin/codex`)
  y en el box `0.166.0` (`/usr/local/bin/codex`).
- Pero **no tiene login**: en el box no hay `~/.codex/auth.json`, no hay
  `config.toml` y no hay `OPENAI_API_KEY` en el entorno. La prueba
  `codex exec "Responde solo: HOLA"` falló con
  `ERROR codex_api::endpoint::responses_websocket: failed to connect`,
  reintentando 2/5 y sin responder.
- Por eso la revisión de abajo es **manual, con `git show` / `grep`** en
  el box, no una salida de Codex. Nada de lo que sigue es inventado:
  cada afirmación cita archivo y línea, o el commit upstream con sus
  medidas. Lo que no se pudo verificar está marcado NO VERIFICADO.
- Para que Codex corra hace falta un login de ChatGPT o una API key de
  OpenAI en el box; eso lo tiene que poner Luis, yo no lo puedo crear.

## 2. Lo que V22 YA trae (por eso queda poco margen)
Leído de `dm/games/0400486024DEC000/game.tsv` (kid V22) y su `README.md`.
Todo esto ya está prendido; no se puede "volver a ganar":
- `tex_release 2` — pico en Kokiri 7.0 → 5.2 GB. Es el nivel máximo.
- `potato` — guard GPU desde 4,400 MB, recycle bin 64 MB, sweep 600
  fences, warm-only, pools >512 MB en archivos, lazy textures.
  Definida en `game.tsv`, la aplica `dm/host/loader.c` (`dm_preset_apply`).
- `gmem_skip on`, `pool_skip_retired on` (~2.5 GB al cambiar de zona),
  `tex_soft on`, `rt_lossy on` (~100 MB en la casa de Link).
- `dispatch_overlap on` — 117 dispatches en Kokiri: 5.7 → 3.7 ms.
- `gpu_timestamps segment`, `present_snap on`, `link_latency30 2`,
  `fps_payback off`, `pso_mtl4 on`.
- `mem_alias 0x200000000` (8 GB), `mem_reserve 0x468000000`,
  `app_pool 0x240000000` (9 GB).
- `rt_drop off` — **a propósito**: kid lo probó y rompió texturas
  (278 de ~300 stand-ins vueltos a dibujar en el título, objetos que
  aparecen y desaparecen). No se reactiva sin reescribir el sweep.
- El fix de la primera nota de ocarina YA está:
  `workspace/oot-ultra-potato/ocarina-note-fix.patch` (commit real
  `8feddfe`, 4 líneas en `dm/host/hle_hid.c`, línea 910 en V22).
  No se rehace aquí.

Conclusión del punto 2: en el iPhone de Luis (entra a 30 fps, baja a 10
en Kokiri, se cierra) el cuello no es un ajuste que falte en el perfil:
es memoria (~6 GB efectivos) + GPU (70–106 ms, 1,100–1,800 draws en
Kokiri). Lo que queda son ports de upstream, no interruptores.

## 3. Candidato 1 — EL MEJOR: devolver bloques de los archivos del juego (upstream `8d5d4f1`, 9 nov 2026)
**Qué es:** los archivos del juego (guest files, donde Potato guarda los
pools) solo se marcaban PROT_NONE al liberarlos: sus bloques de disco se
quedaban ocupados toda la sesión y un rango mapeado de nuevo tomaba
bloques nuevos. El fix los devuelve con F_PUNCHHOLE (barrido cada 10 s
en la región alias) y cambia la regla de parada: ya no 5 GB libres, sino
2 GB contando lo purgable (`DM_GUEST_FILE_MIN_FREE`, ahora 2G).

**Medido por upstream (en el propio commit):** Ocarina en Mac M4 Pro,
5 minutos: páginas sucias del juego 7.80 → 5.98 GB, **1.84 GB devueltos
como huecos, tiempo de frame sin cambio**. Y el caso que lo motivó: un
iPad paró Ocarina con 5.0 GB libres y 6.6 GB de archivos del juego
(PR #1492).

**Por qué importa para Luis:** su iPhone tiene 40 GB libres, pero el
juego se para solo con menos de 5 GB libres (nota de V22) y su log
marcaba 8.0 GB libres en el volumen del juego al final. Con Potato los
pools viven en archivos; si esos archivos no devuelven bloques, el
teléfono cree que no hay sitio y el juego se para. Este fix ataca justo
eso, sin tocar GPU ni shaders.

**Verificado ausente en kid V22:** `grep -c guest_file_punch` en
`dm/host/hle_hid.c` (kid V22) = **0**. No hay `purgeable` en ese archivo.

**Alcance del port:** `dm/host/hle_svc.c`, 184 líneas (+ test
`dm/host/tests/t_svc_memory.c`, 25 líneas; `docs/env_switches.tsv`,
`docs/reference/memory.md`). Nuevos conmutadores:
`DM_GUEST_FILE_PUNCH=0` (volver al comportamiento viejo),
`DM_GUEST_FILE_SCAN=1` (diagnóstico).

**Riesgo: MEDIO.** Toca la gestión de memoria del juego (heap + alias).
El propio upstream lo probó 5 minutos en Mac; en iPhone no hay medida.
No exige recompilar shaders (solo host), así que el rebuild es más
rápido que un build desde cero, pero sigue siendo un build completo del
motor (~40–60 min reutilizando extract/shaders).

**Cómo traerlo en la Mac (no un parche a mano):**
```bash
cd ~/ForkTikiLauncher/engines/kid-with-sword-remake
git checkout v22
git remote add upstream https://github.com/seedds/nxnative.git 2>/dev/null || true
git fetch upstream main
git cherry-pick 8d5d4f1b04610fef5a96521c72a4263d68794959
# Si da conflicto, resolver solo en dm/host/hle_svc.c; no forzarlo.
# Verificar: grep -n guest_file_punch dm/host/hle_svc.c  (debe dar líneas)
```

## 4. Candidato 2 — GPU, EXPERIMENTAL: pool marks con carga normal (upstream `04811a6`, 10 nov 2026)
**Qué es:** cada vez que un shader lee una textura de un pool, marca su
bit en un bitmap (`dm_pool_mark`). Antes era una carga atómica (aunque
relajada, va a la caché compartida de la GPU) y los píxeles de un pase
nombran pocos IDs, así que se encolaban en la misma palabra. Ahora la
palabra se lee con una carga normal y solo se hace el OR atómico si el
bit estaba a 0.

**Medido por upstream (en el propio commit):**
- Pase 1536x864 con 16 marcas por píxel: **2.60 ms (atómico) → 0.34 ms
  (normal)**, 0.18 ms sin marca (Apple M6).
- Pero en Ocarina real, parado en la terraza de Kokiri (M6):
  **GPU p50 14.38 ms en ambos casos** (5 carreras normal 13.99–14.88;
  4 atómico 14.28–15.34). Con los IDs repartidos en 4,096, las dos
  cargas cuestan lo mismo.
- En iPad Pro M5, el pase de color de Ocarina pasó de ~13.0 a ~9.2 ms
  a 1536x864 (lo encontró aksmith-git; el autor no lo comprobó).

**Verificado ausente en kid V22:**
- `dm/gfx/tools/dmsh_build.py` (kid V22): `POOL_MARK` aparece **0 veces**;
  su `pool_arrays` (línea 871) emite `struct spvPool_<name> { uint n;
  array<element, 1> e; }` **sin** el campo `seen`.
- Upstream: `POOL_MARK` en `dm/gfx/tools/dmsh_build.py:1041`, struct
  con `ulong seen;` (línea ~1083), y host `dm/gfx/nvn/nvn_mtl.m:6238`
  (`pool_seen_clear`, `g_seen_buf`, `g_seen_done`, `POOL_SEEN_WORDS`).

**Alcance del port:** GRANDE. Traductor (`dmsh_build.py`: `POOL_MARK`,
struct con `seen`, reescritura de lecturas, `early_fragment_tests`) +
host (`nvn_mtl.m`: bitmap global, `pool_seen_clear`, que `pool_gpu`
solo fabrique las texturas leídas) + test
(`test_dmsh_pool_arrays.py`). Además **cambia la versión de la cadena
de shaders** (upstream: cadena `39eb2f781d07`; kid V22:
`DMSH_CHAIN "804433846e4b"` en `dm/gfx/nvn/dmsh_chain.h:3`): hay que
**recompilar los 42,854 shaders desde cero** (~1–2 h de build).

**Riesgo: ALTO, ganancia DUDOSA en el 15 Pro Max.** El propio upstream
midió 0 en Kokiri (M6). En el iPhone de Luis el pase de color es de
480x270 (render 0.25), o sea ~1/9 de píxeles que 1536x864, y su GPU
está en 70–106 ms por los 1,100–1,800 draws y los mesh shaders de
follaje, no por las marcas de pool. Ganancia esperada en su teléfono:
**de 0 a ~2 ms, sin medir**. No prometer fps por esto.

**Cómo traerlo en la Mac (si se quiere probar, solo y con medida):**
```bash
git cherry-pick 04811a634b7f9344e882129b0973dd493369dd62
# OJO: ese commit es enorme (trae también CI/lint). Mejor traer solo
# el cambio de dmsh_build.py + nvn_mtl.m, o esperar a que kid lo
# integre en V23. No aplicar un parche parcial: el struct con `seen`
# sin el host que lo lee rompe las texturas.
```

## 5. Candidato 3 — cinemática: red de vídeo NDVE con kernels Metal (upstream `c66a36a`, 9 nov 2026)
**Qué es:** la red de vídeo de `nn::ndve` (la que procesa la película
del título) corre como kernels Metal del host en vez de shaders.

**Medido por upstream:** la película del título de Ocarina pasa de
**12.78 a 6.77 ms de GPU por frame** en Mac M4 Pro (issue #1375,
PR #1894).

**Verificado ausente en kid V22:** kid no tiene archivos NDVE del host
(solo `dm/gfx/tests/test_ndve.py`); upstream trae
`dm/gfx/msl/ndve_engine.metal` y `dm/gfx/nvn/nvn_ndve.inc`.

**Relevancia para Luis: MEDIA-BAJA.** Su problema en la cinemática era
el **sonido cortado por errores AV1** (paquetes rechazados en el log),
no la GPU de la película. Esto bajaría la GPU de la cinemática, no
arregla el audio. Riesgo MEDIO (código nuevo de kernels + cadena
`d7576061facd` en otro commit relacionado, no este).

## 6. NO VERIFICADO — no proponer sin comprobar en Mac
- Upstream `8190693` (9 nov 2026): el depth attachment muestreado en
  su propio pase sigue la regla del color; quita las rayas azul claro
  en Death Mountain (PR #1917, #1866). GreenKid 0.2.0 también lo lista.
  **No comprobé si kid V22 ya lo trae** (el cambio está dentro del
  host y no se distingue con un grep simple). Antes de proponerlo hay
  que hacer el diff en la Mac.
- Upstream `1d37720` (pool retirado entre submissions, PR #1392) y
  `68869cc` (present resuelto en el hilo de submit): existen en kid
  las estructuras (`g_res`, `present_enqueue` en `nvn_mtl.m:15349`),
  pero el cambio concreto no se verificó. Mismo trato: diff en Mac.

## 7. Qué NO se entrega como parche, y por qué
No hay ningún `codex-*.patch` en esta entrega, a propósito:
- Los dos ports buenos ( §3 y §4) tocan gestión de memoria del juego y
  el traductor de shaders. Un parche que "aplica limpio" no prueba nada:
  en el box no hay Xcode, Metal ni clang para Objective-C (hay gcc de
  Linux, que no compila `mach/mach.h` ni CoreFoundation), así que **no
  se puede compilar ni probar** aquí. Un parche a mano, sin compilar,
  es más peligroso que útil.
- El mecanismo correcto es el `git cherry-pick` de arriba, en la Mac,
  donde el build valida que compila; y la medida en el iPhone valida
  que ayuda.
- Si kid saca V23 con estos commits integrados, ese es el camino más
  seguro: actualizar el fork y reconstruir, sin cherry-picks.

## 8. Qué queda para probar en Mac / iPhone (en este orden, uno a la vez)
1. **Primero el candidato 1 (`8d5d4f1`)**: aplicar, reconstruir con
   ForkTikiLauncher v7 (Potato on, 30 fps, render 0.25, Separate),
   instalar con AltStore Classic. Medir en Kokiri: GB libres en el
   teléfono, App GB, si se cierra, y el log cada 10 s (línea de
   páginas sucias / huecos). Éxito = aguanta más minutos sin cerrarse,
   con el mismo fps.
2. **Después, solo si el 1 no basta, el candidato 2 (`04811a6`)**:
   rebuild completo de shaders incluido. Medir GPU ms en Kokiri antes
   y después, mismo sitio, mismo render 0.25. Si la GPU no baja, se
   descarta y no se vuelve a tocar.
3. El candidato 3 solo si la cinemática sigue pesando en GPU tras el 1
   y el 2; el audio cortado de la cinemática (AV1) no lo toca ninguno
   de estos tres.
4. Seguir con el parche de la primera nota ya hecho
   (`ocarina-note-fix.patch`, commit `8feddfe`): va en el mismo build,
   no interfiere con estos tres.

## Archivos de esta entrega
- Este archivo: `~/workspace/oot-ultra-potato/codex-optimizaciones.md`
- Parche de la ocarina (ya hecho, sin tocar):
  `~/workspace/oot-ultra-potato/ocarina-note-fix.patch`
- Log en el box: `/workspace/dkb-fork.log` (también `/workspace/ESTADO.txt`)
- Sin perfil ni env.txt nuevos: eso lo aplica Luis afuera, como pidió.
