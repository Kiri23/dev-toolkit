-- kgh_debug.lua - Debug system for KGH modular architecture
-- Provides comprehensive logging and debugging capabilities

local debug = {}

-- Debug state
debug.enabled = false
debug.log_file = nil
debug.start_time = os.time()

-- Color codes for terminal output
debug.colors = {
    reset = "\27[0m",
    red = "\27[31m",
    green = "\27[32m",
    yellow = "\27[33m",
    blue = "\27[34m",
    magenta = "\27[35m",
    cyan = "\27[36m",
    white = "\27[37m",
    bold = "\27[1m"
}

-- Log levels
debug.levels = {
    ERROR = {color = debug.colors.red, icon = "❌", name = "ERROR"},
    WARN = {color = debug.colors.yellow, icon = "⚠️", name = "WARN"},
    INFO = {color = debug.colors.blue, icon = "ℹ️", name = "INFO"},
    SUCCESS = {color = debug.colors.green, icon = "✅", name = "SUCCESS"},
    DEBUG = {color = debug.colors.cyan, icon = "🔍", name = "DEBUG"},
    TRACE = {color = debug.colors.magenta, icon = "🔬", name = "TRACE"}
}

-- Enable debug mode
function debug.enable()
    debug.enabled = true
    debug.start_time = os.time()
    
    -- Optionally create log file
    local log_dir = os.getenv("HOME") .. "/.config/kgh/logs"
    local success, err_msg, err_code = os.execute("mkdir -p " .. log_dir)

    if not success then
        print("Warning: Could not create log directory: " .. (err_msg or err_code or "unknown error"))
        return -- Don't attempt to create log file if directory creation failed
    end

    local log_filename = log_dir .. "/kgh_debug_" .. os.date("%Y%m%d_%H%M%S") .. ".log"
    debug.log_file = io.open(log_filename, "w")
    
    if debug.log_file then
        debug.log_file:write("=== KGH Debug Session Started at " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===\n")
        debug.log_file:flush()
    end
end

-- Disable debug mode
function debug.disable()
    debug.enabled = false
    if debug.log_file then
        debug.log_file:write("=== Debug Session Ended ===\n")
        debug.log_file:close()
        debug.log_file = nil
    end
end

-- Get timestamp for logging
function debug.get_timestamp()
    return os.date("%H:%M:%S")
end

-- Get elapsed time since debug start
function debug.get_elapsed()
    return os.time() - debug.start_time
end

-- Core logging function
function debug.log(level, message, data)
    if not debug.enabled then return end
    
    local level_info = debug.levels[level] or debug.levels.INFO
    local timestamp = debug.get_timestamp()
    local elapsed = debug.get_elapsed()
    
    -- Format message for console
    local console_msg = string.format(
        "%s[%s+%ds]%s %s %s%s%s %s",
        debug.colors.bold,
        timestamp,
        elapsed,
        debug.colors.reset,
        level_info.icon,
        level_info.color,
        level_info.name,
        debug.colors.reset,
        message
    )
    
    -- Print to console
    print(console_msg)
    
    -- Add data if provided
    if data then
        local data_str = debug.serialize_data(data)
        print("  📋 " .. data_str)
    end
    
    -- Log to file if available
    if debug.log_file then
        local file_msg = string.format(
            "[%s+%ds] %s %s",
            timestamp,
            elapsed,
            level_info.name,
            message
        )
        debug.log_file:write(file_msg .. "\n")
        
        if data then
            debug.log_file:write("  Data: " .. debug.serialize_data(data) .. "\n")
        end
        
        debug.log_file:flush()
    end
end

-- Serialize data for logging
function debug.serialize_data(data)
    if type(data) == "table" then
        return debug.table_to_string(data)
    elseif type(data) == "string" then
        return data
    else
        return tostring(data)
    end
end

-- Convert table to string (similar to utils but independent)
function debug.table_to_string(t, indent)
    if type(t) ~= "table" then
        return tostring(t)
    end
    
    indent = indent or 0
    local result = "{"
    local first = true
    
    for k, v in pairs(t) do
        if not first then result = result .. ", " end
        first = false
        
        result = result .. tostring(k) .. "="
        if type(v) == "table" then
            if indent < 2 then -- Prevent infinite recursion
                result = result .. debug.table_to_string(v, indent + 1)
            else
                result = result .. "{...}"
            end
        else
            result = result .. tostring(v)
        end
    end
    
    result = result .. "}"
    return result
end

-- Specific log level functions
function debug.error(message, data)
    debug.log("ERROR", message, data)
end

function debug.warn(message, data)
    debug.log("WARN", message, data)
end

function debug.info(message, data)
    debug.log("INFO", message, data)
end

function debug.success(message, data)
    debug.log("SUCCESS", message, data)
end

function debug.debug(message, data)
    debug.log("DEBUG", message, data)
end

function debug.trace(message, data)
    debug.log("TRACE", message, data)
end

-- Configuration debugging
function debug.config(config_obj)
    if not debug.enabled then return end
    
    debug.info("=== Configuración cargada ===")
    debug.info("PR defaults: " .. debug.serialize_data(config_obj.pr_defaults))
    debug.info("Issue defaults: " .. debug.serialize_data(config_obj.issue_defaults or {}))
    debug.info("Show command: " .. tostring(config_obj.show_command))
    debug.info("===============================")
end

-- Command debugging
function debug.command(cmd, description)
    if not debug.enabled then return end
    
    local cmd_str = type(cmd) == "table" and table.concat(cmd, " ") or tostring(cmd)
    debug.debug("Comando " .. (description or "") .. ": " .. cmd_str)
end

-- Timing functions
debug.timers = {}

function debug.start_timer(name)
    if not debug.enabled then return end
    debug.timers[name] = os.clock()
    debug.trace("Timer iniciado: " .. name)
end

function debug.end_timer(name)
    if not debug.enabled then return end
    
    if debug.timers[name] then
        local elapsed = os.clock() - debug.timers[name]
        debug.trace(string.format("Timer %s: %.3fs", name, elapsed))
        debug.timers[name] = nil
        return elapsed
    else
        debug.warn("Timer no encontrado: " .. name)
        return nil
    end
end

-- Memory usage (basic implementation)
function debug.memory_usage()
    if not debug.enabled then return end
    
    -- Lua's collectgarbage to get memory info (in KB)
    local memory_kb = collectgarbage("count")
    debug.trace(string.format("Memoria en uso: %.2f KB", memory_kb))
    return memory_kb
end

-- Function call tracing
function debug.trace_call(func_name, args)
    if not debug.enabled then return end
    
    local args_str = args and debug.serialize_data(args) or "sin argumentos"
    debug.trace("Llamando función: " .. func_name .. " con " .. args_str)
end

-- Module loading debugging
function debug.module_loaded(module_name)
    if not debug.enabled then return end
    debug.debug("Módulo cargado: " .. module_name)
end

-- Git context debugging
function debug.git_context()
    if not debug.enabled then return end
    
    local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
    if handle then
        local repo_root = handle:read("*a"):gsub("\n", "")
        handle:close()
        
        if repo_root and repo_root ~= "" then
            debug.info("Repositorio Git detectado: " .. repo_root)
            
            -- Get current branch
            local branch_handle = io.popen("git branch --show-current 2>/dev/null")
            if branch_handle then
                local branch = branch_handle:read("*a"):gsub("\n", "")
                branch_handle:close()
                debug.info("Rama actual: " .. (branch ~= "" and branch or "detached HEAD"))
            end
            
            -- Get remote URL
            local remote_handle = io.popen("git remote get-url origin 2>/dev/null")
            if remote_handle then
                local remote = remote_handle:read("*a"):gsub("\n", "")
                remote_handle:close()
                debug.info("Remote origin: " .. (remote ~= "" and remote or "no configurado"))
            end
        else
            debug.warn("No se detectó repositorio Git")
        end
    end
end

-- Cleanup function (called automatically on exit if possible)
function debug.cleanup()
    if debug.log_file then
        debug.log_file:write("=== Debug Session Ended at " .. os.date("%Y-%m-%d %H:%M:%S") .. " ===\n")
        debug.log_file:close()
        debug.log_file = nil
    end
end

-- Auto-cleanup on exit (best effort)
if debug.enabled then
    -- Try to set up cleanup on exit
    local function exit_handler()
        debug.cleanup()
    end
    
    -- This might not work in all Lua environments, but it's worth trying
    if os.exit then
        local original_exit = os.exit
        os.exit = function(...)
            exit_handler()
            original_exit(...)
        end
    end
end

return debug