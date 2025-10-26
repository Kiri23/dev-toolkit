#!/usr/bin/env -S deno run --allow-run=docker
// commands/docker/local.ts
import { listPs, inspectLabel } from "../../core/docker.ts";
import { printTable, printTitle } from "../../core/format.ts";

export const meta = {
  name: "local",
  desc: "List only standalone containers (without com.docker.swarm.service.name label)",
  usage: "dok local",
};

export const requiresDocker = true;

type Container = {
  ID: string;
  NAME: string;
  IMAGE: string;
  PORTS: string;
};

/**
 * Gets and filters standalone containers (composable function)
 */
export async function getData(): Promise<Container[]> {
  const format = "{{.ID}}||{{.Names}}||{{.Image}}||{{.Ports}}";
  const { code, stdout, stderr } = await listPs(format);
  if (code !== 0) {
    console.error(stderr.trim() || "docker ps falló");
    return [];
  }

  const allContainers = stdout
    .trim()
    .split("\n")
    .filter(Boolean)
    .map((line) => {
      const [id, name, image, ports] = line.split("||");
      return {
        ID: id ?? "",
        NAME: name ?? "",
        IMAGE: image ?? "",
        PORTS: ports ?? "",
      };
    });

  // Filter only standalone containers (those without the label)
  const standaloneContainers = [];
  for (const container of allContainers) {
    const label = await inspectLabel(
      container.ID,
      "com.docker.swarm.service.name",
    );
    if (!label || label === "<no value>") {
      standaloneContainers.push(container);
    }
  }

  return standaloneContainers;
}

/**
 * Displays standalone containers (composable function)
 */
export function display(containers: Container[]): void {
  printTitle("Standalone containers");
  printTable(containers, [
    { key: "ID", header: "ID", width: 12 },
    { key: "NAME", header: "NAME", width: 34 },
    { key: "IMAGE", header: "IMAGE", width: 28 },
    { key: "PORTS", header: "PORTS", width: 28 },
  ]);
}

/**
 * Main command entry point (for standalone use)
 */
export async function run(_: string[] = []): Promise<number> {
  const containers = await getData();
  display(containers);
  return 0;
}

if (import.meta.main) {
  run(Deno.args).then((code) => Deno.exit(code));
}
