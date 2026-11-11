# ForkTikiLauncher v49 — perfil "ESTABLE" iPhone 15 Pro Max (Ocarina X9)

## Qué trae

Nuevo preset **"15 Pro Max · 30 fps ESTABLE iPhone (X9)"** (`presetIphoneEstable`,
`patches/env-iphone-15promax-estable.txt`) y el protocolo A/B en
`docs/iphone-estable-AB.md`. No cambia nada de v46/v47/v48.

## Los 3 cambios (todos verificados en kid X9 `a758ea2d`)

1. **`DM_TEX_LAZY=1`** en vez de 2, con la lista Potato deletreada y **sin
   `DM_PRESET=potato`** (lo aplica con `setenv(...,1)` y lo pisaría).
   `dm/gfx/nvn/nvn_mtl.m` `tex_lazy()`: los pool walks no crean textura host
   para ningún ID sin vista ≥ 4 MB. Ataca el Metal que subía solo parado.
   Riesgo: pop-in de un frame en texturas grandes.
2. **`DM_FPS_HOLD=off`** (`dm/gfx/nvn/hle_nvn.c` `fstep_tick`): un frame tardío
   se muestra tarde en vez de quedarse un vsync más. nxnative #1789 / PR #1927:
   frames > 25 ms bajaron de 137-290 a 22-24.
3. **`DM_QOS_MAP=1` + `DM_QOS_EDGES=45,59`** (`dm/host/hle_thread.c`): hilos del
   juego con QoS por prioridad, menos calor. Apagado por defecto "hasta que un
   A/B en teléfono muestre que ahorra sin tirar frames": esta prueba es ese A/B.

## Lo que NO lleva (verificado)

- `DM_OPMODE=0`: el perfil ya es handheld (`game.tsv` `op_mode handheld`).
- `DM_DYNAMIC_RESOLUTION=1`: solo NieR Automata (`hle_fpslock.c` `k_nier_dr`).
- `DM_NVN_ALLOC_CAP=16`: ya es el default en X9.
- `DM_TEX_RELEASE=2`: corrompe texturas. `DM_NVN_FILE_WIRE`: solo Mac.

## En la Mac de Luis

Subir v49 a GitHub, `git pull`, `grep appVersion` debe decir `"v49"`,
`xcodegen generate`, `xcodebuild … -derivedDataPath build/DerivedData build`.
Para probar el perfil estable **no se recompila**: solo se cambia el env.txt
en Documents del juego y se sigue `docs/iphone-estable-AB.md`.
