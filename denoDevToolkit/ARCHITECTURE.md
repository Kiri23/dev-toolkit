# dok - Architecture Documentation

## Overview

`dok` follows a **layered architecture** pattern that separates infrastructure concerns from business logic. This document explains the design decisions and how different components interact.

## 📐 Architectural Layers

```
┌───────────────────────────────────────────────────────────┐
│                     CLI Layer                              │
│                    (cli.ts)                                │
│  • Command routing                                         │
│  • Dynamic module loading                                  │
│  • Permission management                                   │
└────────────────────────┬──────────────────────────────────┘
                         │
┌────────────────────────▼──────────────────────────────────┐
│              Business Logic Layer                          │
│            (commands/docker/*.ts)                          │
│  • Command-specific logic                                  │
│  • Data filtering & transformation                         │
│  • Output formatting decisions                             │
└────────────────────────┬──────────────────────────────────┘
                         │
┌────────────────────────▼──────────────────────────────────┐
│          Infrastructure/Adapter Layer                      │
│              (core/docker.ts)                              │
│  • Docker CLI primitives                                   │
│  • Raw command execution                                   │
│  • Data access abstraction                                 │
└────────────────────────┬──────────────────────────────────┘
                         │
┌────────────────────────▼──────────────────────────────────┐
│             Generic Execution Layer                        │
│                (core/exec.ts)                              │
│  • Generic command runner                                  │
│  • Process management                                      │
│  • Cross-platform compatibility                            │
└───────────────────────────────────────────────────────────┘
```

## 🎯 Key Design Principle

> **`core/docker.ts` provides primitives, `commands/docker/*.ts` implements business logic**

### What does this mean?

- **`core/docker.ts`**: "Here's how to talk to Docker"
- **`commands/docker/*.ts`**: "Here's what to ask Docker and what to do with the answer"

## 📦 Component Breakdown

### 1. `core/exec.ts` - Generic Execution Layer

**Purpose**: Execute any system command, completely agnostic to Docker.

```typescript
// Responsibilities:
runCmd(command, args)           // Execute any CLI command
assertAvailable(command)        // Check if a command exists
```

**Why separate?**: Tomorrow you might want to add `kubectl`, `podman`, or `systemctl` commands. This layer doesn't care what you're executing.

### 2. `core/docker.ts` - Docker Adapter Layer

**Purpose**: Provide **reusable Docker primitives** that multiple commands can use.

```typescript
// Docker-specific primitives:
docker(args)                    // Execute docker with any args
listPs(format)                  // Get container list (raw)
inspectLabel(id, label)         // Get a specific label (raw)
assertDocker()                  // Verify Docker is available
```

**Key Insight**: These are **dumb data fetchers**. They don't know or care:
- How the data will be used
- What filters to apply
- How to format output
- What business rules exist

They just say: "Here's the raw data you asked for."

### 3. `commands/docker/*.ts` - Business Logic Layer

**Purpose**: Implement **smart commands** with specific business requirements.

Each command file is a **complete feature** that:
1. Calls primitives from `core/docker.ts`
2. Applies business logic (filtering, validation, transformation)
3. Formats and presents results

#### Example: `commands/docker/swarm.ts`

```typescript
export async function run() {
  // 1. Get raw data using primitive
  const { stdout } = await listPs(format);
  
  // 2. Parse into structured data
  const allContainers = parseContainers(stdout);
  
  // 3. BUSINESS LOGIC: Filter only Swarm containers
  const swarmContainers = [];
  for (const container of allContainers) {
    const label = await inspectLabel(container.ID, "com.docker.swarm.service.name");
    if (label && label !== "<no value>") {
      swarmContainers.push(container);  // ← Business rule!
    }
  }
  
  // 4. Present results
  printTitle("Swarm containers");
  printTable(swarmContainers, columns);
}
```

## 🔄 Data Flow Example

Let's trace how `dok swarm` works:

```
User runs: dok swarm
      │
      ▼
┌─────────────────────────────────┐
│ cli.ts                          │
│ • Resolves "swarm" command      │
│ • Loads commands/docker/swarm.ts│
│ • Calls run()                   │
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│ commands/docker/swarm.ts        │
│ ┌─────────────────────────────┐ │
│ │ 1. Call listPs()            │ │───┐
│ └─────────────────────────────┘ │   │
└─────────────────────────────────┘   │
                                      │
             ┌────────────────────────┘
             ▼
┌─────────────────────────────────┐
│ core/docker.ts                  │
│ ┌─────────────────────────────┐ │
│ │ listPs(format)              │ │───┐
│ │ • docker(["ps", format])    │ │   │
│ └─────────────────────────────┘ │   │
└─────────────────────────────────┘   │
                                      │
             ┌────────────────────────┘
             ▼
┌─────────────────────────────────┐
│ core/exec.ts                    │
│ ┌─────────────────────────────┐ │
│ │ runCmd("docker", args)      │ │
│ │ • Deno.Command()            │ │
│ │ • Returns stdout            │ │
│ └─────────────────────────────┘ │
└────────────┬────────────────────┘
             │
             ▼ Raw output
┌─────────────────────────────────┐
│ commands/docker/swarm.ts        │
│ ┌─────────────────────────────┐ │
│ │ 2. Parse containers         │ │
│ │ 3. For each container:      │ │
│ │    • Call inspectLabel()    │ │──┐
│ │    • Filter if has label    │ │  │
│ │ 4. Format & print           │ │  │
│ └─────────────────────────────┘ │  │
└─────────────────────────────────┘  │
                                     │
                    ┌────────────────┘
                    ▼
     ┌─────────────────────────────────┐
     │ core/docker.ts                  │
     │ inspectLabel(id, label)         │
     │ • Returns raw label value       │
     └─────────────────────────────────┘
```

## 💡 Why This Architecture?

### 1. **Reusability**

Multiple commands share the same primitives:

```typescript
// core/docker.ts - Write once
listPs()
inspectLabel()

// Used by:
ps.ts       → listPs()
swarm.ts    → listPs() + inspectLabel()
local.ts    → listPs() + inspectLabel()
all.ts      → listPs() + inspectLabel()
```

Without this separation, each command would duplicate the Docker CLI calls.

### 2. **Testability**

You can mock `core/docker.ts` to test business logic in commands:

```typescript
// In tests
mock(listPs, () => ({ stdout: "fake||data||here" }));

// Now test swarm.ts logic without calling real Docker
```

### 3. **Maintainability**

If Docker changes output format:
- ✅ Fix `core/docker.ts` once
- ✅ All commands continue working

If you want to change how Swarm containers are identified:
- ✅ Fix `commands/docker/swarm.ts` only
- ✅ Other commands unaffected

### 4. **Extensibility**

Adding a new command is trivial:

```typescript
// commands/docker/stopped.ts
import { docker } from "../../core/docker.ts";

export async function run() {
  // Use existing primitive with different args
  const { stdout } = await docker(["ps", "-a", "--filter", "status=exited"]);
  // Add your specific logic here
}
```

No need to touch `core/docker.ts` or other commands.

### 5. **Single Responsibility Principle**

Each layer has ONE job:

| Layer | Responsibility | Doesn't Care About |
|-------|---------------|-------------------|
| `core/exec.ts` | Execute commands | What command it is |
| `core/docker.ts` | Docker CLI interface | How data is used |
| `commands/*.ts` | Business logic | How Docker CLI works |
| `core/format.ts` | Pretty output | What data means |

## 🔍 Real-World Comparison

Think of it like a restaurant:

```
┌──────────────────────────────────────┐
│ Customer (cli.ts)                    │  "I want a burger"
└────────────┬─────────────────────────┘
             │
             ▼
┌──────────────────────────────────────┐
│ Chef (commands/docker/burger.ts)     │  "I'll make it special"
│ • Decides what ingredients           │  • Adds secret sauce
│ • Cooks with specific technique      │  • Plates beautifully
│ • Applies special seasoning          │
└────────────┬─────────────────────────┘
             │
             ▼
┌──────────────────────────────────────┐
│ Pantry (core/docker.ts)              │  "Here are ingredients"
│ • getBread()                         │  • Just hands over items
│ • getMeat()                          │  • Doesn't cook
│ • getCheese()                        │  • Doesn't season
└────────────┬─────────────────────────┘
             │
             ▼
┌──────────────────────────────────────┐
│ Suppliers (core/exec.ts)             │  "Here's raw food"
│ • Generic delivery service           │
└──────────────────────────────────────┘
```

- **Suppliers** don't care what restaurant they deliver to
- **Pantry** stores ingredients, doesn't cook
- **Chef** combines ingredients with skill and creativity
- **Customer** just orders what they want

## 📝 Command Convention

Every command in `commands/` follows this contract:

```typescript
// Meta information for help system
export const meta = {
  name: "commandname",
  desc: "What this command does",
  usage: "dok commandname [options]",
};

// Whether Docker is required (default: true)
export const requiresDocker = true;

// Main entry point
export async function run(args: string[]): Promise<number> {
  // 1. Get data from core/docker.ts
  // 2. Apply business logic
  // 3. Format and output
  // 4. Return exit code
  return 0;
}
```

This convention allows the CLI dispatcher to work without hardcoded knowledge of commands.

## 🚀 Adding New Features

### Adding a new Docker command

1. Create `commands/docker/mycommand.ts`
2. Import primitives from `core/docker.ts`
3. Implement your logic
4. Done! No changes to `cli.ts` needed

### Adding a new primitive

1. Add function to `core/docker.ts`
2. Use it in any command
3. Other commands can now use it too

### Adding a non-Docker command

1. Create new adapter like `core/kubectl.ts`
2. Create `commands/k8s/mycommand.ts`
3. Set `requiresDocker = false`
4. Everything just works!

## 🎓 Summary

The architecture of `dok` is built on **separation of concerns**:

- **`core/`** = "How to do things" (infrastructure)
- **`commands/`** = "What to do and why" (business logic)

This makes the codebase:
- ✅ Easy to understand
- ✅ Easy to test
- ✅ Easy to extend
- ✅ Easy to maintain

Each layer can evolve independently without breaking others. This is the power of good architecture! 🎯

