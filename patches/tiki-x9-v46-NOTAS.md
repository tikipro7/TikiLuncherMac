# v46 — Traspaso-iPhone + eje Matías (10 nov 2026)

## Qué aplica el launcher, por plataforma (antes del build, solo kid X9)

- iPhone (`targetPlatform == "ios"`): `tiki-x9-iphone.patch`
  SHA-256 `f1e1d131431085d0cdd0da31fa8ac5f783af12594e55884cf16d68d6a960f66f`
  = combined (01 pool_peek PR #2085 + 02 misses PSO PR #1825 + 03 SHADER_CODE
  + 05 LiveControls) + 06 guest-file-punch + 09 image-family V23 on
  + 08 task-isolate PR #1842. Sin 07 file_wire (solo Mac).
- Mac (`targetPlatform == "mac"`): `tiki-x9-max.patch`
  SHA-256 `faa40c2081264f59db0998e256646b23e07f4f72399610354ac2092571ff2f85`
  = lo mismo + 07 file_wire Mac-only (`#if TARGET_OS_MAC`).

Si el parche único ya está (grep pool_peek + guest_file_punch +
task_isolate_hit) se salta; si falla el `git apply`, el launcher sigue con
los pasos viejos (nota 8feddfe, memoria 8d5d4f1, pool_peek), que también se
saltan solos si ya están.

## Presets v46

- `15 Pro Max · 30 fps Potato iPhone (X9)` = `env-iphone-15promax.txt`:
  `DM_PRESET=potato`, render 0.25, MetalFX, `DM_TEX_RELEASE=1`, FG off.
- `Mac 8 GB · MAX Potato (X9)` = `env-max-8gb.txt`: render 0.25, FG off,
  `DM_GUEST_FILE=1`, `DM_NVN_FILE_WIRE=1`.
- `Mac 16 GB · MAX (X9)` = `env-max-16gb.txt`: render 0.50 (techo a probar,
  fallback 0.40), FG on, `DM_NVN_FILE_WIRE=1`.
- Experimento aparte, no en la lista: `env-iphone-15promax-texlazy1.txt`
  (`DM_TEX_LAZY=1`, sin `DM_PRESET=potato`).

## Antes / después (escetimación, no medición)

- iPhone, parado en Kokiri: antes Metal 6.57 GB, App 3.59 GB, Available
  2.85 GB, FPS 25.95 bajando solo hasta cerrarse. Después, escatimado:
  Metal ~5-5.5 GB, Available ~4 GB, FPS 30 estables.
- Mac, cap vieja: antes Metal 4.57 GB, App 9.51 GB, 50.70 fps a 2560x1440.
  Después, escatimado: Metal ~3-3.5 GB, App ~7.8-8.5 GB, FPS ~50-55.

## Créditos

- Matías (amigo de Luis, no autor de Netal ni de nxnative): aportó Netal,
  las capturas del autor y la idea eje — el buffer es la principal causa
  del consumo excesivo de RAM, y con MetalFX + baja resolución debería ir bien.
- Autores: lunks + Pedro Nascimento (PR #2085 pool_peek), kid X9 cheemu21,
  nxnative (PR #1825, #1936, #1842). Netal: nschlaepfer / Nico, descartado
  para iPhone (solo Mac, sin target iOS).

## Validación pendiente (no compilado aquí, Linux sin Xcode)

En la Mac de Luis: `git pull` / copiar App.swift, `xcodegen generate` +
`xcodebuild`, abrir v46, Build con kid X9 en `a758ea2d`, preset iPhone o
MAX, Separate para iPhone / Bundle para Mac, y medir en Kokiri parado
60 s (Metal/App/Available/FPS a 0, 30 y 60 s). Éxito = Metal deja de subir
y FPS se queda en 30.
