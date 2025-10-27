sudo tee README.md > /dev/null << 'EOF'
# 🚀 KGH - GitHub CLI Personalizado

Wrapper personalizado para GitHub CLI con configuraciones por defecto y sistema de debug.

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/tu-usuario/kgh.git

# Instalar
sudo ./install_kgh.sh

# Uso 
kgh es un wrapper para gh, por lo que todos los comandos de gh son válidos.
Lo interesante es que puedes configurar defaults para los comandos de gh.

# Configurar defaults en config.lua
# Por ejemplo:
config.pr_defaults = {
    base = "main",
    reviewer = "@tu-usuario",
    label = "enhancement",
}

# Crear PR con defaults automáticos
kgh pr create --title "Fix bug"  # Automáticamente usa --base main

# Con debug
kgh pr create --title "Fix bug" --debug

# Otros comandos pasan directamente a gh
kgh repo view