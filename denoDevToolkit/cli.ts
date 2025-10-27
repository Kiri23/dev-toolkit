#!/usr/bin/env -S deno run --allow-run --allow-read
// cli.ts - Dynamic dispatcher for dok CLI
import { assertDocker } from "./core/docker.ts";
import { copyToClipboard } from "./core/clipboard.ts";
import { OutputCapture } from "./core/output.ts";

const HELP_TEXT = `
dok - Docker CLI toolkit

Usage:
  dok <command> [args...] [flags]
  dok --help
  dok help <command>

Flags:
  --copy              Copy command output to clipboard

Commands:
  ps                  List running containers
  swarm               List Swarm containers
  local               List standalone containers
  all                 List all containers (swarm + standalone)
  svc <service>       Inspect a Swarm service
  update              Update dok to the latest version

Examples:
  dok ps              List running containers
  dok ps --copy       List containers and copy to clipboard
  dok swarm           List Swarm containers
  dok local           List standalone containers
  dok all --copy      List all containers and copy output
  dok svc <service>   Inspect a Swarm service
  dok update          Update to the latest version

Run 'dok help <command>' for more information on a specific command.
`;

type CommandModule = {
  meta: { name: string; desc: string; usage?: string };
  requiresDocker?: boolean;
  run: (args: string[]) => Promise<number>;
};

async function resolveCommand(alias: string): Promise<CommandModule | null> {
  const paths = [`./commands/${alias}.ts`, `./commands/docker/${alias}.ts`];

  for (const path of paths) {
    try {
      const module = await import(path);
      return module as CommandModule;
    } catch (e) {
      // Try next path if module not found
      if (e instanceof Error && !e.message.includes("Module not found")) {
        throw e;
      }
    }
  }

  return null;
}

async function showCommandHelp(alias: string): Promise<number> {
  const module = await resolveCommand(alias);

  if (!module) {
    console.error(`Error: command '${alias}' not found`);
    return 1;
  }

  const { meta } = module;
  console.log(`\n${meta.name} - ${meta.desc}`);
  if (meta.usage) {
    console.log(`\nUsage: ${meta.usage}`);
  }
  console.log();

  return 0;
}

/**
 * Parse global flags from arguments
 * @returns Object with flags set and cleaned arguments
 */
function parseGlobalFlags(args: string[]): {
  flags: Set<string>;
  cleanArgs: string[];
} {
  const flags = new Set<string>();
  const cleanArgs: string[] = [];

  for (const arg of args) {
    if (arg.startsWith("--")) {
      const flag = arg.slice(2); // Remove '--'
      flags.add(flag);
    } else {
      cleanArgs.push(arg);
    }
  }

  return { flags, cleanArgs };
}

async function main() {
  const args = Deno.args;

  if (args.length === 0 || args[0] === "--help") {
    console.log(HELP_TEXT);
    Deno.exit(0);
  }

  // Parse global flags
  const { flags, cleanArgs } = parseGlobalFlags(args);

  // Handle help command
  if (cleanArgs[0] === "help") {
    if (cleanArgs.length < 2) {
      console.log(HELP_TEXT);
      Deno.exit(0);
    }
    const code = await showCommandHelp(cleanArgs[1]);
    Deno.exit(code);
  }

  if (cleanArgs.length === 0) {
    console.error("Error: command required");
    console.error("Run 'dok --help' for available commands.");
    Deno.exit(1);
  }

  const alias = cleanArgs[0];
  const commandArgs = cleanArgs.slice(1);

  const module = await resolveCommand(alias);

  if (!module) {
    console.error(`Error: command '${alias}' not found`);
    console.error(`Run 'dok --help' for available commands.`);
    Deno.exit(1);
  }

  // Check if Docker is required
  const requiresDocker = module.requiresDocker ?? true;
  if (requiresDocker) {
    await assertDocker();
  }

  // Execute command with output capture if --copy is enabled
  let code: number;
  if (flags.has("copy")) {
    const capture = new OutputCapture();
    capture.start();

    code = await module.run(commandArgs);

    const output = capture.stop();

    if (code === 0 && output.trim()) {
      const success = await copyToClipboard(output);
      if (success) {
        console.log("\n✓ Output copied to clipboard");
      } else {
        console.error("\n✗ Failed to copy to clipboard");
      }
    }
  } else {
    code = await module.run(commandArgs);
  }

  Deno.exit(code);
}

if (import.meta.main) {
  main();
}
