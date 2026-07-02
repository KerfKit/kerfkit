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
