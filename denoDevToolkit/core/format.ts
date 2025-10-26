// core/format.ts
type Col = { key: string; header: string; width?: number };

function pad(s: string, w: number) {
  return s.length > w ? s.slice(0, Math.max(0, w - 1)) + "…" : s.padEnd(w, " ");
}

export function printTable(rows: Record<string, string>[], cols: Col[]) {
  if (rows.length === 0) {
    console.log("(sin resultados)");
    return;
  }
  // widths
  const widths = cols.map(
    (c) =>
      c.width ??
      Math.max(c.header.length, ...rows.map((r) => (r[c.key] ?? "").length), 6),
  );
  // header
  const header = cols.map((c, i) => pad(c.header, widths[i])).join("  ");
  console.log(header);
  console.log(widths.map((w) => "-".repeat(w)).join("  "));
  // rows
  for (const r of rows) {
    const line = cols.map((c, i) => pad(r[c.key] ?? "", widths[i])).join("  ");
    console.log(line);
  }
}

export function printTitle(t: string) {
  console.log(`\n=== ${t} ===`);
}
