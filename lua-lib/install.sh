#!/bin/bash
# install.sh - Instalar KGH

set -e

echo "🚀 Instalando KGH - GitHub CLI Personalizado..."

# Verificar que gh esté instalado
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) no está instalado."
    echo "   Instala con: brew install gh"
    exit 1
fi

# Verificar que lua esté instalado
if ! command -v lua &> /dev/null; then
    echo "❌ Error: Lua no está instalado."
    echo "   Instala con: brew install lua"
    exit 1
fi

# Obtener el directorio actual (donde están los archivos Lua)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📁 Directorio de KGH: $SCRIPT_DIR"

# Verificar que los archivos Lua existen
required_files=("github.lua" "config.lua" "utils.lua" "kgh_debug.lua")
for file in "${required_files[@]}"; do
    if [ ! -f "$SCRIPT_DIR/$file" ]; then
        echo "❌ Error: Archivo faltante: $file"
        exit 1
    fi
done

echo "✅ Todos los archivos Lua encontrados"

# Crear ejecutable principal
echo "🔧 Creando ejecutable /usr/local/bin/kgh..."
sudo tee /usr/local/bin/kgh > /dev/null << EOF
#!/usr/bin/env lua
local home = os.getenv("HOME")
package.path = home .. "/Documents/Personal projects/dev-toolkit/lua-lib/kgh-wrapper/?.lua;" .. package.path
require("github")
EOF

# Hacer ejecutable
sudo chmod +x /usr/local/bin/kgh

echo "✅ KGH instalado correctamente!"
echo ""
echo "🧪 Prueba con:"
echo "  kgh --help"
echo "  kgh pr create --title 'Test PR' --debug"
echo ""
echo "🔧 Configuración:"
echo "  Archivos Lua en: $SCRIPT_DIR"
echo "  Ejecutable en: /usr/local/bin/kgh"