
#!/usr/bin/env bash

set -Eeuo pipefail

# 1. Configuración inicial.
UMBRAL=80
WEBHOOK_URL=""

# 2. Función de ayuda.
mostrar_ayuda() {
    echo "Uso: $0 [-t umbral] [-w url_webhook] [-h]"
    echo "  -t  Umbral de uso del disco (0-100). Por defecto: 80"
    echo "  -w  URL HTTPS del webhook (opcional)"
    echo "  -h  Mostrar esta ayuda"
}

# 3. Validar las dependencias necesarias.
for comando in df awk curl jq; do
    if ! command -v "$comando" >/dev/null 2>&1; then
        echo "Error: no se encontró el comando '$comando'." >&2
        exit 1
    fi
done

# 4. Procesar las opciones.
while getopts ":t:w:h" opcion; do
    case "$opcion" in
        t)
            UMBRAL="$OPTARG"
            ;;
        w)
            WEBHOOK_URL="$OPTARG"
            ;;
        h)
            mostrar_ayuda
            exit 0
            ;;
        :)
            echo "Error: la opción -$OPTARG requiere un argumento." >&2
            mostrar_ayuda >&2
            exit 1
            ;;
        \?)
            echo "Error: opción no válida -$OPTARG" >&2
            mostrar_ayuda >&2
            exit 1
            ;;
    esac
done

# 5. Rechazar argumentos adicionales.
shift "$((OPTIND - 1))"

if (($# > 0)); then
    echo "Error: argumento inesperado '$1'." >&2
    mostrar_ayuda >&2
    exit 1
fi

# 6. Validar el umbral.
if [[ ! "$UMBRAL" =~ ^([0-9]|[1-9][0-9]|100)$ ]]; then
    echo "Error: el umbral debe ser un entero entre 0 y 100." >&2
    exit 1
fi

# 7. Validar la URL del webhook, si se proporcionó.
if [[ -n "$WEBHOOK_URL" ]]; then
    if [[ ! "$WEBHOOK_URL" =~ ^https://[^[:space:]]+$ ]]; then
        echo "Error: el webhook debe ser una URL HTTPS válida." >&2
        exit 1
    fi
fi

# 8. Función para enviar la alerta.
enviar_alerta() {
    local mensaje="$1"
    local url="$2"
    local payload

    # Convertir el mensaje a JSON de forma segura.
    if ! payload=$(jq -n --arg content "$mensaje" \
        '{content: $content}'); then
        echo "Error: no se pudo construir el JSON." >&2
        return 1
    fi

    echo "Enviando mensaje por webhook..."

    if curl --fail --silent --show-error \
        --connect-timeout 5 \
        --max-time 15 \
        -H "Content-Type: application/json" \
        -X POST \
        --data-binary "$payload" \
        "$url"; then
        echo "Alerta enviada correctamente."
    else
        echo "Error: no se pudo enviar la alerta." >&2
        return 1
    fi
}

# 9. Obtener el uso actual del disco.
if ! USO=$(df -P / | awk 'NR == 2 {
    gsub(/%/, "", $5)
    print $5
}'); then
    echo "Error: no se pudo consultar el disco." >&2
    exit 1
fi

# Verificar que df devolvió un porcentaje numérico.
if [[ ! "$USO" =~ ^[0-9]+$ ]] ||
    (( USO < 0 || USO > 100 )); then
    echo "Error: el uso del disco obtenido no es válido." >&2
    exit 1
fi

# 10. Comparar el uso con el umbral.
if (( USO >= UMBRAL )); then
    MENSAJE="El uso del disco alcanzó el ${USO}%. (Límite: ${UMBRAL}%)"
    echo "$MENSAJE"

    if [[ -n "$WEBHOOK_URL" ]]; then
        enviar_alerta "$MENSAJE" "$WEBHOOK_URL"
    else
        echo "Aviso: no se configuró un webhook."
    fi
else
    echo "Todo en orden. Uso total: ${USO}% (Umbral: ${UMBRAL}%)"
fi
