#!/bin/bash
# install_kgh.sh - Installation script for KGH modular architecture
# Installs the modular KGH system with proper dependencies and configuration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KGH_LIB_DIR="/usr/local/lib/kgh"
KGH_BIN_PATH="/usr/local/bin/kgh"
CONFIG_DIR="$HOME/.config/kgh"
LOG_DIR="$CONFIG_DIR/logs"

# Print colored messages
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_header() {
    echo -e "${BLUE}🚀 KGH - Instalación de Arquitectura Modular${NC}"
    echo -e "${BLUE}===============================================${NC}"
}

# Check if running as root for system installation
check_permissions() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Este script debe ejecutarse como root (usar sudo)"
        print_info "Uso: sudo ./install_kgh.sh"
        exit 1
    fi
}

# Check dependencies
check_dependencies() {
    print_info "Verificando dependencias..."
    
    # Check for lua
    if ! command -v lua &> /dev/null; then
        print_error "Lua no está instalado. Por favor instala Lua 5.1+ primero."
        exit 1
    fi
    
    # Check for gh CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) no está instalado. Por favor instala gh primero."
        print_info "Visita: https://cli.github.com/"
        exit 1
    fi
    
    # Check for git
    if ! command -v git &> /dev/null; then
        print_error "Git no está instalado. Por favor instala git primero."
        exit 1
    fi
    
    print_success "Todas las dependencias están disponibles"
    
    # Show versions
    print_info "Versiones detectadas:"
    echo "  • Lua: $(lua -v 2>&1 | head -n1)"
    echo "  • GitHub CLI: $(gh --version | head -n1)"
    echo "  • Git: $(git --version)"
}

# Create directories
create_directories() {
    print_info "Creando directorios del sistema..."
    
    # Create library directory
    mkdir -p "$KGH_LIB_DIR"
    print_success "Directorio de librerías creado: $KGH_LIB_DIR"
    
    # Create user directories (as the original user, not root)
    local real_user="${SUDO_USER:-$USER}"
    local real_home=$(eval echo "~$real_user")
    local user_config_dir="$real_home/.config/kgh"
    local user_log_dir="$user_config_dir/logs"
    
    sudo -u "$real_user" mkdir -p "$user_config_dir"
    sudo -u "$real_user" mkdir -p "$user_log_dir"
    print_success "Directorios de usuario creados: $user_config_dir"
}

# Install modular files
install_modules() {
    print_info "Instalando módulos de KGH..."
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copy all module files
    cp "$script_dir/gh.lua" "$KGH_LIB_DIR/"
    cp "$script_dir/main.lua" "$KGH_LIB_DIR/"
    cp "$script_dir/config.lua" "$KGH_LIB_DIR/"
    cp "$script_dir/utils.lua" "$KGH_LIB_DIR/"
    cp "$script_dir/kgh_debug.lua" "$KGH_LIB_DIR/"
    
    # Set proper permissions
    chmod 644 "$KGH_LIB_DIR"/*.lua
    chmod +x "$KGH_LIB_DIR/main.lua"
    
    print_success "Módulos instalados en $KGH_LIB_DIR"
}

# Create executable
create_executable() {
    print_info "Creando ejecutable kgh..."
    
    cat > "$KGH_BIN_PATH" << 'EOF'
#!/bin/bash
# KGH - GitHub CLI Wrapper with Modular Architecture
# This script launches the modular KGH system

# Set Lua path to include KGH modules
export LUA_PATH="/usr/local/lib/kgh/?.lua;$LUA_PATH"

# Execute the main.lua with all arguments from the KGH library directory
# but preserve the user's current working directory
exec lua /usr/local/lib/kgh/main.lua "$@"
EOF
    
    chmod +x "$KGH_BIN_PATH"
    print_success "Ejecutable creado: $KGH_BIN_PATH"
}

# Setup default configuration
setup_config() {
    print_info "Configurando archivos de configuración por defecto..."
    
    local real_user="${SUDO_USER:-$USER}"
    local real_home=$(eval echo "~$real_user")
    local config_file="$real_home/.config/kgh/config.lua"
    
    # Only create if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        sudo -u "$real_user" cat > "$config_file" << 'EOF'
-- KGH Configuration File (Modular Architecture)
-- Este archivo permite personalizar el comportamiento de kgh

return {
    -- Configuración de Pull Requests
    pr_defaults = {
        base = "main",           -- Rama base por defecto
        draft = false,           -- Crear como draft por defecto
        assignee = "@me"         -- Asignarse automáticamente
    },
    
    -- Configuración de Issues
    issue_defaults = {
        assignee = "@me"         -- Asignarse automáticamente
    },
    
    -- Configuración de Repositorios
    repo_defaults = {
        clone = true             -- Clonar automáticamente al hacer fork
    },
    
    -- Configuración de Releases
    release_defaults = {
        limit = 10               -- Número máximo de releases a mostrar
    },
    
    -- Configuración de Workflows
    workflow_defaults = {
        all = false              -- Mostrar solo workflows activos por defecto
    },
    
    -- Configuración global
    show_command = false,        -- Mostrar comando antes de ejecutar
    debug_enabled = false        -- Habilitar debug por defecto
}
EOF
        chown "$real_user:$(id -gn "$real_user")" "$config_file"
        print_success "Configuración por defecto creada: $config_file"
    else
        print_info "Configuración existente encontrada, conservando: $config_file"
    fi
}

# Setup legacy compatibility
setup_legacy_compatibility() {
    print_info "Configurando compatibilidad con versión anterior..."
    
    # Check if old github.lua exists in lua-lib/
    if [[ -f "../github.lua" ]]; then
        # Create backup
        mv "../github.lua" "../github.lua.backup"
        print_warning "github.lua anterior respaldado como github.lua.backup"
    fi
    
    # Create new github.lua with deprecation notice
    cat > "../github.lua" << 'EOF'
-- github.lua (DEPRECATED - Legacy Compatibility Layer)
-- Este archivo se mantiene por compatibilidad hacia atrás
-- IMPORTANTE: Migrar a la nueva arquitectura modular en lua-lib/kgh-wrapper/

print("⚠️  ADVERTENCIA: Usando github.lua DEPRECATED")
print("📦 La nueva arquitectura modular está disponible en lua-lib/kgh-wrapper/")
print("🔄 Para usar la nueva versión, ejecuta: sudo ./lua-lib/kgh-wrapper/install_kgh.sh")
print("📖 Consulta CLAUDE.md para más información sobre la migración")
print("")

-- Redirect to new modular system if available
local kgh_installed = os.execute("which kgh > /dev/null 2>&1") == 0

if kgh_installed then
    print("🚀 Redirigiendo a la nueva arquitectura modular...")
    local args = {}
    if arg then
        for i = 1, #arg do
            table.insert(args, arg[i])
        end
    end
    
    -- Escape arguments properly for shell safety
    local escaped_args = {}
    for _, arg_val in ipairs(args) do
        if arg_val:match("[^%w%./%-%_]") then
            table.insert(escaped_args, "'" .. arg_val:gsub("'", "'\\''") .. "'")
        else
            table.insert(escaped_args, arg_val)
        end
    end
    
    local cmd = "kgh " .. table.concat(escaped_args, " ")
    os.exit(os.execute(cmd))
else
    print("❌ Sistema modular no instalado. Ejecuta: sudo ./lua-lib/kgh-wrapper/install_kgh.sh")
    print("📄 Documentación de migración en CLAUDE.md")
    os.exit(1)
end
EOF
    
    print_success "Capa de compatibilidad configurada"
}

# Verify installation
verify_installation() {
    print_info "Verificando instalación..."
    
    # Test kgh command
    if command -v kgh &> /dev/null; then
        print_success "Comando kgh disponible en PATH"
        
        # Test basic functionality
        if kgh --help &> /dev/null; then
            print_success "Funcionalidad básica verificada"
        else
            print_warning "Comando kgh encontrado pero hay problemas de ejecución"
        fi
    else
        print_error "Comando kgh no encontrado en PATH"
        return 1
    fi
    
    # Check module files
    local missing_files=()
    for file in gh.lua main.lua config.lua utils.lua kgh_debug.lua; do
        if [[ ! -f "$KGH_LIB_DIR/$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -eq 0 ]]; then
        print_success "Todos los módulos están presentes"
    else
        print_error "Módulos faltantes: ${missing_files[*]}"
        return 1
    fi
    
    return 0
}

# Show usage instructions
show_usage() {
    print_info "Instrucciones de uso:"
    echo ""
    echo "🔧 Comandos básicos:"
    echo "  kgh --help              Mostrar ayuda completa"
    echo "  kgh --config            Mostrar configuración actual"
    echo "  kgh pr create --title 'Mi PR'  Crear pull request"
    echo "  kgh --debug pr list     Ejecutar con información de debug"
    echo ""
    echo "📁 Archivos importantes:"
    echo "  Configuración: ~/.config/kgh/config.lua"
    echo "  Logs de debug: ~/.config/kgh/logs/"
    echo "  Módulos: $KGH_LIB_DIR"
    echo ""
    echo "📖 Documentación:"
    echo "  Consulta CLAUDE.md para arquitectura y desarrollo"
    echo "  VISION.md para la evolución del proyecto"
    echo ""
}

# Uninstall function
uninstall_kgh() {
    print_info "Desinstalando KGH..."
    
    # Remove executable
    if [[ -f "$KGH_BIN_PATH" ]]; then
        rm "$KGH_BIN_PATH"
        print_success "Ejecutable removido: $KGH_BIN_PATH"
    fi
    
    # Remove library directory
    if [[ -d "$KGH_LIB_DIR" ]]; then
        rm -rf "$KGH_LIB_DIR"
        print_success "Librerías removidas: $KGH_LIB_DIR"
    fi
    
    # Keep user configuration (don't delete ~/.config/kgh)
    print_info "Configuración de usuario conservada en ~/.config/kgh"
    print_success "Desinstalación completada"
}

# Main execution
main() {
    print_header
    
    # Handle uninstall
    if [[ "$1" == "uninstall" ]]; then
        check_permissions
        uninstall_kgh
        exit 0
    fi
    
    # Normal installation
    check_permissions
    check_dependencies
    create_directories
    install_modules
    create_executable
    setup_config
    setup_legacy_compatibility
    
    if verify_installation; then
        print_success "🎉 Instalación completada exitosamente!"
        show_usage
    else
        print_error "❌ Hubo problemas durante la instalación"
        exit 1
    fi
}

# Show help
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    echo "KGH Installation Script - Modular Architecture"
    echo ""
    echo "Uso:"
    echo "  sudo ./install_kgh.sh           Instalar KGH"
    echo "  sudo ./install_kgh.sh uninstall Desinstalar KGH"
    echo "  ./install_kgh.sh --help         Mostrar esta ayuda"
    echo ""
    echo "Prerequisitos:"
    echo "  • Lua 5.1+"
    echo "  • GitHub CLI (gh)"
    echo "  • Git"
    echo ""
    exit 0
fi

# Run main function
main "$@"