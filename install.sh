#!/bin/bash

# Hula Hoop macOS Printer Bridge Installer
# Installs Bun and configures printer-bridge.js as a persistent background Launch Agent.

# Exit on error
set -e

echo "=========================================================="
echo "   HULA HOOP - INSTALADOR REMOTO DE IMPRESIÓN (macOS)     "
echo "=========================================================="

# 1. Detect or install Bun (recommended runtime, zero dependencies)
BUN_BIN=""
if command -v bun &> /dev/null; then
    BUN_BIN=$(which bun)
    echo "[✓] Bun ya está instalado en: $BUN_BIN"
elif [ -f "$HOME/.bun/bin/bun" ]; then
    BUN_BIN="$HOME/.bun/bin/bun"
    echo "[✓] Bun encontrado en: $BUN_BIN"
else
    echo "[!] Bun no está instalado. Instalándolo ahora..."
    curl -fsSL https://bun.sh/install | bash
    
    # Load Bun environment for the current script session
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
    
    if [ -f "$HOME/.bun/bin/bun" ]; then
        BUN_BIN="$HOME/.bun/bin/bun"
        echo "[✓] Bun se instaló en: $BUN_BIN"
    else
        echo "[✗] Error: No se pudo instalar Bun automáticamente."
        exit 1
    fi
fi

# 2. Create the destination directory
INSTALL_DIR="$HOME/.hulahoop-print-bridge"
mkdir -p "$INSTALL_DIR"
echo "[i] Directorio de instalación: $INSTALL_DIR"

# 3. Download the printer-bridge.js script
BRIDGE_URL="https://raw.githubusercontent.com/Eddy-C127/hula-hoop-print-bridge/main/printer-bridge.js"
echo "[i] Descargando bridge de: $BRIDGE_URL"
curl -fsSL "$BRIDGE_URL" -o "$INSTALL_DIR/printer-bridge.js"

# 4. Create the LaunchAgent plist file
PLIST_LABEL="com.hulahoop.printbridge"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"
echo "[i] Generando Launch Agent en: $PLIST_PATH"

mkdir -p "$HOME/Library/LaunchAgents"

cat <<EOF > "$PLIST_PATH"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BUN_BIN</string>
        <string>run</string>
        <string>$INSTALL_DIR/printer-bridge.js</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>WorkingDirectory</key>
    <string>$INSTALL_DIR</string>
    <key>StandardOutPath</key>
    <string>/tmp/hulahoop-printbridge.out.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/hulahoop-printbridge.err.log</string>
</dict>
</plist>
EOF

# Set standard permissions for macOS Plist
chmod 644 "$PLIST_PATH"

# 5. Stop and unload old service if it exists
echo "[i] Deteniendo servicio previo si existía..."
launchctl bootout gui/$(id -u) "$PLIST_PATH" 2>/dev/null || launchctl unload "$PLIST_PATH" 2>/dev/null || true

# 6. Load and bootstrap the new service
echo "[i] Registrando e iniciando puente de impresión en segundo plano..."
launchctl bootstrap gui/$(id -u) "$PLIST_PATH" 2>/dev/null || launchctl load "$PLIST_PATH"

echo "=========================================================="
echo "   [✓] ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!              "
echo "=========================================================="
echo " • El puente de impresión ya está corriendo en segundo plano."
echo " • Se iniciará automáticamente cada vez que enciendas la Mac."
echo " • Logs de salida: tail -f /tmp/hulahoop-printbridge.out.log"
echo " • Logs de errores: tail -f /tmp/hulahoop-printbridge.err.log"
echo "=========================================================="
