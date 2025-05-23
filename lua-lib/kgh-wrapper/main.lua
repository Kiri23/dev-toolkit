-- main.lua - Nuevo punto de entrada (Orquestador)
-- Manejo de argumentos CLI, orchestración de módulos, sistema de debug

local config = require("config")
local utils = require("utils")
local debug = require("kgh_debug")
local gh = require("gh")

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

-- Registry de comandos
local command_handlers = {
    ["pr.create"] = function(options)
        debug.info("Usando módulo gh para crear PR")
        return gh.createPr(options)
    end,
    ["pr.list"] = function(options)
        debug.info("Usando módulo gh para listar PRs")
        return gh.listPrs(options)
    end,
    ["issue.create"] = function(options)
        debug.info("Usando módulo gh para crear Issue")
        return gh.createIssue(options)
    end,
    ["issue.list"] = function(options)
        debug.info("Usando módulo gh para listar Issues")
        return gh.listIssues(options)
    end
}

-- Determinar tipo de comando
local command_type = parsed.command[1]
local subcommand = parsed.command[2]

debug.info("Tipo de comando detectado: " .. (command_type or "ninguno"))
debug.info("Subcomando detectado: " .. (subcommand or "ninguno"))

local final_command

-- Construir la clave del comando
local command_key = command_type .. "." .. subcommand

-- Verificar si existe un manejador específico para este comando
if command_handlers[command_key] then
    local options = {}
    
    -- Aplicar defaults según el tipo de comando
    if command_type == "pr" then
        for key, value in pairs(config.pr_defaults) do
            options[key] = value
        end
    elseif command_type == "issue" and config.issue_defaults then
        for key, value in pairs(config.issue_defaults) do
            options[key] = value
        end
    end
    
    -- Sobrescribir con flags del usuario
    for flag, value in pairs(parsed.flags) do
        if flag ~= "--debug" and flag ~= "-d" then
            local key = string.match(flag, "^%-%-(.+)$")
            if key then
                options[key] = value
            end
        end
    end
    
    debug.info("Opciones para " .. command_key .. ":", options)
    final_command = command_handlers[command_key](options)
else
    debug.info("Comando genérico, usando buildGenericCommand")
    final_command = gh.buildGenericCommand(real_args)
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
