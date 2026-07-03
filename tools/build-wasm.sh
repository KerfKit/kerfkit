#!/bin/bash
# W-2: motoru wasm32-wasi'ye derle, apps/web/public/wasm/ altına kopyala.
# Gerektirir: swift sdk install ile kurulu swift-*-RELEASE_wasm (bkz. apps/web/README).
# KERFKIT_WASM=1 → Package.swift Skip bağımlılıklarını düşürür (wasm'da derlenmezler).
set -euo pipefail
cd "$(dirname "$0")/.."

SDK="${KERFKIT_WASM_SDK:-swift-6.3.2-RELEASE_wasm}"

# Xcode'un Apple Swift'i wasm SDK'sının clang modülleriyle çöküyor — swift.org 6.3.2
# araç zinciri şart (swiftly install 6.3.2). SDK sürümüyle birebir eşleşmeli.
SWIFT=(swift)
if command -v swiftly >/dev/null 2>&1 && swiftly list 2>/dev/null | grep -q "6.3.2"; then
  SWIFT=(swiftly run swift)
  TOOLCHAIN="+6.3.2"
else
  echo "UYARI: swiftly 6.3.2 yok — sistem swift'i deneniyor (Xcode toolchain'i çökebilir)" >&2
  TOOLCHAIN=""
fi

KERFKIT_WASM=1 "${SWIFT[@]}" build ${TOOLCHAIN:+$TOOLCHAIN} \
  --swift-sdk "$SDK" \
  -c release \
  --product CutCoreWasm \
  -Xlinker --export=kk_input_alloc \
  -Xlinker --export=kk_optimize \
  -Xlinker --export=kk_output_ptr \
  -Xlinker --strip-all \
  -Xswiftc -Xclang-linker -Xswiftc -mexec-model=reactor

mkdir -p apps/web/public/wasm
cp .build/release/CutCoreWasm.wasm apps/web/public/wasm/kerfkit-motor.wasm

# Wasm derlemesi kök Package.resolved'ı kirletebilir (Skip'siz graf) — kanonik sürümü koru.
git checkout -- Package.resolved 2>/dev/null || true

ls -lh apps/web/public/wasm/kerfkit-motor.wasm
