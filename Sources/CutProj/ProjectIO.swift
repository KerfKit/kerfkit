import Foundation

// docs/05 — .cutproj okuma/yazma. Kanonik yazım: sortedKeys (+ kaçışsız /) —
// round-trip determinizmi kanonik biçim üzerinden tanımlıdır (decode→encode→decode değişmez;
// bilinmeyen alanlar dahil). Byte-eşitlik, kaynak dosya da kanonik biçimdeyse sağlanır.
public enum ProjectIO {
    public enum IOError: Error, Equatable {
        case newerSchema(found: Int, supported: Int) // docs/05 §3.5: salt-okunur aç + uyarı (UI kararı)
    }

    public static func decode(_ data: Data) throws -> ProjectDoc {
        let probe = try JSONDecoder().decode(SchemaProbe.self, from: data)
        if probe.schemaVersion > cutprojSchemaVersion {
            throw IOError.newerSchema(found: probe.schemaVersion, supported: cutprojSchemaVersion)
        }
        let migrated = try ProjectMigrator.upgradeIfNeeded(data, from: probe.schemaVersion)
        return try JSONDecoder().decode(ProjectDoc.self, from: migrated)
    }

    public static func encode(_ doc: ProjectDoc) throws -> Data {
        let enc = JSONEncoder()
        enc.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try enc.encode(doc)
    }

    struct SchemaProbe: Codable { var schemaVersion: Int }
}

// E3-S1 migrasyon iskeleti: v(n) → v(n+1) adımları zincirlenir. v1 = mevcut.
enum ProjectMigrator {
    static func upgradeIfNeeded(_ data: Data, from version: Int) throws -> Data {
        // v1 = mevcut; ilk gerçek adım (v1→v2) geldiğinde zincir buraya eklenir:
        // for v in version..<cutprojSchemaVersion { switch v { case 1: data = try v1to2(data) ... } }
        _ = version
        return data
    }
}
