-- gh.lua - Módulo GitHub puro (Capa 1: Building Blocks)
-- Funciones puras para interactuar con GitHub CLI
-- Sin efectos secundarios, solo retorna comandos/resultados

local gh = {}
local utils = require("utils")
local config = require("config")

-- Función para crear un Pull Request
-- @param options tabla con opciones: {title, base, body, head, draft, etc.}
-- @return string comando gh para ejecutar
function gh.createPr(options)
    local cmd = "gh pr create"
    
    if options.title then
        cmd = cmd .. " --title " .. utils.escape_shell_arg(options.title)
    end
    if options.body then
        cmd = cmd .. " --body " .. utils.escape_shell_arg(options.body)
    end
    if options.base then
        cmd = cmd .. " --base " .. utils.escape_shell_arg(options.base)
    end
    if options.head then
        cmd = cmd .. " --head " .. utils.escape_shell_arg(options.head)
    end

    if config.dry_run then
        utils.show_dry_run_command(cmd)
        return cmd
    end

    return cmd
end

-- Función para listar Pull Requests
-- @param options tabla con opciones: {state, limit, author, base, etc.}
-- @return string comando gh para ejecutar
function gh.listPrs(options)
    local cmd = "gh pr list"
    
    if options.state then
        cmd = cmd .. " --state " .. utils.escape_shell_arg(options.state)
    end
    if options.limit then
        cmd = cmd .. " --limit " .. utils.escape_shell_arg(options.limit)
    end

    if config.dry_run then
        utils.show_dry_run_command(cmd)
        return cmd
    end

    return cmd
end

-- Función para crear un Issue
-- @param options tabla con opciones: {title, body, assignee, label, etc.}
-- @return string comando gh para ejecutar
function gh.createIssue(options)
    local cmd = "gh issue create"
    
    if options.title then
        cmd = cmd .. " --title " .. utils.escape_shell_arg(options.title)
    end
    if options.body then
        cmd = cmd .. " --body " .. utils.escape_shell_arg(options.body)
    end
    if options.label then
        cmd = cmd .. " --label " .. utils.escape_shell_arg(options.label)
    end

    if config.dry_run then
        utils.show_dry_run_command(cmd)
        return cmd
    end

    return cmd
end

-- Función para listar Issues
-- @param options tabla con opciones: {state, limit, author, assignee, etc.}
-- @return string comando gh para ejecutar
function gh.listIssues(options)
    local cmd = "gh issue list"
    
    if options.state then
        cmd = cmd .. " --state " .. utils.escape_shell_arg(options.state)
    end
    if options.limit then
        cmd = cmd .. " --limit " .. utils.escape_shell_arg(options.limit)
    end

    if config.dry_run then
        utils.show_dry_run_command(cmd)
        return cmd
    end

    return cmd
end

-- Función para construir comando genérico de GitHub
-- @param args tabla con argumentos del comando
-- @return string comando gh para ejecutar
function gh.buildGenericCommand(args)
    local cmd = "gh " .. table.concat(args, " ")

    if config.dry_run then
        utils.show_dry_run_command(cmd)
        return cmd
    end

    return cmd
end

return gh
