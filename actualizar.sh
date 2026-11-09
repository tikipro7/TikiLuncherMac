#!/bin/sh
# Actualizar ForkTikiLauncher a la última versión de GitHub, solo.
# Uso una sola vez: bash actualizar.sh
# Después, la app v13 en adelante se actualiza sola al abrirla.
set -e
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
cd "$HOME/ForkTikiLauncher" || { echo "No existe ~/ForkTikiLauncher, clona primero el repo."; exit 1; }
command -v xcodegen >/dev/null 2>&1 || brew install xcodegen
echo "Bajando la última versión de tikipro7/TikiLuncherMac…"
curl -sL https://raw.githubusercontent.com/tikipro7/TikiLuncherMac/main/Sources/ForkTikiLauncher/App.swift -o Sources/ForkTikiLauncher/App.swift
curl -sL https://raw.githubusercontent.com/tikipro7/TikiLuncherMac/main/project.yml -o project.yml
/opt/homebrew/bin/xcodegen generate
xcodebuild -project ForkTikiLauncher.xcodeproj -scheme ForkTikiLauncher -configuration Release build
mkdir -p build/Release
cp -R "$HOME/Library/Developer/Xcode/DerivedData/ForkTikiLauncher-ghtzqyhxhnoemhcmazbbmdwwdane/Build/Products/Release/ForkTikiLauncher.app" build/Release/ForkTikiLauncher.app
echo "Listo, abriendo la app nueva…"
open build/Release/ForkTikiLauncher.app
