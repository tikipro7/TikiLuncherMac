# tiki-x9-pool-peek — parche tiki: pool_peek portado de nxnative main a kid X9

**Estado: CANDIDATO SIN COMPILAR.** El parche aplica limpio contra kid X9
(`git apply --check` verificado en un clon limpio del tag `x9`), pero **no se
ha compilado**: en este entorno no hay Xcode ni Metal (solo gcc en Linux, sin
clang). La Mac de Luis debe validarlo con un build real de Ocarina. No se
promete ningún fps ni que el juego quepa en el iPhone 15 Pro Max.

## Origen (upstream, verificado)

- seedds/nxnative, commit `6f50de00d2a94f823aa36ba3e33c3be3ef6221aa`,
  2026-11-10, PR #2085, issue #2068, co-autor Pedro Nascimento.
- Mensaje: *"The pool walk's statistics no longer make or lengthen a chunk
  of a large pool for every texture they ask about"*.
- El bug: `pool_find(addr, 1)` sobre un pool grande llama a `big_lookup`,
  que crea o alarga el chunk del stride a 80 MB o más (`BIG_UNKNOWN` = 64 MB
  pasado el address). En la carga de área de Ocarina (pool de 2.432 MB,
  153 strides) eso hizo 77 chunks fuera del residency set, 6,7 GB de
  `currentAllocatedSize`; Metal pasó de 13,3 a 6,2 GB en el mismo punto en
  un M5 Pro.
- Documentado en upstream `docs/reference/memory.md`, sección *"The pool
  walk's statistics made chunks of a large pool"*.
- La cifra "1715 MiB a 0" **no** aparece en ningún archivo, commit ni release
  revisado: probablemente es una línea del censo (`mem_census()`) en una
  corrida concreta en Mac, no una cifra de release. No se usa como promesa.

## Por qué no es un cherry-pick literal

Los dos call sites de upstream **no existen en kid X9**:

1. La estadística del pool walk (`pool walk: ... in wired pools`, cada 500
   builds, `pool_find(lo, 1)`) no está en el `pool_gpu` de kid: el de kid
   es una versión distinta de esa función, sin ese bloque de estadísticas.
2. El log de edad de pools de `gml_read` (`pool_find(e[0], 1)`,
   `g_pools[p].born`) tampoco está en el `gml_read` de kid.

Pero el mecanismo sí existe en kid, y peor: el call site que sí tiene es
**por textura y por pool walk**, no cada 500 builds:

- `tex_storage_live()` (`nvn_mtl.m`, ~L9284) llama a
  `mtl_addr_mapped(t->mem, t->L.size ? t->L.size : 1)` por cada textura
  registrada sin vista, en cada `pool_entry` ← `pool_gpu`. El propio
  comentario de kid lo dice: *"every pool holding a registered texture
  stayed wired whole (Ocarina of Time: 5.3 GB of pools on top of 6.4 GB
  of textures)"*. Cada textura en un stride nuevo creaba su chunk de 80 MB+.
- `mtl_pool_holds()` (`nvn_mtl.m`, ~L1017), llamado por `keys_hash`
  (`hle_nvn.c:698`) con el largo del código del shader, también preguntaba
  por `pool_find` y creaba chunks para código en pools grandes.

## Qué cambia el parche (2 archivos, +29 −5)

### 1. `dm/gfx/nvn/nvn_mtl.m` (+24 −5)

- **Hunk 1 — núcleo, port literal de upstream `6f50de0`:** `pool_find` se
  divide en `pool_held` (la búsqueda de siempre, sin crear nada: pool
  ordinario o chunk ya existente) + `pool_find` (wrapper: `big_lookup`
  para pools grandes, `pool_held` para el resto) + **`pool_peek(addr)`**
  nuevo (el chunk del stride si lo hay, si no −1; nunca crea ni alarga).
  El `pool_find` de kid X9 era byte-idéntico al de upstream antes del fix,
  así que este hunk es un port 1:1.
- **Hunk 2 — `mtl_addr_mapped` (call site de kid):** ya no pregunta por
  `pool_find`. Un pool grande se responde por su rango
  (`addr + len <= g_big[b].hi`), como hace el `mtl_addr_known` de upstream;
  un pool ordinario se responde con `pool_held`. Es la semántica correcta
  para una pregunta de rango: `pool_peek(addr)` solo no bastaba, porque
  un rango que cruza strides sin chunk en el primero se habría contestado
  "no está mapeado" y la textura se habría contado como desaparecida.
- **Hunk 3 — `mtl_pool_holds` (keys_hash):** mismo tratamiento que
  `mtl_addr_known` de upstream: rango para pools grandes, `pool_held`
  para los demás.
- **Sin tocar, a propósito:** `mtl_addr` y `mtl_gpu_addr` siguen usando
  `pool_find`, porque ahí sí hay un uso real de la GPU y el chunk debe
  crearse. Después del parche, son los **únicos** llamadores de
  `pool_find` en producción en `nvn_mtl.m`.

### 2. `dm/gfx/tests/t_pool_chunks.m` (+5, port literal de upstream)

Los 3 checks nuevos de upstream `6f50de0`, en el mismo sitio: preguntar
dónde está un address no crea chunk (`peeked == -1`, `g_npool` sin cambio),
`pool_peek` encuentra el chunk de un stride que lo tiene, y de uno que
no lo tiene devuelve −1 sin crear nada.

### No portado (a propósito)

- Los hunks de docs de upstream (`docs/reference/memory.md`,
  `docs/agents/symptoms.md`, `dm/games/0400486024DEC000/README.md`): sus
  anclajes no existen en kid X9 (su `memory.md` tiene 491 líneas frente
  a 562 en main, sin esa sección). El contenido está resumido en esta nota.
- Los hunks de los dos call sites de upstream: no hay contexto al que
  aplicarlos en kid; sus equivalentes en kid son los hunks 2 y 3 de arriba.
- `pool_peek` queda sin llamador en producción en kid (solo el test lo
  usa); es la API de upstream, disponible para futuros call sites. Un
  `static` sin usar solo da warning, y los Makefiles del proyecto ya
  llevan `-Wno-unused-function`.

## Stat

```
 dm/gfx/nvn/nvn_mtl.m         | 24 +++++++++++++++++++-----
 dm/gfx/tests/t_pool_chunks.m |  5 +++++
 2 files changed, 24 insertions(+), 5 deletions(-)
```

- Parche: `tiki-x9-pool-peek.patch`, 66 líneas,
  SHA256 `341729ce35d829a80d7a5a8ad49d3cc906b1cc6dd6f330f16adfad00e1d345fd`
- Base: kid-with-sword-remake tag `x9` (commit
  `3461fafc75f7a1acb75b06113393b58647ac0bea`). Rama de trabajo local:
  `tiki-x9-pool-peek` sobre ese tag.

## Verificación hecha

- `git apply --check` del parche contra un clon limpio del tag `x9`: **OK**,
  y `git apply` completo: **OK**, mismo stat (24/5 en 2 archivos).
- Delta de llaves/paréntesis del parche: +2 `{` / +2 `}`, +7 `(` / +7 `)`,
  consistente con 3 funciones nuevas menos 1 (el `pool_find` viejo).
  (El conteo absoluto del archivo da desequilibrio también en el original
  sin parchear: es un artefacto del contador ingenuo con literales
  Objective-C, no del parche.)
- **No compilado:** no hay clang ni Metal en este entorno Linux. El test
  `t_pool_chunks` con los 3 checks nuevos tampoco se pudo correr aquí.

## Cómo verificar en la Mac de Luis

```bash
cd ~/ForkTikiLauncher/engines/kid-with-sword-remake
git fetch origin x9; git checkout x9
git apply --check /ruta/a/tiki-x9-pool-peek.patch   # debe salir sin errores
git apply /ruta/a/tiki-x9-pool-peek.patch
grep -n pool_peek dm/gfx/nvn/nvn_mtl.m              # debe dar la definición
```

Luego el test (en la Mac, con Xcode):

```bash
make -C dm/gfx/tests GAME=0400486024DEC000 check_t_pool_chunks
```

Y en el juego: comparar el censo de memoria (`mem_census`, línea
"GPU allocation census") en la carga de área antes y después, y el
`currentAllocatedSize` de Metal. En upstream la mejora fue de 13,3 a
6,2 GB en ese punto en M5 Pro; en kid el trigger es distinto (por
textura y por walk), así que el número en Kokiri hay que medirlo, no
restarlo de la foto de Mac a 1440p (App 9,51 GB − 1,68 GB = 7,83 GB,
todavía 1,73 GB arriba del límite de ~6,1 GB del 15 Pro Max).

## Pendiente

1. Integrar el parche en ForkTikiLauncher como mejora tiki (v45):
   aplicar `tiki-x9-pool-peek.patch` en `applyTikiFixesToFork` después del
   checkout de `x9`, con verificación por `grep pool_peek`, como ya se
   hace con el fix de la nota.
2. Compilar un build real de Ocarina con X9 + este parche en la Mac.
3. Probar en el iPhone 15 Pro Max en Kokiri: fps, si se cierra, y el
   censo de memoria del log. Solo eso dirá si, combinado con X2 (pools
   en archivos) + Potato + render 0.25, cabe por debajo de ~6,1 GB.
