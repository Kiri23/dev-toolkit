// core/docker.ts
import { runCmd, assertAvailable, type ExecResult } from "./exec.ts";

export async function assertDocker(): Promise<void> {
  await assertAvailable("docker", [
    "version",
    "--format",
    "{{.Client.Version}}",
  ]);
}

export async function docker(args: string[]): Promise<ExecResult> {
  return await runCmd("docker", args);
}

export async function listPs(
  format: string = "{{.ID}}||{{.Names}}||{{.Image}}||{{.Ports}}",
): Promise<ExecResult> {
  return await docker(["ps", "--format", format]);
}

export async function inspectLabel(id: string, label: string): Promise<string> {
  const { stdout } = await docker([
    "inspect",
    "-f",
    `{{ index .Config.Labels "${label}" }}`,
    id,
  ]);
  return stdout.trim();
}
