# 📚 API Documentation

## Módulos Lua

### 🔧 `config.lua`

Módulo de configuración centralizada para KGH.

#### Estructura

```lua
config = {
    pr_defaults = {
        base = "main"
    },
    issue_defaults = {},
    show_command = true
}
```

#### Propiedades

- **`pr_defaults`** - Configuraciones por defecto para Pull Requests
  - `base`: Rama base para PRs (por defecto: "main")
  - Se puede extender con `reviewer`, `label`, etc.
- **`issue_defaults`** - Configuraciones por defecto para Issues
- **`show_command`** - Mostrar comando real antes de ejecutar

#### Ejemplo de Uso

```lua
local config = require("config")
print(config.pr_defaults.base) -- "main"
```

---

### 🛠 `utils.lua`

Utilidades para parsing de argumentos y ejecución de comandos.

#### Funciones

##### `utils.set_debug(debug_module)`

Inyecta el módulo de debug en utils.

**Parámetros:**
- `debug_module`: Instancia del módulo de debug

**Ejemplo:**
```lua
utils.set_debug(debug)
```

##### `utils.execute_command(cmd)`

Ejecuta un comando del sistema y retorna el resultado.

**Parámetros:**
- `cmd` (string): Comando a ejecutar

**Retorna:**
- `result` (string): Output del comando
- `success` (boolean): Si el comando fue exitoso

**Ejemplo:**
```lua
local result, success = utils.execute_command("gh pr list")
```

##### `utils.parse_args(args)`

Parsea argumentos de línea de comandos.

**Parámetros:**
- `args` (table): Lista de argumentos

**Retorna:**
- `parsed` (table): Estructura con comando, flags y estado debug
  - `command` (table): Partes del comando
  - `flags` (table): Flags y sus valores
  - `has_debug` (boolean): Si se detectó flag de debug

**Ejemplo:**
```lua
local parsed = utils.parse_args({"pr", "create", "--title", "Fix bug", "--debug"})
-- parsed.command = {"pr", "create"}
-- parsed.flags = {"--title": "Fix bug"}
-- parsed.has_debug = true
```

##### `utils.build_command_with_defaults(base_command, user_flags, defaults)`

Construye comando con configuraciones por defecto.

**Parámetros:**
- `base_command` (table): Comando base
- `user_flags` (table): Flags del usuario
- `defaults` (table): Configuraciones por defecto

**Retorna:**
- `cmd` (string): Comando final construido

**Ejemplo:**
```lua
local cmd = utils.build_command_with_defaults(
    {"pr", "create"},
    {"--title": "Fix bug"},
    {base = "main"}
)
-- Resultado: "gh pr create --title \"Fix bug\" --base main"
```

##### `utils.build_generic_command(args)`

Construye comando genérico para pasar directamente a `gh`.

**Parámetros:**
- `args` (table): Argumentos

**Retorna:**
- `cmd` (string): Comando construido

##### `utils.escape_args(args)`

Escapa argumentos que contienen espacios.

**Parámetros:**
- `args` (table): Lista de argumentos

**Retorna:**
- `escaped` (table): Argumentos escapados

---

### 🐛 `kgh_debug.lua`

Sistema de debug avanzado con colores y categorías.

#### Funciones

##### `debug_module.enable()`

Habilita el modo debug.

##### `debug_module.disable()`

Deshabilita el modo debug.

##### `debug_module.log(category, message, data)`

Función principal de logging.

**Parámetros:**
- `category` (string): Categoría del log (ERROR, WARN, SUCCESS, INFO)
- `message` (string): Mensaje a mostrar
- `data` (opcional): Datos adicionales

##### Funciones Específicas

- **`debug_module.args(args)`** - Debug de argumentos
- **`debug_module.command(cmd)`** - Debug de comandos
- **`debug_module.config(config_data)`** - Debug de configuración
- **`debug_module.parsing(parsed_data)`** - Debug de parsing
- **`debug_module.error(message, error_data)`** - Debug de errores
- **`debug_module.success(message)`** - Debug de éxitos
- **`debug_module.info(message, data)`** - Debug de información

##### Funciones de Performance

- **`debug_module.timer_start()`** - Inicia timer
- **`debug_module.timer_end(operation)`** - Termina timer y muestra duración

##### Funciones de Resultado

- **`debug_module.command_result(cmd, result, success)`** - Debug de resultados de comandos

#### Ejemplo de Uso

```lua
local debug = require("kgh_debug")

debug.enable()
debug.success("Operación exitosa")
debug.error("Error encontrado", {code = 500})
debug.timer_start()
-- ... operación ...
debug.timer_end("Operación completa")
```

---

### 🎯 `github.lua`

Orquestador principal que coordina todos los módulos.

#### Flujo de Ejecución

1. **Carga módulos** - config, utils, debug
2. **Inyecta debug** - en utils para evitar dependencias circulares
3. **Parsea argumentos** - detecta flags y comandos
4. **Habilita debug** - si se detecta flag `--debug`
5. **Valida argumentos** - muestra ayuda si no hay argumentos
6. **Determina tipo** - PR, Issue, o genérico
7. **Aplica defaults** - según configuración
8. **Ejecuta comando** - con logging y manejo de errores

#### Comandos Soportados

- **PR commands**: `kgh pr create`, `kgh pr list`, etc.
- **Issue commands**: `kgh issue create`, `kgh issue list`, etc.
- **Comandos genéricos**: Cualquier comando `gh` pasa directamente

#### Ejemplo de Uso

```bash
# Comando con defaults automáticos
kgh pr create --title "Fix bug"
# Se convierte en: gh pr create --title "Fix bug" --base main

# Comando con debug
kgh pr create --title "Fix bug" --debug
# Muestra información detallada del proceso

# Comando genérico
kgh repo clone owner/repo
# Pasa directamente a: gh repo clone owner/repo
```

---

## 🚀 Instalación de Módulos

### Requisitos

- **Lua** (5.1+)
- **GitHub CLI** (`gh`)

### Instalación

```bash
cd lua-lib
sudo ./install.sh
```

### Verificación

```bash
kgh --help
kgh pr create --title "Test" --debug
```

---

## 🔧 Extensión de Módulos

### Agregar Nuevos Defaults

```lua
-- En config.lua
config.pr_defaults = {
    base = "main",
    reviewer = "@tu-usuario",
    label = "enhancement"
}
```

### Agregar Nuevos Comandos

```lua
-- En github.lua
elseif command_type == "release" then
    defaults = config.release_defaults or {}
    debug.info("Aplicando defaults de Release")
    final_command = utils.build_command_with_defaults(parsed.command, parsed.flags, defaults)
```

---

## 🎯 Patrones de Diseño

### Dependency Injection

```lua
-- Evitar dependencias circulares
local debug = require("kgh_debug")
local utils = require("utils")
utils.set_debug(debug)  -- Inyección después de carga
```

### Configuration-Driven

```lua
-- Comportamiento controlado por configuración
local defaults = config.pr_defaults
local final_command = utils.build_command_with_defaults(command, flags, defaults)
```

### Pass-Through Architecture

```lua
-- Comandos desconocidos pasan directamente
if command_type == "unknown" then
    final_command = utils.build_generic_command(args)
end
```

---

*Para más ejemplos y casos de uso, consulta los archivos de ejemplo en el directorio `examples/`.*