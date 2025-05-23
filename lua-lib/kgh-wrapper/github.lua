-- github.lua (versión corregida - dependencias ordenadas)
local config = require("config")
local utils = require("utils")
local debug = require("kgh_debug")

-- IMPORTANTE: Inyectar debug en utils DESPUÉS de cargar ambos módulos
utils.set_debug(debug)

-- Obtener argumentos de línea de comandos
local args = {}
if arg then
    for i = 1, #arg do
        table.insert(args, arg[i])
    end
end

-- Parsear argumentos (esto detectará el flag --debug)
local parsed = utils.parse_args(args)

-- Habilitar debug si se detectó el flag
if parsed.has_debug then
    debug.enable()
    debug.success("🐛 Modo debug activado")
    debug.config(config)
end

-- Si no hay argumentos válidos (excluyendo --debug), mostrar ayuda
local real_args = {}
for _, arg_val in ipairs(args) do
    if arg_val ~= "--debug" and arg_val ~= "-d" then
        table.insert(real_args, arg_val)
    end
end

if #real_args == 0 then
    print("🚀 KGH - GitHub CLI Personalizado")
    print("Uso: kgh [comando] [argumentos] [--debug]")
    print("")
    print("Ejemplos:")
    print("  kgh pr create --title 'Fix bug'")
    print("  kgh pr create --title 'Fix bug' --debug")
    print("  kgh pr list --debug")
    print("")
    print("💡 Configuraciones automáticas:")
    print("  - PRs: --base " .. config.pr_defaults.base)
    print("")
    print("🐛 Debug:")
    print("  --debug, -d    Mostrar información de debug")
    print("")
    os.exit(0)
end

-- Determinar tipo de comando
local command_type = parsed.command[1]
local subcommand = parsed.command[2]

debug.info("Tipo de comando detectado: " .. (command_type or "ninguno"))
debug.info("Subcomando detectado: " .. (subcommand or "ninguno"))

local final_command
local defaults = {}

-- Aplicar configuraciones por defecto
if command_type == "pr" then
    defaults = config.pr_defaults
    debug.info("Aplicando defaults de PR")
    final_command = utils.build_command_with_defaults(parsed.command, parsed.flags, defaults)
elseif command_type == "issue" then
    defaults = config.issue_defaults or {}
    debug.info("Aplicando defaults de Issue")
    final_command = utils.build_command_with_defaults(parsed.command, parsed.flags, defaults)
else
    debug.info("Comando genérico, pasando directamente a gh")
    final_command = utils.build_generic_command(real_args)
end

-- Mostrar comando si está habilitado en config
if config.show_command then
    utils.show_debug_command(final_command)
end

-- Ejecutar comando
local result, success = utils.execute_command(final_command)

-- Mostrar resultado
if result and result ~= "" then
    print(result)
end

-- Salir con código apropiado
if not success then
    debug.error("Comando falló")
    os.exit(1)
else
    debug.success("Comando ejecutado exitosamente")
end