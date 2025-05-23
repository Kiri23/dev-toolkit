# 🗺 Dev-Toolkit Roadmap

## 🎯 Próximas Funcionalidades

### 1. 🔧 KGH Config Manager (Alta Prioridad)

**Objetivo**: Sistema de configuración como Git
```bash
kgh config set pr.base main
kgh config set pr.reviewer @username
kgh config set pr.label enhancement
kgh config get pr.base
kgh config list
kgh config reset pr
```

**Implementación**:
- Archivo `user_config.lua` generado automáticamente
- Merge con config por defecto en runtime
- Validación de valores antes de guardar

### 2. 🌿 Git Wrapper (kgit)

**Objetivo**: Wrapper para Git con defaults inteligentes
```bash
kgit commit -m "Fix bug"           # Auto-push si está configurado
kgit branch feature/new-thing      # Auto-switch al crear
kgit sync                          # pull + cleanup branches
kgit quick-commit "Quick fix"      # add . + commit + push
```

### 3. 📋 Templates System

**PR Templates**:
```bash
kgh pr create --template bug --title "Fix login"
kgh pr create --template feature --title "Add dark mode"
```

**Issue Templates**:
```bash
kgh issue create --template bug --title "Button not working"
```

### 4. 🤖 Automation Scripts

**Python Tools**:
- Email automation
- API utilities  
- File processing scripts

**Ansible Playbooks**:
- macOS development setup
- Server configuration
- Application deployment

### 5. 🔍 Enhanced Debug System

```bash
kgh --debug-level 2 pr create     # Niveles de debug
kgh --debug-only config pr create # Solo debug de config
kgh pr create --log-file debug.log # Output a archivo
```

## 📅 Timeline

### Phase 1 (Próximas 2 semanas)
- [x] Estructura base de dev-toolkit
- [x] KGH funcionando desde nueva ubicación
- [ ] Config manager para KGH
- [ ] Templates básicos (bug, feature)

### Phase 2 (Próximo mes)
- [ ] Git wrapper (kgit) básico
- [ ] Python tools estructura
- [ ] Ansible playbook para macOS setup

### Phase 3 (Futuro)
- [ ] Analytics y estadísticas
- [ ] Multi-repo support
- [ ] Integración con otras herramientas
- [ ] Sistema de hooks

## 🛠 Implementación Técnica

### Estructura Final
```
dev-toolkit/
├── lua-lib/
│   ├── kgh-wrapper/           # GitHub CLI wrapper
│   ├── kgit-wrapper/          # Git wrapper (futuro)
│   ├── shared/                # Funciones compartidas
│   │   ├── config_manager.lua
│   │   ├── template_engine.lua
│   │   └── debug_system.lua
│   └── templates/             # Templates para PR/issues
├── python-tools/
│   ├── email_automation/
│   ├── api_utilities/
│   └── file_processors/
├── ansible/
│   ├── playbooks/
│   └── roles/
└── install/                   # Scripts de instalación
```

### Binarios a Crear
- `/usr/local/bin/kgh` ✅ (Ya existe)
- `/usr/local/bin/kgit` (Futuro)
- `/usr/local/bin/dev-toolkit` (Meta-comando)

## 🎨 Ideas Avanzadas

### Meta-comando
```bash
dev-toolkit install kgh        # Instalar herramienta específica
dev-toolkit update             # Actualizar todas las herramientas
dev-toolkit list               # Ver herramientas disponibles
dev-toolkit config             # Configuración global
```

### Smart Defaults
```bash
# Auto-detectar tipo de proyecto y aplicar defaults
kgh pr create --smart          # Usa template basado en archivos cambiados
kgit commit --smart            # Genera mensaje basado en diff
```

### Integration Hub
```bash
# Conectar con otras herramientas
kgh pr create --jira PROJ-123
kgh pr create --slack-notify
```

## 🔥 Quick Wins (Fáciles de implementar)

1. **KGH Config Manager** - Extend actual sistema
2. **Basic Git Wrapper** - Similar estructura que KGH
3. **PR Templates** - Solo archivos markdown + lógica simple
4. **Ansible macOS Setup** - Un playbook básico

## 🎯 Objetivos de Aprendizaje

- **Lua avanzado**: Módulos, metaprogramming, DSL design
- **Unix philosophy**: Herramientas pequeñas que hacen una cosa bien
- **Configuration management**: Sistemas flexibles y user-friendly
- **Automation**: Reducir friction en workflows diarios
- **Tool integration**: Conectar herramientas existentes elegantemente

---

*"La mejor herramienta es la que no tienes que pensar para usar"* 🧠