#!/bin/bash
# ==============================================================================
# Nombre:       power-manager.sh
# Descripción:  Script de orquestación para encendido (WoL), apagado y reinicio
#               remoto de estación de trabajo Windows desde servidor Linux.
# Uso:          ./power-manager.sh [prender | apagar | reiniciar | estado]
# ==============================================================================

# --- Variables de Configuración (Reemplazar con valores del entorno local) ---
TARGET_MAC="XX:XX:XX:XX:XX:XX"       # Dirección MAC de la tarjeta Ethernet
TARGET_HOST="<HOSTNAME_O_IP>"        # Hostname o IP local / Tailscale del PC
TARGET_USER="<USUARIO_WINDOWS>"      # Nombre de usuario en el nodo Windows

# --- Funciones Operativas ---
encender_nodo() {
    echo "[INFO] Enviando Magic Packet (Wake-on-LAN) a $TARGET_MAC..."
    wakeonlan "$TARGET_MAC"
    echo "[OK] Señal enviada. El equipo iniciará el arranque físico."
}

apagar_nodo() {
    echo "[INFO] Enviando orden de apagado vía SSH a $TARGET_USER@$TARGET_HOST..."
    ssh "${TARGET_USER}@${TARGET_HOST}" "shutdown /s /t 0"
    echo "[OK] Orden de apagado ejecutada."
}

reiniciar_nodo() {
    echo "[INFO] Enviando orden de reinicio vía SSH a $TARGET_USER@$TARGET_HOST..."
    ssh "${TARGET_USER}@${TARGET_HOST}" "shutdown /r /t 0"
    echo "[OK] Orden de reinicio ejecutada."
}

verificar_estado() {
    echo "[INFO] Verificando disponibilidad de red en $TARGET_HOST..."
    if ping -c 2 -W 2 "$TARGET_HOST" > /dev/null 2>&1; then
        echo "[ACTIVO] El nodo $TARGET_HOST está ENCENDIDO y responde en red."
    else
        echo "[INACTIVO] El nodo $TARGET_HOST está APAGADO o fuera de línea."
    fi
}

# --- Controlador Principal ---
case "$1" in
    prender)
        encender_nodo
        ;;
    apagar)
        apagar_nodo
        ;;
    reiniciar)
        reiniciar_nodo
        ;;
    estado)
        verificar_estado
        ;;
    *)
        echo "Uso: $0 {prender|apagar|reiniciar|estado}"
        exit 1
        ;;
esac