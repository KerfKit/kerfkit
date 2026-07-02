# 05 — Veri Modeli ve .cutproj Dosya Formatı

> İlke: **proje dosyası = motorun girdisi = golden test vektörü.** Tek şema, üç kullanım.
> Format: sürümlü JSON; bilinmeyen alanlar korunur (forward-compat); kanonik kayıt local-first.

## 1. Varlıklar ve ilişkiler

```
Project 1—n Material 1—n StockSheet / StockLength
Project 1—n Part            (her Part bir Material'a bağlı)
Project 1—n Plan            (Plan = OptimizeRequest anlık görüntüsü + OptimizeResult)
Project 1—n Offcut          (v1.1: tamamlanan plandan stok havuzuna düşenler)
Settings (uygulama-geneli): birim modu varsayılanı, kerf/trim varsayılanı, tema
```

- **AÇIKÇA yazılmış ilişki kuralları** (ajan çıkarsamasın): Part.materialId zorunlu ve Project
  içindeki bir Material'ı göstermeli; Plan silinince Offcut'ları da silinir (cascade); Material
  silinemez eğer Part'ı varsa (önce taşı/sil diyaloğu).

## 2. JSON şeması (v1) — örnekli

```json
{
  "schemaVersion": 1,
  "id": "uuid",
  "name": "Mutfak Dolabı",
  "createdAt": "2026-07-02T10:00:00Z",
  "modifiedAt": "...",
  "unitMode": "metric_mm | imperial_frac64",
  "defaults": { "kerf": 300, "trim": 1000, "objective": "sheets" },
  "materials": [
    { "id": "m1", "name": "18mm Birch Ply", "kind": "sheet",
      "thicknessLabel": "18mm", "costPerUnit": null, "grainAxis": "x" }
  ],
  "stocks": [
    { "id": "s1", "materialId": "m1", "w": 244000, "h": 122000,
      "qty": 5, "isOffcut": false, "label": "4x8 sheet" }
  ],
  "parts": [
    { "id": "p1", "name": "Yan panel", "materialId": "m1",
      "w": 60000, "h": 40000, "qty": 4,
      "rotation": "allowed | fixed",
      "banding": { "top": true, "bottom": false, "left": true, "right": true },
      "notes": "" }
  ],
  "plans": [
    { "id": "pl1", "createdAt": "...", "engineVersion": "1.0.0",
      "request": { "...OptimizeRequest alanları..." },
      "result": { "...OptimizeResult..." },
      "stale": false,
      "workshopProgress": { "completedCutIds": ["c1","c4"] } }
  ]
}
```

Notlar: tüm boyutlar Int (birim modu kuralı 04 §2); `stale` — girdiler plan üretiminden sonra
değiştiyse true (UI "Yeniden hesapla" bandı); `workshopProgress` atölye modunun kalıcılığı.

## 3. Değişmezler (invariant — test edilir)

1. Round-trip: decode→encode bit-eşit (bilinmeyen alan kaybı yok).
2. Her Part.materialId geçerli bir Material'ı gösterir; her Stock.materialId de öyle.
3. unitMode proje içinde tekil; kerf/trim/boyutlar ≥0; qty ≥1.
4. Plan.request, üretildiği andaki parça/stok kümesiyle tutarlı hash taşır → stale tespiti hash farkıyla.
5. schemaVersion > uygulamanın bildiği sürüm → salt-okunur aç + güncelleme uyarısı (asla sessiz bozma).

## 4. Kalıcılık ve senkron

- **Yerel:** GRDB (MIT; Skip tarafında SkipSQL karşılığı var — SwiftData bilinçli DIŞLANDI:
  Apple-kilidi Android portunu zorlaştırır). Otomatik kayıt: değişiklikte 500ms debounce.
- **Dosya:** dışa/içe aktarım `.cutproj` (yukarıdaki JSON) + `.csv` (yalnız parça listesi).
  Paylaşım sayfası + Files entegrasyonu. **Veri asla yalnız bellekte/çerezde yaşamaz** (rakip 1★ dersi).
- **iCloud (v1.1):** iCloud Documents ile .cutproj klasörü; çakışmada son-yazan-kazanır +
  yedek kopya (sessiz veri kaybı YASAK).
- **v2 (Supabase):** auth (e-posta magic link) + projects tablosu + licenses tablosu (08 §5) —
  yalnız üç-platform senkron için; motor asla sunucuda koşmaz.

## 5. DO-NOT-CHANGE listesi (ajan anayasasına girer)

- Birim temsilini (Int + mod) değiştirme; Double'a çevirme teklifi bile etme.
- schemaVersion migrasyonsuz artırma; alan silme (yalnız deprecate + koruma).
- GRDB→SwiftData/CoreData geçişi önerme (Android paritesi kırılır).
- Plan.result'ı yeniden hesaplamadan mutasyona uğratma (sonuçlar immutable; yeni plan üret).
