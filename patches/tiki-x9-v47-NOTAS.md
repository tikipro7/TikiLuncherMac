# v47 — Modo bajo de RAM por defecto en el juego (10 nov 2026)

## Qué cambia

El modo bajo de RAM ya viene prendido por defecto, no solo en ajustes:

1. **En el juego (kid X9, parche `tiki-x9-oot-defaults.patch`, SHA-256 `e60e82c90e94e5e459311ab838e5e19975d4106de664373a640fb6480b883ab4`)**
   - `dm/games/0400486024DEC000/game.tsv`: `fps_target 60 → 30`,
     `render_scale_default 0.667 → 0.25`, y clave nueva `potato_default on`.
   - `dm/games/game.py`: la clave genera `#define DM_GAME_POTATO_DEFAULT 1`
     (0 si está off o no existe, así otros juegos quedan igual).
   - `dm/games/settings.tsv`: el default de `DM_PRESET` pasa de `0` a
     `DM_GAME_POTATO_DEFAULT`. Solo Ocarina tiene lista Potato, así que
     solo a Ocarina le cambia.
   - `dm/games/0400486024DEC000/README.md`: el cambio queda en la nota
     del juego, como pide el AGENTS.md de kid.
   - Verificado aquí: aplica limpio sobre kid X9 `a758ea2d` (`git apply
     --check` OK); `game.py header` da `DM_GAME_FPS_TARGET 30`,
     `DM_GAME_POTATO_DEFAULT 1`, `DM_GAME_RENDER_SCALE_DEFAULT 0.25f`;
     `settings.py` genera `DM_PRESET` default `potato` y `DM_FPS_TARGET`
     default `30`. El slider de render solo aparece con los fixups reales
     del build, pero su default viene del perfil.
   - Apagar Potato sigue siendo un toggle en el launcher del juego, y una
     elección guardada o un `env.txt` que ponga `DM_PRESET` siguen ganando
     sobre este default. No se quita la fila de ajustes.

2. **En el launcher (ForkTikiLauncher v47)**
   - `optimalPreset(for:platform:)` ya devuelve el preset por defecto
     para Ocarina según el dispositivo: iPhone -> 30 fps Potato,
     Mac -> Mac 8 GB MAX Potato (mismo eje, con file_wire solo Mac).
     Al cambiar de dispositivo, el preset cambia solo si era uno de
     los dos defaults de Ocarina. Para otros juegos sigue siendo
     "Sin preset". Se puede cambiar en la lista.
   - En Mac, el default en el juego también vale: `settings.py` es
     compartida con la ventana de ajustes de Mac, y con
     `SETTINGS_PLATFORM=mac` el launcher.json sale con `DM_PRESET`
     potato y `DM_FPS_TARGET` 30 (verificado).
   - `applyTikiFixesToFork` aplica el parche de defaults después del
     parche por plataforma (v46), antes del build, solo para kid/Ocarina.
     Si ya está, lo salta; si falla, el juego queda con sus defaults
     viejos y el log lo dice, el build no se para.

## Antes / después en el juego

- Antes: al abrir, Frame rate 60, Render scale 0.667, Potato mode off.
  Había que prender Potato a mano en ajustes.
- Después: al abrir, Frame rate 30, Render scale 0.25 (Potato), Potato
  mode on, con sus filas bloqueadas en sus valores mientras esté on.

## Validación pendiente (no compilado aquí, Linux sin Xcode)

En la Mac de Luis: subir v47 a GitHub, `git pull`, `grep appVersion`
debe decir `v47`, `xcodegen generate` + `xcodebuild`, Build con kid X9
en `a758ea2d`, y al abrir el juego comprobar que Potato ya viene on,
Frame rate en 30 y Render scale en 0.25, sin tocar ajustes. Luego medir
en Kokiri parado 60 s (Metal/App/Available/FPS a 0, 30 y 60 s).
