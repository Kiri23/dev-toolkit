# dok - Docker CLI Toolkit

A lightweight, fast CLI tool for Docker container management built with Deno.

## Features

- 🚀 Dynamic command dispatcher (no hardcoded registry)
- 📦 Compiles to a single binary (no Deno runtime required on target)
- 🔒 Minimal permissions (only `--allow-run` in binary)
- 🎯 Clean, table-based output
- 🔧 Extensible architecture

## Installation

### Method 1: Using install.sh (Recommended)

```bash
chmod +x install.sh
./install.sh
```

This will compile the binary and install it to `/usr/local/bin/dok`.

### Method 2: Manual compilation

```bash
deno task compile
sudo mv dok /usr/local/bin/
```

### Method 3: Run directly with Deno

```bash
deno run --allow-run --allow-read cli.ts <command>
```

## Usage

```bash
# List running containers
dok ps

# List only Swarm containers
dok swarm

# List only standalone containers
dok local

# List all containers (grouped by type)
dok all

# Inspect a Swarm service
dok svc <service-name>

# Get help
dok --help
dok help <command>
```

## Commands

### `dok ps`
List all running Docker containers with ID, name, image, and ports.

### `dok swarm`
List only containers that are part of Docker Swarm (have `com.docker.swarm.service.name` label).

### `dok local`
List only standalone containers (not part of Swarm).

### `dok all`
List all containers grouped by type (Swarm and Standalone).

### `dok svc <service>`
Inspect a Swarm service, showing:
1. Service tasks (ID, node, desired state, current state, ports)
2. Running containers for the service

## Development

### Prerequisites

- Deno 1.x or higher
- Docker CLI

### Running in development

```bash
# Run with help
deno task dev

# Run a specific command
deno task run ps
```

### Project Structure

```
denoDevToolkit/
├── cli.ts                    # Main dispatcher
├── deno.json                 # Task definitions
├── install.sh                # Installation script
├── core/
│   ├── exec.ts              # Generic command execution
│   ├── docker.ts            # Docker-specific adapter
│   └── format.ts            # Output formatting
└── commands/
    └── docker/
        ├── ps.ts            # List containers
        ├── swarm.ts         # List Swarm containers
        ├── local.ts         # List standalone containers
        ├── all.ts           # List all (grouped)
        └── svc.ts           # Inspect service
```

### Architecture

The project follows a **layered architecture** pattern that separates infrastructure concerns from business logic:

- **`core/`** provides reusable primitives/commands (data access layer)
- **`commands/`** implements post processing for the data returned by the primitives/commands (application layer)

This separation makes the codebase modular, testable, and maintainable. For a detailed explanation of the architecture, design decisions, and data flow, see [ARCHITECTURE.md](./ARCHITECTURE.md).

## Adding New Commands

To add a new command, create a file in `commands/` or `commands/docker/` with this structure:

```typescript
export const meta = {
  name: "mycommand",
  desc: "Description of my command",
  usage: "dok mycommand [args]",
};

export const requiresDocker = true; // optional, defaults to true
export async function getData(): Promise<any> {
  // Your raw command execution logic here
  return []; // Return the data as an array of objects
}
export function display(data: any): void {
  // Your display logic here
  // Use the printTable and printTitle functions from the core/format.ts file
  printTitle("My command");
  const columns = [
    { key: "ID", header: "ID", width: 12 },
    { key: "NAME", header: "NAME", width: 34 },
  ];
  printTable(data, columns);
}
export async function run(args: string[]): Promise<number> {
  // Your command logic here
  const data = await getData();
  display(data);
  return 0; // Return exit code
}
```

No changes to `cli.ts` are needed - the dispatcher will automatically discover your command!

## Binary Distribution

The compiled binary includes the Deno runtime and all dependencies. It can run on any compatible system without requiring Deno to be installed.

The binary only requires `--allow-run` permission, which is baked into the compilation. No additional permissions are needed at runtime.

## License

MIT

