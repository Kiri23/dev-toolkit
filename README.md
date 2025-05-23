# 🛠 Dev-Toolkit

Mi colección personal de herramientas CLI y scripts de automatización.

## 📁 Estructura

```
dev-toolkit/
├── lua-lib/           # Biblioteca Lua y DSL personal
│   └── kgh-wrapper/   # GitHub CLI personalizado
├── python-tools/      # Utilidades Python (emails, APIs)
├── ansible/           # Playbooks de automatización
└── README.md          # Este archivo
```

## 🚀 Herramientas Disponibles

### KGH - GitHub CLI Wrapper
```bash
# Usar
kgh pr create --title "Fix bug"  # Auto-añade --base main
kgh --debug  # Modo debug
```

### Configuration Management (`kgh config`)

The `kgh` tool includes a configuration management system that allows you to customize its behavior. Configuration is stored in `~/.config/kgh/user_config.lua`.

**View Current Configuration**

To see all currently active configuration settings (including defaults merged with your user-specific settings), use:

```bash
kgh config list
```

*Example Output:*
```
pr.base=main
user.name=Your Name
```
*(Actual output will vary based on your settings and defaults.)*

**Get a Specific Configuration Value**

To retrieve a specific configuration value by its key:

```bash
kgh config get pr.base
```
*Example Output:*
```
main
```

To get a value you've set:
```bash
kgh config get user.name
```
*Example Output:*
```
Your Name
```
If the key is not found, `kgh config get` will produce no output.

**Set a Configuration Value**

To set or update a configuration value:

```bash
kgh config set user.name "Your Full Name"
kgh config set pr.reviewer "@yourgithubuser"
kgh config set feature.defaultBranch "develop" 
kgh config set project.id 123
kgh config set enable.notifications true
```

This will create or update the value in your `~/.config/kgh/user_config.lua` file.
Keys are dot-separated to represent structure. For example, `feature.defaultBranch` might be stored in a `feature` table within your Lua config file.

*Example:*
```bash
# Set your name
kgh config set user.name "Jane Doe"

# Verify it's set
kgh config get user.name
# Output: Jane Doe

# Set default PR reviewer
kgh config set pr.reviewer "johndoe"

# List all configs to see it
kgh config list
# Output might include:
# pr.base=main
# pr.reviewer=johndoe
# user.name=Jane Doe
```

**Configuration File Location**

Your personal configurations are stored at: `~/.config/kgh/user_config.lua`.
This is a Lua file that returns a table. You can edit it directly, but using `kgh config set` is generally safer.

*Example `user_config.lua` content:*
```lua
-- kgh user configuration file
return {
  user = {
    name = "Jane Doe"
  },
  pr = {
    reviewer = "johndoe"
  }
}
```
Defaults are merged with these settings at runtime. Your settings in `user_config.lua` will override any default values for the same keys.

### Python Tools
*Coming soon...*

### Ansible Playbooks
*Coming soon...*

## 🎯 Filosofía

Cada comando que aprendo se convierte en:
1. **Script documentado** - Para referencia y reutilización
2. **Función Lua** - Para crear DSL más expresivo
3. **Abstracción útil** - Para simplificar tareas complejas

## 📚 Aprendizaje

Este repositorio es tanto una herramienta como un registro de aprendizaje de:
- Comandos Unix/Linux avanzados
- Bash scripting
- Lua como meta-lenguaje
- Automatización con Python
- Gestión de infraestructura con Ansible

## 🔧 Instalación

The recommended way to install `kgh` and set up its basic configuration is by using the provided Ansible playbook. This requires Ansible to be installed on your system.

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/tu-usuario/dev-toolkit.git
    cd dev-toolkit
    ```
    *(Replace `tu-usuario` with the actual repository owner/path if different.)*

2.  **Run the Ansible playbook:**
    ```bash
    ansible-playbook ansible/install_kgh.yml
    ```
    This playbook will make the `kgh` script executable, create a symbolic link at `/usr/local/bin/kgh` (this may require sudo privileges, which Ansible will handle if configured for `become`), and set up an initial user configuration directory and file at `~/.config/kgh/user_config.lua`.

    If you prefer manual installation or do not have Ansible, you can inspect the `ansible/install_kgh.yml` playbook to see the steps involved (e.g., creating a symlink and the user config file). The old `lua-lib/install.sh` script is no longer the recommended method for installing `kgh`.

---
*Construyendo productividad, un comando a la vez.* ⚡