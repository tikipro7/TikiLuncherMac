#!/bin/sh
# Actualizar ForkTikiLauncher a la última versión de GitHub, solo.
# Uso: bash actualizar.sh
# (La app v13+ también lo hace con el botón "Actualizar launcher".)
# v48: baja a archivos temporales y valida antes de reemplazar el código,
# compila con -derivedDataPath propio (funciona en cualquier Mac, ya no
# depende del hash de DerivedData) y si algo falla restaura el código anterior.
set -e
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
cd "$HOME/ForkTikiLauncher" || { echo "No existe ~/ForkTikiLauncher, clona primero el repo."; exit 1; }
command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
API="https://api.github.com/repos/tikipro7/TikiLuncherMac/contents"
echo "Bajando la última versión de tikipro7/TikiLuncherMac…"
curl -fsSL -H "Accept: application/vnd.github.raw" "$API/Sources/ForkTikiLauncher/App.swift" -o App.swift.new || { echo "No se pudo bajar App.swift (revisa internet o el límite de la API de GitHub)."; exit 1; }
curl -fsSL -H "Accept: application/vnd.github.raw" "$API/project.yml" -o project.yml.new || { echo "No se pudo bajar project.yml."; exit 1; }
grep -q "import SwiftUI" App.swift.new || { echo "El App.swift bajado no parece Swift, no lo uso."; exit 1; }
grep -q "^name: ForkTikiLauncher" project.yml.new || { echo "El project.yml bajado no es válido, no lo uso."; exit 1; }
mkdir -p Sources/ForkTikiLauncher
cp Sources/ForkTikiLauncher/App.swift App.swift.bak 2>/dev/null || true
cp project.yml project.yml.bak 2>/dev/null || true
mv App.swift.new Sources/ForkTikiLauncher/App.swift
mv project.yml.new project.yml
restore() {
  echo "$1"
  [ -f App.swift.bak ] && cp App.swift.bak Sources/ForkTikiLauncher/App.swift
  [ -f project.yml.bak ] && cp project.yml.bak project.yml
  exit 1
}
xcodegen generate || restore "xcodegen falló, restauré el código anterior."
xcodebuild -project ForkTikiLauncher.xcodeproj -scheme ForkTikiLauncher -configuration Release -derivedDataPath build/DerivedData build || restore "xcodebuild falló, restauré el código anterior."
NEW="build/DerivedData/Build/Products/Release/ForkTikiLauncher.app"
[ -d "$NEW" ] || restore "No apareció $NEW."
mkdir -p build/Release
rm -rf build/Release/ForkTikiLauncher.app
cp -R "$NEW" build/Release/ForkTikiLauncher.app
echo "Listo, abriendo la app nueva…"
open build/Release/ForkTikiLauncher.app
