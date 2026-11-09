# Fork genérico para cualquier juego Switch 2 — con nxnative / NX2Apple
# OJO: esto NO es el fork kid-with-sword-remake, que es solo para Ocarina.
# Esto es lo genérico de ese fork, adaptado para cualquier juego SW2,
# con valores conservadores. Cada quien ajusta su juego por Title ID.

## 1. Perfil genérico — game.tsv
# Copia esto a graphics/nvn/games/<TU_TITLE_ID>/game.tsv
# Cambia <TU_TITLE_ID> por el Title ID de tu juego, ej. 0400486024DEC000
# NO copies el game.tsv de Ocarina a otro juego, los valores de alias
# y de resolución son de Ocarina. Mide tu juego primero.

# Memoria — valores conservadores para iPhone 15 Pro Max 8 GB
# mem_reserve: reserva total. Ocarina usa 0x468000000 (18 GB virtual).
# Para otro juego empieza con lo de upstream, y sube solo si te falta.
mem_reserve 0x320000000
mem_alias 0x100000000
mem_map_limit on
mem_stack 0x10000000
app_pool 0x240000000
sys_resource 0x3000000

# Texturas — tex_release genérico del fork
# Nivel 2 = más RAM libre, como en Ocarina (7.07 GB a 5.2 GB en Kokiri),
# pero si el juego relee una textura liberada, sale en negro.
# Prueba primero con DM_TEX_RELEASE=probe, y solo deja 2 si no hay texturas negras.
tex_release 2

# Shaders — prebuild Metal 4, genérico
pso_mtl4 on
pso_prebuild on

# Resolución — Potato genérico, sin overlay de Ocarina
# NO uses el overlay 720p de Ocarina en otro juego, su pack BYML es solo suyo.
# Usa escala genérica: 0.5 = Potato, 0.75 = ligero, 1.0 = normal
res_scale 0.5

# Workgroup — Deadline boost off, genérico, ayuda en iPhone
frame_wg off

# Controles — layout Native genérico
pad_layout native

## 2. env.txt genérico — para iPhone 15 Pro Max, 30 fps estable
# Pon esto en Documents/env.txt del juego en el iPhone
# Cada quien ajusta DM_RENDER_SCALE y DM_FPS_TARGET a su juego
DM_FPS_TARGET=30
DM_OPMODE=0
DM_RENDER_SCALE=0.5
DM_PRESENT_UPSCALE=off
DM_UPSCALER=metalfx
DM_PSO_PREBUILD=1
DM_PSO_MTL4=1
DM_PRESENT_SNAP=1
DM_NVN_ENC_THREAD=1
DM_FPS_HOLD=on
DM_FRAME_WG=0
DM_QOS_MAP=1
DM_QOS_EDGES=45,59
DM_SHOW_FPS=0
DM_METAL_HUD=0
DM_TOUCH_HAPTICS=0
DM_RUMBLE=0
DM_PICTURE_FIT=fit

## 3. Qué ajustar por juego — checklist
# - Title ID: pon el tuyo, no el de Ocarina 0400486024DEC000
# - mem_alias: mide con addr_need.py, no subas a 8 GB a ciegas
# - tex_release: 1 primero, 2 solo si no hay texturas negras
# - DM_RENDER_SCALE: 0.5 si va lento, 0.75 si va bien, 1.0 si sobra
# - DM_FPS_TARGET: 30 estable primero, 60 solo si el juego lo aguanta
# - Frame-step 30/60: NO es genérico, hay que buscar el stub de TU juego
#   y TU build, con RE. No copies el stub de Ocarina a otro juego.
# - Resolución 720p fija: NO es genérica, cada juego guarda su tabla distinto.
#   Usa res_scale genérico, no el overlay de Ocarina.
# - Si el juego crashea o salen texturas negras, baja a tex_release 1,
#   res_scale 0.75, y DM_FPS_TARGET=30, y prueba de nuevo.

## 4. Cómo usarlo con nxnative / NX2Apple
# 1. Clona nxnative upstream, no el fork de Ocarina
# 2. Crea graphics/nvn/games/<TU_TITLE_ID>/game.tsv con lo de arriba
# 3. Compila con el script normal, Separate recomendado
# 4. Pon el env.txt de arriba en Documents del juego en el iPhone
# 5. Instala con AltStore Classic, para que no se pierda Increased Memory Limit
