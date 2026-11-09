import SwiftUI
import AppKit
import UniformTypeIdentifiers

// ForkTikiLauncher — v18 (9 nov 2026)
// v18: TODO mas entendible para quien la usa por primera vez.
// Tarjeta de bienvenida arriba con 3 pasos en palabras simples,
// modo principiante que esconde lo avanzado (Python, prod.keys manual,
// forks avanzados), textos cortos sin tecnicismos, y cada seccion
// con un 'Que es esto?' desplegable. Incluye el arreglo v17 de
// xcodegen en segundo plano (PATH de Homebrew).
// v17: ARREGLO xcodegen not found. El actualizador corria en segundo
// plano sin el PATH de Homebrew, y xcodegen no se encontraba, por eso
// el build se interrumpia. Ahora exporta PATH con /opt/homebrew/bin
// y usa /opt/homebrew/bin/xcodegen con ruta completa.
// v16: ARREGLO DEL BUCLE. La v15 se cerraba y abria en bucle porque el
// parseo de la version con grep -o '[0-9]*' devolvia vacio y siempre
// creia que habia version nueva. Ahora usa grep -oE 'v[0-9]+', y la
// auto-actualizacion al abrir YA NO corre sola: solo cuando le das
// al boton. Asi no se vuelve a cerrar sola en bucle.
// v15: en Fork ya salen TODOS los disponibles de GitHub, no solo 4.
// Boton "Cargar todos los forks de GitHub": consulta los forks de
// seedds/nxnative en la API de GitHub (hasta 100), los mete en la
// lista del Picker, con su nombre y estrellas, y te dice cuantos cargo.
// Tambien busca forks de kid-with-sword-remake.
// v14: la app RECONOCE tu juego sola. Al elegir el juego (o poner su
// Title ID), te dice en una tarjeta verde: hay fork para este juego,
// cual es, y que mejora se le puede aplicar al compilar. Un boton
// "Usar este fork" lo elige y lo clona solo. Si no hay fork especifico,
// te dice que si hay optimizacion universal Switch 2 aplicable.
// v13: auto-actualizacion DE VERDAD. La v10-v12 fallaba porque intentaba
// reemplazar la app mientras estaba corriendo, y macOS no deja. Ahora,
// si hay version nueva, la app escribe un actualizador aparte,
// se CIERRA sola, el actualizador baja el codigo, recompila y ABRE
// la app nueva solo. Tu no tienes que descargar, copiar ni compilar nada.
// OJO: la primera vez que pases a v13 SI tienes que hacerlo a mano una
// vez, porque la v8/v9 que tienes no trae este codigo todavia.
// v12: optimizado NO solo Ocarina. 1) Buscar forks en GitHub: escribe
// el nombre del juego y te lista forks de nxnative en el log, para
// añadir el que quieras. 2) Optimizacion universal Switch 2: aplica
// el perfil generico (tex_release 2, Potato, pso_mtl4/prebuild,
// res_scale 0.5, frame_wg off) a CUALQUIER juego Switch 2 por Title ID,
// con backup del perfil original. No es el perfil de Ocarina, es el
// generico, y avisa que tex_release 2 puede dar texturas negras.
// v11: interfaz nueva, mas bonita y mas entendible. Tarjetas por paso,
// numeros grandes 1-2-3-4, botones con icono, textos cortos en español
// claro, y los detalles tecnicos escondidos en "¿Que es esto?".
// v10: AUTO-ACTUALIZACION. Al abrir la app, sola consulta tu GitHub
// tikipro7/TikiLuncherMac; si el README dice una version mayor que v10,
// baja sola el App.swift nuevo, lo copia a Sources, recompila con
// xcodegen + xcodebuild y deja la app nueva en build/Release. Solo
// tienes que cerrar esta app y abrir la nueva. Si no hay version nueva,
// no hace nada. El boton manual hace lo mismo cuando lo tocas.
// v9: el launcher se revisa a si mismo en tu GitHub tikipro7/TikiLuncherMac:
// boton "Revisar si hay version nueva del launcher" consulta el README
// en main y el ultimo commit; si hay una v10 o mas, baja el repo nuevo.
// Tambien aplica primero el parche de memoria ya resuelto tiki-v22-mem.patch
// (8d5d4f1 resuelto a mano, candidato sin compilar) antes de intentar el
// cherry-pick, que antes chocaba siempre en hle_svc.c.
// v8: mejoras tiki aplicadas al fork kid V22 antes del build, si el
// toggle está prendido (default ON, solo para kid/Ocarina):
//  1) fix primera nota de ocarina, commit real 8feddfe (NO b1d7c70/6121fd7),
//     4 líneas en dm/host/hle_hid.c, IsOunceVibrationDeviceMounted.
//  2) memoria/disco upstream 8d5d4f1, guest files devuelven bloques
//     con F_PUNCHHOLE, 1.84 GB devueltos en Mac, ataca el cierre por
//     falta de espacio libre. Cherry-pick en la Mac, donde el build valida.
// v7.1: sin preset por defecto — Luis lo agrega afuera. El preset
// V22 sigue disponible en la lista, pero ya no se aplica solo.
// v7: preset 30 fps actualizado a V22 (Potato mode V18 para 15 Pro,
// MetalFX a 0.25 en V19, shaders 1 GB menos en V21, foliage Kokiri
// en V22). Aviso: V22 se cierra en la primera nota de ocarina.
// v6: preset 30 fps actualizado a V17 (DM_FPS_HOLD=off, DM_FPS_PAYBACK=off,
// DM_THERMAL_CAP=0, DM_PRESENT_SNAP=1, 30 fps estable).
// v5: motor S2Arm headless (pack/oneclick/oneclick.sh, sin S2Arm.app ni
// ventana), carátula del IPA (icon.png en la carpeta del build), opción
// de borrar el juego (.nup / .nsp) al terminar el build si el IPA existe.
// v4: motor S2Arm (rápido, genérico), preset "Sin preset", updates y DLC
// múltiples, barra de progreso con paso/%/ETA, cuadro de Espacio para
// cualquier juego (~4x+6 GB Separate, ~5x+7 GB Bundle), botones en vez de
// Picker para Juego y Plataforma.
// v3: revisa dependencias antes del Build (módulos Python, xcodegen, git)
// e instala lo que falta, para que una Mac nueva no falle como la de Pedro
// el 8 nov 2026 (lz4/capstone/fontTools/backports.zstd, luego xcodegen,
// luego zbic, este último después de descomprimir 24 GB).
// Ocarina of Time + Donkey Kong Bananza + otro juego manual, fork
// kid-with-sword-remake o nxnative upstream, o cualquier fork de GitHub
// que alguien añada con nombre + URL. Preset de 30 fps para M1 + 15 Pro Max.
// Compiló en la Mac de Luis el 8 nov 2026 (tras corregir project.yml:
// sources como lista, sin bloque info, GENERATE_INFOPLIST_FILE: YES).
// El .app queda en DerivedData, no en build/Release.
// No es sandbox: corre el build con Process, como lo harías en Terminal.

// MARK: - Modelos

struct Fork: Identifiable, Hashable {
    let id: String
    let name: String
    let repo: String
    let folder: String
}

struct GitHubFork: Decodable {
    let full_name: String
    let html_url: String
    let description: String?
    let stargazers_count: Int?
}

struct Preset: Identifiable, Hashable {
    let id: String
    let name: String
    let detail: String
    let env: String
}

let defaultForks: [Fork] = [
    Fork(id: "kid-with-sword",
         name: "kid-with-sword-remake (Ocarina)",
         repo: "https://github.com/cheemu21/kid-with-sword-remake.git",
         folder: "kid-with-sword-remake"),
    Fork(id: "nxnative",
         name: "nxnative upstream (otros juegos)",
         repo: "https://github.com/seedds/nxnative.git",
         folder: "nxnative"),
    Fork(id: "horizon-nx2",
         name: "horizon-nx2 (Bananza / Pokopia / Mario Kart)",
         repo: "https://github.com/joaoalvess/horizon-nx2.git",
         folder: "horizon-nx2"),
    Fork(id: "pokopia-native",
         name: "pokopia-native (Pokopia)",
         repo: "https://github.com/joaoalvess/pokopia-native.git",
         folder: "pokopia-native")
]

struct Game: Identifiable, Hashable {
    let id: String
    let name: String
    let titleId: String
}

let games: [Game] = [
    Game(id: "oot", name: "Ocarina of Time (Switch 2)", titleId: "0400486024DEC000"),
    Game(id: "dkb", name: "Donkey Kong Bananza (Switch 2)", titleId: "040074A01BF12000"),
    Game(id: "pkp", name: "Pokémon Pokopia (Switch 2)", titleId: "0400A3A01EE4C000"),
    Game(id: "other", name: "Otro juego (manual)", titleId: ""),
]

/// ¿Hay fork / mejora para este Title ID? La app lo reconoce sola.
func recommendedFork(for titleId: String) -> (forkId: String, text: String) {
    switch titleId.uppercased() {
    case "0400486024DEC000":
        return ("kid-with-sword", "✅ Hay fork para Ocarina: kid V22 + mejoras tiki. Arregla la primera nota de ocarina y devuelve 1.84 GB de memoria. Es el mejor para este juego.")
    case "040074A01BF12000":
        return ("horizon-nx2", "✅ Hay fork para Bananza: horizon-nx2. No tiene releases, solo perfil, y solo está probado el primer nivel. También se le puede aplicar la optimización universal Switch 2.")
    case "0400A3A01EE4C000":
        return ("pokopia-native", "⚠️ Hay fork para Pokopia: pokopia-native / horizon-nx2, pero el juego pide 9 GB de heap y en tu 15 Pro Max (8 GB) se cierra por memoria después de crear el personaje. No es un problema del fork.")
    default:
        return ("nxnative", "ℹ️ No hay un fork específico conocido para este juego. Sí se le puede aplicar la optimización universal Switch 2 (tex_release 2, Potato, Metal 4).")
    }
}

// Sin preset por defecto (Luis lo agrega afuera). El preset V22
// sigue en la lista por si lo quiere elegir.
// Al cambiar de juego, la app ya no vuelve a poner el de 30 fps.
func optimalPreset(for game: Game) -> Preset { presetNone }
let preset30 = Preset(
    id: "m1-30fps",
    name: "M1 + 15 Pro Max · 30 fps Potato (V22)",
    detail: "30 fps Potato V22, render 0.25, MetalFX, Potato mode ON para 15 Pro. Primer arranque tarda más por los shaders nuevos.",
    env: """
    DM_FPS_TARGET=30
    DM_RENDER_SCALE=0.25
    DM_UPSCALER=metalfx
    DM_PRESENT_UPSCALE=off
    DM_PSO_PREBUILD=1
    DM_PSO_MTL4=1
    DM_PRESENT_SNAP=1
    DM_FPS_HOLD=off
    DM_FPS_PAYBACK=off
    DM_THERMAL_CAP=0
    DM_NVN_ENC_THREAD=1
    DM_FRAME_WG=0
    DM_QOS_MAP=1
    DM_QOS_EDGES=45,59
    DM_NVN_GPUPROF=every:600
    DM_METAL_HUD=0
    DM_SHOW_FPS=0
    """
)

// El fork trae render 0.667 por default; a 60 fps solo tiene sentido
// en hardware con más RAM (M5 / 18 Pro). Sin probar en 15 Pro Max.
let preset60 = Preset(
    id: "m5-60fps",
    name: "M5 / 18 Pro · 60 fps Normal",
    detail: "60 fps, render 0.667 (default del fork). No probado en 15 Pro Max.",
    env: """
    DM_FPS_TARGET=60
    DM_RENDER_SCALE=0.667
    DM_PSO_PREBUILD=1
    DM_PSO_MTL4=1
    DM_SHOW_FPS=1
    """
)

let presetNone = Preset(
    id: "none",
    name: "Sin preset (default del juego)",
    detail: "Sin env.txt. El juego corre con sus valores por default.",
    env: ""
)

let presets: [Preset] = [preset30, preset60, presetNone]

// MARK: - App

@main
struct ForkTikiLauncherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var selectedEngine: String = "nxnative"
    @State private var selectedGame: Game = games[0]
    @State private var s2armStatus: String = ""
    @State private var iconPath: String = ""
    @State private var gamePlatform: String = "sw2"
    @State private var prodKeysPath: String = ""
    @State private var customTitleId: String = ""
    @State private var forks: [Fork] = defaultForks
    @State private var selectedFork: Fork = defaultForks[0]
    @State private var customForkName: String = ""
    @State private var customForkRepo: String = ""
    @State private var forkAddStatus: String = ""
    @State private var selectedPreset: Preset = presetNone
    @State private var potatoMode: Bool = true
    @State private var applyTikiFixes: Bool = true
    @State private var tikiFixApplied: Bool = false
    @State private var tikiFixStatus: String = ""
    @State private var forkVersion: String = "V22 + mejoras tiki (9 nov 2026)"
    @State private var forkUpdateStatus: String = ""
    @State private var appUpdateStatus: String = ""
    private let appVersion = "v18"
    private let appVersionNumber = 18
    @State private var showWelcome: Bool = true
    @State private var beginnerMode: Bool = true
    @State private var allForksStatus: String = ""
    @State private var forkRecommendation: String = recommendedFork(for: "0400486024DEC000").text
    @State private var forkSearchText: String = ""
    @State private var forkSearchStatus: String = ""
    @State private var universalOptStatus: String = ""
    @State private var universalOptOn: Bool = true

    // MARK: - Interfaz v11: tarjetas y pasos claros
    @ViewBuilder
    private func stepTitle(number: String, icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(number)
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.orange)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Label(title, systemImage: icon).font(.headline)
                Text(subtitle).font(.callout).foregroundStyle(.secondary)
            }
        }
    }

    private func card<Content: View>(_ content: Content) -> some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(14)
    }
    @State private var nupPath: String = ""
    @State private var extraPaths: [String] = []
    @State private var inputKind: String = "file"
    @State private var gameFolderPath: String = ""
    @State private var romfsMode: String = "separate"
    @State private var pythonPath: String = "/opt/homebrew/bin/python3.12"
    @State private var log: String = ""
    @State private var status: String = "Listo."
    @State private var gitStatus: String = ""
    @State private var freeGB: String = "…"
    @State private var depStatus: String = "Sin revisar en esta sesión."
    @State private var depChecked: Bool = false
    @State private var isCheckingDeps: Bool = false
    @State private var isBuilding: Bool = false
    @State private var buildProgress: Double = 0
    @State private var buildStepText: String = ""
    @State private var buildETA: String = ""

    private var home: URL { FileManager.default.homeDirectoryForCurrentUser }
    private var baseDir: URL { home.appendingPathComponent("ForkTikiLauncher") }
    private var enginesDir: URL { baseDir.appendingPathComponent("engines") }
    private var buildsDir: URL { baseDir.appendingPathComponent("builds") }
    private var presetsDir: URL { baseDir.appendingPathComponent("presets") }

    private func engineDir(_ fork: Fork) -> URL {
        enginesDir.appendingPathComponent(fork.folder)
    }

    private var currentTitleId: String {
        selectedGame.id == "other" ? customTitleId.trimmingCharacters(in: .whitespacesAndNewlines) : selectedGame.titleId
    }

    private func onGameChanged(_ game: Game) {
        // Al cambiar de juego, los valores se ponen en lo más óptimo para M1 + 15 Pro Max.
        selectedPreset = optimalPreset(for: game)
        status = "Juego: \(game.name). Preset óptimo: \(selectedPreset.name)."
        // La app reconoce el juego sola y te dice si hay fork / mejora.
        let rec = recommendedFork(for: game.titleId)
        forkRecommendation = rec.text
        if let fork = forks.first(where: { $0.id == rec.forkId }) {
            selectedFork = fork
        }
    }

    /// Botón "Usar este fork": elige el fork recomendado para el juego
    /// actual y lo clona/actualiza solo, sin que lo busques a mano.
    private func useRecommendedFork() {
        let rec = recommendedFork(for: currentTitleId)
        if let fork = forks.first(where: { $0.id == rec.forkId }) {
            selectedFork = fork
            forkRecommendation = rec.text
            cloneOrUpdateFork()
        }
    }
    private var spaceNote: String {
        romfsMode == "separate"
            ? "Separate: IPA ~3.2 GB + romfs.img aparte. Pico ~102 GB con el .nup."
            : "Bundle: IPA ~27 GB con todo dentro. Pico ~127 GB con el .nup."
    }

    private var freeGBValue: Double {
        if let values = try? home.resourceValues(forKeys: [.volumeAvailableCapacityKey]),
           let bytes = values.volumeAvailableCapacity {
            return Double(bytes) / 1_000_000_000
        }
        return 0
    }

    private var inputSizeGB: Double {
        let fm = FileManager.default
        let path = gameInputPath
        guard !path.isEmpty else { return 0 }
        var isDir: ObjCBool = false
        guard fm.fileExists(atPath: path, isDirectory: &isDir) else { return 0 }
        if !isDir.boolValue {
            let size = (try? fm.attributesOfItem(atPath: path)[.size] as? NSNumber)?.doubleValue ?? 0
            return size / 1_000_000_000
        }
        // Carpeta descomprimida: suma el tamaño de los archivos dentro.
        var total: Double = 0
        if let enumerator = fm.enumerator(atPath: path) {
            for case let file as String in enumerator {
                let full = (path as NSString).appendingPathComponent(file)
                let size = (try? fm.attributesOfItem(atPath: full)[.size] as? NSNumber)?.doubleValue ?? 0
                total += size
            }
        }
        return total / 1_000_000_000
    }

    // Pico aprox para cualquier juego, no solo Ocarina:
    // Separate ~4x el tamaño del .nup/carpeta + 6 GB, Bundle ~5x + 7 GB.
    // Ocarina (24 GB) da ~102 GB en Separate y ~127 GB en Bundle, que es lo medido.
    private var spaceNeededGB: Double {
        let nup = inputSizeGB
        guard nup > 0 else { return romfsMode == "separate" ? 102 : 127 }
        return romfsMode == "separate" ? nup * 4 + 6 : nup * 5 + 7
    }

    private var inputSizeText: String {
        if inputSizeGB > 0 {
            return String(format: "Juego: ~%.1f GB (%@)", inputSizeGB, selectedGame.name)
        }
        return "Juego: tamaño sin medir, elige el .nup o la carpeta para calcularlo"
    }

    private var romfsModeText: String { romfsMode == "separate" ? "Separate" : "Bundle" }

    private var spaceNeededText: String {
        String(format: "Este build consumirá: ~%.0f GB en pico (%@), con el .nup incluido", spaceNeededGB, romfsModeText)
    }

    private var spaceFreeText: String {
        String(format: "Tienes: %.0f GB libres en tu Mac", freeGBValue)
    }

    private var spaceResultText: String {
        if spaceFits {
            return String(format: "Te sobran ~%.0f GB después del build. Sí cabe.", freeGBValue - spaceNeededGB)
        }
        return String(format: "No cabe: te faltan ~%.0f GB. Libera espacio o usa Separate.", spaceNeededGB - freeGBValue)
    }

    private var spaceFits: Bool { freeGBValue >= spaceNeededGB }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Label("ForkTikiLauncher", systemImage: "gamecontroller.fill")
                            .font(.largeTitle.bold())
                        Text(appVersion)
                            .font(.callout.bold())
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(8)
                        Spacer()
                        Label(freeGB, systemImage: "internaldrive.fill")
                            .font(.callout).foregroundStyle(.secondary)
                    }
                    Text("🎮 Elige el motor, mete tu juego y dale a Compilar. Yo hago lo demás.")
                        .font(.title3)
                    Text("Solo 4 pasos. Lo demás es opcional, y si algo te suena raro, toca “¿Qué es esto?”.")
                        .font(.callout).foregroundStyle(.secondary)
                    HStack {
                        Button { checkAppUpdate() } label: {
                            Label("Actualizar launcher", systemImage: "arrow.down.circle.fill")
                        }
                        .buttonStyle(.bordered)
                        Text(appUpdateStatus).font(.callout).foregroundStyle(.secondary)
                    }
                    Text("Al abrir, la app sola revisa si hay una versión nueva en tu GitHub y te deja la nueva lista en build/Release.")
                        .font(.callout).foregroundStyle(.secondary)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.orange.opacity(0.12))
                .cornerRadius(16)

                if showWelcome {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("¿Primera vez aquí? Empieza aquí 👇", systemImage: "hand.wave.fill").font(.headline)
                        Text("1️⃣ Elige tu juego abajo, en el Paso 2.").font(.callout)
                        Text("2️⃣ La app te dice sola si hay una versión mejorada para ese juego.").font(.callout)
                        Text("3️⃣ Dale al botón verde COMPILAR y espera. Tarda unas 2 horas, no cierres la app.").font(.callout)
                        Text("No necesitas saber qué es un fork, un perfil o un shader. La app lo elige por ti. Si algo te suena raro, toca “¿Qué es esto?”").font(.callout).foregroundStyle(.secondary)
                        HStack {
                            Button("Entendido, empezar") { showWelcome = false }
                                .buttonStyle(.borderedProminent)
                            Toggle("Modo principiante", isOn: $beginnerMode)
                        }
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.blue.opacity(0.12))
                    .cornerRadius(14)
                }

                card(stepTitle(number: "1", icon: "cpu.fill", title: "Motor: ¿rápido o optimizado?", subtitle: "El motor es lo que convierte tu juego a iPhone o Mac."))
                HStack {
                    Button { selectedEngine = "nxnative" } label: {
                        Label("Optimizado (Ocarina)", systemImage: "star.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedEngine == "nxnative" ? .orange : .gray)
                    Button { selectedEngine = "s2arm" } label: {
                        Label("Rápido (cualquier juego)", systemImage: "bolt.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedEngine == "s2arm" ? .orange : .gray)
                }
                DisclosureGroup("¿Qué es esto?") {
                    Text("El motor es el programa que convierte tu juego de Switch a iPhone o Mac. “Optimizado” es más lento de construir pero corre mejor. “Rápido” construye en minutos pero sin arreglos especiales. Si no sabes, deja Optimizado.").font(.callout).foregroundStyle(.secondary)
                }
                if selectedEngine == "s2arm" {
                    Text("S2Arm headless, sin instalar S2Arm.app y sin abrir su ventana. Usa pack/oneclick/oneclick.sh del repo copiado en engines/s2arm. ForkTikiLauncher lo corre directo, te da IPA + paquete de recursos.")
                        .font(.callout).foregroundStyle(.secondary)
                    HStack {
                        Button("Copiar motor S2Arm a la app") { copyS2ArmEngine() }
                        Text(s2armStatus).font(.callout).foregroundStyle(.secondary)
                    }
                    HStack {
                        Button("Compilar con S2Arm (sin abrir su app)") { openS2Arm() }
                        Text(s2armStatus).font(.callout).foregroundStyle(.secondary)
                    }
                    Text("Copiar el motor clona todo el repo de S2Arm en ~/ForkTikiLauncher/engines/s2arm. El build corre headless con pack/oneclick/oneclick.sh, sin instalar S2Arm.app ni abrir su launcher.")
                        .font(.callout).foregroundStyle(.secondary)
                }

                Divider()
                stepTitle(number: "•", icon: "arrow.down.to.line", title: "Descargar motores (opcional)", subtitle: "Un clic y se descargan solos, no tienes que ir a GitHub.")
                Text("Con un botón se descarga en el momento, no tienes que ir a GitHub a mano. Se guarda en ~/ForkTikiLauncher/engines/.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    Button("Descargar kid-with-sword-remake") { downloadFromGitHub(repo: "https://github.com/cheemu21/kid-with-sword-remake.git", folder: "kid-with-sword-remake") }
                    if hasKid { Text("✓ Ya lo tienes").foregroundStyle(.green) }
                    Button("Descargar nxnative") { downloadFromGitHub(repo: "https://github.com/seedds/nxnative.git", folder: "nxnative") }
                    if hasNxnative { Text("✓ Ya lo tienes").foregroundStyle(.green) }
                }
                HStack {
                    Button("Descargar S2Arm (código)") { downloadFromGitHub(repo: "https://github.com/jhaizhou-ops/S2Arm.git", folder: "s2arm") }
                    if hasS2ArmCode { Text("✓ Ya lo tienes").foregroundStyle(.green) }
                }
                Text(downloadStatus).font(.callout).foregroundStyle(.secondary)

                Divider()
                stepTitle(number: "•", icon: "photo.fill", title: "Carátula del juego (opcional)", subtitle: "La imagen que se ve en tu iPhone cuando instalas el juego.")
                Text("Antes de cada juego, elige la imagen que quieres que lleve el IPA como icono / carátula. PNG o JPG, cuadrada, 1024×1024 ideal.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    TextField("Ruta de la imagen, ej. ~/Downloads/ocarina.png", text: $iconPath)
                        .textFieldStyle(.roundedBorder)
                    Button("Elegir imagen…") { pickIcon() }
                    if !iconPath.isEmpty {
                        Button("Quitar") { iconPath = "" }
                    }
                }
                if !iconPath.isEmpty {
                    Text("Imagen: \(URL(fileURLWithPath: iconPath).lastPathComponent)")
                        .font(.callout).foregroundStyle(.secondary)
                }

                Divider()
                stepTitle(number: "2", icon: "gamecontroller", title: "Tu juego", subtitle: "Elige el juego y mete tu archivo .nup o .nsp.")
                HStack {
                    ForEach(games) { game in
                        Button(game.name) { onGameChanged(game); selectedGame = game }
                            .buttonStyle(.bordered)
                            .tint(selectedGame.id == game.id ? .orange : nil)
                    }
                }
                if selectedGame.id == "other" {
                    TextField("Title ID manual, ej. 0400486024DEC000", text: $customTitleId)
                        .textFieldStyle(.roundedBorder)
                    Button("Reconocer este juego") {
                        forkRecommendation = recommendedFork(for: currentTitleId).text
                        if let fork = forks.first(where: { $0.id == recommendedFork(for: currentTitleId).forkId }) { selectedFork = fork }
                    }
                    .buttonStyle(.bordered)
                } else {
                    Text("\(selectedGame.name) · \(selectedGame.titleId)")
                        .font(.callout)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Label("La app reconoció tu juego", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                    Text(forkRecommendation)
                        .font(.callout)
                    HStack {
                        Button { useRecommendedFork() } label: {
                            Label("Usar este fork", systemImage: "arrow.down.to.line")
                        }
                        .buttonStyle(.borderedProminent)
                        Button { applyUniversalOptimization() } label: {
                            Label("Aplicar mejora universal", systemImage: "wand.and.stars")
                        }
                        .buttonStyle(.bordered)
                    }
                    Text("“Usar este fork” lo elige y lo descarga solo. “Aplicar mejora universal” le pone tex_release 2, Potato y Metal 4, para cualquier juego Switch 2.")
                        .font(.callout).foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.12))
                .cornerRadius(12)
                Text("Plataforma").font(.subheadline.bold())
                HStack {
                    Button("Switch 2 (.nup, sin prod.keys)") { gamePlatform = "sw2" }
                        .buttonStyle(.bordered)
                        .tint(gamePlatform == "sw2" ? .orange : nil)
                    Button("Switch 1 (.nsp/.nsz, con prod.keys)") { gamePlatform = "sw1" }
                        .buttonStyle(.bordered)
                        .tint(gamePlatform == "sw1" ? .orange : nil)
                }
                if gamePlatform == "sw1" {
                    HStack {
                        TextField("Ruta de tu prod.keys", text: $prodKeysPath)
                            .textFieldStyle(.roundedBorder)
                        Button("Elegir prod.keys…") { pickProdKeys() }
                    }
                    Text("Switch 1 sí ocupa prod.keys. Tiene que ser el tuyo, exportado de tu Switch. El build lo busca en su ruta estándar; si no está ahí, ponlo en ~/.local/share/eden/keys/prod.keys")
                        .font(.callout).foregroundStyle(.secondary)
                } else {
                    Text("Switch 2 (.nup) no ocupa prod.keys.")
                        .font(.callout).foregroundStyle(.secondary)
                }

                Divider()
                stepTitle(number: "•", icon: "tuningfork", title: "Fork: la versión optimizada", subtitle: "Solo si elegiste Optimizado. Es el motor con arreglos para Ocarina.")
                Picker("Fork", selection: $selectedFork) {
                    ForEach(forks) { fork in
                        Text(fork.name).tag(fork)
                    }
                }
                .pickerStyle(.menu)
                HStack {
                    Button("Clonar / actualizar fork") { cloneOrUpdateFork() }
                    Text(gitStatus).font(.callout).foregroundStyle(.secondary)
                }
                HStack {
                    Button { loadAllForksFromGitHub() } label: {
                        Label("Cargar todos los forks de GitHub", systemImage: "list.bullet")
                    }
                    .buttonStyle(.bordered)
                    Text(allForksStatus).font(.callout).foregroundStyle(.secondary)
                }
                Text("Esto trae TODOS los forks de nxnative que hay en GitHub, hasta 100, y los mete en esta lista. Ya no son solo 4, son todos los disponibles.")
                    .font(.callout).foregroundStyle(.secondary)
                Text("Fork: \(forkVersion). V22 trae Potato mode para 15 Pro, MetalFX a 0.25, shaders 1 GB menos y fix de foliage en Kokiri. Aviso V22: se cierra en la primera nota de ocarina.")
                    .font(.callout).foregroundStyle(.secondary)
                Toggle("Mejoras tiki (Ocarina: nota + memoria)", isOn: $applyTikiFixes)
                Text("Prendido: antes del build aplica al fork kid V22 el fix de la primera nota de ocarina (8feddfe, 4 líneas en hle_hid.c) y el fix de memoria/disco upstream 8d5d4f1 (devuelve 1.84 GB con F_PUNCHHOLE). Solo para kid/Ocarina, no toca el perfil ni el env, que los agregas tú afuera.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    Button("Aplicar mejoras tiki ahora") { applyTikiFixesToFork { _ in } }
                    Text(tikiFixStatus).font(.callout).foregroundStyle(.secondary)
                }
                HStack {
                    Button("Revisar si hay versión nueva") { checkForkUpdate() }
                    Text(forkUpdateStatus).font(.callout).foregroundStyle(.secondary)
                }
                Text("Revisar versión consulta GitHub Releases (cheemu21/kid-with-sword-remake). Si hay una V23 o más, dale a Clonar / actualizar fork y vuelve a compilar. tiki también lo revisa cada mañana y te avisa.")
                    .font(.callout).foregroundStyle(.secondary)
                Text("Se clona en ~/ForkTikiLauncher/engines/\(selectedFork.folder)")
                    .font(.callout).foregroundStyle(.secondary)
                stepTitle(number: "🔍", icon: "magnifyingglass", title: "Buscar más forks en GitHub", subtitle: "No solo Ocarina. Busca forks para Bananza, Pokopia, Mario Kart, el juego que quieras.")
                TextField("¿Qué juego? Ej. Bananza, Pokopia, Mario Kart World", text: $forkSearchText)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button { searchForks() } label: {
                        Label("Buscar forks", systemImage: "magnifyingglass")
                    }
                    .buttonStyle(.bordered)
                    Text(forkSearchStatus).font(.callout).foregroundStyle(.secondary)
                }
                Text("Te lista en el log los forks de nxnative que encuentra en GitHub. Copia la URL del que te guste y pégala abajo en “Añadir fork”.")
                    .font(.callout).foregroundStyle(.secondary)
                Text("Añadir cualquier fork").font(.subheadline.bold())
                Text("Si alguien crea un fork nuevo, lo pega aquí y queda en la lista. No solo los dos de arriba.")
                    .font(.callout).foregroundStyle(.secondary)
                TextField("Nombre del fork, ej. mi-fork-ocarina", text: $customForkName)
                    .textFieldStyle(.roundedBorder)
                TextField("URL del repo, ej. https://github.com/usuario/mi-fork.git", text: $customForkRepo)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Añadir fork") { addCustomFork() }
                    Text(forkAddStatus).font(.callout).foregroundStyle(.secondary)
                }

                Divider()
                stepTitle(number: "⚡", icon: "bolt.fill", title: "Optimización universal Switch 2", subtitle: "Para CUALQUIER juego Switch 2, no solo Ocarina. Aplica el perfil genérico: tex_release 2, Potato, Metal 4, render 0.5.")
                Toggle("Optimización universal prendida", isOn: $universalOptOn)
                Text("Esto no copia el perfil de Ocarina a otro juego. Usa el perfil genérico, con valores conservadores para tu 15 Pro Max. Si salen texturas negras, baja a tex_release 1 y res_scale 0.75.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    Button { applyUniversalOptimization() } label: {
                        Label("Aplicar optimización universal a este juego", systemImage: "wand.and.stars")
                    }
                    .buttonStyle(.borderedProminent)
                    Text(universalOptStatus).font(.callout).foregroundStyle(.secondary)
                }
                Text("Se aplica al Title ID del juego que elegiste arriba, en el motor que tienes clonado. Hace backup del perfil original como game.tsv.bak.")
                    .font(.callout).foregroundStyle(.secondary)

                Divider()
                stepTitle(number: "3", icon: "speedometer", title: "¿A cuántos fps quieres jugar?", subtitle: "30 fps es estable en tu iPhone. 60 fps se ve mejor, pero se calienta más.")
                Picker("Preset", selection: $selectedPreset) {
                    ForEach(presets) { preset in
                        Text(preset.name).tag(preset)
                    }
                }
                .pickerStyle(.menu)
                Text(selectedPreset.detail).font(.callout).foregroundStyle(.secondary)
                Toggle("Potato mode (V18+, para iPhone 15 Pro)", isOn: $potatoMode)
                Text("Potato mode ON es lo que hace que V22 corra en tu 15 Pro Max: guarda de memoria desde 4,400 MB, recycle bin 64 MB, pools en archivos. Actívalo también en el launcher del juego al arrancar. Con Potato OFF, el build juega como V17.")
                    .font(.callout).foregroundStyle(.secondary)
                Text(selectedPreset.env)
                    .font(.system(.callout, design: .monospaced))
                    .padding(8)
                    .background(Color(nsColor: .textBackgroundColor))
                    .cornerRadius(6)

                Divider()
                Text("Tu archivo del juego").font(.headline)
                Picker("Entrada", selection: $inputKind) {
                    Text("Archivo (.nup / .nsp / .nsz)").tag("file")
                    Text("Carpeta del juego descomprimida").tag("folder")
                }
                .pickerStyle(.segmented)
                if inputKind == "folder" {
                    HStack {
                        TextField("Ruta de la carpeta del juego, ej. base/exefs + base/romfs", text: $gameFolderPath)
                            .textFieldStyle(.roundedBorder)
                        Button("Elegir carpeta…") { pickGameFolder() }
                    }
                    Text("Si descomprimes el juego y te sale en carpeta, elige esa carpeta. El build la lee igual que un .nup/.nsp.")
                        .font(.callout).foregroundStyle(.secondary)
                } else {
                    HStack {
                        TextField("Ruta del .nup, manual o con el botón", text: $nupPath)
                            .textFieldStyle(.roundedBorder)
                        Button("Elegir .nup…") { pickNup() }
                    }
                }
                Text("Puedes escribir la ruta a mano o elegir cualquier .nup, no solo el de Ocarina.")
                    .font(.callout).foregroundStyle(.secondary)

                Divider()
                Text("Updates y DLC (opcional)").font(.headline)
                Text("Si tu juego tiene update o DLC, agrégalos aquí. Puedes agregar más de 1 DLC, los que tengas, se pasan todos al build.")
                    .font(.callout).foregroundStyle(.secondary)
                Button("Agregar update / DLC…") { pickExtra() }
                if extraPaths.isEmpty {
                    Text("Sin updates ni DLC por ahora.")
                        .font(.callout).foregroundStyle(.secondary)
                } else {
                    ForEach(extraPaths, id: \.self) { path in
                        HStack {
                            Text(URL(fileURLWithPath: path).lastPathComponent)
                                .font(.callout)
                            Spacer()
                            Button("Quitar") { extraPaths.removeAll { $0 == path } }
                        }
                    }
                    Text("\(extraPaths.count) archivo(s) de update / DLC.")
                        .font(.callout).foregroundStyle(.secondary)
                }

                Divider()
                stepTitle(number: "4", icon: "hammer.fill", title: "Compilar: el paso final", subtitle: "Elige dónde vas a jugar y dale al botón verde. Tarda unas 2 horas.")
                Text("¿Para qué dispositivo?").font(.callout).foregroundStyle(.secondary)
                HStack {
                    Button { targetPlatform = "ios" } label: {
                        Label("iPhone 📱", systemImage: "iphone")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(targetPlatform == "ios" ? .blue : .gray)
                    Button { targetPlatform = "mac" } label: {
                        Label("Mac 💻", systemImage: "macbook")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(targetPlatform == "mac" ? .blue : .gray)
                }
                Text(targetPlatform == "mac" ? "Mac: te da una .app para tu Mac, con el mismo fork, no un IPA." : "iPhone: te da el IPA para AltStore Classic.")
                    .font(.callout).foregroundStyle(.secondary)
                Picker("RomFS", selection: $romfsMode) {
                    Text("Separate").tag("separate")
                    Text("Bundle (todo dentro)").tag("bundle")
                }
                .pickerStyle(.segmented)
                Text(spaceNote).font(.callout).foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Espacio").font(.subheadline.bold())
                    Text(spaceFreeText)
                    Text(inputSizeText)
                    Text(spaceNeededText)
                    Text(spaceResultText)
                        .foregroundStyle(spaceFits ? .green : .red)
                }
                .font(.callout)
                .padding(8)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(6)
                if !beginnerMode {
                    HStack {
                        Text("Python:").font(.callout)
                        TextField("/opt/homebrew/bin/python3.12", text: $pythonPath)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                Text("El fork recomienda Python 3.15; con 3.12 ocupa backports.zstd (ya lo tienes).")
                    .font(.callout).foregroundStyle(.secondary)

                Divider()
                Text("Dependencias (se revisan solas antes de compilar)").font(.headline)
                Text("En una Mac nueva faltan los módulos de Python, xcodegen y zbic. Revisa antes de compilar: si falta algo, el Build se para y no lo descubres después de descomprimir 24 GB.")
                    .font(.callout).foregroundStyle(.secondary)
                HStack {
                    Button("Revisar dependencias") { checkDependencies { ok in depChecked = ok } }
                        .disabled(isCheckingDeps || isBuilding)
                    Button("Instalar lo que falta") { installDependencies() }
                        .disabled(isCheckingDeps || isBuilding)
                    Text(depStatus).font(.callout).foregroundStyle(.secondary)
                }

                Divider()
                Toggle("Borrar el juego (.nup / .nsp) cuando termine el build, para ahorrar espacio", isOn: $deleteGameAfterBuild)
                Text("Solo se borra si el build terminó bien y el IPA ya existe. Si el build falla, no se borra nada.")
                    .font(.callout).foregroundStyle(.secondary)
                Button { build() } label: {
                    Label(isBuilding ? "Compilando… no cierres la app" : "🚀 Compilar \(selectedGame.name)", systemImage: "play.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)
                .disabled(isBuilding || isCheckingDeps || gameInputPath.isEmpty)
                Text(status).font(.callout).foregroundStyle(.secondary)
                if isBuilding {
                    VStack(alignment: .leading, spacing: 4) {
                        ProgressView(value: buildProgress)
                        HStack {
                            Text(buildStepText.isEmpty ? "Compilando…" : buildStepText)
                            Spacer()
                            Text("\(Int(buildProgress * 100))%")
                            if !buildETA.isEmpty { Text("· \(buildETA)") }
                        }
                        .font(.callout).foregroundStyle(.secondary)
                    }
                }

                Text("Log del build").font(.headline)
                TextEditor(text: $log)
                    .font(.system(.callout, design: .monospaced))
                    .frame(minHeight: 220)
                    .border(Color(nsColor: .separatorColor))
                HStack {
                    Button("Copiar log") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(log, forType: .string)
                    }
                    Button("Mostrar carpeta del build") {
                        ensureDirs()
                        NSWorkspace.shared.open(buildsDir)
                    }
                    Spacer()
                    Text("El IPA sale en la carpeta del build. No borres el .nup hasta tenerlo instalado.")
                        .font(.callout).foregroundStyle(.secondary)
                }
            }
            .padding()
            .frame(minWidth: 640)
        }
        .frame(minWidth: 680, minHeight: 600)
        .onAppear { refreshDisk() }
    }

    // MARK: - Acciones

    private func ensureDirs() {
        let fm = FileManager.default
        for dir in [baseDir, enginesDir, buildsDir, presetsDir] {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }

    private func refreshDisk() {
        if let values = try? home.resourceValues(forKeys: [.volumeAvailableCapacityKey]),
           let bytes = values.volumeAvailableCapacity {
            freeGB = String(format: "%.0f GB libres", Double(bytes) / 1_000_000_000)
        } else {
            freeGB = "espacio sin dato"
        }
    }

    private var gameInputPath: String {
        inputKind == "folder" ? gameFolderPath.trimmingCharacters(in: .whitespacesAndNewlines) : nupPath.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func pickGameFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                DispatchQueue.main.async {
                    inputKind = "folder"
                    gameFolderPath = url.path
                    refreshDisk()
                }
            }
        }
    }

    private func pickExtra() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "nsp") ?? .data, UTType(filenameExtension: "nsz") ?? .data, UTType(filenameExtension: "nup") ?? .data]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK {
                for url in panel.urls where !extraPaths.contains(url.path) {
                    extraPaths.append(url.path)
                }
            }
        }
    }

    @State private var deleteGameAfterBuild: Bool = false
    @State private var targetPlatform: String = "ios"
    @State private var downloadStatus: String = ""

    private var hasNxnative: Bool { FileManager.default.fileExists(atPath: enginesDir.appendingPathComponent("nxnative/.git").path) }
    private var hasKid: Bool { FileManager.default.fileExists(atPath: enginesDir.appendingPathComponent("kid-with-sword-remake/.git").path) }
    private var hasS2ArmCode: Bool { FileManager.default.fileExists(atPath: enginesDir.appendingPathComponent("s2arm/.git").path) }

    private func downloadFromGitHub(repo: String, folder: String) {
        ensureDirs()
        let dir = enginesDir.appendingPathComponent(folder)
        downloadStatus = "Descargando \(folder) de GitHub…"
        if FileManager.default.fileExists(atPath: dir.appendingPathComponent(".git").path) {
            runCommand("/usr/bin/git", ["-C", dir.path, "pull"]) { code in
                downloadStatus = code == 0 ? "\(folder) actualizado." : "\(folder): git pull falló (código \(code))."
            }
        } else {
            runCommand("/usr/bin/git", ["clone", repo, dir.path]) { code in
                downloadStatus = code == 0 ? "\(folder) descargado en engines/\(folder)." : "\(folder): git clone falló (código \(code))."
            }
        }
    }

    private func downloadS2ArmApp() {
        downloadStatus = "Descargando S2Arm.app de GitHub Releases…"
        let dmg = home.appendingPathComponent("Downloads/S2Arm-mac-arm64.dmg").path
        runCommand("/usr/bin/curl", ["-L", "-o", dmg, "https://github.com/jhaizhou-ops/S2Arm/releases/latest/download/S2Arm-mac-arm64.dmg"]) { code in
            if code == 0 {
                downloadStatus = "S2Arm descargado en Downloads/S2Arm-mac-arm64.dmg. Ábrelo y arrastra S2Arm.app a Aplicaciones."
                NSWorkspace.shared.open(URL(fileURLWithPath: dmg))
            } else {
                downloadStatus = "Descarga de S2Arm falló (código \(code))."
            }
        }
    }

    private func pickIcon() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.png, UTType.jpeg]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                iconPath = url.path
            }
        }
    }

    private func copyS2ArmEngine() {
        ensureDirs()
        let dir = enginesDir.appendingPathComponent("s2arm")
        let gitDir = dir.appendingPathComponent(".git").path
        s2armStatus = "Copiando motor S2Arm…"
        if FileManager.default.fileExists(atPath: gitDir) {
            runCommand("/usr/bin/git", ["-C", dir.path, "pull"]) { code in
                s2armStatus = code == 0 ? "Motor S2Arm actualizado en engines/s2arm." : "git pull falló (código \(code)). Revisa el log."
            }
        } else {
            runCommand("/usr/bin/git", ["clone", "https://github.com/jhaizhou-ops/S2Arm.git", dir.path]) { code in
                s2armStatus = code == 0 ? "Motor S2Arm copiado en engines/s2arm." : "git clone falló (código \(code)). Revisa el log."
            }
        }
    }

    private func pickProdKeys() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "keys") ?? .data]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.begin { response in
            if response == .OK, let url = panel.url {
                prodKeysPath = url.path
            }
        }
    }

    private func pickNup() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            UTType(filenameExtension: "nup") ?? .data,
            UTType(filenameExtension: "nsp") ?? .data,
            UTType(filenameExtension: "nsz") ?? .data,
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.begin { response in
            if response == .OK, let url = panel.url {
                DispatchQueue.main.async {
                    inputKind = "file"
                    nupPath = url.path
                    refreshDisk()
                }
            }
        }
    }

    private func appendLog(_ text: String) {
        DispatchQueue.main.async {
            log += text
            parseProgress(text)
        }
    }

    /// Lee el log del build y saca paso, % y ETA para la barra.
    /// El build escribe [1/6] unpack, [2/6] rewrite, [3/6] shader split…
    /// y en shaders escribe "6,789 / 42,854 shaders" y "ETA 0:05".
    private func parseProgress(_ text: String) {
        // ETA que trae el propio build, ej. "ETA 0:05" o "ETA 1:16:00".
        if let etaRange = text.range(of: "ETA ") {
            let rest = text[etaRange.upperBound...]
            let eta = rest.split(separator: " ").first.map(String.init) ?? ""
            if !eta.isEmpty { buildETA = "ETA \(eta)" }
        }
        // Paso [x/6] o [x/5].
        if let open = text.firstIndex(of: "["),
           let close = text[open...].firstIndex(of: "]") {
            let inside = String(text[text.index(after: open)..<close])
            let parts = inside.split(separator: "/")
            if parts.count == 2,
               let step = Double(parts[0]), let total = Double(parts[1]), total > 0 {
                let stepName = text[close...].trimmingCharacters(in: .whitespacesAndNewlines)
                    .split(separator: " ").first.map(String.init) ?? ""
                buildStepText = "Paso \(Int(step)) de \(Int(total))" + (stepName.isEmpty ? "" : " · \(stepName)")
                var frac = (step - 1) / total
                // Dentro de shader split, el conteo "6,789 / 42,854" afina el %.
                if text.lowercased().contains("shader") {
                    let nums = text.split(whereSeparator: { !$0.isNumber && $0 != "," })
                        .compactMap { Double($0.replacingOccurrences(of: ",", with: "")) }
                    if nums.count >= 2, nums[1] > 0 {
                        frac = ((step - 1) + min(1, nums[0] / nums[1])) / total
                    }
                }
                buildProgress = min(1, max(0, frac))
            }
        }
        if text.contains("BUILD SUCCEEDED") || log.contains("✓ [6/6]") || log.contains("✓ [5/5]") {
            buildProgress = 1
            buildStepText = "Terminado"
        }
    }

    /// Corre un comando y manda cada línea al log. Llama onDone en el hilo principal.
    private func runCommand(_ launchPath: String, _ args: [String], onDone: @escaping (Int32) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        pipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let line = String(data: data, encoding: .utf8), !line.isEmpty {
                appendLog(line)
            }
        }
        process.terminationHandler = { proc in
            pipe.fileHandleForReading.readabilityHandler = nil
            DispatchQueue.main.async { onDone(proc.terminationStatus) }
        }
        do {
            try process.run()
        } catch {
            DispatchQueue.main.async {
                status = "No se pudo correr \(launchPath): \(error.localizedDescription)"
            }
            onDone(-1)
        }
    }

    private func addCustomFork() {
        let name = customForkName.trimmingCharacters(in: .whitespacesAndNewlines)
        var repo = customForkRepo.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { forkAddStatus = "Ponle un nombre al fork."; return }
        guard repo.contains("github.com/") else { forkAddStatus = "Esa URL no parece de GitHub."; return }
        if !repo.hasSuffix(".git") { repo += ".git" }
        var folder = repo.split(separator: "/").last.map(String.init) ?? name
        folder = folder.replacingOccurrences(of: ".git", with: "")
        if forks.contains(where: { $0.repo == repo }) { forkAddStatus = "Ese fork ya está en la lista."; return }
        let fork = Fork(id: UUID().uuidString, name: name, repo: repo, folder: folder)
        forks.append(fork)
        selectedFork = fork
        customForkName = ""
        customForkRepo = ""
        forkAddStatus = "Fork añadido: \(name). Dale a Clonar / actualizar fork."
    }

    /// Buscar forks en GitHub para cualquier juego, no solo Ocarina.
    /// Consulta la API de GitHub con el texto que escribiste + nxnative,
    /// y lista los repos en el log (nombre + descripción). No descarga
    /// nada solo: tú eliges y lo pegas en "Añadir fork".
    private func searchForks() {
        let q = forkSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { forkSearchStatus = "Escribe el nombre del juego primero."; return }
        forkSearchStatus = "Buscando en GitHub…"
        let encoded = q.replacingOccurrences(of: " ", with: "+")
        let script = "curl -s 'https://api.github.com/search/repositories?q=\(encoded)+nxnative&per_page=8' | grep -E '\"full_name\"|\"description\"' | head -n 32 || echo 'No se pudo buscar en GitHub'"
        appendLog("$ Buscar forks: \(q)\n")
        runCommand("/bin/sh", ["-c", script]) { code in
            forkSearchStatus = code == 0 ? "Mira el log: ahí van los forks. Copia la URL del que quieras." : "No se pudo buscar (código \(code))."
        }
    }

    /// Cargar TODOS los forks disponibles de GitHub en la lista.
    /// Baja los forks de seedds/nxnative (hasta 100) y de kid, los
    /// decodifica y los mete en el Picker, sin duplicar los que ya
    /// estaban. Si GitHub no responde, te lo dice y no borra la lista.
    private func loadAllForksFromGitHub() {
        allForksStatus = "Cargando todos los forks de GitHub…"
        let jsonURL = baseDir.appendingPathComponent("forks.json")
        let script = "curl -s 'https://api.github.com/repos/seedds/nxnative/forks?per_page=100' -o /tmp/forks1.json; curl -s 'https://api.github.com/repos/cheemu21/kid-with-sword-remake/forks?per_page=100' -o /tmp/forks2.json; /opt/homebrew/bin/python3.12 -c \"import json; a=json.load(open('/tmp/forks1.json')); b=json.load(open('/tmp/forks2.json')); json.dump(a+b, open('\(jsonURL.path)','w'))\" || echo 'No se pudo cargar GitHub'"
        appendLog("$ Cargar todos los forks de GitHub\n")
        runCommand("/bin/sh", ["-c", script]) { code in
            guard let data = try? Data(contentsOf: jsonURL),
                  let list = try? JSONDecoder().decode([GitHubFork].self, from: data) else {
                allForksStatus = "No se pudo cargar GitHub. Revisa el log e inténtalo de nuevo."
                return
            }
            var added = 0
            for item in list {
                let repo = item.html_url + ".git"
                if forks.contains(where: { $0.repo == repo }) { continue }
                let folder = item.full_name.split(separator: "/").last.map(String.init) ?? item.full_name
                let stars = item.stargazers_count ?? 0
                let name = "\(item.full_name) ★\(stars)"
                forks.append(Fork(id: UUID().uuidString, name: name, repo: repo, folder: folder))
                added += 1
            }
            allForksStatus = "Listo: \(added) forks nuevos, \(forks.count) en total en la lista."
        }
    }

    /// Optimización universal Switch 2, para cualquier juego por Title ID.
    /// Escribe el perfil genérico (no el de Ocarina) en el motor clonado:
    /// tex_release 2, Potato, pso_mtl4/prebuild, res_scale 0.5, frame_wg off.
    /// Hace backup game.tsv.bak si ya había perfil. Si el motor no está
    /// clonado, te lo dice y no hace nada.
    private func applyUniversalOptimization() {
        guard universalOptOn else { universalOptStatus = "Prende el toggle primero."; return }
        let titleId = selectedGame.id == "other" ? customTitleId : selectedGame.titleId
        guard !titleId.isEmpty else { universalOptStatus = "Elige un juego con Title ID primero."; return }
        let dir = engineDir(selectedFork)
        guard FileManager.default.fileExists(atPath: dir.appendingPathComponent(".git").path) else {
            universalOptStatus = "Primero clona el motor/fork arriba."
            return
        }
        universalOptStatus = "Aplicando optimización universal…"
        let profile = """
        # Perfil generico Switch 2 — ForkTikiLauncher v12, para \(titleId)
        # NO es el perfil de Ocarina. Valores conservadores para 15 Pro Max 8 GB.
        mem_reserve 0x320000000
        mem_alias 0x100000000
        mem_map_limit on
        mem_stack 0x10000000
        app_pool 0x240000000
        sys_resource 0x3000000
        tex_release 2
        pso_mtl4 on
        pso_prebuild on
        res_scale 0.5
        frame_wg off
        pad_layout native
        """
        let gameDir = dir.appendingPathComponent("graphics/nvn/games/\(titleId)")
        let profileURL = gameDir.appendingPathComponent("game.tsv")
        let script = """
        set -x
        mkdir -p "\(gameDir.path)"
        if [ -f "\(profileURL.path)" ]; then cp "\(profileURL.path)" "\(profileURL.path).bak"; echo "Backup: game.tsv.bak"; fi
        cat > "\(profileURL.path)" <<'EOF'
        \(profile)
        EOF
        echo "Optimización universal aplicada a \(titleId)"
        """
        appendLog("$ Optimización universal Switch 2 para \(titleId)\n")
        runCommand("/bin/sh", ["-c", script]) { code in
            universalOptStatus = code == 0 ? "Aplicada a \(titleId). Si salen texturas negras, baja a tex_release 1." : "No se pudo aplicar (código \(code)). Revisa el log."
        }
    }

    private func checkForkUpdate() {
        forkUpdateStatus = "Revisando GitHub Releases…"
        let script = "curl -s https://api.github.com/repos/cheemu21/kid-with-sword-remake/releases/latest | grep -m1 '\"tag_name\"' || echo 'No se pudo leer GitHub'"
        appendLog("$ Revisar versión del fork\n")
        runCommand("/bin/sh", ["-c", script]) { code in
            forkUpdateStatus = code == 0 ? "Revisa el log: si el tag es mayor que V22, actualiza el fork." : "No se pudo revisar (código \(code))."
        }
    }

    /// Auto-actualización DE VERDAD desde tu GitHub tikipro7/TikiLuncherMac.
    /// Lee la versión del README en main. Si no hay nada nuevo, no toca nada.
    /// Si hay una mayor, escribe un actualizador aparte en
    /// ~/ForkTikiLauncher/actualizar.sh, lo lanza en segundo plano y
    /// CIERRA esta app. El actualizador espera 3 s, baja el App.swift
    /// nuevo, corre xcodegen + xcodebuild, copia la app nueva a
    /// build/Release y LA ABRE solo. Así ya no tienes que descargar,
    /// copiar ni compilar nada a mano. Si el build falla, la app vieja
    /// sigue en build/Release y el log queda en actualizar.log.
    private func checkAppUpdate() {
        appUpdateStatus = "Revisando tu GitHub…"
        let script = """
        set -x
        cd "\(baseDir.path)"
        VER=$(curl -s https://raw.githubusercontent.com/tikipro7/TikiLuncherMac/main/README.md | grep -m1 -oE 'ForkTikiLauncher v[0-9]+' | grep -oE '[0-9]+')
        echo "Versión en GitHub: v$VER, esta app: \(appVersion)"
        if [ -z "$VER" ]; then echo "No se pudo leer GitHub, no se actualiza."; exit 0; fi
        if [ "$VER" -le \(appVersionNumber) ]; then echo "Ya estás en la última versión."; exit 0; fi
        echo "Hay versión nueva v$VER, actualizando sola, la app se va a cerrar…"
        cat > actualizar.sh <<'EOS'
        #!/bin/sh
        sleep 3
        cd "$HOME/ForkTikiLauncher" || exit 1
        exec >> actualizar.log 2>&1
        export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
        echo "Actualizando a la versión nueva…"
        curl -sL https://raw.githubusercontent.com/tikipro7/TikiLuncherMac/main/Sources/ForkTikiLauncher/App.swift -o Sources/ForkTikiLauncher/App.swift
        curl -sL https://raw.githubusercontent.com/tikipro7/TikiLuncherMac/main/project.yml -o project.yml
        /opt/homebrew/bin/xcodegen generate
        xcodebuild -project ForkTikiLauncher.xcodeproj -scheme ForkTikiLauncher -configuration Release build
        cp -R "$HOME/Library/Developer/Xcode/DerivedData/ForkTikiLauncher-ghtzqyhxhnoemhcmazbbmdwwdane/Build/Products/Release/ForkTikiLauncher.app" build/Release/ForkTikiLauncher.app
        echo "Listo, abriendo la app nueva…"
        open build/Release/ForkTikiLauncher.app
        EOS
        chmod +x actualizar.sh
        nohup ./actualizar.sh >/dev/null 2>&1 &
        echo "ACTUALIZANDO_SOLA"
        """
        appendLog("$ Auto-actualizar launcher desde tikipro7/TikiLuncherMac\n")
        runCommand("/bin/sh", ["-c", script]) { code in
            if log.contains("ACTUALIZANDO_SOLA") {
                appUpdateStatus = "Actualizando sola, la app se va a cerrar y se abre la nueva."
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    NSApplication.shared.terminate(nil)
                }
            } else {
                appUpdateStatus = code == 0 ? "Ya estás en la última versión, o no se pudo leer GitHub. Revisa el log." : "No se pudo revisar (código \(code))."
            }
        }
    }

    /// Mejoras tiki para Ocarina, solo en el fork kid V22.
    /// 1) Fix primera nota (commit real 8feddfe, NO b1d7c70/6121fd7):
    ///    4 líneas en dm/host/hle_hid.c, IsOunceVibrationDeviceMounted.
    /// 2) Memoria/disco upstream 8d5d4f1: guest files devuelven bloques
    ///    con F_PUNCHHOLE, 1.84 GB devueltos en Mac.
    /// No toca perfil ni env.txt. Si un fix ya está, lo salta.
    /// Si el cherry-pick da conflicto, lo aborta y sigue con el otro fix;
    /// el build no se para por esto, pero el log lo dice.
    private func applyTikiFixesToFork(onDone: @escaping (Bool) -> Void) {
        guard selectedFork.folder == "kid-with-sword-remake" else {
            tikiFixStatus = "Mejoras tiki solo para kid/Ocarina."
            onDone(true)
            return
        }
        let dir = engineDir(selectedFork)
        guard FileManager.default.fileExists(atPath: dir.appendingPathComponent(".git").path) else {
            tikiFixStatus = "Primero clona el fork."
            onDone(false)
            return
        }
        tikiFixStatus = "Aplicando mejoras tiki…"
        appendLog("$ Mejoras tiki: ocarina 8feddfe + memoria 8d5d4f1\n")
        // Parche de la nota, embebido, para no depender de un archivo suelto.
        let patch = """
        diff --git a/dm/host/hle_hid.c b/dm/host/hle_hid.c
        --- a/dm/host/hle_hid.c
        +++ b/dm/host/hle_hid.c
        @@ -906,6 +906,10 @@
         HLE_FORCE("_ZN2nn3hid24IsVibrationDeviceMountedERKNS0_21VibrationDeviceHandleE", "vibration: device mounted when the channel has an output", unsigned, h_hid_VibMounted, const uint32_t *h) {
             return h && vib_targets(*h);
         }
        +// The Switch 2's form of the same question (Kirby Air Riders asks soon after boot in a run with a window, main+0x10709b0; its SDK's call reads the same null service object)
        +HLE_FORCE("_ZN2nn3hid29IsOunceVibrationDeviceMountedERKNS0_21VibrationDeviceHandleE", "vibration (Switch 2): device mounted when the channel has an output", unsigned, h_hid_VibMountedOunce, const uint32_t *h) {
        +    return h && vib_targets(*h);
        +}
         HLE_FORCE("_ZN2nn3hid23GetActualVibrationValueEPNS0_14VibrationValueERKNS0_21VibrationDeviceHandleE", "vibration: last accepted channel value", void, h_hid_VibActual, dm_vibration *v, const uint32_t *h) {
             uint32_t targets = h ? vib_targets(*h) : 0;
             *v = targets ? dm_haptics_actual(__builtin_ctz(targets), *h >> 16 & 1) : (dm_vibration){0, 160, 0, 320};
        """
        let patchURL = FileManager.default.temporaryDirectory.appendingPathComponent("ocarina-note-fix.patch")
        try? patch.write(to: patchURL, atomically: true, encoding: .utf8)
        let script = """
        set -x
        cd "\(dir.path)"
        git checkout v22 2>/dev/null || git checkout 84aa8c3
        if grep -q IsOunceVibrationDeviceMounted dm/host/hle_hid.c; then
          echo "Ocarina: fix de la nota ya está."
        else
          git apply "\(patchURL.path)" && echo "Ocarina: parche de la nota aplicado." || echo "Ocarina: git apply falló, pega las 4 líneas a mano (ver NOTAS.txt)."
        fi
        grep -n IsOunceVibrationDeviceMounted dm/host/hle_hid.c || true
        if grep -q guest_file_punch dm/host/hle_svc.c; then
          echo "Memoria: fix 8d5d4f1 ya está."
        else
          curl -sL https://raw.githubusercontent.com/tikipro7/TikiLuncherMac/main/patches/tiki-v22-mem.patch -o /tmp/tiki-v22-mem.patch
          if git apply /tmp/tiki-v22-mem.patch 2>/dev/null; then
            echo "Memoria: parche tiki-v22-mem aplicado (8d5d4f1 resuelto a mano, candidato sin compilar)."
          else
            git remote add upstream https://github.com/seedds/nxnative.git 2>/dev/null || true
            git fetch upstream main --depth 50
            git cherry-pick 8d5d4f1b04610fef5a96521c72a4263d68794959 && echo "Memoria: cherry-pick 8d5d4f1 aplicado." || { git cherry-pick --abort 2>/dev/null || true; echo "Memoria: cherry-pick 8d5d4f1 con conflicto, se abortó. Prueba en V23 o aplica a mano."; }
          fi
        fi
        grep -n guest_file_punch dm/host/hle_svc.c || true
        echo "Mejoras tiki terminadas."
        """
        runCommand("/bin/sh", ["-c", script]) { code in
            self.tikiFixStatus = code == 0 ? "Mejoras tiki aplicadas (revisa el log)." : "Mejoras tiki con avisos (código \(code)). Revisa el log."
            onDone(code == 0)
        }
    }

    private func cloneOrUpdateFork() {
        ensureDirs()
        let dir = engineDir(selectedFork)
        let gitDir = dir.appendingPathComponent(".git").path
        gitStatus = "Trabajando…"
        if FileManager.default.fileExists(atPath: gitDir) {
            runCommand("/usr/bin/git", ["-C", dir.path, "pull"]) { code in
                gitStatus = code == 0 ? "Fork actualizado." : "git pull falló (código \(code)). Revisa el log."
            }
        } else {
            runCommand("/usr/bin/git", ["clone", selectedFork.repo, dir.path]) { code in
                gitStatus = code == 0 ? "Fork clonado." : "git clone falló (código \(code)). Revisa el log."
            }
        }
    }

    /// Revisa lo que el build necesita antes de descomprimir nada:
    /// módulos Python lz4.block, capstone, fontTools, backports.zstd y zbic,
    /// más xcodegen y git. Devuelve true solo si está todo.
    private func checkDependencies(onDone: @escaping (Bool) -> Void) {
        isCheckingDeps = true
        depStatus = "Revisando…"
        let script = """
        PY="\(pythonPath)"
        missing=0
        for m in lz4.block capstone fontTools backports.zstd zbic; do
          "$PY" -c "import $m" 2>/dev/null || { echo "Falta módulo Python: $m"; missing=1; }
        done
        command -v xcodegen >/dev/null 2>&1 || { echo "Falta: xcodegen (brew install xcodegen)"; missing=1; }
        command -v git >/dev/null 2>&1 || { echo "Falta: git"; missing=1; }
        if [ "$missing" = 0 ]; then echo "Dependencias OK."; else exit 1; fi
        """
        appendLog("$ Revisar dependencias\n")
        runCommand("/bin/sh", ["-c", script]) { code in
            isCheckingDeps = false
            depStatus = code == 0 ? "Dependencias OK." : "Faltan dependencias — mira el log."
            onDone(code == 0)
        }
    }

    /// Instala lo que faltó, con el mismo comando que se le dio a Pedro:
    /// pip con --break-system-packages (el pip de Homebrew bloquea el
    /// pip normal) y brew install xcodegen si no está.
    private func installDependencies() {
        isCheckingDeps = true
        depStatus = "Instalando lo que falta… tarda unos minutos."
        let script = """
        "\(pythonPath)" -m pip install --break-system-packages lz4 "capstone>=5,<6" fonttools backports.zstd zbic
        command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
        echo "Instalación terminada. Dale a Revisar dependencias para confirmar."
        """
        appendLog("$ Instalar dependencias\n")
        runCommand("/bin/sh", ["-c", script]) { code in
            isCheckingDeps = false
            depChecked = false
            depStatus = code == 0
                ? "Instalación terminada. Dale a Revisar dependencias para confirmar."
                : "La instalación terminó con error (código \(code)). Revisa el log."
        }
    }

    private func openS2Arm() {
        // S2Arm headless, sin instalar S2Arm.app y sin abrir su ventana.
        // Usa pack/oneclick/oneclick.sh del repo copiado en engines/s2arm.
        // s2armctl NO sirve sin S2Arm.app, este sí.
        let engine = enginesDir.appendingPathComponent("s2arm")
        let oneclick = engine.appendingPathComponent("pack/oneclick/oneclick.sh").path
        guard FileManager.default.fileExists(atPath: oneclick) else {
            s2armStatus = "No está el motor S2Arm copiado. Dale a 'Copiar motor S2Arm a la app' o a 'Descargar S2Arm (código)' primero."
            return
        }
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: gameInputPath, isDirectory: &isDir)
        let gameFolder = isDir.boolValue ? gameInputPath : (gameInputPath as NSString).deletingLastPathComponent
        s2armStatus = "S2Arm headless: preparando toolchains y compilando iOS…"
        appendLog("S2Arm headless: bash \(oneclick) \"\(gameFolder)\" --target ios\n")
        let applenv = engine.appendingPathComponent("pack/jobs/applenv.py").path
        runCommand(pythonPath, [applenv]) { _ in
            var args: [String] = [oneclick, gameFolder, "--target", targetPlatform == "mac" ? "mac" : "ios"]
            if !prodKeysPath.isEmpty {
                args += ["--keys", prodKeysPath]
            }
            runCommand("/bin/bash", args) { code in
                s2armStatus = code == 0
                    ? "S2Arm headless terminó. Busca el .ipa y el paquete de recursos en la carpeta de salida."
                    : "S2Arm headless falló (código \(code)). Revisa el log."
            }
        }
    }

    private func build() {
        if selectedEngine == "s2arm" {
            openS2Arm()
            return
        }
        guard FileManager.default.fileExists(atPath: gameInputPath) else {
            status = "El juego no existe en esa ruta. Escríbelo a mano o elígelo con el botón."
            return
        }
        guard !currentTitleId.isEmpty else {
            status = "Pon el Title ID del juego, para el build."
            return
        }
        if gamePlatform == "sw1" {
            guard !prodKeysPath.isEmpty, FileManager.default.fileExists(atPath: prodKeysPath) else {
                status = "Switch 1 ocupa prod.keys. Elige tu prod.keys con el botón."
                return
            }
            appendLog("prod.keys: \(prodKeysPath)\n")
        }
        // Sin dependencias revisadas no se arranca: en la Mac de Pedro el
        // build falló por módulos, luego por xcodegen y luego por zbic,
        // este último después de descomprimir 24 GB. Si falta algo, se
        // para aquí y se le dice que instale, en vez de fallar a mitad.
        if !depChecked {
            status = "Revisando dependencias antes del Build…"
            checkDependencies { ok in
                if ok {
                    depChecked = true
                    build()
                } else {
                    status = "Faltan dependencias (mira el log). Dale a Instalar lo que falta y luego Build."
                }
            }
            return
        }
        // Mejoras tiki, una vez por Build, antes de compilar: si el toggle
        // está prendido y el motor es kid, aplica ocarina + memoria y
        // luego vuelve a build() ya con tikiFixApplied en true.
        if applyTikiFixes && !tikiFixApplied {
            tikiFixApplied = true
            status = "Aplicando mejoras tiki al fork…"
            applyTikiFixesToFork { _ in self.build() }
            return
        }
        let engine = engineDir(selectedFork)
        let script = engine.appendingPathComponent("scripts/build_ipa_from_nsp.py").path
        guard FileManager.default.fileExists(atPath: script) else {
            status = "No está el script en \(engine.path). Primero clona el fork."
            return
        }
        ensureDirs()
        if potatoMode {
            appendLog("Potato mode V18+ ON: activa Potato en el launcher del juego al arrancar (render 0.25, 30 fps).\n")
        }
        let envURL = presetsDir.appendingPathComponent("\(selectedPreset.id).txt")
        var envArgs: [String] = []
        if !selectedPreset.env.isEmpty {
            do {
                try selectedPreset.env.write(to: envURL, atomically: true, encoding: .utf8)
            } catch {
                status = "No se pudo escribir el env: \(error.localizedDescription)"
                return
            }
            envArgs = ["--env-file", envURL.path]
        } else {
            appendLog("Sin preset: no se pasa --env-file, el juego usa sus valores por default.\n")
        }
        let workDir = buildsDir.appendingPathComponent("\(currentTitleId)_build").path
        isBuilding = true
        buildProgress = 0
        buildStepText = "Empezando…"
        buildETA = ""
        log = ""
        status = "Compilando \(selectedGame.name) con \(selectedFork.name)… tarda 1-2 h, no cierres la app."
        if !iconPath.isEmpty, FileManager.default.fileExists(atPath: iconPath) {
            try? FileManager.default.createDirectory(atPath: workDir, withIntermediateDirectories: true)
            let iconDest = (workDir as NSString).appendingPathComponent("icon.png")
            try? FileManager.default.removeItem(atPath: iconDest)
            try? FileManager.default.copyItem(atPath: iconPath, toPath: iconDest)
            appendLog("Imagen del IPA: \(iconPath) -> \(iconDest)\n")
        }
        appendLog("$ \(pythonPath) \(script) \(gameInputPath) \(extraPaths.joined(separator: " ")) --romfs \(romfsMode) --work-dir \(workDir) -l es-419 \(envArgs.joined(separator: " "))\n")
        var buildArgs: [String] = [script, gameInputPath] + extraPaths + ["--romfs", romfsMode,
                                "--work-dir", workDir, "-l", "es-419"] + envArgs
        if targetPlatform == "mac" {
            buildArgs += ["--platform", "mac-app"]
        }
        runCommand(pythonPath, buildArgs) { code in
            isBuilding = false
            tikiFixApplied = false
            if code == 0 {
                buildProgress = 1
                buildStepText = "Terminado"
                status = "Build terminado. El IPA está en la carpeta del build."
                if deleteGameAfterBuild {
                    let ipaPath = buildsDir.appendingPathComponent("\(selectedGame.name).ipa").path
                    // El IPA de nxnative sale como <NombreDelJuego>.ipa en builds/,
                    // o como OcarinaOfTime.ipa; solo borra si hay un IPA nuevo.
                    let ipaFiles = (try? FileManager.default.contentsOfDirectory(atPath: buildsDir.path).filter { $0.hasSuffix(".ipa") }) ?? []
                    if !ipaFiles.isEmpty {
                        try? FileManager.default.removeItem(atPath: gameInputPath)
                        status += " Juego original borrado para ahorrar espacio."
                        appendLog("Juego original borrado: \(gameInputPath)\n")
                    } else {
                        status += " No se borró el juego porque no se encontró el IPA."
                    }
                    _ = ipaPath
                }
            } else {
                status = "El build terminó con error (código \(code)). Copia el log y mándamelo."
            }
            refreshDisk()
        }
    }
}
