-- config.lua
local config = {}

-- Configuraciones por defecto para PRs
config.pr_defaults = {
    base = "main",
    -- Puedes agregar más defaults aquí:
    -- reviewer = "@tu-usuario",
    -- label = "enhancement",
}

-- Configuraciones para otros comandos
config.issue_defaults = {
    -- Defaults para issues si los necesitas
}

-- Configuración de debug
config.show_command = true  -- Mostrar el comando real ejecutado

return config