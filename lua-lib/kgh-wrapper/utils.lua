-- utils.lua (versión corregida - sin dependencia circular)
local utils = {}

-- Variable para debug que se inyectará desde fuera
utils.debug = nil

-- Función para inyectar el módulo debug
function utils.set_debug(debug_module)
    utils.debug = debug_module
end

-- Helper para debug seguro
local function safe_debug(func_name, ...)
    if utils.debug and utils.debug[func_name] then
        utils.debug[func_name](...)
    end
end

-- Función para ejecutar comandos del sistema
function utils.execute_command(cmd)
    safe_debug("timer_start")
    safe_debug("command", cmd)
    
    local handle = io.popen(cmd .. " 2>&1")
    local result = handle:read("*a")
    local success = handle:close()
    
    safe_debug("timer_end", "Comando ejecutado")
    safe_debug("command_result", cmd, result, success)
    
    return result, success
end

-- Función para mostrar el comando que se va a ejecutar
function utils.show_debug_command(cmd)
    print("🔧 Ejecutando: " .. cmd)
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end

-- Función para parsear argumentos (SIN debug interno para evitar dependencia circular)
function utils.parse_args(args)
    safe_debug("info", "Iniciando parsing de argumentos")
    safe_debug("args", args)
    
    local parsed = {
        command = {},
        flags = {},
        has_debug = false
    }
    
    local i = 1
    while i <= #args do
        local current_arg = args[i]
        
        -- Detectar flag de debug
        if current_arg == "--debug" or current_arg == "-d" then
            parsed.has_debug = true
            safe_debug("success", "Debug habilitado via flag")
            i = i + 1
        elseif string.match(current_arg, "^%-%-") then
            -- Es una flag larga (--title)
            if i + 1 <= #args and not string.match(args[i + 1], "^%-") then
                parsed.flags[current_arg] = args[i + 1]
                safe_debug("info", "Flag detectada: " .. current_arg .. " = " .. args[i + 1])
                i = i + 2
            else
                parsed.flags[current_arg] = true
                safe_debug("info", "Flag booleana detectada: " .. current_arg)
                i = i + 1
            end
        elseif string.match(current_arg, "^%-") then
            -- Es una flag corta (-t)
            if i + 1 <= #args and not string.match(args[i + 1], "^%-") then
                parsed.flags[current_arg] = args[i + 1]
                safe_debug("info", "Flag corta detectada: " .. current_arg .. " = " .. args[i + 1])
                i = i + 2
            else
                parsed.flags[current_arg] = true
                safe_debug("info", "Flag corta booleana detectada: " .. current_arg)
                i = i + 1
            end
        else
            -- Es un comando o argumento
            table.insert(parsed.command, current_arg)
            safe_debug("info", "Comando/argumento agregado: " .. current_arg)
            i = i + 1
        end
    end
    
    safe_debug("parsing", parsed)
    return parsed
end

-- Función para construir comando con defaults
function utils.build_command_with_defaults(base_command, user_flags, defaults)
    safe_debug("info", "Construyendo comando con defaults")
    safe_debug("info", "Comando base", base_command)
    safe_debug("info", "Flags del usuario", user_flags)
    safe_debug("info", "Defaults a aplicar", defaults)
    
    local cmd_parts = {"gh"}
    
    -- Agregar el comando base
    for _, part in ipairs(base_command) do
        table.insert(cmd_parts, part)
    end
    
    -- Agregar flags del usuario
    for flag, value in pairs(user_flags) do
        if flag ~= "--debug" and flag ~= "-d" then  -- Excluir flag de debug
            if type(value) == "boolean" and value then
                table.insert(cmd_parts, flag)
            elseif type(value) == "string" then
                table.insert(cmd_parts, flag)
                table.insert(cmd_parts, '"' .. value .. '"')
            end
        end
    end
    
    -- Agregar defaults solo si el usuario no los especificó
    for default_flag, default_value in pairs(defaults) do
        local full_flag = "--" .. default_flag
        if not user_flags[full_flag] then
            table.insert(cmd_parts, full_flag)
            table.insert(cmd_parts, default_value)
            safe_debug("success", "Default aplicado: " .. full_flag .. " " .. default_value)
        else
            safe_debug("info", "Default omitido (usuario lo especificó): " .. full_flag)
        end
    end
    
    local final_cmd = table.concat(cmd_parts, " ")
    safe_debug("success", "Comando final construido: " .. final_cmd)
    
    return final_cmd
end

-- Función para escapar argumentos de shell de forma segura
function utils.escape_shell_arg(arg)
    if type(arg) ~= "string" then
        return tostring(arg)
    end
    
    -- Si el argumento está vacío, devolver comillas vacías
    if arg == "" then
        return '""'
    end
    
    -- Si el argumento no contiene caracteres especiales, devolverlo tal cual
    if not string.match(arg, "[^%w%./-]") then
        return arg
    end
    
    -- Escapar comillas simples y backslashes
    local escaped = string.gsub(arg, "['\\]", "\\%1")
    
    -- Escapar otros caracteres especiales
    escaped = string.gsub(escaped, "[%z\1-\31]", function(c)
        return string.format("\\x%02x", string.byte(c))
    end)
    
    -- Envolver en comillas simples
    return "'" .. escaped .. "'"
end

-- Función para escapar múltiples argumentos
function utils.escape_args(args)
    local escaped = {}
    for _, arg in ipairs(args) do
        table.insert(escaped, utils.escape_shell_arg(arg))
    end
    return escaped
end

-- Función para construir comando genérico (no pr/issue)
function utils.build_generic_command(args)
    safe_debug("info", "Construyendo comando genérico")
    safe_debug("args", args)
    
    local escaped_args = utils.escape_args(args)
    local cmd = "gh " .. table.concat(escaped_args, " ")
    
    safe_debug("success", "Comando genérico construido: " .. cmd)
    return cmd
end

return utils