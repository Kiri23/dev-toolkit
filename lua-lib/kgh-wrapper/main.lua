#!/usr/bin/env lua
-- main.lua - CLI orchestrator (Layer 2: Smart Wrappers)
-- This module handles argument parsing, configuration, and command routing

local gh = require("gh")
local config = require("config")
local utils = require("utils")
local debug = require("kgh_debug")

-- Inject debug functionality into utils
utils.set_debug(debug)

-- Get command line arguments
local args = {}
if arg then
    for i = 1, #arg do
        table.insert(args, arg[i])
    end
end

-- Parse arguments and handle special flags
local parsed = utils.parse_args(args)

-- Handle special commands first
if parsed.show_config then
    config.show_current_config()
    os.exit(0)
end

if parsed.show_help or #args == 0 then
    print("🚀 KGH - GitHub CLI Personalizado (Arquitectura Modular)")
    print("Uso: kgh [comando] [argumentos] [--debug]")
    print("")
    print("Comandos principales:")
    print("  pr create    Crear pull request")
    print("  pr list      Listar pull requests")
    print("  pr view      Ver pull request")
    print("  pr merge     Fusionar pull request")
    print("  pr close     Cerrar pull request")
    print("")
    print("  issue create Crear issue")
    print("  issue list   Listar issues")
    print("  issue view   Ver issue")
    print("  issue close  Cerrar issue")
    print("")
    print("  repo view    Ver repositorio")
    print("  repo clone   Clonar repositorio")
    print("  repo fork    Hacer fork")
    print("")
    print("  release list Listar releases")
    print("  workflow list Listar workflows")
    print("")
    print("Flags especiales:")
    print("  --debug, -d      Mostrar información de debug")
    print("  --config         Mostrar configuración actual")
    print("  --help, -h       Mostrar esta ayuda")
    print("")
    print("💡 Configuraciones automáticas desde config.lua:")
    print("  - PRs: --base " .. config.pr_defaults.base)
    print("  - Repositorio detectado automáticamente")
    print("")
    print("🏗️ Arquitectura modular - Phase 2 implementada")
    os.exit(0)
end

-- Enable debug mode if requested
if parsed.has_debug then
    debug.enable()
    debug.success("🐛 Modo debug activado")
    debug.config(config)
    debug.info("Argumentos recibidos: " .. table.concat(args, " "))
end

-- Get clean arguments (without debug flags)
local clean_args = {}
for _, arg_val in ipairs(args) do
    if arg_val ~= "--debug" and arg_val ~= "-d" and arg_val ~= "--config" and arg_val ~= "--help" and arg_val ~= "-h" then
        table.insert(clean_args, arg_val)
    end
end

if #clean_args == 0 then
    debug.error("No se proporcionaron argumentos válidos")
    os.exit(1)
end

-- Determine command type and subcommand
local command_type = clean_args[1]
local subcommand = clean_args[2]

debug.info("Tipo de comando: " .. (command_type or "ninguno"))
debug.info("Subcomando: " .. (subcommand or "ninguno"))

local command_to_execute
local defaults = {}

-- Route commands to appropriate gh module functions
if command_type == "pr" then
    defaults = config.pr_defaults
    debug.info("Aplicando defaults de PR: " .. utils.table_to_string(defaults))
    
    -- Merge user arguments with defaults
    local merged_options = utils.merge_arguments_with_defaults(parsed.flags, defaults)
    debug.info("Opciones fusionadas: " .. utils.table_to_string(merged_options))
    
    if subcommand == "create" then
        command_to_execute = gh.createPr(merged_options)
    elseif subcommand == "list" then
        command_to_execute = gh.listPrs(merged_options)
    elseif subcommand == "view" then
        local pr_number = clean_args[3]
        command_to_execute = gh.viewPr(pr_number, merged_options)
    elseif subcommand == "merge" then
        local pr_number = clean_args[3]
        command_to_execute = gh.mergePr(pr_number, merged_options)
    elseif subcommand == "close" then
        local pr_number = clean_args[3]
        command_to_execute = gh.closePr(pr_number, merged_options)
    else
        debug.warn("Subcomando PR desconocido, usando passthrough")
        command_to_execute = gh.passthrough(clean_args)
    end
    
elseif command_type == "issue" then
    defaults = config.issue_defaults or {}
    debug.info("Aplicando defaults de Issue: " .. utils.table_to_string(defaults))
    
    local merged_options = utils.merge_arguments_with_defaults(parsed.flags, defaults)
    
    if subcommand == "create" then
        command_to_execute = gh.createIssue(merged_options)
    elseif subcommand == "list" then
        command_to_execute = gh.listIssues(merged_options)
    elseif subcommand == "view" then
        local issue_number = clean_args[3]
        command_to_execute = gh.viewIssue(issue_number, merged_options)
    elseif subcommand == "close" then
        local issue_number = clean_args[3]
        command_to_execute = gh.closeIssue(issue_number, merged_options)
    else
        debug.warn("Subcomando Issue desconocido, usando passthrough")
        command_to_execute = gh.passthrough(clean_args)
    end
    
elseif command_type == "repo" then
    defaults = config.repo_defaults or {}
    local merged_options = utils.merge_arguments_with_defaults(parsed.flags, defaults)
    
    if subcommand == "view" then
        local repo = clean_args[3]
        command_to_execute = gh.repoView(repo, merged_options)
    elseif subcommand == "clone" then
        local repo = clean_args[3]
        command_to_execute = gh.repoClone(repo, merged_options)
    elseif subcommand == "fork" then
        local repo = clean_args[3]
        command_to_execute = gh.repoFork(repo, merged_options)
    else
        debug.warn("Subcomando Repo desconocido, usando passthrough")
        command_to_execute = gh.passthrough(clean_args)
    end
    
elseif command_type == "release" then
    defaults = config.release_defaults or {}
    local merged_options = utils.merge_arguments_with_defaults(parsed.flags, defaults)
    
    if subcommand == "list" then
        command_to_execute = gh.listReleases(merged_options)
    elseif subcommand == "view" then
        local tag = clean_args[3]
        command_to_execute = gh.viewRelease(tag, merged_options)
    else
        debug.warn("Subcomando Release desconocido, usando passthrough")
        command_to_execute = gh.passthrough(clean_args)
    end
    
elseif command_type == "workflow" then
    defaults = config.workflow_defaults or {}
    local merged_options = utils.merge_arguments_with_defaults(parsed.flags, defaults)
    
    if subcommand == "list" then
        command_to_execute = gh.listWorkflows(merged_options)
    elseif subcommand == "run" then
        local workflow = clean_args[3]
        command_to_execute = gh.runWorkflow(workflow, merged_options)
    else
        debug.warn("Subcomando Workflow desconocido, usando passthrough")
        command_to_execute = gh.passthrough(clean_args)
    end
    
else
    debug.info("Comando genérico, usando passthrough a gh")
    command_to_execute = gh.passthrough(clean_args)
end

-- Show command if enabled in config
if config.show_command then
    utils.show_debug_command(command_to_execute)
end

debug.info("Comando a ejecutar: " .. table.concat(command_to_execute, " "))

-- Execute the command
local result, success = utils.execute_command(command_to_execute)

-- Show result
if result and result ~= "" then
    print(result)
end

-- Exit with appropriate code
if not success then
    debug.error("Comando falló")
    os.exit(1)
else
    debug.success("Comando ejecutado exitosamente")
end