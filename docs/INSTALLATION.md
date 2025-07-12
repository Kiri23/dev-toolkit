# 🚀 Guía de Instalación

## 📋 Requisitos Previos

### 1. Herramientas Necesarias

```bash
# Verificar si están instaladas
lua -v        # Lua 5.1+
gh --version  # GitHub CLI
git --version # Git
```

### 2. Instalación de Dependencias

#### macOS (Homebrew)
```bash
# Instalar Lua
brew install lua

# Instalar GitHub CLI
brew install gh

# Autenticarse con GitHub
gh auth login
```

#### Ubuntu/Debian
```bash
# Instalar Lua
sudo apt update
sudo apt install lua5.3

# Instalar GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Autenticarse con GitHub
gh auth login
```

#### Arch Linux
```bash
# Instalar Lua
sudo pacman -S lua

# Instalar GitHub CLI
sudo pacman -S github-cli

# Autenticarse con GitHub
gh auth login
```

---

## 🔧 Instalación de Dev-Toolkit

### 1. Clonar el Repositorio

```bash
cd ~/Documents
git clone https://github.com/tu-usuario/dev-toolkit.git
cd dev-toolkit
```

### 2. Configurar KGH

```bash
cd lua-lib
sudo ./install.sh
```

### 3. Verificar Instalación

```bash
# Verificar que kgh está disponible
which kgh
# Debería mostrar: /usr/local/bin/kgh

# Probar funcionamiento básico
kgh --help
```

---

## ⚙️ Configuración

### 1. Configuración Básica

El archivo `lua-lib/config.lua` contiene la configuración por defecto:

```lua
-- config.lua
config.pr_defaults = {
    base = "main",
    -- Agregar más configuraciones aquí
}

config.issue_defaults = {
    -- Configuraciones para issues
}

config.show_command = true  -- Mostrar comando real ejecutado
```

### 2. Personalización

#### Cambiar Rama Base por Defecto

```lua
-- En config.lua
config.pr_defaults = {
    base = "develop",  -- Cambiar de "main" a "develop"
}
```

#### Agregar Reviewer por Defecto

```lua
-- En config.lua
config.pr_defaults = {
    base = "main",
    reviewer = "@tu-usuario",
}
```

#### Agregar Label por Defecto

```lua
-- En config.lua
config.pr_defaults = {
    base = "main",
    label = "enhancement",
}
```

### 3. Configuración de Path

Si tienes el proyecto en una ubicación diferente, edita el ejecutable:

```bash
sudo nano /usr/local/bin/kgh
```

Cambia la línea del `package.path` para apuntar a tu ubicación:

```lua
local home = os.getenv("HOME")
package.path = home .. "/tu-ruta/dev-toolkit/lua-lib/?.lua;" .. package.path
```

---

## 🧪 Verificación y Pruebas

### 1. Pruebas Básicas

```bash
# Mostrar ayuda
kgh --help

# Listar PRs (comando genérico)
kgh pr list

# Crear PR con debug
kgh pr create --title "Test PR" --debug
```

### 2. Verificar Defaults

```bash
# Crear PR - debería usar --base main automáticamente
kgh pr create --title "Test PR" --debug

# Verificar en el output que se agregó "--base main"
```

### 3. Pruebas de Debug

```bash
# Activar debug con --debug
kgh --debug pr list

# Activar debug con -d
kgh -d pr list

# Debug con comando específico
kgh pr create --title "Test" --debug
```

---

## 🔧 Troubleshooting

### Problema: "kgh: command not found"

**Solución:**
```bash
# Verificar que el archivo existe
ls -la /usr/local/bin/kgh

# Verificar permisos
ls -la /usr/local/bin/kgh

# Reinstalar si es necesario
cd dev-toolkit/lua-lib
sudo ./install.sh
```

### Problema: "Error: GitHub CLI (gh) no está instalado"

**Solución:**
```bash
# Instalar GitHub CLI
brew install gh

# Verificar instalación
gh --version
```

### Problema: "Error: Lua no está instalado"

**Solución:**
```bash
# macOS
brew install lua

# Ubuntu/Debian
sudo apt install lua5.3

# Verificar instalación
lua -v
```

### Problema: "module 'config' not found"

**Causa:** El path en el ejecutable no apunta a la ubicación correcta.

**Solución:**
```bash
# Editar el ejecutable
sudo nano /usr/local/bin/kgh

# Verificar que el path es correcto
local home = os.getenv("HOME")
package.path = home .. "/ruta-correcta/dev-toolkit/lua-lib/?.lua;" .. package.path
```

### Problema: "Permission denied"

**Solución:**
```bash
# Asegurar que el archivo sea ejecutable
sudo chmod +x /usr/local/bin/kgh

# Verificar permisos
ls -la /usr/local/bin/kgh
```

### Problema: Debug no funciona

**Verificación:**
```bash
# Probar con flag explícito
kgh --debug pr list

# Verificar que el módulo de debug se carga
kgh pr create --title "Test" --debug
```

---

## 🔄 Actualización

### 1. Actualizar Código

```bash
cd ~/Documents/dev-toolkit
git pull origin main
```

### 2. Reinstalar (si es necesario)

```bash
cd lua-lib
sudo ./install.sh
```

### 3. Verificar Cambios

```bash
kgh --help
kgh pr create --title "Test" --debug
```

---

## 🗑 Desinstalación

### 1. Remover Ejecutable

```bash
sudo rm /usr/local/bin/kgh
```

### 2. Remover Repositorio

```bash
rm -rf ~/Documents/dev-toolkit
```

### 3. Verificar Desinstalación

```bash
which kgh
# No debería encontrar nada
```

---

## 📁 Estructura de Archivos

```
dev-toolkit/
├── lua-lib/
│   ├── config.lua       # Configuración
│   ├── utils.lua        # Utilidades
│   ├── kgh_debug.lua    # Sistema de debug
│   ├── github.lua       # Orquestador principal
│   └── install.sh       # Script de instalación
├── docs/
│   ├── API.md           # Documentación de API
│   └── INSTALLATION.md  # Esta guía
└── /usr/local/bin/kgh   # Ejecutable instalado
```

---

## 🎯 Próximos Pasos

1. **Explorar la documentación**: Lee [`docs/API.md`](./API.md) para entender la API
2. **Personalizar configuración**: Modifica `config.lua` según tus necesidades
3. **Crear aliases**: Agrega shortcuts a tu `.bashrc` o `.zshrc`
4. **Contribuir**: Lee la guía de contribución si quieres ayudar

---

## 🆘 Soporte

Si tienes problemas:

1. **Verifica requisitos**: Asegúrate de tener Lua y GitHub CLI instalados
2. **Revisa logs**: Usa `--debug` para ver información detallada
3. **Consulta documentación**: Revisa [`docs/API.md`](./API.md)
4. **Reporta issues**: Crea un issue en el repositorio

---

*¡Listo para usar KGH! 🚀*