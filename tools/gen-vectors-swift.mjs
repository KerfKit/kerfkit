// Golden vektörleri Swift'e gömer: Bundle/asset erişimi olmayan platformlarda
// (Android/Kotlin testleri, ileride Wasm) parite koşusu için. Tek kaynak
// Tests/CutCoreTests/vectors/*.json'dur; bu dosya türetilmiştir — elle düzenleme.
// Senkron bekçisi: GoldenRunnerTests.testEmbeddedVectorsMatchDisk (macOS).
import { readFileSync, writeFileSync, readdirSync } from "node:fs";
import { join } from "node:path";

const dir = new URL("../Tests/CutCoreTests/vectors/", import.meta.url).pathname;
const names = readdirSync(dir).filter(n => n.endsWith(".json")).sort();
const entries = names.map(n => {
  const body = readFileSync(join(dir, n), "utf8");
  return `        "${n}": #"""\n${body}\n"""#,`;
}).join("\n");
const swift = `// uretildi: node tools/gen-vectors-swift.mjs — elle duzenleme; kaynak: vectors/*.json
// Android/Kotlin (ve ileride Wasm) parite kosusu Bundle yerine bu gomulu kopyayi okur.
enum VectorData {
    static let all: [String: String] = [
${entries}
    ]
}
`;
writeFileSync(new URL("../Tests/CutCoreTests/VectorData.swift", import.meta.url), swift);
console.log(`VectorData.swift uretildi: ${names.length} vektor`);
