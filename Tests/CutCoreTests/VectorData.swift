// uretildi: node tools/gen-vectors-swift.mjs — elle duzenleme; kaynak: vectors/*.json
// Android/Kotlin (ve ileride Wasm) parite kosusu Bundle yerine bu gomulu kopyayi okur.
enum VectorData {
    static let all: [String: String] = [
        "001_basic_single_sheet.json": #"""
{
  "name": "001 tek levhaya 4 parca (E1-S1 AC-1)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "panel", "materialId": "m1", "w": 60000, "h": 40000, "qty": 4, "rotation": "allowed" }]
  },
  "expected": {"sheetCount": 1, "wasteBps": 6775, "cutCount": 5, "placementsHash": "cc87b44fd7fe8d86"}
}

"""#,
        "002_kerf_3mm.json": #"""
{
  "name": "002 kerf=3mm komsuluk (E1-S2 AC-1)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 300, "trim": 1000, "objective": "waste", "seed": 7,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 2, "isOffcut": false }],
    "parts": [
      { "id": "p1", "name": "raf", "materialId": "m1", "w": 80000, "h": 30000, "qty": 6, "rotation": "fixed" },
      { "id": "p2", "name": "yan", "materialId": "m1", "w": 70000, "h": 45000, "qty": 2, "rotation": "allowed" }
    ]
  },
  "expected": {"sheetCount": 1, "wasteBps": 3046, "cutCount": 12, "placementsHash": "914c367fa59a390b"}
}

"""#,
        "003_tam_dolum.json": #"""
{
  "name": "003 tek parca levhayi tam doldurur (kesimsiz)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "tam", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "rotation": "fixed" }]
  },
  "expected": {"sheetCount": 1, "wasteBps": 0, "cutCount": 0, "placementsHash": "a45e5502add2ab52"}
}

"""#,
        "004_sabit_rotasyon_seritler.json": #"""
{
  "name": "004 sabit rotasyonlu 4 serit (rotation=fixed, tek levha)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "raf", "materialId": "m1", "w": 200000, "h": 30000, "qty": 4, "rotation": "fixed" }]
  },
  "expected": {"sheetCount": 1, "wasteBps": 1937, "cutCount": 5, "placementsHash": "5fc29031baa9c875"}
}

"""#,
        "005_iki_levha.json": #"""
{
  "name": "005 uc yarim-levha parca iki levhaya tasar (coklu levha)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 2, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "yarim", "materialId": "m1", "w": 244000, "h": 61000, "qty": 3, "rotation": "fixed" }]
  },
  "expected": {"sheetCount": 2, "wasteBps": 2500, "cutCount": 2, "placementsHash": "64b20100668ac988"}
}

"""#,
        "006_kerf0_trim10.json": #"""
{
  "name": "006 kerf=0 ucu + trim=10mm (E1-S2 AC-2/AC-3)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 1000, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "panel", "materialId": "m1", "w": 60000, "h": 40000, "qty": 4, "rotation": "allowed" }]
  },
  "expected": {"sheetCount": 1, "wasteBps": 6775, "cutCount": 4, "placementsHash": "deb8f68220853257"}
}

"""#,
        "007_kerf12_uc.json": #"""
{
  "name": "007 kerf=12mm ucu (E1-S2 AC-3)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 1200, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "panel", "materialId": "m1", "w": 60000, "h": 40000, "qty": 4, "rotation": "allowed" }]
  },
  "expected": {"sheetCount": 1, "wasteBps": 6775, "cutCount": 5, "placementsHash": "98376a32e1d801c8"}
}

"""#,
        "008_kerf3_toz.json": #"""
{
  "name": "008 kerf=3mm, artik kerf'e esit — toz durumu (E1-S2)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 300, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "yarim", "materialId": "m1", "w": 121700, "h": 122000, "qty": 2, "rotation": "fixed" }]
  },
  "expected": {"sheetCount": 1, "wasteBps": 24, "cutCount": 2, "placementsHash": "0bcbc714ca2ee892"}
}

"""#,
        "009_damar_fixed_dortlu.json": #"""
{
  "name": "009 damar kilidi: fixed dortlu asla donmez (E1-S3 AC-1)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "damarli", "materialId": "m1", "w": 40000, "h": 60000, "qty": 4, "rotation": "fixed" }]
  },
  "expected": {"sheetCount": 1, "wasteBps": 6775, "cutCount": 5, "placementsHash": "e255af01cc747b00"}
}

"""#,
        "010_damar_zorunlu_rotasyon.json": #"""
{
  "name": "010 damar: yalniz donerek sigan allowed parca (E1-S3 AC-2)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "uzun", "materialId": "m1", "w": 120000, "h": 230000, "qty": 1, "rotation": "allowed" }]
  },
  "expected": {"sheetCount": 1, "wasteBps": 728, "cutCount": 2, "placementsHash": "613503806aef7010"}
}

"""#,
        "011_damar_karisik.json": #"""
{
  "name": "011 damar: fixed + allowed karisik paket, kerf 3mm (E1-S3)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 300, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [
      { "id": "p1", "name": "kapak", "materialId": "m1", "w": 80000, "h": 50000, "qty": 2, "rotation": "fixed" },
      { "id": "p2", "name": "raf", "materialId": "m1", "w": 90000, "h": 35000, "qty": 3, "rotation": "allowed" }
    ]
  },
  "expected": {"sheetCount": 1, "wasteBps": 4138, "cutCount": 8, "placementsHash": "49a33364952ace4b"}
}

"""#,
        "012_iki_malzeme_havuzu.json": #"""
{
  "name": "012 iki malzeme havuzu ayrik (E1-S4 AC-1)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [
      { "id": "mdf", "materialId": "mdf12", "w": 280000, "h": 207000, "qty": 2, "isOffcut": false },
      { "id": "birch", "materialId": "birch18", "w": 244000, "h": 122000, "qty": 2, "isOffcut": false }
    ],
    "parts": [
      { "id": "b1", "name": "govde", "materialId": "birch18", "w": 60000, "h": 40000, "qty": 4, "rotation": "allowed" },
      { "id": "m1", "name": "arkalik", "materialId": "mdf12", "w": 120000, "h": 90000, "qty": 2, "rotation": "fixed" }
    ]
  },
  "expected": {"sheetCount": 2, "wasteBps": 6443, "cutCount": 8, "placementsHash": "14c233d618413cdb"}
}

"""#,
        "013_stok_tukenmesi.json": #"""
{
  "name": "013 stok tukenmesi: 3 yarimdan 1'i unplaced (E1-S4 AC-3)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "yarim", "materialId": "m1", "w": 244000, "h": 61000, "qty": 3, "rotation": "fixed" }]
  },
  "expected": {"sheetCount": 1, "wasteBps": 0, "cutCount": 1, "placementsHash": "589e46812750c42e"}
}

"""#,
        "014_uc_levha.json": #"""
{
  "name": "014 uc levhaya tasan bes yarim (coklu levha)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 0, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [{ "id": "s1", "materialId": "m1", "w": 244000, "h": 122000, "qty": 3, "isOffcut": false }],
    "parts": [{ "id": "p1", "name": "yarim", "materialId": "m1", "w": 244000, "h": 61000, "qty": 5, "rotation": "fixed" }]
  },
  "expected": {"sheetCount": 3, "wasteBps": 1666, "cutCount": 3, "placementsHash": "c32d435902fdc842"}
}

"""#,
        "015_iki_malzeme_kerf.json": #"""
{
  "name": "015 iki malzeme + kerf 3mm + trim 10mm karisik (E1-S4)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 300, "trim": 1000, "objective": "sheets", "seed": 1,
    "stocks": [
      { "id": "birch", "materialId": "birch18", "w": 244000, "h": 122000, "qty": 2, "isOffcut": false },
      { "id": "mdf", "materialId": "mdf12", "w": 244000, "h": 122000, "qty": 1, "isOffcut": false }
    ],
    "parts": [
      { "id": "yan", "name": "yan", "materialId": "birch18", "w": 72000, "h": 58000, "qty": 4, "rotation": "fixed" },
      { "id": "raf", "name": "raf", "materialId": "birch18", "w": 76400, "h": 30000, "qty": 3, "rotation": "allowed" },
      { "id": "arka", "name": "arka", "materialId": "mdf12", "w": 118000, "h": 75000, "qty": 1, "rotation": "allowed" }
    ]
  },
  "expected": {"sheetCount": 2, "wasteBps": 4552, "cutCount": 13, "placementsHash": "aa86a4ca1a909f03"}
}

"""#,
        "016_hedef_sheets.json": #"""
{
  "name": "016 hedef=sheets: az levha odunlesimi (E1-S4 AC-2 uclusu)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 300, "trim": 0, "objective": "sheets", "seed": 1,
    "stocks": [
      { "id": "kucuk", "materialId": "m1", "w": 130000, "h": 130000, "qty": 10, "isOffcut": false },
      { "id": "buyuk", "materialId": "m1", "w": 250000, "h": 250000, "qty": 10, "isOffcut": false }
    ],
    "parts": [
      { "id": "kare", "name": "kare", "materialId": "m1", "w": 120000, "h": 120000, "qty": 4, "rotation": "allowed" },
      { "id": "serit", "name": "serit", "materialId": "m1", "w": 240000, "h": 30000, "qty": 4, "rotation": "fixed" }
    ]
  },
  "expected": {"sheetCount": 3, "wasteBps": 1028, "cutCount": 16, "placementsHash": "9c84117910dabffa"}
}

"""#,
        "017_hedef_waste.json": #"""
{
  "name": "017 hedef=waste: ayni girdi, fire onceligi (E1-S4 AC-2 uclusu)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 300, "trim": 0, "objective": "waste", "seed": 1,
    "stocks": [
      { "id": "kucuk", "materialId": "m1", "w": 130000, "h": 130000, "qty": 10, "isOffcut": false },
      { "id": "buyuk", "materialId": "m1", "w": 250000, "h": 250000, "qty": 10, "isOffcut": false }
    ],
    "parts": [
      { "id": "kare", "name": "kare", "materialId": "m1", "w": 120000, "h": 120000, "qty": 4, "rotation": "allowed" },
      { "id": "serit", "name": "serit", "materialId": "m1", "w": 240000, "h": 30000, "qty": 4, "rotation": "fixed" }
    ]
  },
  "expected": {"sheetCount": 3, "wasteBps": 1028, "cutCount": 16, "placementsHash": "9c84117910dabffa"}
}

"""#,
        "018_hedef_cuts.json": #"""
{
  "name": "018 hedef=cuts: ayni girdi, az kesim odunlesimi (E1-S4 AC-2 uclusu)",
  "pending": false,
  "request": {
    "unitMode": "metric_mm", "kerf": 300, "trim": 0, "objective": "cuts", "seed": 1,
    "stocks": [
      { "id": "kucuk", "materialId": "m1", "w": 130000, "h": 130000, "qty": 10, "isOffcut": false },
      { "id": "buyuk", "materialId": "m1", "w": 250000, "h": 250000, "qty": 10, "isOffcut": false }
    ],
    "parts": [
      { "id": "kare", "name": "kare", "materialId": "m1", "w": 120000, "h": 120000, "qty": 4, "rotation": "allowed" },
      { "id": "serit", "name": "serit", "materialId": "m1", "w": 240000, "h": 30000, "qty": 4, "rotation": "fixed" }
    ]
  },
  "expected": {"sheetCount": 4, "wasteBps": 2367, "cutCount": 13, "placementsHash": "aac97dc9d0226631"}
}

"""#,
    ]
}
