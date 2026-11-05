# Unattended Workstation & Edge Node Orchestration

## Descripción Ejecutiva
Este proyecto implementa una arquitectura de **gestión remota desatendida y optimización energética** para una estación de trabajo de alto rendimiento (orientada a cargas de trabajo locales e Inteligencia Artificial), controlada desde un servidor Linux doméstico (CasaOS) y accesible desde terminales móviles.

El diseño resuelve dos desafíos críticos en infraestructuras locales modernas:
1. **Eficiencia Térmica y Longevidad del Silicio:** Optimización a nivel de firmware (BIOS) mediante subvoltaje dinámico (*Curve Optimizer*) y límites térmicos estrictos, maximizando la frecuencia sostenida por vatio.
2. **Disponibilidad Bajo Demanda (Zero-Idle Waste):** Encendido físico remoto desde estado de apagado total ($S5$) vía *Wake-on-LAN (WoL)* sobre Ethernet y apagado/reinicio seguro mediante ejecución remota en *OpenSSH Server*.

---

## Arquitectura del Sistema

~~~text
[ Terminal Móvil (Android / Cliente SSH) ]
                   │
                   ▼ (Red Local / VPN Mesh)
[ Servidor Linux Siempre Activo (CasaOS) ]
         │                         │
         │ 1. Encendido (UDP:9)    │ 2. Control y Apagado (TCP:22)
         │    Magic Packet (WoL)   │    OpenSSH Remote Execution
         ▼                         ▼
[ Estación de Trabajo (Windows 11 / AMD Zen 5) ]
  └── NIC: 2.5GbE (Estado S5 Escucha Activa)
  └── CPU: PBO Advanced + Curve Optimizer (-20)
~~~

---

## Estructura Modular del Proyecto (Por Capas)

La documentación está diseñada por capas de abstracción para facilitar su auditoría, replicación y mantenimiento:

* **[Capa 1: Optimización de Hardware y Firmware (BIOS)](./docs/01-capa-firmware-bios.md)**
  Ajuste de precisión para procesadores AMD Ryzen (arquitectura Zen 5), configuración de límites térmicos ($85\text{ }^\circ\text{C}$), reducción de voltaje en todos los núcleos y habilitación de estados de despertar por bus PCIe.
* **[Capa 2: Configuración del Nodo Destino (Windows OS)](./docs/02-capa-sistema-operativo.md)**
  Ajuste de administración de energía en interfaz de red Ethernet, transición al estado de energía $S5$ real (desactivación de hibérnación híbrida) y despliegue del servicio nativo *OpenSSH Server*.
* **[Capa 3: Orquestación desde Servidor Linux y Móvil](./docs/03-capa-orquestacion-remota.md)**
  Configuración del nodo controlador en Linux/CasaOS, despacho de tramas *Magic Packet* en capa de enlace y automatización mediante alias de consola.
* **[Capa 4: Script de Automatización Parametrizado](./scripts/power-manager.sh)**
  Script ejecutable en Bash listo para producción que centraliza el encendido, apagado, reinicio y verificación de estado (*ping check*) del nodo remoto.

---

## Tecnologías y Herramientas Utilizadas
* **Hardware & Firmware:** UEFI/BIOS MSI, AMD Precision Boost Overdrive (PBO2), Realtek 2.5GbE NIC.
* **Sistemas Operativos:** Linux (Debian/Ubuntu sobre CasaOS) y Windows 11 Pro.
* **Protocolos de Red y Seguridad:** OpenSSH (TCP/22), Wake-on-LAN Magic Packet (UDP/9), Tailscale (WireGuard Mesh VPN).
* **Metodología:** Ingeniería asistida por IA para diagnóstico de bajo nivel, depuración de protocolos de red y estandarización documental.