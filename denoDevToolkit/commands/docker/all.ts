#!/usr/bin/env -S deno run --allow-run=docker
// commands/docker/all.ts
import * as swarmCmd from "./swarm.ts";
import * as localCmd from "./local.ts";

export const meta = {
  name: "all",
  desc: "List all containers grouped by type (Swarm and Standalone)",
  usage: "dok all",
};

export const requiresDocker = true;

/**
 * Composed command that uses other commands
 */
export async function run(_: string[] = []): Promise<number> {
  // Get data from both commands
  const swarmContainers = await swarmCmd.getData();
  const localContainers = await localCmd.getData();

  // Display using each command's display function
  swarmCmd.display(swarmContainers);
  localCmd.display(localContainers);

  return 0;
}

if (import.meta.main) {
  run(Deno.args).then((code) => Deno.exit(code));
}
