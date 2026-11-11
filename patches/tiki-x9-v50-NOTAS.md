# ForkTikiLauncher v50 — perfil "ESTABLE" genérico Switch 2

## Qué trae

Nuevo preset **"Genérico · 30 fps ESTABLE (Switch 2)"** (`presetGenericoEstable`,
`patches/env-generico-estable.txt`) y el env genérico actualizado en
`docs/fork-generico-sw2.md` (sección 2). No cambia nada de v46-v49.

## Los 3 cambios (los mismos del estable de Ocarina, genéricos NVN)

1. `DM_TEX_LAZY=1` + `DM_TEX_LAZY_MIN_KB=4096`
2. `DM_FPS_HOLD=off`
3. `DM_QOS_MAP=1` + `DM_QOS_EDGES=45,59`

Base genérica: 30 fps, Handheld (`DM_OPMODE=0`, en otros juegos sí es un cambio
real), render 0.5, MetalFX, `DM_TEX_RELEASE=1` primero.

## Ocarina se queda con lo suyo

Ocarina sigue con **SU perfil completo** (`presetIphoneEstable`,
`patches/env-iphone-15promax-estable.txt`): render 0.25, Potato deletreado,
image-family, task-isolate. El genérico no trae nada de eso, porque es propio
de Ocarina. El genérico es para los demás juegos; Ocarina jala mejor con el suyo.

## En la Mac de Luis

Subir v50 a GitHub, `git pull`, `grep appVersion` debe decir `"v50"`,
`xcodegen generate`, `xcodebuild … -derivedDataPath build/DerivedData build`.
Sin probar por juego: cada juego se mide aparte.
