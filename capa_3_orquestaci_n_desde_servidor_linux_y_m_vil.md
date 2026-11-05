# Capa 3: Orquestación desde Servidor Linux (CasaOS) y Terminal Móvil

## Objetivo de la Capa
Centralizar el envío de comandos de encendido y apagado en un nodo servidor Linux siempre activo (accesible vía interfaz web de CasaOS o cliente SSH móvil), permitiendo operar la estación de trabajo desde cualquier lugar.

---

## 1. Instalación de Herramientas en el Servidor Linux

En la terminal del servidor Linux (Ubuntu/Debian), se instala el paquete encargado de construir y difundir las tramas UDP (Magic Packets) en la red local:

~~~bash
sudo apt update && sudo apt install -y wakeonlan openssh-client
~~~

---

## 2. Comandos Operativos de Control

### A. Encendido Remoto (Wake-on-LAN)
El servidor envía una trama de difusión (*broadcast*) al puerto UDP 9 conteniendo la dirección MAC física de la interfaz Ethernet de la estación de trabajo:

~~~bash
wakeonlan <MAC_ADDRESS_ETHERNET>
# Ejemplo de formato: wakeonlan AA:BB:CC:DD:EE:FF
~~~

### B. Apagado Remoto Seguro (OpenSSH)
El servidor establece un túnel cifrado SSH hacia la estación de trabajo y ejecuta la instrucción nativa de cierre del sistema operativo:

~~~bash
ssh <USUARIO_WINDOWS>@<HOSTNAME_O_IP> "shutdown /s /t 0"
~~~

### C. Reinicio Remoto (OpenSSH)
Para aplicar actualizaciones o reiniciar servicios a distancia:

~~~bash
ssh <USUARIO_WINDOWS>@<HOSTNAME_O_IP> "shutdown /r /t 0"
~~~

*(Nota de Seguridad: En la primera conexión, SSH aplica el protocolo TOFU —Trust On First Use— registrando la huella criptográfica `ED25519` del equipo destino en `~/.ssh/known_hosts` para prevenir ataques Man-in-the-Middle).*

---

## 3. Simplificación mediante Alias para Operación Móvil

Para facilitar la ejecución desde la terminal móvil o la consola web de CasaOS sin digitar direcciones MAC ni parámetros extensos, se configuran alias persistentes en el perfil del usuario del servidor (`~/.bashrc`):

~~~bash
# Agregar al final de ~/.bashrc
alias prender='wakeonlan <MAC_ADDRESS_ETHERNET>'
alias apagar='ssh <USUARIO_WINDOWS>@<HOSTNAME_O_IP> "shutdown /s /t 0"'
alias reiniciar='ssh <USUARIO_WINDOWS>@<HOSTNAME_O_IP> "shutdown /r /t 0"'
~~~

Recargar la configuración de la consola:
~~~bash
source ~/.bashrc
~~~