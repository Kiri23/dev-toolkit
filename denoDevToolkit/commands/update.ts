// commands/update.ts
export const meta = {
  name: "update",
  desc: "Update dok to the latest version from GitHub",
  usage: "dok update",
};

export const requiresDocker = false;

const GITHUB_BASE_URL =
  "https://raw.githubusercontent.com/Kiri23/dev-toolkit/main/denoDevToolkit";

export async function run(_args: string[]): Promise<number> {
  console.log("🔄 Updating dok to the latest version...\n");

  // Detectar OS y arquitectura (built-in de Deno!)
  const os = Deno.build.os; // "linux", "darwin", "windows"
  const arch = Deno.build.arch; // "x86_64", "aarch64"

  // Mapear a nombres de binarios
  const archName = arch === "x86_64" ? "x64" : "arm64";
  const binaryName = `dok-${os}-${archName}`;
  const downloadUrl = `${GITHUB_BASE_URL}/${binaryName}`;

  console.log(`📦 Downloading: ${binaryName}`);
  console.log(`🔗 From: ${downloadUrl}\n`);

  try {
    // Descargar el binario
    const response = await fetch(downloadUrl);
    if (!response.ok) {
      console.error(`❌ Failed to download: HTTP ${response.status}`);
      return 1;
    }

    const binaryData = await response.arrayBuffer();
    const tempPath = "/tmp/dok_update";

    // Escribir a archivo temporal
    await Deno.writeFile(tempPath, new Uint8Array(binaryData));
    await Deno.chmod(tempPath, 0o755);

    // Obtener path del binario actual
    const currentBinaryPath = Deno.execPath();
    console.log(`📝 Replacing: ${currentBinaryPath}`);

    // Intentar reemplazar el binario
    try {
      await Deno.rename(tempPath, currentBinaryPath);
      console.log("\n✅ Update successful!");
      return 0;
    } catch (error) {
      // Si falla por permisos, usar sudo
      if (error instanceof Deno.errors.PermissionDenied) {
        console.log("🔐 Requesting sudo privileges...");

        const process = new Deno.Command("sudo", {
          args: ["mv", tempPath, currentBinaryPath],
          stdin: "inherit",
          stdout: "inherit",
          stderr: "inherit",
        });

        const { code } = await process.output();

        if (code === 0) {
          console.log("\n✅ Update successful!");
          return 0;
        } else {
          console.error("\n❌ Update failed");
          return 1;
        }
      }
      throw error;
    }
  } catch (error) {
    console.error(
      `❌ Update failed: ${error instanceof Error ? error.message : error}`,
    );
    return 1;
  }
}
