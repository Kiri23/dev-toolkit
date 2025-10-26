// core/exec.ts
export type ExecResult = { code: number; stdout: string; stderr: string };
const td = new TextDecoder();

export async function runCmd(
  command: string,
  args: string[],
): Promise<ExecResult> {
  console.log(`Running command: ${formatCommand(command, args)}`);
  const cmd = new Deno.Command(command, {
    args,
    stdout: "piped",
    stderr: "piped",
  });
  const { code, stdout, stderr } = await cmd.output();
  return { code, stdout: td.decode(stdout), stderr: td.decode(stderr) };
}

export async function assertAvailable(
  command: string,
  versionArgs: string[] = ["--version"],
): Promise<void> {
  const { code, stderr } = await runCmd(command, versionArgs);
  if (code !== 0) {
    console.error(
      stderr.trim() ||
        `Error: ${command} CLI no disponible. Instálalo o agrega al PATH.`,
    );
    Deno.exit(1);
  }
}


/**
 * Formats a command and its args as a copy-paste ready shell command
 */
function formatCommand(command: string, args: string[]): string {
    return `${command} ${args.map(shellEscape).join(" ")}`;
}

/**
 * Escapes a shell argument to make it safe for copy-paste
 */
function shellEscape(arg: string): string {
    // If argument contains special chars, wrap in single quotes
    // and escape any single quotes inside
    if (/[\s'"{}|&;<>()$`\\*?[\]#~]/.test(arg)) {
      return `'${arg.replace(/'/g, "'\\''")}'`;
    }
    return arg;
}