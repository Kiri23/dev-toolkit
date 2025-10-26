// core/clipboard.ts

/**
 * Copies text to clipboard using platform-specific command
 */
export async function copyToClipboard(text: string): Promise<boolean> {
  const encoder = new TextEncoder();
  const data = encoder.encode(text);

  // Detect platform
  const os = Deno.build.os;

  let command: string[];
  if (os === "darwin") {
    command = ["pbcopy"];
  } else if (os === "linux") {
    // Try xclip first
    command = ["xclip", "-selection", "clipboard"];
  } else if (os === "windows") {
    command = ["clip"];
  } else {
    console.error("Clipboard copy not supported on this platform");
    return false;
  }

  try {
    const process = new Deno.Command(command[0], {
      args: command.slice(1),
      stdin: "piped",
      stdout: "null",
      stderr: "piped",
    });

    const child = process.spawn();
    const writer = child.stdin.getWriter();
    await writer.write(data);
    await writer.close();

    const { success } = await child.status;
    return success;
  } catch (error) {
    if (error instanceof Error) {
      console.error(`Failed to copy to clipboard: ${error.message}`);
    }
    return false;
  }
}
