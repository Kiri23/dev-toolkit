# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Vision

This is an ambitious personal toolkit project evolving from basic CLI tools to a sophisticated DSL for DevOps automation. The project follows a **4-layer architecture** designed for progressive enhancement - each layer adds value without breaking previous ones.

### Architecture Layers

1. **Building Blocks** - Pure module wrappers (`filesystem.lua`, `git.lua`, `github.lua`)
2. **Smart Wrappers** - Intelligent CLI tools (`kgh`, `kgit`) with smart defaults  
3. **Programmatic Composition** - Complex workflow scripting
4. **DSL Expression** - Natural language automation syntax (meta-goal)

## Current Implementation Status

**Phase 1 Complete** ✅: KGH wrapper with debug system and modular organization
**Phase 2 In Progress** 🚧: Refactoring to modular architecture with centralized config

## Project Structure

- `lua-lib/kgh-wrapper/` - Current GitHub CLI wrapper (will evolve to modular architecture)
- `python-tools/` - Future Python automation utilities
- `ansible/` - Future infrastructure automation playbooks

## KGH Architecture (Current Implementation)

### Core Components
- `github.lua` - Main orchestrator with dependency injection pattern
- `config.lua` - Configuration-driven defaults system
- `utils.lua` - Command parsing and execution utilities
- `kgh_debug.lua` - Comprehensive debug system
- `install_kgh.sh` - System-wide deployment script

### Key Design Patterns
- **Configuration-driven**: Merge defaults with user arguments
- **Pass-through architecture**: Unknown commands go directly to `gh`
- **Debug injection**: Debug functionality injected after module loading
- **Backward compatibility**: All `gh` commands work unchanged

## Development Commands

### Installation
```bash
cd lua-lib/kgh-wrapper
sudo ./install_kgh.sh
```

### Testing
No formal test suite. Test manually with debug mode:
```bash
kgh --debug pr create --title "Test PR"
```

### Architecture Migration (Phase 2)
When refactoring to modular architecture:
- Split `github.lua` into separate module files
- Implement registry-based dispatcher
- Create centralized config manager
- Maintain backward compatibility

## Development Philosophy

### Core Principles
1. **Progressive Enhancement** - Each layer adds value without breaking previous
2. **Composition over Inheritance** - Small tools that combine into complex functionality  
3. **Learn by Doing** - Every command learned becomes a reusable module
4. **Smart Defaults, Explicit Overrides** - Intelligent behavior with configuration escape hatches

### Code Conventions
- **Spanish documentation** - All README files and comments in Spanish
- **Modular design** - One module = one responsibility
- **Debug-first** - All tools support `--debug` mode
- **Configuration-driven** - Behavior controlled by `config.lua` files

## Planned Evolution

### Immediate Next Steps (Phase 2)
- Refactor monolithic `github.lua` into separate modules
- Implement dispatcher with command registry
- Create `filesystem.lua`, `git.lua`, `openai.lua` modules
- Centralized config management system

### Future Layers (Phase 3-4)
- AI-powered code review integration
- Natural language workflow DSL
- Multi-tool composition patterns
- Context management for complex automations

## Critical Dependencies
- **Lua** - Primary scripting language for all tools
- **GitHub CLI (gh)** - Required for KGH wrapper functionality
- **Pass-through compatibility** - All original tool commands must continue working

## Architecture Goals
The end goal is workflows like:
```lua
workflow "AI Code Review" do
  find_files "*.js" as changed_files
  get_diff from git as current_diff
  ai_review current_diff with context = changed_files
  create_pr with ai_review.title and ai_review.description
end
```

This represents a complete evolution from simple CLI wrappers to an expressive automation DSL.