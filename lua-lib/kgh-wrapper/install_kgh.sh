#!/bin/bash
# install_kgh.sh

echo "🚀 Instalando KGH - GitHub CLI Personalizado..."

# Crear directorios necesarios
echo "📁 Creando estructura de directorios..."
mkdir -p /usr/local/bin
mkdir -p /usr/local/lib/kgh

# Copiar archivos
echo "📋 Copiando archivos..."
cp main.lua /usr/local/lib/kgh/
cp config.lua /usr/local/lib/kgh/
cp utils.lua /usr/local/lib/kgh/
cp kgh_debug.lua /usr/local/lib/kgh/
cp gh.lua /usr/local/lib/kgh/

# Crear ejecutable
echo "🔧 Creando ejecutable..."
cat > /usr/local/bin/kgh << 'EOF'
#!/bin/bash
lua /usr/local/lib/kgh/main.lua "$@"
EOF

# Dar permisos de ejecución
chmod +x /usr/local/bin/kgh

echo "✅ KGH instalado correctamente!"
echo ""
echo "🧪 Prueba con:"
echo "  kgh pr create --title 'Test PR'"
echo "  kgh --help"
