-- config.lua - Configuration management for KGH modular architecture
-- Provides smart defaults and user preference handling

local config = {}

-- Default configuration for pull requests
config.pr_defaults = {
    base = "main",
    draft = false,
    assignee = "@me"
}

-- Default configuration for issues
config.issue_defaults = {
    assignee = "@me"
}

-- Default configuration for repositories  
config.repo_defaults = {
    clone = true
}

-- Default configuration for releases
config.release_defaults = {
    limit = 10
}

-- Default configuration for workflows
config.workflow_defaults = {
    all = false
}

-- Global configuration
config.show_command = false
config.debug_enabled = false

-- Configuration file paths
config.global_config_path = os.getenv("HOME") .. "/.config/kgh/config.lua"
config.local_config_path = "./.kgh/config.lua"

-- Load user configuration from files
function config.load_user_config()
    local user_config = {}
    
    -- Try to load global config
    local global_file = io.open(config.global_config_path, "r")
    if global_file then
        global_file:close()
        local ok, global_config = pcall(dofile, config.global_config_path)
        if ok and type(global_config) == "table" then
            user_config = config.deep_merge(user_config, global_config)
        end
    end
    
    -- Try to load local config (overrides global)
    local local_file = io.open(config.local_config_path, "r")
    if local_file then
        local_file:close()
        local ok, local_config = pcall(dofile, config.local_config_path)
        if ok and type(local_config) == "table" then
            user_config = config.deep_merge(user_config, local_config)
        end
    end
    
    -- Merge user config with defaults
    if next(user_config) then
        config.pr_defaults = config.deep_merge(config.pr_defaults, user_config.pr_defaults or {})
        config.issue_defaults = config.deep_merge(config.issue_defaults, user_config.issue_defaults or {})
        config.repo_defaults = config.deep_merge(config.repo_defaults, user_config.repo_defaults or {})
        config.release_defaults = config.deep_merge(config.release_defaults, user_config.release_defaults or {})
        config.workflow_defaults = config.deep_merge(config.workflow_defaults, user_config.workflow_defaults or {})
        
        config.show_command = user_config.show_command or config.show_command
        config.debug_enabled = user_config.debug_enabled or config.debug_enabled
    end
end

-- Deep merge two tables
function config.deep_merge(t1, t2)
    local result = {}
    
    -- Copy t1
    for k, v in pairs(t1) do
        if type(v) == "table" then
            result[k] = config.deep_merge({}, v)
        else
            result[k] = v
        end
    end
    
    -- Merge t2
    for k, v in pairs(t2) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = config.deep_merge(result[k], v)
        else
            result[k] = v
        end
    end
    
    return result
end

-- Create default configuration file
function config.create_default_config()
    local config_dir = os.getenv("HOME") .. "/.config/kgh"
    os.execute("mkdir -p " .. config_dir)
    
    local config_content = [[-- KGH Configuration File
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
]]
    
    local file = io.open(config.global_config_path, "w")
    if file then
        file:write(config_content)
        file:close()
        return true
    end
    return false
end

-- Show current configuration
function config.show_current_config()
    print("🔧 Configuración actual de KGH:")
    print("")
    print("📋 Pull Requests:")
    for k, v in pairs(config.pr_defaults) do
        print("  " .. k .. ": " .. tostring(v))
    end
    print("")
    print("🐛 Issues:")
    for k, v in pairs(config.issue_defaults) do
        print("  " .. k .. ": " .. tostring(v))
    end
    print("")
    print("📁 Repositorios:")
    for k, v in pairs(config.repo_defaults) do
        print("  " .. k .. ": " .. tostring(v))
    end
    print("")
    print("🚀 Configuración global:")
    print("  show_command: " .. tostring(config.show_command))
    print("  debug_enabled: " .. tostring(config.debug_enabled))
    print("")
    print("📄 Archivos de configuración:")
    print("  Global: " .. config.global_config_path)
    print("  Local:  " .. config.local_config_path)
    print("")
    print("💡 Para personalizar, edita los archivos de configuración")
end

-- Get repository information from git
function config.get_repo_info()
    local handle = io.popen("git remote get-url origin 2>/dev/null")
    if handle then
        local result = handle:read("*a")
        handle:close()
        if result and result ~= "" then
            -- Parse GitHub URL to extract owner/repo
            local owner, repo = result:match("github%.com[:/]([^/]+)/([^/%.]+)")
            if owner and repo then
                return {
                    owner = owner,
                    repo = repo:gsub("%.git$", ""),
                    url = result:gsub("\n", "")
                }
            end
        end
    end
    return nil
end

-- Initialize configuration (load user settings)
config.load_user_config()

return config