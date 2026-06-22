# Hula Hoop - Ticket Printer Bridge (macOS / Linux / Windows)

A lightweight WebSocket-to-TCP bridge that listens on port `9101` and forwards raw ESC/POS binary payloads to thermal ticket printers (either via TCP/IP on port `9100` or local USB using CUPS raw queue).

## 🚀 Easy macOS Installation

Run the following command in your macOS terminal. It will install Bun (if not present), download the bridge script, and register it as a persistent Launch Agent that auto-starts when the computer boots:

```bash
curl -fsSL https://raw.githubusercontent.com/Eddy-C127/hula-hoop-print-bridge/main/install.sh | bash
```

## 📋 Configuration in Hula Hoop App

In the Printer Settings screen of the POS app, enter:
- **Connection Type:** IP / Red
- **Bridge Address:** `localhost` (if using on the same Mac) or the Mac's IP (if using from an iPad/tablet).
- **IP Address:** 
  - **For Network Printers:** The IP address of the printer (e.g., `192.168.1.100`).
  - **For USB Printers:** Write `usb` (or the printer queue name from `lpstat -p`).
- **Port:** `9100` (default raw TCP port).
