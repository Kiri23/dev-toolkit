-- gh.lua - Módulo GitHub puro (Capa 1: Building Blocks)
-- Funciones puras para interactuar con GitHub CLI
-- Sin efectos secundarios, solo retorna comandos/resultados

local gh = {}

-- Función para crear un Pull Request
-- @param options tabla con opciones: {title, base, body, head, draft, etc.}
-- @return string comando gh para ejecutar
function gh.createPr(options)
    options = options or {}
    
    local cmd_parts = {"gh", "pr", "create"}
    
    -- Agregar opciones obligatorias y opcionales
    if options.title then
        table.insert(cmd_parts, "--title")
        table.insert(cmd_parts, '"' .. options.title .. '"')
    end
    
    if options.base then
        table.insert(cmd_parts, "--base")
        table.insert(cmd_parts, options.base)
    end
    
    if options.body then
        table.insert(cmd_parts, "--body")
        table.insert(cmd_parts, '"' .. options.body .. '"')
    end
    
    if options.head then
        table.insert(cmd_parts, "--head")
        table.insert(cmd_parts, options.head)
    end
    
    if options.draft then
        table.insert(cmd_parts, "--draft")
    end
    
    if options.reviewer then
        table.insert(cmd_parts, "--reviewer")
        table.insert(cmd_parts, options.reviewer)
    end
    
    if options.assignee then
        table.insert(cmd_parts, "--assignee")
        table.insert(cmd_parts, options.assignee)
    end
    
    if options.label then
        table.insert(cmd_parts, "--label")
        table.insert(cmd_parts, options.label)
    end
    
    return table.concat(cmd_parts, " ")
end

-- Función para listar Pull Requests
-- @param options tabla con opciones: {state, limit, author, base, etc.}
-- @return string comando gh para ejecutar
function gh.listPrs(options)
    options = options or {}
    
    local cmd_parts = {"gh", "pr", "list"}
    
    if options.state then
        table.insert(cmd_parts, "--state")
        table.insert(cmd_parts, options.state)
    end
    
    if options.limit then
        table.insert(cmd_parts, "--limit")
        table.insert(cmd_parts, tostring(options.limit))
    end
    
    if options.author then
        table.insert(cmd_parts, "--author")
        table.insert(cmd_parts, options.author)
    end
    
    if options.base then
        table.insert(cmd_parts, "--base")
        table.insert(cmd_parts, options.base)
    end
    
    if options.head then
        table.insert(cmd_parts, "--head")
        table.insert(cmd_parts, options.head)
    end
    
    if options.label then
        table.insert(cmd_parts, "--label")
        table.insert(cmd_parts, options.label)
    end
    
    return table.concat(cmd_parts, " ")
end

-- Función para crear un Issue
-- @param options tabla con opciones: {title, body, assignee, label, etc.}
-- @return string comando gh para ejecutar
function gh.createIssue(options)
    options = options or {}
    
    local cmd_parts = {"gh", "issue", "create"}
    
    if options.title then
        table.insert(cmd_parts, "--title")
        table.insert(cmd_parts, '"' .. options.title .. '"')
    end
    
    if options.body then
        table.insert(cmd_parts, "--body")
        table.insert(cmd_parts, '"' .. options.body .. '"')
    end
    
    if options.assignee then
        table.insert(cmd_parts, "--assignee")
        table.insert(cmd_parts, options.assignee)
    end
    
    if options.label then
        table.insert(cmd_parts, "--label")
        table.insert(cmd_parts, options.label)
    end
    
    if options.milestone then
        table.insert(cmd_parts, "--milestone")
        table.insert(cmd_parts, options.milestone)
    end
    
    return table.concat(cmd_parts, " ")
end

-- Función para listar Issues
-- @param options tabla con opciones: {state, limit, author, assignee, etc.}
-- @return string comando gh para ejecutar
function gh.listIssues(options)
    options = options or {}
    
    local cmd_parts = {"gh", "issue", "list"}
    
    if options.state then
        table.insert(cmd_parts, "--state")
        table.insert(cmd_parts, options.state)
    end
    
    if options.limit then
        table.insert(cmd_parts, "--limit")
        table.insert(cmd_parts, tostring(options.limit))
    end
    
    if options.author then
        table.insert(cmd_parts, "--author")
        table.insert(cmd_parts, options.author)
    end
    
    if options.assignee then
        table.insert(cmd_parts, "--assignee")
        table.insert(cmd_parts, options.assignee)
    end
    
    if options.label then
        table.insert(cmd_parts, "--label")
        table.insert(cmd_parts, options.label)
    end
    
    if options.milestone then
        table.insert(cmd_parts, "--milestone")
        table.insert(cmd_parts, options.milestone)
    end
    
    return table.concat(cmd_parts, " ")
end

-- Función para construir comando genérico de GitHub
-- @param args tabla con argumentos del comando
-- @return string comando gh para ejecutar
function gh.buildGenericCommand(args)
    local cmd_parts = {"gh"}
    
    for _, arg in ipairs(args) do
        -- Escapar argumentos que contienen espacios
        if string.match(arg, "%s") then
            table.insert(cmd_parts, '"' .. arg .. '"')
        else
            table.insert(cmd_parts, arg)
        end
    end
    
    return table.concat(cmd_parts, " ")
end

return gh
