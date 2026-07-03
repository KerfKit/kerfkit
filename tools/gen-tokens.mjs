import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const tokens = JSON.parse(readFileSync(new URL("../tokens/tokens.json", import.meta.url)));

function get(path) {
  let node = tokens;
  for (const key of path.split(".")) { node = node?.[key]; if (!node) throw new Error("alias yok: " + path); }
  return node;
}
function resolve(value) {
  if (typeof value !== "string") return value;
  const m = value.match(/^\{(.+)\}$/);
  if (!m) return value;
  const node = get(m[1]);
  return resolve(node.$value ?? node);
}
const light = [], dark = [];
function walk(node, path) {
  if (node && typeof node === "object" && "$value" in node) {
    const name = "--" + path.join("-");
    light.push([name, resolve(node.$value)]);
    const dv = node.$extensions?.mode?.dark;
    if (dv) dark.push([name, resolve(dv)]);
    return;
  }
  for (const [k, v] of Object.entries(node)) {
    if (k.startsWith("$")) continue;
    walk(v, [...path, k]);
  }
}
walk(tokens, []);
const fmt = (rows, indent) => rows.map(([k, v]) => `${indent}${k}: ${v};`).join("\n");
const css = `/* uretildi: node tools/gen-tokens.mjs — elle duzenleme, tokens/tokens.json'u degistir */
:root {
${fmt(light, "  ")}
}
@media (prefers-color-scheme: dark) { :root {
${fmt(dark, "  ")}
} }
[data-mode="dark"] {
${fmt(dark, "  ")}
}
`;
mkdirSync(new URL("../apps/web/styles/", import.meta.url), { recursive: true });
writeFileSync(new URL("../apps/web/styles/tokens.css", import.meta.url), css);
console.log(`tokens.css uretildi: ${light.length} token, ${dark.length} dark override`);

// — Swift çıktısı (docs/12: tokens.json → CSS + Swift; tek kaynak) —
const camel = (name) => name.slice(2).split("-")
  .map((p, i) => (i === 0 ? p : p[0].toUpperCase() + p.slice(1))).join("");
function swiftValue(v) {
  const s = String(v);
  const hex = s.match(/^#([0-9A-Fa-f]{6})$/);
  if (hex) return { type: "Color", code: `Color(hex: 0x${hex[1].toUpperCase()})` };
  const px = s.match(/^(-?[\d.]+)(px|pt)?$/);
  if (px) return { type: "CGFloat", code: px[1] };
  return null; // font yığını vb. — Swift tarafında gereksiz
}
const emit = (rows, indent) => rows
  .map(([name, v]) => ({ name: camel(name), sv: swiftValue(v) }))
  .filter((r) => r.sv)
  .map((r) => `${indent}public static let ${r.name}: ${r.sv.type} = ${r.sv.code}`)
  .join("\n");
const swift = `// uretildi: node tools/gen-tokens.mjs — elle duzenleme, tokens/tokens.json'u degistir
import SwiftUI

public enum DesignTokens {
${emit(light, "    ")}

    // Dark mod override'ları (koyu-öncelikli marka: uygulama kabuğu bunları kullanır)
    public enum Dark {
${emit(dark, "        ")}
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: 1)
    }
}
`;
mkdirSync(new URL("../apps/ios/Kerf/Generated/", import.meta.url), { recursive: true });
writeFileSync(new URL("../apps/ios/Kerf/Generated/DesignTokens.swift", import.meta.url), swift);
console.log("DesignTokens.swift uretildi");
