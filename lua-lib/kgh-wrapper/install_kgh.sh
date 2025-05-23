#!/bin/bash
# install_kgh.sh

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

# Crear directorios
echo "📁 Creando estructura de directorios..."
sudo mkdir -p /usr/local/share/kgh

# Copiar archivos (asumiendo que están en el directorio actual)
echo "📋 Copiando archivos..."
sudo cp config.lua /usr/local/share/kgh/
sudo cp utils.lua /usr/local/share/kgh/
sudo cp kgh_debug.lua /usr/local/share/kgh/
sudo cp gh.lua /usr/local/share/kgh/
sudo cp main.lua /usr/local/share/kgh/
sudo cp github.lua /usr/local/share/kgh/

# Crear ejecutable principal
echo "🔧 Creando ejecutable..."
sudo tee /usr/local/bin/kgh > /dev/null << 'EOF'
#!/usr/bin/env lua

-- Cargar el script principal desde /usr/local/share/kgh/
package.path = "/usr/local/share/kgh/?.lua;" .. package.path

-- Ejecutar la lógica principal
require("main")
EOF

# Hacer ejecutable
sudo chmod +x /usr/local/bin/kgh

echo "✅ KGH instalado correctamente!"
echo ""
echo "🧪 Prueba con:"
echo "  kgh pr create --title 'Test PR'"
echo "  kgh --help"
