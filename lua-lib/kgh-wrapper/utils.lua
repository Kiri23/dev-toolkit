-- utils.lua - Utility functions for KGH modular architecture
-- Provides command execution, argument parsing, and helper functions

local utils = {}
local debug -- Will be injected by main.lua

-- Set debug module (dependency injection)
function utils.set_debug(debug_module)
    debug = debug_module
end

-- Execute a command and return result and success status
function utils.execute_command(cmd)
    if not cmd or #cmd == 0 then
        if debug then debug.error("Comando vacío recibido") end
        return nil, false
    end
    
    local command_string = table.concat(cmd, " ")
    if debug then debug.info("Ejecutando: " .. command_string) end
    
    local handle = io.popen(command_string .. " 2>&1")
    if not handle then
        if debug then debug.error("No se pudo abrir el proceso") end
        return nil, false
    end
    
    local result = handle:read("*a")
    local success = handle:close()
    
    if debug then
        if success then
            debug.success("Comando ejecutado exitosamente")
        else
            debug.error("Comando falló")
        end
        if result and result ~= "" then
            debug.info("Salida del comando: " .. result:sub(1, 200) .. (result:len() > 200 and "..." or ""))
        end
    end
    
    return result, success
end

-- Parse command line arguments
function utils.parse_args(args)
    local parsed = {
        command = {},
        flags = {},
        has_debug = false,
        show_help = false,
        show_config = false
    }
    
    local i = 1
    while i <= #args do
        local arg = args[i]
        
        if arg == "--debug" or arg == "-d" then
            parsed.has_debug = true
        elseif arg == "--help" or arg == "-h" then
            parsed.show_help = true
        elseif arg == "--config" then
            parsed.show_config = true
        elseif arg:sub(1, 2) == "--" then
            -- Long flag
            local flag_name = arg:sub(3)
            if i + 1 <= #args and not args[i + 1]:sub(1, 1) == "-" then
                -- Flag with value
                parsed.flags[flag_name] = args[i + 1]
                i = i + 1
            else
                -- Boolean flag
                parsed.flags[flag_name] = true
            end
        elseif arg:sub(1, 1) == "-" and arg ~= "-" then
            -- Short flag
            local flag_name = arg:sub(2)
            if i + 1 <= #args and not args[i + 1]:sub(1, 1) == "-" then
                -- Flag with value
                parsed.flags[flag_name] = args[i + 1]
                i = i + 1
            else
                -- Boolean flag
                parsed.flags[flag_name] = true
            end
        else
            -- Regular argument (command)
            table.insert(parsed.command, arg)
        end
        
        i = i + 1
    end
    
    return parsed
end

-- Merge user arguments with default configuration
function utils.merge_arguments_with_defaults(user_flags, defaults)
    local merged = {}
    
    -- Start with defaults
    for k, v in pairs(defaults) do
        merged[k] = v
    end
    
    -- Override with user flags
    for k, v in pairs(user_flags) do
        merged[k] = v
    end
    
    return merged
end

-- Convert table to string for debugging
function utils.table_to_string(t, indent)
    if type(t) ~= "table" then
        return tostring(t)
    end
    
    indent = indent or 0
    local result = "{\n"
    local spaces = string.rep("  ", indent + 1)
    
    for k, v in pairs(t) do
        result = result .. spaces .. tostring(k) .. " = "
        if type(v) == "table" then
            result = result .. utils.table_to_string(v, indent + 1)
        else
            result = result .. tostring(v)
        end
        result = result .. ",\n"
    end
    
    result = result .. string.rep("  ", indent) .. "}"
    return result
end

-- Show debug command before execution
function utils.show_debug_command(cmd)
    if cmd and #cmd > 0 then
        print("🔍 Ejecutando: " .. table.concat(cmd, " "))
    end
end

-- Check if a file exists
function utils.file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- Read file contents
function utils.read_file(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        return content
    end
    return nil
end

-- Write file contents
function utils.write_file(path, content)
    local file = io.open(path, "w")
    if file then
        file:write(content)
        file:close()
        return true
    end
    return false
end

-- Get current timestamp
function utils.get_timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

-- Check if we're in a git repository
function utils.is_git_repo()
    local handle = io.popen("git rev-parse --is-inside-work-tree 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result:match("true") ~= nil
    end
    return false
end

-- Get current git branch
function utils.get_git_branch()
    local handle = io.popen("git branch --show-current 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result:gsub("\n", "")
    end
    return nil
end

-- Get git remote origin URL
function utils.get_git_remote()
    local handle = io.popen("git remote get-url origin 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        return result:gsub("\n", "")
    end
    return nil
end

-- Parse GitHub repository from URL
function utils.parse_github_repo(url)
    if not url then return nil end
    
    -- Match github.com URLs (both HTTPS and SSH)
    local owner, repo = url:match("github%.com[:/]([^/]+)/([^/%.]+)")
    if owner and repo then
        return {
            owner = owner,
            repo = repo:gsub("%.git$", ""),
            url = url
        }
    end
    
    return nil
end

-- Split string by delimiter
function utils.split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    
    for match in str:gmatch(pattern) do
        table.insert(result, match)
    end
    
    return result
end

-- Trim whitespace from string
function utils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Check if string starts with prefix
function utils.starts_with(str, prefix)
    return str:sub(1, #prefix) == prefix
end

-- Check if string ends with suffix
function utils.ends_with(str, suffix)
    return str:sub(-#suffix) == suffix
end

-- Escape string for shell command
function utils.shell_escape(str)
    return "'" .. str:gsub("'", "'\\''") .. "'"
end

return utils