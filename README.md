# Disk Usage Monitor

Script de Bash para monitorizar el porcentaje de uso del disco en Linux y generar alertas cuando se alcanza un umbral configurable. Permite enviar notificaciones a un canal de Discord mediante un webhook.

## Características

- Monitorización del uso de la partición raíz (`/`).
- Umbral de uso configurable mediante argumentos.
- Notificaciones opcionales a Discord mediante webhooks.
- Validación de argumentos y parámetros.
- Comprobación de dependencias necesarias.
- Manejo de errores durante la consulta del disco y el envío de alertas.
- Construcción segura del payload JSON mediante `jq`.

## Requisitos

- Linux.
- Bash.
- `df`, `awk`, `curl` y `jq`.
- Un webhook de Discord, si deseas recibir notificaciones.

En distribuciones basadas en Debian o Ubuntu, puedes instalar las dependencias con:

```bash
sudo apt update
sudo apt install bash coreutils gawk curl jq
```

## Instalación

Clona el repositorio:

```bash
git clone <REPOSITORY_URL>
cd <REPOSITORY_DIRECTORY>
```

Dale permisos de ejecución al script:

```bash
chmod +x monitor_disco.sh
```

## Uso

```bash
./monitor_disco.sh [-t umbral] [-w url_webhook] [-h]
```

### Argumentos

| Opción | Descripción | Valor predeterminado |
|---|---|---|
| `-t` | Umbral de uso del disco, entre 0 y 100. | `80` |
| `-w` | URL HTTPS del webhook para enviar alertas. | Sin webhook |
| `-h` | Muestra la ayuda. | — |

### Ejemplos

**Consultar el disco con el umbral predeterminado:**

```bash
./monitor_disco.sh
```

**Establecer un umbral del 90 %:**

```bash
./monitor_disco.sh -t 90
```

**Configurar un webhook de Discord:**

```bash
./monitor_disco.sh -t 80 -w "https://discord.com/api/webhooks/ID/TOKEN"
```

**Consultar la ayuda:**

```bash
./monitor_disco.sh -h
```

> **Importante:** utiliza una URL de webhook propia. No publiques tokens ni URLs de webhooks reales en el repositorio.

## Funcionamiento

1. Inicializa el umbral de uso y la URL del webhook.
2. Comprueba que estén disponibles los comandos necesarios.
3. Procesa los argumentos proporcionados por el usuario.
4. Valida el umbral y el formato de la URL, si se proporciona.
5. Consulta el uso de la partición raíz mediante `df` y procesa el resultado con `awk`.
6. Compara el porcentaje de uso con el umbral configurado.
7. Si el umbral se alcanza o supera, muestra una alerta y, si se configuró un webhook, envía una notificación a Discord.
8. Si el uso está por debajo del umbral, muestra un mensaje indicando que todo está en orden.

## Validaciones y manejo de errores

El script incorpora comprobaciones para:

- Detectar opciones desconocidas y argumentos faltantes.
- Rechazar umbrales que no sean enteros entre 0 y 100.
- Validar de forma básica el formato HTTPS del webhook.
- Verificar la disponibilidad de las dependencias.
- Comprobar que el porcentaje obtenido sea numérico.
- Detectar errores durante las solicitudes HTTP.

## Limitaciones

- Monitoriza únicamente la partición raíz (`/`).
- Se ejecuta cuando el usuario lo invoca; no realiza monitorización continua por sí solo.
- El formato HTTPS de la URL no garantiza que el webhook sea válido o accesible.
- Para recibir alertas periódicas, puede programarse mediante `cron` o un temporizador de `systemd`.

## Tecnologías

- Bash
- Linux
- Coreutils (`df`)
- `awk`
- `curl`
- `jq`
- Discord Webhooks

## Licencia

Este proyecto se distribuye bajo la licencia que se indique en el archivo `LICENSE` del repositorio.
