-- config.lua
local config = {}

-- Configuraciones por defecto para PRs
config.pr_defaults = {
    base = "main",
    head = "develop",
    -- Puedes agregar más defaults aquí:
    -- reviewer = "@tu-usuario",
    -- label = "enhancement",
}

-- Configuraciones para otros comandos
config.issue_defaults = {
    label = "enhancement"
}

-- Configuración de debug
config.show_command = true  -- Mostrar el comando real ejecutado
config.dry_run = false  -- Nuevo flag para modo simulación

return config