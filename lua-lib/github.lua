-- github.lua (versión corregida - dependencias ordenadas)
local config = require("config")
local utils = require("utils")
local debug = require("kgh_debug")
local ConfigManager = require("config_manager")

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

debug.info("KGH Command processing: type='" .. (command_type or "nil") .. "', subcommand='" .. (subcommand or "nil") .. "'")

-- Handle 'config' commands first
if command_type == "config" then
    debug.info("Handling 'config' command type.")
    if subcommand == "get" then
        local key = parsed.command[3]
        if not key then
            debug.error("No key provided for 'kgh config get'")
            print("Error: No key provided for 'kgh config get'. Usage: kgh config get <key>")
            os.exit(1)
        end
        debug.info("Calling ConfigManager.get_value for key: " .. key)
        local value = ConfigManager.get_value(key)
        if value ~= nil then
            print(tostring(value))
        else
            -- Optionally, print a specific message or just exit silently if key not found
            debug.info("Key '" .. key .. "' not found in configuration. No output printed.")
        end
        os.exit(0) -- Successfully handled 'config get', exit.
    elseif subcommand == "set" then
        local key = parsed.command[3]
        local value_str = parsed.command[4] -- Value from command line is always a string initially
        
        if not key or value_str == nil then -- Check value_str for nil explicitly
            debug.error("Key or value not provided for 'kgh config set'")
            print("Error: Key or value not provided. Usage: kgh config set <key> <value>")
            os.exit(1)
        end

        local processed_value
        if value_str == "true" then
            processed_value = true
        elseif value_str == "false" then
            processed_value = false
        else
            local num_value = tonumber(value_str)
            if num_value ~= nil then
                processed_value = num_value
            else
                processed_value = value_str -- Keep as string if not boolean or number
            end
        end
        
        debug.info("Calling ConfigManager.set_value for key: '" .. key .. "', processed_value: '" .. tostring(processed_value) .. "' (original string: '" .. value_str .. "')")
        if ConfigManager.set_value(key, processed_value) then
            print("Configuration updated for key: " .. key)
            debug.success("Configuration updated for key: " .. key)
        else
            -- ConfigManager.set_value should print specific errors
            print("Failed to update configuration for key: " .. key)
            debug.error("Failed to update configuration (ConfigManager.set_value returned false) for key: " .. key)
            os.exit(1) 
        end
        os.exit(0)
    elseif subcommand == "list" then
        debug.info("Calling ConfigManager.list_configs")
        local config_lines = ConfigManager.list_configs()
        if #config_lines > 0 then
            for _, line in ipairs(config_lines) do
                print(line)
            end
        else
            debug.info("No configurations to display for 'list' command.")
            -- Consider if a message like "No configurations set." should be printed to stdout
            -- For now, it prints nothing if the list is empty, consistent with `git config -l` on an empty config
        end
        os.exit(0) -- Successfully handled 'config list', exit.
    else
        debug.error("Unknown 'kgh config' subcommand: " .. (subcommand or "none"))
        -- Update the supported command list in the error message
        print("Error: Unknown 'kgh config' subcommand: " .. (subcommand or "none") .. ". Supported: get, set, list.")
        os.exit(1)
    end
end

-- If not a 'config' command, proceed to existing logic for pr, issue, and generic commands
debug.info("Command type is not 'config', proceeding to other command handlers.")
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