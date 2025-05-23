-- kgh_debug.lua
local debug_module = {}

-- Estado del debug (se activa con --debug)
debug_module.enabled = false

-- Colores para la consola
local colors = {
    reset = "\27[0m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    gray = "\27[90m"
}

-- Función para habilitar debug
function debug_module.enable()
    debug_module.enabled = true
end

-- Función para deshabilitar debug
function debug_module.disable()
    debug_module.enabled = false
end

-- Función principal de debug
function debug_module.log(category, message, data)
    if not debug_module.enabled then
        return
    end
    
    local timestamp = os.date("%H:%M:%S")
    local color = colors.cyan
    
    -- Diferentes colores por categoría
    if category == "ERROR" then
        color = colors.red
    elseif category == "WARN" then
        color = colors.yellow
    elseif category == "SUCCESS" then
        color = colors.green
    elseif category == "INFO" then
        color = colors.blue
    end
    
    print(colors.gray .. "[" .. timestamp .. "] " .. 
          color .. "[" .. category .. "] " .. 
          colors.reset .. message)
    
    -- Si hay datos adicionales, mostrarlos
    if data then
        if type(data) == "table" then
            debug_module.print_table(data, "  ")
        else
            print("  " .. colors.gray .. tostring(data) .. colors.reset)
        end
    end
end

-- Función para imprimir tablas de forma legible
function debug_module.print_table(t, indent)
    if not debug_module.enabled then
        return
    end
    
    indent = indent or ""
    
    for k, v in pairs(t) do
        if type(v) == "table" then
            print(indent .. colors.magenta .. tostring(k) .. colors.reset .. ":")
            debug_module.print_table(v, indent .. "  ")
        else
            print(indent .. colors.magenta .. tostring(k) .. colors.reset .. 
                  " = " .. colors.cyan .. tostring(v) .. colors.reset)
        end
    end
end

-- Funciones específicas para diferentes tipos de debug
function debug_module.args(args)
    debug_module.log("ARGS", "Argumentos recibidos:", args)
end

function debug_module.command(cmd)
    debug_module.log("CMD", "Comando a ejecutar: " .. colors.yellow .. cmd .. colors.reset)
end

function debug_module.config(config_data)
    debug_module.log("CONFIG", "Configuración cargada:", config_data)
end

function debug_module.parsing(parsed_data)
    debug_module.log("PARSE", "Resultado del parsing:", parsed_data)
end

function debug_module.error(message, error_data)
    debug_module.log("ERROR", message, error_data)
end

function debug_module.success(message)
    debug_module.log("SUCCESS", message)
end

function debug_module.info(message, data)
    debug_module.log("INFO", message, data)
end

-- Función para debug de performance
function debug_module.timer_start()
    if debug_module.enabled then
        debug_module._start_time = os.clock()
    end
end

function debug_module.timer_end(operation)
    if debug_module.enabled and debug_module._start_time then
        local elapsed = os.clock() - debug_module._start_time
        debug_module.log("PERF", operation .. " tomó " .. string.format("%.3f", elapsed) .. "s")
    end
end

-- Función para debug de red/comandos
function debug_module.command_result(cmd, result, success)
    if debug_module.enabled then
        debug_module.log("RESULT", "Comando: " .. cmd)
        debug_module.log("RESULT", "Éxito: " .. tostring(success))
        if result and result ~= "" then
            debug_module.log("RESULT", "Output:", result)
        end
    end
end

return debug_module