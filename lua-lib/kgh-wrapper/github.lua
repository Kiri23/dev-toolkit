-- github.lua (DEPRECATED - Legacy Compatibility Layer)
-- Este archivo se mantiene por compatibilidad hacia atrás
-- IMPORTANTE: Migrar a la nueva arquitectura modular

print("⚠️  ADVERTENCIA: Usando github.lua DEPRECATED")
print("📦 La nueva arquitectura modular está disponible en lua-lib/kgh-wrapper/")
print("🔄 Para migrar, ejecuta: sudo ./lua-lib/kgh-wrapper/install_kgh.sh")
print("📖 Consulta CLAUDE.md para información sobre Phase 2: Modular Architecture")
print("")
print("🏗️  Beneficios de la nueva arquitectura:")
print("   • Módulos puros reutilizables (gh.lua)")
print("   • CLI inteligente con defaults (main.lua)")
print("   • Sistema de configuración avanzado (config.lua)")
print("   • Debug system completo (kgh_debug.lua)")
print("   • Fundación para Phase 3: Programmatic Composition")
print("")

-- Check if new modular system is installed
local kgh_installed = os.execute("which kgh > /dev/null 2>&1") == 0

if kgh_installed then
    print("🚀 Redirigiendo a la nueva arquitectura modular...")
    local args = {}
    if arg then
        for i = 1, #arg do
            table.insert(args, arg[i])
        end
    end
    
    -- Build command with proper escaping
    local escaped_args = {}
    for _, arg_val in ipairs(args) do
        -- Simple escaping for shell safety
        if arg_val:match("%s") then
            table.insert(escaped_args, "'" .. arg_val:gsub("'", "'\\''") .. "'")
        else
            table.insert(escaped_args, arg_val)
        end
    end
    
    local cmd = "kgh " .. table.concat(escaped_args, " ")
    print("🔄 Ejecutando: " .. cmd)
    os.exit(os.execute(cmd))
else
    print("❌ Sistema modular no instalado.")
    print("📋 Para instalar la nueva arquitectura modular:")
    print("   1. cd lua-lib/kgh-wrapper/")
    print("   2. sudo ./install_kgh.sh")
    print("")
    print("📄 Documentación completa en CLAUDE.md")
    print("🎯 Issue de migración: https://github.com/Kiri23/dev-toolkit/issues/2")
    print("")
    print("🏗️  Arquitectura objetivo (Phase 2):")
    print("   • Layer 1: Building Blocks - Módulos puros (gh.lua)")
    print("   • Layer 2: Smart Wrappers - CLI inteligente (main.lua)")
    print("   • Preparación para Layer 3: Programmatic Composition")
    print("")
    os.exit(1)
end