# 📖 Guía del Usuario

## 🚀 Introducción

**Dev-Toolkit** es una colección de herramientas CLI que transforma comandos complejos en acciones simples. La primera herramienta disponible es **KGH**, un wrapper inteligente para GitHub CLI que añade configuraciones por defecto y funcionalidades avanzadas.

### 🎯 Objetivo Principal

- **Automatizar** tareas repetitivas
- **Simplificar** comandos complejos
- **Personalizar** comportamientos con configuraciones
- **Aprender** comandos mientras los usas

---

## 🏁 Inicio Rápido

### 1. Instalación

```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/dev-toolkit.git
cd dev-toolkit/lua-lib

# Instalar
sudo ./install.sh

# Verificar
kgh --help
```

### 2. Primer Uso

```bash
# Listar PRs existentes
kgh pr list

# Crear PR con defaults automáticos
kgh pr create --title "Mi primer PR con KGH"

# Ver qué comando se ejecutó realmente
kgh pr create --title "Mi primer PR con KGH" --debug
```

---

## 🔧 KGH - GitHub CLI Wrapper

### ¿Qué es KGH?

KGH es un wrapper inteligente para GitHub CLI (`gh`) que:
- **Añade configuraciones por defecto** (ej: `--base main`)
- **Mantiene compatibilidad completa** con `gh`
- **Proporciona debug detallado** para aprender
- **Permite personalización** total

### Comandos Básicos

#### Pull Requests

```bash
# Crear PR básico
kgh pr create --title "Fix authentication bug"

# Equivale a:
# gh pr create --title "Fix authentication bug" --base main

# Crear PR con más opciones
kgh pr create --title "Add dark mode" --body "Implemented dark theme support"

# Listar PRs
kgh pr list

# Ver PR específico
kgh pr view 123
```

#### Issues

```bash
# Crear issue
kgh issue create --title "Button not working" --body "Description of the problem"

# Listar issues
kgh issue list

# Ver issue específico
kgh issue view 456
```

#### Comandos Genéricos

```bash
# Cualquier comando de gh funciona igual
kgh repo clone owner/repo
kgh auth status
kgh release list
```

---

## 🎨 Personalización

### Configuración Básica

El archivo `lua-lib/config.lua` controla el comportamiento:

```lua
-- config.lua
config.pr_defaults = {
    base = "main",  -- Rama base para PRs
}

config.show_command = true  -- Mostrar comando real
```

### Configuraciones Avanzadas

#### Cambiar Rama Base

```lua
-- Para proyectos que usan 'develop'
config.pr_defaults = {
    base = "develop",
}
```

#### Agregar Reviewer Automático

```lua
config.pr_defaults = {
    base = "main",
    reviewer = "@tu-usuario",
}
```

#### Agregar Label por Defecto

```lua
config.pr_defaults = {
    base = "main",
    label = "enhancement",
}
```

#### Configuración para Issues

```lua
config.issue_defaults = {
    label = "bug",
    assignee = "@tu-usuario",
}
```

---

## 🐛 Modo Debug

### ¿Para qué sirve el Debug?

El modo debug te permite:
- **Aprender** qué comando real se ejecuta
- **Diagnosticar** problemas
- **Verificar** configuraciones
- **Entender** el flujo interno

### Uso del Debug

```bash
# Activar debug con --debug
kgh --debug pr create --title "Test PR"

# Activar debug con -d
kgh -d pr list

# Debug en cualquier comando
kgh pr create --title "Fix bug" --debug
```

### Ejemplo de Output Debug

```bash
$ kgh pr create --title "Fix login bug" --debug

🐛 Modo debug activado
[12:34:56] [SUCCESS] 🐛 Modo debug activado
[12:34:56] [CONFIG] Configuración cargada:
  pr_defaults:
    base = main
  show_command = true
[12:34:56] [INFO] Tipo de comando detectado: pr
[12:34:56] [INFO] Subcomando detectado: create
[12:34:56] [INFO] Aplicando defaults de PR
[12:34:56] [SUCCESS] Default aplicado: --base main
[12:34:56] [CMD] Comando a ejecutar: gh pr create --title "Fix login bug" --base main
🔧 Ejecutando: gh pr create --title "Fix login bug" --base main
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[12:34:58] [PERF] Comando ejecutado tomó 1.234s
[12:34:58] [SUCCESS] Comando ejecutado exitosamente
```

---

## 🎯 Casos de Uso Comunes

### 1. Flujo de Desarrollo Típico

```bash
# 1. Crear rama y hacer cambios
git checkout -b feature/new-feature
# ... hacer cambios ...
git add .
git commit -m "Implement new feature"
git push origin feature/new-feature

# 2. Crear PR con KGH
kgh pr create --title "Add new feature" --body "Description of the new feature"

# 3. Revisar PRs existentes
kgh pr list

# 4. Merge PR desde CLI
kgh pr merge 123
```

### 2. Gestión de Issues

```bash
# Crear issue para bug
kgh issue create --title "Login page not loading" --body "Steps to reproduce..."

# Listar issues abiertas
kgh issue list --state open

# Asignar issue a ti mismo
kgh issue edit 456 --add-assignee @tu-usuario

# Cerrar issue
kgh issue close 456
```

### 3. Release Management

```bash
# Listar releases
kgh release list

# Crear release
kgh release create v1.0.0 --title "Version 1.0.0" --notes "Release notes..."

# Ver release específico
kgh release view v1.0.0
```

### 4. Colaboración en Equipos

```bash
# Revisar PRs de teammates
kgh pr list --author @teammate

# Checkout PR para testing
kgh pr checkout 123

# Aprobar PR
kgh pr review 123 --approve --body "LGTM!"
```

---

## 💡 Tips y Trucos

### 1. Aliases Útiles

Agrega a tu `.bashrc` o `.zshrc`:

```bash
# Shortcuts para comandos frecuentes
alias kpr="kgh pr"
alias kpc="kgh pr create"
alias kpl="kgh pr list"
alias kis="kgh issue"
alias kic="kgh issue create"
alias kil="kgh issue list"

# Debug rápido
alias kghd="kgh --debug"
```

### 2. Plantillas de PR

Crea plantillas para diferentes tipos de PR:

```bash
# Bug fix
kgh pr create --title "Fix: " --body "## Bug Description\n\n## Solution\n\n## Testing"

# Feature
kgh pr create --title "Feature: " --body "## New Feature\n\n## Implementation\n\n## Testing"
```

### 3. Comandos Combinados

```bash
# Crear PR y asignar reviewer en un comando
kgh pr create --title "Fix bug" --reviewer @teammate --label bug

# Crear issue y asignar a ti mismo
kgh issue create --title "New task" --assignee @tu-usuario --label enhancement
```

### 4. Debugging Avanzado

```bash
# Solo debug de configuración
kgh --debug pr create --title "Test" | grep CONFIG

# Debug con output a archivo
kgh --debug pr create --title "Test" 2>&1 | tee debug.log
```

---

## 🔄 Workflows Avanzados

### 1. Automated PR Creation

```bash
#!/bin/bash
# create_pr.sh - Script para crear PR automáticamente

BRANCH=$(git branch --show-current)
TITLE="WIP: ${BRANCH//-/ }"

# Crear PR con título basado en rama
kgh pr create --title "$TITLE" --draft --debug
```

### 2. Issue Triage

```bash
#!/bin/bash
# triage_issues.sh - Script para triaje de issues

# Listar issues sin label
kgh issue list --json number,title,labels | jq '.[] | select(.labels == [])'

# Agregar label automáticamente
kgh issue edit $1 --add-label needs-triage
```

### 3. Release Automation

```bash
#!/bin/bash
# create_release.sh - Script para crear release

VERSION=$1
CHANGELOG=$(git log --oneline $(git describe --tags --abbrev=0)..HEAD)

kgh release create $VERSION --title "Release $VERSION" --notes "$CHANGELOG"
```

---

## 📊 Estadísticas y Monitoreo

### Comandos para Análisis

```bash
# Estadísticas de PRs
kgh pr list --json number,title,state,author | jq 'group_by(.state) | map({state: .[0].state, count: length})'

# PRs por autor
kgh pr list --json author | jq 'group_by(.author.login) | map({author: .[0].author.login, count: length})'

# Issues abiertas por label
kgh issue list --json labels | jq 'map(.labels[].name) | group_by(.) | map({label: .[0], count: length})'
```

---

## 🚨 Solución de Problemas

### Problemas Comunes

#### 1. Comando No Encontrado

```bash
# Verificar instalación
which kgh

# Reinstalar si es necesario
cd dev-toolkit/lua-lib
sudo ./install.sh
```

#### 2. Configuración No Aplicada

```bash
# Verificar configuración con debug
kgh --debug pr create --title "Test"

# Buscar línea CONFIG en el output
```

#### 3. Comando Fallido

```bash
# Usar debug para ver error exacto
kgh --debug pr create --title "Test"

# Verificar autenticación con GitHub
gh auth status
```

### Debug Avanzado

```bash
# Verificar módulos cargados
kgh --debug pr list | grep -E "(CONFIG|PARSE|CMD)"

# Probar comando equivalente con gh
gh pr create --title "Test" --base main

# Verificar permisos del repositorio
gh repo view
```

---

## 📈 Próximos Pasos

### 1. Explorar Funcionalidades

- Lee [`docs/API.md`](./API.md) para entender la API completa
- Experimenta con diferentes configuraciones
- Prueba el modo debug en todos los comandos

### 2. Personalizar tu Flujo

- Modifica `config.lua` según tus necesidades
- Crea aliases personalizados
- Desarrolla scripts de automatización

### 3. Contribuir al Proyecto

- Reporta bugs o solicita features
- Contribuye con mejoras
- Comparte tus configuraciones útiles

---

## 🎓 Recursos Adicionales

- **GitHub CLI Docs**: https://cli.github.com/manual/
- **Lua Tutorial**: https://www.lua.org/pil/
- **Dev-Toolkit Roadmap**: [`Roadmap.md`](../Roadmap.md)
- **Project Vision**: [`VISION.md`](../VISION.md)

---

*¡Feliz automatización! 🚀*