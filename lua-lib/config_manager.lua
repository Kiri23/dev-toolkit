-- lua-lib/config_manager.lua
local debug = require("kgh_debug") 
local fs = require("lfs") -- For checking file/directory existence

local ConfigManager = {}

-- Path to user configuration
local user_config_dir = os.getenv("HOME") .. "/.config/kgh"
local user_config_path = user_config_dir .. "/user_config.lua"

-- Default configuration (can be expanded later)
local default_config = {
  pr = {
    base = "main"
  }
}

-- Function to safely load user configuration
function ConfigManager.load_user_config()
    debug.info("Attempting to load user config from: " .. user_config_path)
    -- Ensure the directory exists before trying to read the file
    -- This check is more relevant for 'set', but good to be aware of.
    -- For 'get', if the dir or file doesn't exist, it's not an error, just no user config.
    if fs.attributes(user_config_path, "mode") == "file" then
        local status, config_or_error = pcall(dofile, user_config_path)
        if status and type(config_or_error) == "table" then
            debug.success("User config loaded successfully.")
            debug.config(config_or_error) -- Log the loaded user config
            return config_or_error
        elseif not status then
            debug.error("Error loading user_config.lua: " .. tostring(config_or_error))
            return {} -- Return empty table on error to prevent breaking
        else
            debug.warn("user_config.lua did not return a table or was empty.")
            return {} -- Return empty table if file doesn't return a table
        end
    else
        debug.info("User config file not found at: " .. user_config_path .. ". Using defaults only.")
        return {} -- Return empty table if file doesn't exist
    end
end

-- Function to merge default and user configurations
function ConfigManager.get_merged_config()
    local user_cfg = ConfigManager.load_user_config()
    local final_config = {}

    -- Deep copy defaults to avoid modifying the original default_config table
    for k, v in pairs(default_config) do
        if type(v) == "table" then
            final_config[k] = {}
            for k2, v2 in pairs(v) do
                final_config[k][k2] = v2
            end
        else
            final_config[k] = v
        end
    end

    -- Merge user config into final_config, overriding defaults
    for k, v in pairs(user_cfg) do
        if type(v) == "table" and type(final_config[k]) == "table" then
            -- Merge nested tables (one level deep for simplicity, can be made recursive)
            for k2, v2 in pairs(v) do
                final_config[k][k2] = v2
            end
        else
            -- This handles top-level keys and overwrites nested tables if types don't match
            final_config[k] = v
        end
    end
    debug.info("Final merged config being used:", final_config)
    return final_config
end

-- Function to get a configuration value by key (e.g., "pr.base")
function ConfigManager.get_value(key)
    if not key or key == "" then
        debug.error("ConfigManager.get_value: key is nil or empty")
        print("Error: Configuration key cannot be empty.")
        return nil
    end
    debug.info("ConfigManager.get_value called for key: '" .. key .. "'")

    local config_table = ConfigManager.get_merged_config()
    
    local keys = {}
    for k_part in string.gmatch(key, "[^%.]+") do
        table.insert(keys, k_part)
    end

    if #keys == 0 then
        debug.error("ConfigManager.get_value: Parsed key is empty for input key '" .. key .. "'")
        print("Error: Invalid configuration key format.")
        return nil
    end

    local current_value = config_table
    for i, k_part in ipairs(keys) do
        if type(current_value) == "table" and current_value[k_part] ~= nil then
            current_value = current_value[k_part]
        else
            debug.warn("Key part '" .. k_part .. "' (from key '" .. key .. "') not found or current value is not a table.")
            return nil -- Key part not found or path interrupted
        end
    end
    
    debug.success("Value for key '" .. key .. "': " .. tostring(current_value))
    return current_value
end

-- Helper function to convert a Lua table to a string representation for saving
function ConfigManager.serialize_lua_table(tbl, indent_level)
    indent_level = indent_level or 0
    local indent_str = string.rep("  ", indent_level)
    local next_indent_str = string.rep("  ", indent_level + 1)
    local s = "{\n"
    local first = true

    -- Consistent ordering for more stable output (optional, but good for diffs)
    local keys_to_serialize = {}
    for k in pairs(tbl) do table.insert(keys_to_serialize, k) end
    table.sort(keys_to_serialize)

    for _, k in ipairs(keys_to_serialize) do
        local v = tbl[k]
        if not first then
            s = s .. ",\n"
        end
        first = false

        s = s .. next_indent_str
        if type(k) == "string" then
            -- Check if key is a valid Lua identifier, else use ["key"] format
            if string.match(k, "^[_%a][_%w]*$") then
                s = s .. k .. ' = '
            else
                s = s .. '["' .. tostring(k) .. '"] = '
            end
        else
            s = s .. '[' .. tostring(k) .. '] = ' -- For non-string keys (e.g. numbers if ever used)
        end

        if type(v) == "table" then
            s = s .. ConfigManager.serialize_lua_table(v, indent_level + 1)
        elseif type(v) == "string" then
            s = s .. '"' .. tostring(v):gsub('"', '\\"'):gsub("\n", "\\n") .. '"' -- Escape quotes and newlines
        elseif type(v) == "boolean" then
            s = s .. tostring(v)
        elseif type(v) == "number" then
            s = s .. tostring(v)
        else
            s = s .. '"UNKNOWN_TYPE[' .. type(v) .. ']"' 
            debug.warn("serialize_lua_table: Unhandled type '" .. type(v) .. "' for key: " .. tostring(k))
        end
    end
    s = s .. "\n" .. indent_str .. "}"
    return s
end

-- Function to save the user configuration table to user_config.lua
function ConfigManager.save_user_config(config_table)
    debug.info("Attempting to save user config to: " .. user_config_path)

    if fs.attributes(user_config_dir, "mode") ~= "directory" then
        debug.info("User config directory not found, creating: " .. user_config_dir)
        local success, err = fs.mkdir(user_config_dir)
        if not success then
            debug.error("Failed to create directory " .. user_config_dir .. ": " .. tostring(err))
            print("Error: Could not create configuration directory: " .. user_config_dir)
            return false
        end
        debug.success("Created directory: " .. user_config_dir)
    end

    local serialized_config = "return " .. ConfigManager.serialize_lua_table(config_table)
    debug.info("Serialized config to save:", serialized_config)

    local file, err = io.open(user_config_path, "w")
    if not file then
        debug.error("Failed to open " .. user_config_path .. " for writing: " .. tostring(err))
        print("Error: Could not open configuration file for writing: " .. user_config_path)
        return false
    end

    local bytes_written, write_err = file:write(serialized_config)
    if not bytes_written then -- Check if write returned nil or false (error)
        debug.error("Failed to write to " .. user_config_path .. ": " .. tostring(write_err))
        file:close()
        print("Error: Could not write to configuration file: " .. user_config_path .. (write_err and (": " .. write_err) or ""))
        return false
    end

    file:close()
    debug.success("User config saved successfully to: " .. user_config_path)
    return true
end

-- Function to set a configuration value by key (e.g., "pr.base")
function ConfigManager.set_value(key, value)
    if not key or key == "" then
        debug.error("ConfigManager.set_value: key is nil or empty")
        print("Error: Configuration key cannot be empty.")
        return false
    end
    -- Allow empty string for value, but not nil.
    if value == nil then
        debug.error("ConfigManager.set_value: value is nil for key '" .. key .. "'")
        print("Error: Configuration value cannot be nil. To remove a key, use 'kgh config unset <key>' (not yet implemented).")
        return false
    end

    debug.info("ConfigManager.set_value called for key: '" .. key .. "' with value: '" .. tostring(value) .. "' of type " .. type(value))

    local user_cfg = ConfigManager.load_user_config() 
    if user_cfg == nil then user_cfg = {} end 

    local keys = {}
    for k_part in string.gmatch(key, "[^%.]+") do
        table.insert(keys, k_part)
    end

    if #keys == 0 then
        debug.error("ConfigManager.set_value: Parsed key is empty for input key '" .. key .. "'")
        print("Error: Invalid configuration key format.")
        return false
    end

    local current_table = user_cfg
    for i = 1, #keys - 1 do
        local k_part = keys[i]
        if not current_table[k_part] or type(current_table[k_part]) ~= "table" then
            current_table[k_part] = {}
        end
        current_table = current_table[k_part]
    end

    current_table[keys[#keys]] = value 
    debug.info("Updated user_cfg table (before saving):", user_cfg)

    return ConfigManager.save_user_config(user_cfg)
end

-- Helper function to flatten the configuration table for 'list' command
-- Takes a table and an optional prefix for nested keys.
function ConfigManager.flatten_config_table(tbl, prefix)
    local result_lines = {}
    prefix = prefix or ""

    -- Create a sorted list of keys for consistent output order
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)

    for _, k in ipairs(keys) do
        local v = tbl[k]
        local current_key_str
        if prefix == "" then
            current_key_str = tostring(k)
        else
            current_key_str = prefix .. "." .. tostring(k)
        end

        if type(v) == "table" then
            -- Recursively flatten nested tables
            local nested_lines = ConfigManager.flatten_config_table(v, current_key_str)
            for _, line in ipairs(nested_lines) do
                table.insert(result_lines, line)
            end
        else
            -- Add key=value string to results
            table.insert(result_lines, current_key_str .. "=" .. tostring(v))
        end
    end
    return result_lines
end

-- Function to list all configurations (merged default and user)
function ConfigManager.list_configs()
    debug.info("ConfigManager.list_configs called.")
    local merged_config = ConfigManager.get_merged_config() -- This already logs the merged config
    
    if not merged_config or next(merged_config) == nil then
        debug.info("No configurations (merged) found to list.")
        return {} 
    end

    local flat_list = ConfigManager.flatten_config_table(merged_config)
    
    if #flat_list == 0 then
        debug.info("Flattened configuration list is empty (e.g. empty tables).")
    else
        debug.info("Flattened configuration list for display:", flat_list)
    end
    return flat_list -- Return as a list of strings "key=value"
end

return ConfigManager
