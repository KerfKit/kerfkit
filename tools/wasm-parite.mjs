// W-2 parite kanıtı (docs/06 §1): golden vektörler 001/002 wasm motorunda koşar,
// sheetCount/wasteBps/cutCount/placementsHash Swift golden'ıyla birebir olmalı.
// Koşum: node tools/wasm-parite.mjs  (wasm: apps/web/public/wasm/kerfkit-motor.wasm)
import { readFile } from 'node:fs/promises';
import { WASI } from 'node:wasi';

const VECTORS = [
  'Tests/CutCoreTests/vectors/001_basic_single_sheet.json',
  'Tests/CutCoreTests/vectors/002_kerf_3mm.json',
];
const WASM_PATH = 'apps/web/public/wasm/kerfkit-motor.wasm';

const wasi = new WASI({ version: 'preview1' });
const wasm = await WebAssembly.compile(await readFile(new URL(`../${WASM_PATH}`, import.meta.url)));
const instance = await WebAssembly.instantiate(wasm, wasi.getImportObject());
wasi.initialize(instance); // reactor: _initialize

const { kk_input_alloc, kk_optimize, kk_output_ptr, memory } = instance.exports;

function runEngine(request) {
  const bytes = new TextEncoder().encode(JSON.stringify(request));
  const inPtr = kk_input_alloc(bytes.length);
  new Uint8Array(memory.buffer, inPtr, bytes.length).set(bytes);
  const outLen = kk_optimize(bytes.length);
  if (outLen < 0) throw new Error(`kk_optimize hata kodu: ${outLen}`);
  // bellek büyümüş olabilir — görünümü çağrıdan SONRA al
  const out = new Uint8Array(instance.exports.memory.buffer, kk_output_ptr(), outLen);
  return JSON.parse(new TextDecoder().decode(out));
}

let failed = 0;
for (const path of VECTORS) {
  const vector = JSON.parse(await readFile(new URL(`../${path}`, import.meta.url), 'utf8'));
  if (vector.pending) { console.log(`ATLA  ${vector.name} (pending)`); continue; }

  const reply = runEngine(vector.request);
  if (!reply.ok) { console.error(`HATA  ${vector.name}: ${reply.error}`); failed++; continue; }

  const got = {
    sheetCount: reply.result.stats.sheetCount,
    wasteBps: reply.result.stats.wasteBps,
    cutCount: reply.result.stats.cutCount,
    placementsHash: reply.placementsHash,
  };
  const want = vector.expected;
  const same = JSON.stringify(got) === JSON.stringify(want);
  console.log(`${same ? 'OK   ' : 'FARK '} ${vector.name}`);
  if (!same) {
    console.error(`  beklenen: ${JSON.stringify(want)}`);
    console.error(`  wasm    : ${JSON.stringify(got)}`);
    failed++;
  }
}

if (failed > 0) { console.error(`\n${failed} vektör pariteden düştü.`); process.exit(1); }
console.log('\nWasm paritesi tam: vektörler Swift golden ile bit-eşit.');
