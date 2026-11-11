# Prueba A/B: perfil normal vs perfil "estable" (iPhone 15 Pro Max, Ocarina X9)

## Los dos perfiles

- **A (normal):** `patches/env-iphone-15promax.txt` (preset "15 Pro Max · 30 fps Potato iPhone (X9)").
- **B (estable):** `patches/env-iphone-15promax-estable.txt` (preset "15 Pro Max · 30 fps ESTABLE iPhone (X9)").

Solo se cambia el env.txt en Documents del juego, **no se recompila** (Separate: el env vive fuera del IPA).

## Los 3 cambios de B (todos verificados en kid X9 `a758ea2d`)

| Cambio | Dónde se verifica | Qué hace |
|---|---|---|
| `DM_TEX_LAZY=1` (en vez de 2, Potato deletreado sin `DM_PRESET`) | `dm/gfx/nvn/nvn_mtl.m` `tex_lazy()` | Los pool walks no crean textura host para ningún ID sin vista ≥ 4 MB. Ataca el Metal que subía solo parado. |
| `DM_FPS_HOLD=off` | `dm/gfx/nvn/hle_nvn.c` `fstep_tick` | Un frame tardío se muestra tarde, no se queda un vsync más. En nxnative #1789 / PR #1927, frames > 25 ms bajaron de 137-290 a 22-24. |
| `DM_QOS_MAP=1` + `DM_QOS_EDGES=45,59` | `dm/host/hle_thread.c` | Los hilos del juego toman QoS por prioridad; menos CPU en hilos de fondo, menos calor. |

## Lo que NO va (verificado, no hace nada en Ocarina)

- `DM_OPMODE=0`: el perfil ya es handheld (`game.tsv` línea 70, `op_mode handheld`).
- `DM_DYNAMIC_RESOLUTION=1`: solo NieR Automata (`hle_fpslock.c`, tabla `k_nier_dr`); Ocarina no tiene esa capacidad (`patches.py` solo trae `WIDE_VIEW`).
- `DM_NVN_ALLOC_CAP=16`: ya es el default en X9 (`ALLOC_DEFAULT 16`).
- `DM_TEX_RELEASE=2`: corrompe texturas.
- `DM_NVN_FILE_WIRE`: solo Mac.

## Protocolo (mismo en A y en B, mismo día, misma ruta)

1. iPhone con ≥ 15 GB libres, No Molestar prendido, cargador puesto.
2. Abrir el juego, ir a la casa de Link en Kokiri, **quedarse parado 60 s sin tocar nada**.
   Anotar a **0 s / 30 s / 60 s**: Metal, App, Available Memory, FPS, GPU ms, Frame Interval, thermal state.
3. Salir a Kokiri Forest, caminar 5 minutos por la misma ruta. Anotar FPS y thermal state al minuto 1, 3 y 5.
4. Guardar el log (`Documents/log.txt`) antes de volver a abrir: buscar las líneas
   `DM_TEX_LAZY=`, `[nvn] frame step: frames are not held`, `DM_QOS_MAP=1`.

## Cómo decidir

- **B gana** si entre 30 s y 60 s parado el Metal deja de subir y los FPS se quedan en 30, o si a los 5 minutos caminando los FPS no bajaron contra A.
- **B pierde** si se ve pop-in de texturas (CAMBIO 1) o si los FPS caen (CAMBIO 3): quitar ese cambio y repetir solo con los otros dos.
- Si A y B salen iguales, quedarse con A (el normal) y no tocar nada más.
