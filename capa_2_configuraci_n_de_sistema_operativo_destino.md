# Capa 2: Configuración del Nodo Destino (Windows)

## Objetivo de la Capa
Preparar el sistema operativo de la estación de trabajo para que:
1. No bloquee la energía de la tarjeta de red al cerrar el sistema.
2. Escuche activamente paquetes mágicos de red en su interfaz cableada.
3. Acepte órdenes seguras de administración y apagado mediante el protocolo SSH.

---

## 1. Configuración del Adaptador Ethernet (NIC)

El encendido desde apagado total ($S5$) requiere el uso de la interfaz física Ethernet (**Realtek Gaming 2.5GbE**), dado que las interfaces inalámbricas (Wi-Fi) pierden la asociación y el intercambio de llaves WPA2/WPA3 al apagarse el sistema operativo.

### Procedimiento en Administrador de Dispositivos (`devmgmt.msc`)
Dentro de **Adaptadores de red** $\rightarrow$ **Propiedades** del adaptador Ethernet:

1. **Pestaña Opciones Avanzadas:**
   * `Wake on Magic Packet`: **Enabled**
   * `Shutdown Wake-On-Lan`: **Enabled**
   * `Energy Efficient Ethernet (EEE)`: **Disabled** (opcional, previene desconexiones en reposo).
2. **Pestaña Administración de Energía:**
   * `[x]` Permitir que el equipo apague este dispositivo para ahorrar energía.
   * `[x]` Permitir que este dispositivo reactive el equipo.
   * `[x]` Permitir solo un Magic Packet para reactivar el equipo.

---

## 2. Desactivación del Inicio Rápido (Transición a Estado S5 Real)

Por defecto, Windows utiliza el *Inicio Rápido* (estado de hibernación híbrida $S4$), el cual bloquea los controladores de red al apagar e impide que la placa base responda a señales Wake-on-LAN.

### Procedimiento (`powercfg.cpl`)
1. Ir a **Opciones de energía** $\rightarrow$ **Elegir el comportamiento de los botones de inicio/apagado**.
2. Hacer clic en **Cambiar la configuración actualmente no disponible**.
3. Desmarcar la casilla **Activar inicio rápido (recomendado)** y guardar cambios.
4. **Verificación física:** Al apagar el equipo, el LED de estado del puerto RJ45 trasero debe permanecer encendido o parpadeando tenuemente.

---

## 3. Aprovisionamiento de OpenSSH Server

Para permitir el apagado y reinicio remoto seguro sin recurrir a protocolos antiguos vulnerables (como RPC/SMB expuestos), se despliega el servicio oficial **OpenSSH Server**.

### Despliegue vía PowerShell (Administrador)
~~~powershell
# 1. Instalar la capacidad nativa de servidor OpenSSH
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# 2. Iniciar el servicio inmediatamente
Start-Service sshd

# 3. Configurar el arranque automático junto con el sistema
Set-Service -Name sshd -StartupType 'Automatic'

# 4. Verificar que la regla del Firewall de Windows esté activa en el puerto 22
Get-NetFirewallRule -Name *OpenSSH-Server* | Select-Object Name, Enabled
~~~

### Obtención de Identificadores de Red (Sanitizados)
Para vincular este nodo con el servidor de orquestación, se extraen los identificadores locales:
~~~powershell
# Obtener el nombre exacto del usuario local
whoami
# Salida esperada: <HOSTNAME_PC>\<USUARIO_WINDOWS>

# Obtener la dirección física (MAC) e IPv4 de la tarjeta Ethernet
ipconfig /all
# Salida esperada:
# Dirección física: XX-XX-XX-XX-XX-XX
# Dirección IPv4:   <IP_DESTINO>
~~~