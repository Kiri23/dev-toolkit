// core/output.ts

/**
 * Manages output capture for global flags like --copy
 */
export class OutputCapture {
  private captured: string[] = [];
  private isCapturing = false;
  private originalLog: typeof console.log;
  private originalError: typeof console.error;

  constructor() {
    this.originalLog = console.log;
    this.originalError = console.error;
  }

  /**
   * Start capturing console output
   */
  start(): void {
    this.isCapturing = true;
    this.captured = [];

    // Override console.log to capture output
    console.log = (...args: unknown[]) => {
      const message = args
        .map((arg) => (typeof arg === "string" ? arg : JSON.stringify(arg)))
        .join(" ");

      this.captured.push(message);
      this.originalLog(...args); // Still print to terminal
    };

    // Also capture console.error for completeness
    console.error = (...args: unknown[]) => {
      const message = args
        .map((arg) => (typeof arg === "string" ? arg : JSON.stringify(arg)))
        .join(" ");

      this.captured.push(message);
      this.originalError(...args); // Still print to terminal
    };
  }

  /**
   * Stop capturing and restore original console functions
   * @returns Captured output as string
   */
  stop(): string {
    this.isCapturing = false;
    console.log = this.originalLog;
    console.error = this.originalError;
    return this.captured.join("\n");
  }

  /**
   * Get captured output without stopping capture
   */
  getOutput(): string {
    return this.captured.join("\n");
  }
}
