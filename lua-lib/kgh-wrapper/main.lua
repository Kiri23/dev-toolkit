-- main.lua - Nuevo punto de entrada (Orquestador)
-- Manejo de argumentos CLI, orchestración de módulos, sistema de debug

local config = require("config")
local utils = require("utils")
local debug = require("kgh_debug")
local gh = require("gh")

-- IMPORTANTE: Inyectar debug en utils DESPUÉS de cargar ambos módulos
utils.set_debug(debug)

-- Obtener argumentos de línea de comandos
local args = {}
if arg then
    for i = 1, #arg do
        table.insert(args, arg[i])
    end
end

-- Parsear argumentos (esto detectará el flag --debug)
local parsed = utils.parse_args(args)

-- Habilitar debug si se detectó el flag
if parsed.has_debug then
    debug.enable()
    debug.success("🐛 Modo debug activado")
    debug.config(config)
end

-- Si no hay argumentos válidos (excluyendo --debug), mostrar ayuda
local real_args = {}
for _, arg_val in ipairs(args) do
    if arg_val ~= "--debug" and arg_val ~= "-d" then
        table.insert(real_args, arg_val)
    end
end

if #real_args == 0 then
    print("🚀 KGH - GitHub CLI Personalizado")
    print("Uso: kgh [comando] [argumentos] [--debug]")
    print("")
    print("Ejemplos:")
    print("  kgh pr create --title 'Fix bug'")
    print("  kgh pr create --title 'Fix bug' --debug")
    print("  kgh pr list --debug")
    print("")
    print("💡 Configuraciones automáticas:")
    print("  - PRs: --base " .. config.pr_defaults.base)
    print("")
    print("🐛 Debug:")
    print("  --debug, -d    Mostrar información de debug")
    print("")
    os.exit(0)
end

-- Determinar tipo de comando
local command_type = parsed.command[1]
local subcommand = parsed.command[2]

debug.info("Tipo de comando detectado: " .. (command_type or "ninguno"))
debug.info("Subcomando detectado: " .. (subcommand or "ninguno"))

local final_command

-- Usar el módulo gh para comandos específicos de GitHub
if command_type == "pr" and subcommand == "create" then
    debug.info("Usando módulo gh para crear PR")
    
    -- Convertir flags a opciones para el módulo gh
    local options = {}
    
    -- Aplicar defaults de configuración
    for key, value in pairs(config.pr_defaults) do
        options[key] = value
    end
    
    -- Sobrescribir con flags del usuario
    if parsed.flags["--title"] then
        options.title = parsed.flags["--title"]
    end
    if parsed.flags["--base"] then
        options.base = parsed.flags["--base"]
    end
    if parsed.flags["--body"] then
        options.body = parsed.flags["--body"]
    end
    if parsed.flags["--head"] then
        options.head = parsed.flags["--head"]
    end
    if parsed.flags["--draft"] then
        options.draft = true
    end
    if parsed.flags["--reviewer"] then
        options.reviewer = parsed.flags["--reviewer"]
    end
    if parsed.flags["--assignee"] then
        options.assignee = parsed.flags["--assignee"]
    end
    if parsed.flags["--label"] then
        options.label = parsed.flags["--label"]
    end
    
    debug.info("Opciones para createPr:", options)
    final_command = gh.createPr(options)
    
elseif command_type == "pr" and subcommand == "list" then
    debug.info("Usando módulo gh para listar PRs")
    
    local options = {}
    if parsed.flags["--state"] then
        options.state = parsed.flags["--state"]
    end
    if parsed.flags["--limit"] then
        options.limit = tonumber(parsed.flags["--limit"])
    end
    if parsed.flags["--author"] then
        options.author = parsed.flags["--author"]
    end
    if parsed.flags["--base"] then
        options.base = parsed.flags["--base"]
    end
    if parsed.flags["--head"] then
        options.head = parsed.flags["--head"]
    end
    if parsed.flags["--label"] then
        options.label = parsed.flags["--label"]
    end
    
    debug.info("Opciones para listPrs:", options)
    final_command = gh.listPrs(options)
    
elseif command_type == "issue" and subcommand == "create" then
    debug.info("Usando módulo gh para crear Issue")
    
    local options = {}
    
    -- Aplicar defaults de configuración si existen
    if config.issue_defaults then
        for key, value in pairs(config.issue_defaults) do
            options[key] = value
        end
    end
    
    -- Sobrescribir con flags del usuario
    if parsed.flags["--title"] then
        options.title = parsed.flags["--title"]
    end
    if parsed.flags["--body"] then
        options.body = parsed.flags["--body"]
    end
    if parsed.flags["--assignee"] then
        options.assignee = parsed.flags["--assignee"]
    end
    if parsed.flags["--label"] then
        options.label = parsed.flags["--label"]
    end
    if parsed.flags["--milestone"] then
        options.milestone = parsed.flags["--milestone"]
    end
    
    debug.info("Opciones para createIssue:", options)
    final_command = gh.createIssue(options)
    
elseif command_type == "issue" and subcommand == "list" then
    debug.info("Usando módulo gh para listar Issues")
    
    local options = {}
    if parsed.flags["--state"] then
        options.state = parsed.flags["--state"]
    end
    if parsed.flags["--limit"] then
        options.limit = tonumber(parsed.flags["--limit"])
    end
    if parsed.flags["--author"] then
        options.author = parsed.flags["--author"]
    end
    if parsed.flags["--assignee"] then
        options.assignee = parsed.flags["--assignee"]
    end
    if parsed.flags["--label"] then
        options.label = parsed.flags["--label"]
    end
    if parsed.flags["--milestone"] then
        options.milestone = parsed.flags["--milestone"]
    end
    
    debug.info("Opciones para listIssues:", options)
    final_command = gh.listIssues(options)
    
else
    debug.info("Comando genérico, usando buildGenericCommand")
    final_command = gh.buildGenericCommand(real_args)
end

-- Mostrar comando si está habilitado en config
if config.show_command then
    utils.show_debug_command(final_command)
end

-- Ejecutar comando
local result, success = utils.execute_command(final_command)

-- Mostrar resultado
if result and result ~= "" then
    print(result)
end

-- Salir con código apropiado
if not success then
    debug.error("Comando falló")
    os.exit(1)
else
    debug.success("Comando ejecutado exitosamente")
end
