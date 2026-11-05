# Capa 1: Optimización de Hardware y Firmware (BIOS)

## Objetivo de la Capa
Configurar el firmware de la placa base para cumplir dos propósitos simultáneos:
1. Maximizar el rendimiento sostenido del procesador reduciendo el estrés eléctrico y térmico mediante *Undervolting* inteligente.
2. Mantener energizado el carril PCIe de la tarjeta de red cuando el equipo se encuentra apagado ($S5$), permitiendo el arranque físico por red.

---

## 1. Optimización de Rendimiento y Vida Útil (AMD PBO & Curve Optimizer)

Los procesadores modernos operan con márgenes de voltaje conservadores de fábrica. Al dejar el ajuste en modo automático o simplemente activado (*Enabled*), el procesador escala su voltaje hasta topar con el límite térmico de $95\text{ }^\circ\text{C}$, generando consumo y degradación innecesarios.

### Ruta en BIOS
`Overclocking \ Advanced CPU Configuration \ AMD Overclocking \ Precision Boost Overdrive`

### Parámetros Aplicados

| Parámetro | Valor Configurado | Justificación Técnica |
| :--- | :--- | :--- |
| **Precision Boost Overdrive** | `[Advanced]` | Habilita el control granular de límites térmicos y curvas de voltaje. |
| **PBO Limits** | `[Auto]` | Mantiene los límites eléctricos seguros de fábrica ($88\text{ W}$ PPT) sin forzar la etapa de potencia (VRM). |
| **PBO Scalar Ctrl** | `[Auto]` | Evita la inyección artificial de sobrevoltaje sostenido, protegiendo el silicio de la electromigración. |
| **Platform Thermal Throttle Limit** | `85` | Fija un techo térmico estricto de $85\text{ }^\circ\text{C}$, garantizando operación segura con refrigeración por aire. |
| **Curve Optimizer** | `[All Cores]` | Aplica el desplazamiento de frecuencia/voltaje de manera uniforme en todos los núcleos físicos. |
| **Curve Optimizer Sign** | `[Negative]` | Indica reducción de voltaje en cada punto de la curva frecuencia-voltaje. |
| **Curve Optimizer Magnitude** | `20` | Reduce entre $60\text{ mV}$ y $80\text{ mV}$ la demanda eléctrica por ciclo, disminuyendo temperaturas entre $5\text{ }^\circ\text{C}$ y $8\text{ }^\circ\text{C}$ y elevando el reloj sostenido. |

*(Nota: El ajuste `GFX Curve Optimizer` se mantiene en `[Disabled]` al utilizarse una GPU dedicada y haberse deshabilitado la gráfica integrada para liberar recursos).*

---

## 2. Configuración de Energía para Encendido Remoto (Wake-on-LAN)

Para que la tarjeta de red (NIC) pueda interceptar un *Magic Packet* con la fuente de alimentación en estado de reposo, la placa base no debe cortar el suministro de reserva ($+5\text{ VSB}$).

### Ruta en BIOS
1. **Administración de Energía:** `Settings \ Advanced \ Power Management Setup`
   * **ErP Ready:** `[Disabled]`
   * *Por qué:* El estándar europeo ErP corta la energía de los puertos Ethernet y USB al apagar el PC para reducir el consumo en reposo a menos de $1\text{ W}$. Desactivarlo es requisito obligatorio para Wake-on-LAN.
2. **Eventos de Reactivación:** `Settings \ Advanced \ Wake Up Event Setup`
   * **Resume By PCI-E Device:** `[Enabled]`
   * *Por qué:* Autoriza al controlador Ethernet integrado (conectado internamente vía bus PCI-E) a enviar la señal de arranque (`PS_ON#`) a la fuente de poder.