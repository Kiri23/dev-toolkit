# 🐛 Debugging Lua Scripts - Proceso y Lecciones

## Problema Típico: "attempt to call a nil value"

### 1. Identificar el Error
```bash
lua: /path/script.lua:22: attempt to call a nil value (field 'function_name')
```

**Significa**: La función existe pero es `nil` = módulo no se cargó correctamente.

### 2. Verificar Carga de Módulos

```bash
# Verificar si el archivo existe
ls -la /path/to/module.lua

# Probar carga manual del módulo
lua -e "
package.path = '/path/to/?.lua;' .. package.path
local module = require('module_name')
print('Module loaded:', type(module))
for k,v in pairs(module) do
    print('  ' .. k .. ' = ' .. type(v))
end
"
```

### 3. Conflictos de Nombres Comunes

**❌ Nombres que NO usar:**
- `debug.lua` → conflicto con `debug` built-in de Lua
- `string.lua` → conflicto con `string` built-in
- `math.lua` → conflicto con `math` built-in
- `io.lua` → conflicto con `io` built-in

**✅ Nombres seguros:**
- `kgh_debug.lua`, `logger.lua`, `utils.lua`, `config.lua`

### 4. Dependencias Circulares

**Problema**: `utils.lua` require `debug.lua` y viceversa.

**Solución**: Inyección de dependencias
```lua
-- En utils.lua
local utils = {}
utils.debug = nil
function utils.set_debug(debug_module)
    utils.debug = debug_module
end

-- En main.lua
local utils = require("utils")
local debug = require("kgh_debug")
utils.set_debug(debug)  -- Inyectar después de cargar ambos
```

## Comandos de Debug Rápido

```bash
# Ver argumentos que recibe el script
lua script.lua arg1 arg2  # arg[1] = arg1, arg[2] = arg2

# Debug package.path
lua -e "print(package.path)"

# Verificar módulo específico
lua -e "local m = require('module'); print(type(m))"

# Ver todas las funciones de un módulo
lua -e "for k,v in pairs(require('module')) do print(k,type(v)) end"
```

## Patrón de Debug con Flag

```lua
-- main.lua
local has_debug = false
for _, arg in ipairs(arg) do
    if arg == "--debug" or arg == "-d" then
        has_debug = true
        break
    end
end

if has_debug then
    local debug = require("kgh_debug")
    debug.enable()
    debug.info("Debug activado")
end
```

## Fix Rápido para Conflictos de Nombres

```bash
# Renombrar archivo conflictivo
sudo mv /path/debug.lua /path/kgh_debug.lua

# Actualizar todas las referencias
sudo sed -i.backup 's/require("debug")/require("kgh_debug")/g' /path/*.lua
```

## Estructura Recomendada

```
/usr/local/share/project/
├── main.lua              ← Lógica principal
├── config.lua            ← Configuraciones
├── utils.lua             ← Utilidades (sin dependencias complejas)  
├── kgh_debug.lua         ← Debug (nombre único)
└── project_specific.lua  ← Módulos con prefijo del proyecto
```

**Regla de oro**: Nombrar módulos con prefijo del proyecto para evitar conflictos.