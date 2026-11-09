# PASOS — ForkTikiLauncher v11

v11: interfaz nueva con tarjetas por paso, números 1-2-3-4, botón verde grande para Compilar, y textos cortos.

# PASOS — ForkTikiLauncher v10

v10: auto-actualización al abrir la app, desde tikipro7/TikiLuncherMac. Si hay versión nueva, baja el App.swift, recompila sola y deja la app nueva en build/Release.

# PASOS — ForkTikiLauncher v9

v9: botón arriba para revisar si hay versión nueva del launcher en tikipro7/TikiLuncherMac, y el build aplica primero el parche de memoria tiki-v22-mem.patch antes del cherry-pick.

# ForkTikiLauncher — pasos desde Terminal

App de Mac (SwiftUI) para compilar juegos de Switch con forks y presets,
sin acordarte de los comandos. v9 (9 nov 2026): mejoras tiki aplicadas
al fork kid V22 antes del build, si el toggle está prendido (default ON):
fix primera nota de ocarina (commit real 8feddfe, 4 líneas en hle_hid.c)
y fix memoria/disco upstream 8d5d4f1 (devuelve 1.84 GB con F_PUNCHHOLE).
También hay botón "Aplicar mejoras tiki ahora" en Fork, y el log dice
si ya estaban o si el cherry-pick dio conflicto. Sin preset por defecto
(v7.1, Luis lo agrega afuera). v7 (9 nov 2026): preset 30 fps actualizado a
V22 (Potato mode V18 para 15 Pro, MetalFX a 0.25 en V19, shaders 1 GB menos
en V21, foliage Kokiri en V22), botón "Revisar si hay versión nueva" en
Fork, y toggle Potato mode. Aviso V22: se cierra en la primera nota de
ocarina (Impa, Zelda's Lullaby). tiki revisa cada mañana si hay versión
nueva del fork y te avisa antes de un build. v6 (8 nov 2026): preset 30 fps actualizado a
V17 (DM_FPS_HOLD=off, DM_FPS_PAYBACK=off, DM_THERMAL_CAP=0, DM_PRESENT_SNAP=1,
30 fps estable). v5 (8 nov 2026): motor S2Arm headless
(`pack/oneclick/oneclick.sh`, sin instalar S2Arm.app ni abrir su ventana),
carátula del IPA, y opción de borrar el juego (.nup / .nsp) al terminar el
build para ahorrar espacio. v4 (8 nov 2026): motor S2Arm (rápido,
genérico) además de nxnative / fork, preset "Sin preset", updates y DLC
múltiples, barra de progreso del build con paso, % y ETA, y cuadro de
Espacio que calcula el pico para cualquier juego. v3 (8 nov 2026): revisa
dependencias antes del Build (módulos Python, xcodegen, git) e instala lo
que falta, para que una Mac nueva no falle como la de Pedro el 8 nov 2026.
v2 (8 nov 2026): selector de juego (Ocarina of Time, Donkey Kong Bananza,
u otro juego manual con su Title ID), cualquier fork de GitHub (además de
`kid-with-sword-remake` y nxnative upstream), `.nup` manual o con botón, y
al cambiar de juego los valores vuelven al preset óptimo para M1 + 15 Pro
Max: 30 fps, render 0.5, MetalFX, prebuild.

> Compiló en la Mac de Luis el 8 nov 2026. El `.app` queda en DerivedData,
> en `/Users/tiki/Library/Developer/Xcode/DerivedData/ForkTikiLauncher-ghtzqyhxhnoemhcmazbbmdwwdane/Build/Products/Release/ForkTikiLauncher.app`,
> no en `build/Release/`. Después de cada `xcodebuild`, cópialo a
> `~/ForkTikiLauncher/build/Release/` (paso 2): si abres el de
> `build/Release/` sin copiar, sigues abriendo la versión vieja, sin los
> botones nuevos ni la barra. Si da error al recompilar, pega el error tal cual.

## Requisitos (los del fork, revisados el 8 nov 2026)

- Mac Apple Silicon M1 en adelante, macOS 26.6 o más, Xcode 27.2
- Python 3.12 en `/opt/homebrew/bin/python3.12` (ya lo tienes; el fork
  recomienda 3.15, con 3.12 ocupa `backports.zstd`, que ya instalaste)
- Módulos Python: `lz4`, `capstone`, `fonttools`, `backports.zstd`, `zbic`
- `xcodegen`, `git`, Homebrew
- ~80 GB libres para la carpeta del build + 3 GB (Separate) o 27 GB (Bundle)
  para el IPA. Con el `.nup` de 24 GB, el pico es ~102 GB en Separate
  y ~127 GB en Bundle. Revisa antes: `df -h ~`
- El fork sigue en **V16** (revisado el 8 nov 2026 en GitHub)
- Para instalar el IPA en el iPhone: AltStore Classic con tu Apple ID
  (mantiene el permiso de memoria aumentada; Sideloadly lo quita)

## 1. Copiar estos archivos a tu Mac

Los archivos están en esta carpeta:

```
ForkTikiLauncher/
  project.yml
  PASOS.md
  Sources/ForkTikiLauncher/App.swift
```

Cópialos a `~/ForkTikiLauncher/` con esa misma estructura.

## 2. Crear la app (todo desde Terminal, sin abrir Xcode)

```bash
brew install xcodegen
mkdir -p ~/ForkTikiLauncher/Sources/ForkTikiLauncher
cd ~/ForkTikiLauncher
# (aquí van project.yml, PASOS.md y App.swift, ya copiados)
xcodegen generate
xcodebuild -project ForkTikiLauncher.xcodeproj -scheme ForkTikiLauncher -configuration Release build
```

El `.app` sale en DerivedData. Para abrirlo y copiarlo a tu proyecto:

```bash
open "/Users/tiki/Library/Developer/Xcode/DerivedData/ForkTikiLauncher-ghtzqyhxhnoemhcmazbbmdwwdane/Build/Products/Release/"
mkdir -p ~/ForkTikiLauncher/build/Release
cp -R "/Users/tiki/Library/Developer/Xcode/DerivedData/ForkTikiLauncher-ghtzqyhxhnoemhcmazbbmdwwdane/Build/Products/Release/ForkTikiLauncher.app" ~/ForkTikiLauncher/build/Release/
open ~/ForkTikiLauncher/build/Release/ForkTikiLauncher.app
```

Siempre copia después de recompilar, o abres la versión vieja.

## 3. Usarla

0. **Motor:** arriba, 2 botones. **nxnative / fork** es el de siempre:
   Ocarina optimizado con los parches del fork (1-2 h, 42,854 shaders).
   **S2Arm (rápido, genérico)** es headless, sin instalar S2Arm.app ni
   abrir su ventana. No usa `s2armctl` (ese no sirve sin S2Arm.app, sí
   abre su ventana): corre directo el camino headless que ya trae el repo:
   ```bash
   python3 pack/jobs/applenv.py
   bash pack/oneclick/oneclick.sh "/ruta/al/juego" --target ios
   ```
   En la app: primero dale a **"Copiar motor S2Arm a la app"** (o
   "Descargar S2Arm (código)"), que clona todo el repo en
   `~/ForkTikiLauncher/engines/s2arm` (154 MB, 10,038 archivos; si ya está,
   te sale "✓ Ya lo tienes" / "Motor S2Arm actualizado en engines/s2arm").
   La primera vez en cada Mac, `applenv.py` prepara las toolchains (Xcode,
   .NET 10, Python 3.12, Rust, GNU Make 4 y la shell iOS), 30-90 min
   estimado, no medido. Después, el botón **"Compilar con S2Arm (sin
   abrir su app)"** corre ese `oneclick.sh` directo. Te da IPA + paquete
   de recursos aparte (Animal Crossing en ~8 min, TOTK en ~34 min en
   S2Arm). S2Arm no aplica el fork, no hace Bundle, y el nombre del IPA
   se mantiene original, en inglés (ej. `Animal Crossing: New Horizons.ipa`),
   no se cambia a chino: lo chino es solo la interfaz de S2Arm.
1. **Juego:** 3 botones, no menú desplegable: Ocarina of Time (Title ID
   `0400486024DEC000`), Donkey Kong Bananza (`040074A01BF12000`, verificado
   en Switchbrew), u Otro juego manual con su Title ID a mano. Al cambiar
   de juego, el preset vuelve al óptimo de 30 fps para M1 + 15 Pro Max.
   **Plataforma:** Switch 2 (`.nup`, sin prod.keys) o Switch 1
   (`.nsp`/`.nsz`, con prod.keys, botón Elegir prod.keys; sin él el build
   no arranca).
2. **Fork:** deja `kid-with-sword-remake` y dale a **Clonar / actualizar fork**.
   Se clona en `~/ForkTikiLauncher/engines/kid-with-sword-remake`. Para
   añadir cualquier otro fork: nombre + URL del repo
   (`https://github.com/usuario/mi-fork.git`) y botón **Añadir fork**.
   Si alguien crea un fork nuevo, esa persona lo sube a GitHub y luego
   se añade aquí. Para otros juegos usa **nxnative upstream**, el genérico.
3. **Preset:** 3 opciones: `M1 + 15 Pro Max · 30 fps Potato` (tu env de 30 fps,
   render 0.5, MetalFX, prebuild), `M5 / 18 Pro · 60 fps Normal`, y
   **Sin preset (default del juego)**: sin `env.txt`, el juego corre con
   sus valores por default.
4. **.nup:** elige cualquier `.nup` con el botón, o escribe la ruta a mano.
   Para Ocarina no ocupa `prod.keys`. También acepta carpeta del juego
   descomprimida (base/exefs + base/romfs).
5. **Updates y DLC (3b, si hay):** botón "Agregar update / DLC…", puedes
   elegir varios a la vez o uno por uno, y quitar el que te equivoques.
   El build pasa base + update + todos los DLC juntos.
5b. **Carátula del IPA (opcional, antes del Build):** en "Carátula del IPA
   (opcional)", dale a **"Elegir imagen…"** y elige un PNG o JPG cuadrado,
   1024×1024 ideal. Al darle Build, la app la copia como `icon.png` en la
   carpeta del build. Ojo: el script de nxnative no tiene un `--icon` que
   la ponga directo en el IPA, por eso en el log de Pedro salió "no game
   icon, the home-screen icon will be blank". La carátula queda guardada
   con el build como fuente del icono, no siempre se aplica sola.
   Esto es para el IPA del juego, no para el icono de ForkTikiLauncher:
   ese se pone en Finder, clic derecho en la app > Obtener información >
   arrastrar el PNG al iconito de arriba a la izquierda. Para que quede
   fijo en el proyecto, hay que ponerlo en Xcode como AppIcon.
6. **IPA:** Separate (IPA ~3.2 GB + romfs.img aparte) o Bundle (IPA ~27 GB
   con todo dentro). Separate es el que recomienda upstream.
   **Espacio:** el cuadro calcula el pico para cualquier juego con su
   tamaño medido: Separate ~4x el tamaño + 6 GB, Bundle ~5x + 7 GB.
   Ocarina, 24 GB, da ~102 GB en Separate y ~127 GB en Bundle, que es lo
   medido. Te dice cuánto tienes libre, cuánto consumirá y si cabe o no.
7. **Dependencias (antes del Build):** dale a **Revisar dependencias**.
   Si falta algo (módulos Python, `xcodegen`), dale a **Instalar lo que
   falta** y vuelve a revisar. El Build no arranca sin dependencias OK.
8. **Build:** corre el mismo comando que usabas en Terminal
   (`build_ipa_from_nsp.py` del fork) y te muestra el log en vivo, con
   barra de progreso: paso (ej. `Paso 3 de 6 · shader split`), % afinado
   con el conteo de shaders (ej. `6,789 / 42,854`) y la ETA del build.
   Tarda 1-2 h. Al acabar, el IPA queda en
   `~/ForkTikiLauncher/builds/<TitleID>_build`.
   Si el build falla al final, no hay que hacerlo todo de nuevo: la
   carpeta de trabajo se conserva y el siguiente build reutiliza extract,
   rewrite y shaders, y retoma desde donde se quedó.

Ojo: el comando lleva `-l es-419` fijo, que es solo el idioma por defecto,
no el recorte a es-ES + es-419 + en-US.

**Ahorrar espacio por juego:** usa Separate, no Bundle. En el Paso 4 ·
Compilar hay una opción, apagada por default: **"Borrar el juego (.nup /
.nsp) cuando termine el build, para ahorrar espacio"**. Solo se borra si
el build terminó bien y el IPA ya existe en `builds/`; si el build falla,
no se borra nada, para poder reintentarlo. A mano, cuando ya tengas el IPA
instalado en el iPhone, borra la carpeta del build (lo que más pesa) y
luego el `.nup`:
```bash
rm -rf ~/ForkTikiLauncher/builds/0400486024DEC000_build
rm "/Users/tiki/Downloads/The Legend of Zelda Ocarina of Time [0400486024dec000][v131072].nup"
```
Cambia el Title ID por el del juego que hiciste.

**No borres el `.nup` hasta tener el IPA construido e instalado.**
Y no borres el build del fork hasta probar S2Arm esta noche (8 nov 2026):
si S2Arm da 30 fps estables en tu 15 Pro Max, decides entonces cuál quedarte.

## 4. Compartirla con la otra persona

Luis solo hace la app; la otra persona hace el build del juego.

**Opción A — pasarle el `.app` ya hecho, más rápido:**

```bash
cd ~/ForkTikiLauncher/build/Release
zip -r ForkTikiLauncher.zip ForkTikiLauncher.app
```

Ese `.zip` (64K) se sube a Drive o se pasa por AirDrop / WhatsApp.
Al descomprimirlo, como no está firmado, clic derecho > Abrir, y luego
Abrir de nuevo. No hace falta pasarle tus carpetas `engines/` ni `builds/`:
la app las crea solas en su Mac.

**Opción B — pasarle el proyecto, más seguro:**

Pásale la carpeta `~/ForkTikiLauncher/` con `project.yml`, `PASOS.md` y
`Sources/`, y que corra `xcodegen generate` y el `xcodebuild` del paso 2.
Así le compila en su Mac, sin problema de firma.

Lo que necesita esa persona en su Mac: Apple Silicon, macOS 26,
Xcode 27.2, Homebrew + xcodegen, git, Python 3.12 (o cambiar el campo
Python en la app), su propio `.nup` de Ocarina (~24 GB, sin prod.keys)
y ~102 GB libres en Separate o ~127 GB en Bundle. Luis no necesita nada
de eso solo para hacer la app.

## Si te da error al compilar la app

- `xcodegen: command not found` → `brew install xcodegen` de nuevo
- Xcode no seleccionado → `sudo xcode-select -s /Applications/Xcode.app`
- `deploymentTarget 26.0` no te deja → cámbialo a `15.0` en el `project.yml`
- `Parsing project spec failed: Decoding failed at "path"` → `sources` tiene
  que ser lista con `- path: Sources/ForkTikiLauncher`, sin bloque `info`
  solo con `properties`, y con `GENERATE_INFOPLIST_FILE: YES` (ya corregido)
- Cualquier otro error → pega el error completo, tal cual sale, y revisa
  la línea exacta con `xcodebuild ... 2>&1 | grep -B2 -A5 "error:"`

## Qué sigue después de la v5

- Más juegos y más forks en la lista (ya se pueden añadir a mano)
- Guardar juegos y presets en JSON, backup de saves
- Botón de instalar con AltStore / exportar el IPA
- Windows no: es SwiftUI solo para Mac, y nxnative / el fork también son
  solo Mac con Apple Silicon y Metal. En Windows, para iPhone, la opción
  es S2Arm o NX2Apple (v1.2.0 en adelante trae `NX2Apple-windows-x64.zip`),
  pero ahí no se puede aplicar el fork `kid-with-sword-remake`.
