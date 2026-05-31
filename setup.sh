#!/bin/bash
# ─────────────────────────────────────────────────────────────
#  Trading Platform v1 – Raspberry Pi Setup
#  Einmal ausfuehren als: bash setup.sh
# ─────────────────────────────────────────────────────────────

set -e  # Bei Fehler sofort abbrechen

INSTALL_DIR="/home/pi/trading"
SERVICE_NAME="trading-platform"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
PYTHON=$(which python3)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Trading Platform v1 – Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Verzeichnis anlegen
echo "[1/5] Installationsverzeichnis anlegen..."
mkdir -p "$INSTALL_DIR"
echo "      → $INSTALL_DIR"

# 2. Python-Abhaengigkeiten installieren
echo "[2/5] Python-Pakete installieren..."
pip3 install requests --break-system-packages -q
echo "      → requests installiert"

# 3. platform.py kopieren (falls nicht schon dort)
echo "[3/5] Plattform-Datei pruefen..."
if [ -f "./platform.py" ]; then
    cp ./platform.py "$INSTALL_DIR/platform.py"
    echo "      → platform.py kopiert nach $INSTALL_DIR"
else
    echo "      ⚠️  platform.py nicht im aktuellen Verzeichnis gefunden."
    echo "      Bitte platform.py manuell nach $INSTALL_DIR kopieren."
fi

# 4. systemd Service installieren
echo "[4/5] systemd Service einrichten..."
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Trading Platform v1 – Multi Bot
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=pi
WorkingDirectory=${INSTALL_DIR}
ExecStart=${PYTHON} ${INSTALL_DIR}/platform.py
Restart=on-failure
RestartSec=15
StandardOutput=append:${INSTALL_DIR}/platform.log
StandardError=append:${INSTALL_DIR}/platform.log
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable "$SERVICE_NAME"
echo "      → Service registriert und autostart aktiviert"

# 5. IP-Adresse ermitteln
echo "[5/5] Netzwerk-Info..."
LOCAL_IP=$(hostname -I | awk '{print $1}')
echo "      → Pi-IP im Netzwerk: $LOCAL_IP"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Setup abgeschlossen!"
echo ""
echo "  Plattform starten:    sudo systemctl start $SERVICE_NAME"
echo "  Plattform stoppen:    sudo systemctl stop $SERVICE_NAME"
echo "  Status pruefen:       sudo systemctl status $SERVICE_NAME"
echo "  Live-Log:             tail -f ${INSTALL_DIR}/platform.log"
echo ""
echo "  Dashboard erreichbar unter:"
echo "  → http://${LOCAL_IP}:5000"
echo "  → http://$(hostname).local:5000  (mDNS, falls aktiviert)"
echo ""
echo "  Vor dem Start: API-Keys in"
echo "  ${INSTALL_DIR}/platform_config.json eintragen"
echo "  (oder im Dashboard unter Settings)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
