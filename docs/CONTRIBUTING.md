# 🤝 Guía de Contribución

## 🎯 Formas de Contribuir

### 1. 🐛 Reportar Bugs
- Usa el modo debug para obtener información detallada
- Incluye pasos para reproducir el problema
- Menciona tu sistema operativo y versiones de dependencias

### 2. 💡 Solicitar Features
- Describe el problema que resuelve
- Proporciona ejemplos de uso
- Considera si encaja con la filosofía del proyecto

### 3. 📝 Mejorar Documentación
- Corregir errores o ambigüedades
- Agregar ejemplos prácticos
- Traducir documentación

### 4. 🔧 Contribuir Código
- Implementar nuevas funcionalidades
- Optimizar código existente
- Agregar tests y validaciones

---

## 🛠 Configuración del Entorno

### 1. Fork y Clone

```bash
# Fork el repositorio en GitHub
# Luego clona tu fork
git clone https://github.com/tu-usuario/dev-toolkit.git
cd dev-toolkit

# Agregar upstream
git remote add upstream https://github.com/usuario-original/dev-toolkit.git
```

### 2. Dependencias

```bash
# Verificar herramientas necesarias
lua -v        # Lua 5.1+
gh --version  # GitHub CLI
git --version # Git

# Instalar dependencias si es necesario
# macOS
brew install lua gh

# Ubuntu/Debian
sudo apt install lua5.3 gh
```

### 3. Configurar KGH para Desarrollo

```bash
# Crear enlace simbólico para desarrollo
cd lua-lib
sudo ln -sf "$(pwd)/github.lua" /usr/local/bin/kgh-dev

# Crear wrapper temporal
sudo tee /usr/local/bin/kgh-dev > /dev/null << 'EOF'
#!/usr/bin/env lua
package.path = "/ruta/completa/a/dev-toolkit/lua-lib/?.lua;" .. package.path
require("github")
EOF

sudo chmod +x /usr/local/bin/kgh-dev
```

### 4. Verificar Configuración

```bash
# Probar versión de desarrollo
kgh-dev --help
kgh-dev --debug pr list
```

---

## 📋 Estándares de Código

### 1. Convenciones de Lua

```lua
-- Usar nombres descriptivos
local function parse_command_arguments(args)
    -- Lógica clara y comentada
end

-- Comentarios en español
-- Función para construir comando con configuraciones por defecto
local function build_command_with_defaults(base, flags, defaults)
    -- Implementación
end

-- Manejo de errores explícito
local result, error = execute_command(cmd)
if not result then
    debug.error("Error ejecutando comando", error)
    return false
end
```

### 2. Estructura de Módulos

```lua
-- Al inicio: dependencias
local config = require("config")
local utils = require("utils")

-- Luego: variables locales
local module = {}

-- Funciones privadas primero
local function private_helper()
    -- Implementación
end

-- Funciones públicas después
function module.public_function()
    -- Implementación
end

-- Al final: return del módulo
return module
```

### 3. Comentarios y Documentación

```lua
-- Comentarios de función
-- Parsea argumentos de línea de comandos
-- @param args: tabla con argumentos
-- @return parsed: tabla con comando, flags y estado debug
function utils.parse_args(args)
    -- Implementación
end

-- Comentarios inline para lógica compleja
if string.match(current_arg, "^%-%-") then
    -- Es una flag larga (--title)
    -- Buscar valor en el siguiente argumento
end
```

---

## 🔄 Flujo de Desarrollo

### 1. Crear Rama

```bash
# Sincronizar con upstream
git checkout main
git pull upstream main

# Crear rama para tu feature
git checkout -b feature/nueva-funcionalidad
```

### 2. Desarrollar

```bash
# Hacer cambios
nano lua-lib/config.lua

# Probar cambios
kgh-dev --debug pr create --title "Test"

# Commit frecuente
git add .
git commit -m "Add: Nueva configuración para releases"
```

### 3. Testing

```bash
# Probar funcionalidad básica
kgh-dev --help
kgh-dev pr list
kgh-dev pr create --title "Test PR" --debug

# Probar edge cases
kgh-dev --debug
kgh-dev pr create --title "Test con espacios" --debug
```

### 4. Documentar

```bash
# Actualizar documentación relevante
nano docs/API.md
nano docs/USER_GUIDE.md

# Agregar ejemplos de uso
# Documentar cambios en configuración
```

---

## 📝 Crear Pull Request

### 1. Preparar PR

```bash
# Asegurar que todos los cambios están commitados
git status

# Push a tu fork
git push origin feature/nueva-funcionalidad
```

### 2. Template de PR

```markdown
## 🎯 Descripción

Breve descripción de los cambios realizados.

## ✅ Cambios Implementados

- [ ] Nueva funcionalidad X
- [ ] Mejora en módulo Y
- [ ] Documentación actualizada

## 🧪 Testing

- [ ] Probado en macOS/Linux
- [ ] Probado con modo debug
- [ ] Verificado backward compatibility

## 📋 Checklist

- [ ] Código sigue las convenciones
- [ ] Documentación actualizada
- [ ] Tests pasando
- [ ] No breaking changes

## 🔗 Issues Relacionadas

Fixes #123
```

### 3. Información Requerida

- **Título claro**: `Add: Nueva funcionalidad de config manager`
- **Descripción detallada**: Qué hace y por qué es necesario
- **Evidencia**: Screenshots o output de comandos
- **Testing**: Cómo se probó la funcionalidad

---

## 🎨 Tipos de Contribuciones

### 1. 🔧 Nuevas Funcionalidades

#### Agregar Nuevo Comando

```lua
-- En github.lua
elseif command_type == "release" then
    defaults = config.release_defaults or {}
    debug.info("Aplicando defaults de Release")
    final_command = utils.build_command_with_defaults(
        parsed.command, 
        parsed.flags, 
        defaults
    )
```

#### Agregar Nueva Configuración

```lua
-- En config.lua
config.release_defaults = {
    draft = true,
    prerelease = false,
}
```

### 2. 🐛 Bug Fixes

#### Identificar Bug

```bash
# Usar debug para identificar problema
kgh-dev --debug pr create --title "Test"

# Analizar output para encontrar error
```

#### Implementar Fix

```lua
-- Antes (con bug)
if not args or #args == 0 then
    -- No maneja caso edge

-- Después (arreglado)
if not args or #args == 0 or (args and #args == 1 and args[1] == "--debug") then
    -- Maneja caso edge correctamente
```

### 3. 📚 Mejoras de Documentación

#### Agregar Ejemplos

```markdown
### Ejemplo Práctico

```bash
# Comando
kgh pr create --title "Fix bug" --debug

# Output esperado
[INFO] Comando detectado: pr create
[SUCCESS] Default aplicado: --base main
```

#### Corregir Errores

- Revisar typos y errores gramaticales
- Verificar que los ejemplos funcionen
- Actualizar información obsoleta

---

## 🧪 Testing y Validación

### 1. Tests Manuales

```bash
# Test básico
kgh-dev --help

# Test con diferentes argumentos
kgh-dev pr create --title "Test"
kgh-dev pr create --title "Test" --debug
kgh-dev pr create --title "Test con espacios" --debug

# Test de edge cases
kgh-dev --debug
kgh-dev pr --debug
kgh-dev --debug pr
```

### 2. Checklist de Testing

- [ ] Comando funciona sin argumentos
- [ ] Comando funciona con argumentos básicos
- [ ] Modo debug funciona correctamente
- [ ] Configuraciones se aplican correctamente
- [ ] Backward compatibility preservada
- [ ] Manejo de errores funciona

### 3. Validación de Configuración

```bash
# Verificar que config se carga
kgh-dev --debug pr create --title "Test" | grep CONFIG

# Verificar que defaults se aplican
kgh-dev --debug pr create --title "Test" | grep "Default aplicado"
```

---

## 📐 Arquitectura del Proyecto

### 1. Estructura de Módulos

```
lua-lib/
├── github.lua      # Orquestador principal
├── config.lua      # Configuración centralizada
├── utils.lua       # Utilidades y helpers
├── kgh_debug.lua   # Sistema de debug
└── install.sh      # Script de instalación
```

### 2. Flujo de Datos

```
args → parse_args() → apply_defaults() → build_command() → execute()
  ↓
debug.log() en cada paso
```

### 3. Patterns de Diseño

- **Dependency Injection**: `utils.set_debug(debug)`
- **Configuration-driven**: Behavior controlado por `config.lua`
- **Pass-through**: Comandos desconocidos van directo a `gh`

---

## 🎯 Filosofía del Proyecto

### 1. Principios Fundamentales

- **Progressive Enhancement**: Cada capa añade valor
- **Backward Compatibility**: Nunca romper funcionalidad existente
- **Learn by Doing**: Herramientas que enseñan mientras se usan
- **Smart Defaults**: Comportamiento inteligente por defecto

### 2. Criterios de Aceptación

- ¿Añade valor real al usuario?
- ¿Mantiene simplicidad?
- ¿Es consistente con la arquitectura?
- ¿Está bien documentado?

### 3. Evolución del Proyecto

- **Phase 1**: KGH wrapper básico ✅
- **Phase 2**: Arquitectura modular 🚧
- **Phase 3**: Composición inteligente 🔮
- **Phase 4**: DSL expresivo 🌟

---

## 🏷 Proceso de Release

### 1. Versionado

- **Major**: Cambios breaking
- **Minor**: Nuevas funcionalidades
- **Patch**: Bug fixes

### 2. Changelog

```markdown
## [1.2.0] - 2024-01-15

### Added
- Nueva funcionalidad de config manager
- Soporte para releases con defaults

### Changed
- Mejorado sistema de debug

### Fixed
- Corregido parsing de argumentos con espacios
```

---

## 📞 Comunidad y Soporte

### 1. Canales de Comunicación

- **GitHub Issues**: Para bugs y feature requests
- **GitHub Discussions**: Para preguntas y discusiones
- **Pull Requests**: Para contribuciones de código

### 2. Código de Conducta

- Se respetuoso y constructivo
- Ayuda a otros contributors
- Mantén discusiones técnicas centradas
- Celebra los éxitos del equipo

---

## 🎉 Reconocimientos

Los contributors serán reconocidos en:
- README.md del proyecto
- Release notes
- Documentación relevante

---

*¡Gracias por contribuir al Dev-Toolkit! 🚀*