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

    // If xclip fails on Linux (e.g., no display), fallback to OSC 52
    if (!success && os === "linux") {
      return copyUsingOSC52(text);
    }

    return success;
  } catch (error) {
    // If command not found on Linux, try OSC 52
    if (os === "linux") {
      return copyUsingOSC52(text);
    }
    if (error instanceof Error) {
      console.error(`Failed to copy to clipboard: ${error.message || error}`);
    }
    return false;
  }
}

/**
 * Copies text using OSC 52 escape sequences (works over SSH/headless)
 *
 * OSC 52 is an ANSI escape sequence that allows terminal programs to set
 * the clipboard on the local machine, even when connected via SSH.
 * The terminal emulator intercepts the sequence and updates the local clipboard.
 * Format: ESC]52;c;<base64_text>BEL
 */
function copyUsingOSC52(text: string): boolean {
  try {
    // Encode text to UTF-8 bytes first, then to base64
    const encoder = new TextEncoder();
    const data = encoder.encode(text);

    // Convert Uint8Array to base64 (handling UTF-8 correctly)
    let binary = "";
    for (let i = 0; i < data.length; i++) {
      binary += String.fromCharCode(data[i]);
    }
    const base64 = btoa(binary);

    // OSC 52 escape sequence: \x1b]52;c;<base64>\x07
    const osc52 = `\x1b]52;c;${base64}\x07`;

    // Write directly to stdout
    Deno.stdout.writeSync(new TextEncoder().encode(osc52));
    return true;
  } catch (_error) {
    console.error(
      "Failed to copy using OSC 52. Error: ",
      _error instanceof Error ? _error.message : _error,
    );
    return false;
  }
}
