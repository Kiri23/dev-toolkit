#!/usr/bin/env -S deno run --allow-run=docker
// commands/docker/svc.ts
import { docker } from "../../core/docker.ts";
import { printTable, printTitle } from "../../core/format.ts";

export const meta = {
  name: "svc",
  desc: "Inspect a Swarm service (tasks + containers)",
  usage: "dok svc <service>",
};

export const requiresDocker = true;

export async function run(args: string[] = []): Promise<number> {
  if (args.length === 0) {
    console.error("Error: service name required");
    console.error(`Usage: ${meta.usage}`);
    return 1;
  }

  const service = args[0];

  // Table 1: docker service ps
  const taskFormat =
    "TASK={{.ID}}||NODE={{.Node}}||DESIRED={{.DesiredState}}||CURRENT={{.CurrentState}}||PORTS={{.Ports}}";
  const {
    code: code1,
    stdout: stdout1,
    stderr: stderr1,
  } = await docker([
    "service",
    "ps",
    service,
    "--no-trunc",
    "--format",
    taskFormat,
  ]);

  if (code1 !== 0) {
    console.error(stderr1.trim() || `docker service ps ${service} falló`);
    return code1 || 1;
  }

  const tasks = stdout1
    .trim()
    .split("\n")
    .filter(Boolean)
    .map((line) => {
      const parts = line.split("||");
      const result: Record<string, string> = {};
      for (const part of parts) {
        const [key, ...valueParts] = part.split("=");
        result[key] = valueParts.join("=");
      }
      return result;
    });

  printTitle(`Service: ${service} - Tasks`);
  printTable(tasks, [
    { key: "TASK", header: "TASK", width: 25 },
    { key: "NODE", header: "NODE", width: 20 },
    { key: "DESIRED", header: "DESIRED", width: 12 },
    { key: "CURRENT", header: "CURRENT", width: 30 },
    { key: "PORTS", header: "PORTS", width: 20 },
  ]);

  // Table 2: docker ps --filter
  const containerFormat = "{{.ID}}||{{.Names}}||{{.Image}}||{{.Ports}}";
  const {
    code: code2,
    stdout: stdout2,
    stderr: stderr2,
  } = await docker([
    "ps",
    "--filter",
    `label=com.docker.swarm.service.name=${service}`,
    "--format",
    containerFormat,
  ]);

  if (code2 !== 0) {
    console.error(stderr2.trim() || `docker ps --filter falló`);
    return code2 || 1;
  }

  const containers = stdout2
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

  printTitle(`Service: ${service} - Containers`);
  printTable(containers, [
    { key: "ID", header: "ID", width: 12 },
    { key: "NAME", header: "NAME", width: 34 },
    { key: "IMAGE", header: "IMAGE", width: 28 },
    { key: "PORTS", header: "PORTS", width: 28 },
  ]);

  return 0;
}

if (import.meta.main) {
  run(Deno.args).then((code) => Deno.exit(code));
}
