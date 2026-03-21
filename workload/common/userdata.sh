#!/bin/bash
set -euxo pipefail

# ===== Config =====
APP_PORT="${APP_PORT:-8080}"     # puedes sobreescribir con templatefile o variable de entorno
APP_DIR="/opt/tfg-app"

# ===== Paquetes (opcional; si no hay Internet, no pasa nada) =====
if command -v dnf >/dev/null 2>&1; then
  dnf -y install python3 || true
elif command -v yum >/dev/null 2>&1; then
  yum -y install python3 || true
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update || true
  DEBIAN_FRONTEND=noninteractive apt-get -y install python3 || true
fi

# Asegura que existe python3
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 no disponible; abortando despliegue de la app" >&2
  exit 1
fi

# ===== App mínima =====
mkdir -p "$APP_DIR"
cat > "$APP_DIR/app.py" <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
import os, socket

PORT = int(os.getenv("APP_PORT", "8080"))

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Health check para el ALB (200 OK en cualquier ruta)
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.end_headers()
        self.wfile.write(f"OK - {socket.gethostname()}:{PORT}\n".encode())

# Desactiva logging ruidoso
    def log_message(self, format, *args): 
        return

if __name__ == "__main__":
    srv = HTTPServer(("0.0.0.0", PORT), Handler)
    srv.serve_forever()
PY

# ===== Servicio systemd =====
cat > /etc/systemd/system/tfg-app.service <<UNIT
[Unit]
Description=TFG demo HTTP app
After=network-online.target

[Service]
Type=simple
User=root
Environment=APP_PORT=${APP_PORT}
ExecStart=/usr/bin/python3 ${APP_DIR}/app.py
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

# Arrancar en boot y ahora
systemctl daemon-reload
systemctl enable --now tfg-app

echo "==> App desplegada y escuchando en puerto ${APP_PORT}"
