#!/usr/bin/env -S deno run --allow-run --allow-read
// cli.ts - Dynamic dispatcher for dok CLI
import { assertDocker } from "./core/docker.ts";

const HELP_TEXT = `
dok - Docker CLI toolkit

Usage:
  dok <command> [args...]
  dok --help
  dok help <command>

Examples:
  dok ps              List running containers
  dok swarm           List Swarm containers
  dok local           List standalone containers
  dok all             List all containers (grouped)
  dok svc <service>   Inspect a Swarm service

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

async function main() {
  const args = Deno.args;

  if (args.length === 0 || args[0] === "--help") {
    console.log(HELP_TEXT);
    Deno.exit(0);
  }

  if (args[0] === "help") {
    if (args.length < 2) {
      console.log(HELP_TEXT);
      Deno.exit(0);
    }
    const code = await showCommandHelp(args[1]);
    Deno.exit(code);
  }

  const alias = args[0];
  const commandArgs = args.slice(1);

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

  const code = await module.run(commandArgs);
  Deno.exit(code);
}

if (import.meta.main) {
  main();
}
