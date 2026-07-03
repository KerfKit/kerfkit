import CutModels

// docs/05 §2 — .cutproj v1 şeması (E3-S1 / K-10).
// İlke: bilinmeyen alanlar KORUNUR (forward-compat) — her varlık, tanımadığı anahtarları
// `extra` sözlüğünde taşır ve geri yazar. Tarihler String (ISO-8601) tutulur: byte-sadakat.
// Plan.request/result motor tipleridir (CutModels) — motor G/Ç'sinde extra taşınmaz (bilinçli).

public let cutprojSchemaVersion = 1

// JSON değeri — round-trip için sayılar tam/ondalık ayrımıyla saklanır.
public indirect enum JSONValue: Codable, Equatable, Sendable {
    case null
    case bool(Bool)
    case integer(Int64)
    case number(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null }
        else if let b = try? c.decode(Bool.self) { self = .bool(b) }
        else if let i = try? c.decode(Int64.self) { self = .integer(i) }
        else if let d = try? c.decode(Double.self) { self = .number(d) }
        else if let s = try? c.decode(String.self) { self = .string(s) }
        else if let a = try? c.decode([JSONValue].self) { self = .array(a) }
        else { self = .object(try c.decode([String: JSONValue].self)) }
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .null: try c.encodeNil()
        case .bool(let b): try c.encode(b)
        case .integer(let i): try c.encode(i)
        case .number(let d): try c.encode(d)
        case .string(let s): try c.encode(s)
        case .array(let a): try c.encode(a)
        case .object(let o): try c.encode(o)
        }
    }
}

struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }
    init(_ s: String) { stringValue = s }
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}

func decodeExtras(_ decoder: Decoder, known: Set<String>) throws -> [String: JSONValue] {
    let c = try decoder.container(keyedBy: AnyKey.self)
    var extra: [String: JSONValue] = [:]
    for key in c.allKeys where !known.contains(key.stringValue) {
        extra[key.stringValue] = try c.decode(JSONValue.self, forKey: key)
    }
    return extra
}

func encodeExtras(_ extra: [String: JSONValue], to encoder: Encoder) throws {
    var c = encoder.container(keyedBy: AnyKey.self)
    for (k, v) in extra { try c.encode(v, forKey: AnyKey(k)) }
}

public struct MaterialDoc: Codable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var kind: String            // "sheet" | "length"
    public var thicknessLabel: String?
    public var costPerUnit: Int64?     // v1.1 maliyet; Int (docs/05)
    public var grainAxis: String?      // "x" | "y"
    public var extra: [String: JSONValue] = [:]

    static let known: Set<String> = ["id", "name", "kind", "thicknessLabel", "costPerUnit", "grainAxis"]
    enum K: String, CodingKey { case id, name, kind, thicknessLabel, costPerUnit, grainAxis }

    public init(id: String, name: String, kind: String,
                thicknessLabel: String? = nil, costPerUnit: Int64? = nil, grainAxis: String? = nil) {
        self.id = id; self.name = name; self.kind = kind
        self.thicknessLabel = thicknessLabel; self.costPerUnit = costPerUnit; self.grainAxis = grainAxis
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: K.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        kind = try c.decode(String.self, forKey: .kind)
        thicknessLabel = try c.decodeIfPresent(String.self, forKey: .thicknessLabel)
        costPerUnit = try c.decodeIfPresent(Int64.self, forKey: .costPerUnit)
        grainAxis = try c.decodeIfPresent(String.self, forKey: .grainAxis)
        extra = try decodeExtras(decoder, known: Self.known)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: K.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(kind, forKey: .kind)
        try c.encodeIfPresent(thicknessLabel, forKey: .thicknessLabel)
        try c.encodeIfPresent(costPerUnit, forKey: .costPerUnit)
        try c.encodeIfPresent(grainAxis, forKey: .grainAxis)
        try encodeExtras(extra, to: encoder)
    }
}

public struct StockDoc: Codable, Equatable, Sendable {
    public var id: String
    public var materialId: String
    public var w: Units
    public var h: Units
    public var qty: Int
    public var isOffcut: Bool
    public var label: String?
    public var extra: [String: JSONValue] = [:]

    static let known: Set<String> = ["id", "materialId", "w", "h", "qty", "isOffcut", "label"]
    enum K: String, CodingKey { case id, materialId, w, h, qty, isOffcut, label }

    public init(id: String, materialId: String, w: Units, h: Units, qty: Int,
                isOffcut: Bool = false, label: String? = nil) {
        self.id = id; self.materialId = materialId; self.w = w; self.h = h
        self.qty = qty; self.isOffcut = isOffcut; self.label = label
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: K.self)
        id = try c.decode(String.self, forKey: .id)
        materialId = try c.decode(String.self, forKey: .materialId)
        w = try c.decode(Units.self, forKey: .w)
        h = try c.decode(Units.self, forKey: .h)
        qty = try c.decode(Int.self, forKey: .qty)
        isOffcut = try c.decodeIfPresent(Bool.self, forKey: .isOffcut) ?? false
        label = try c.decodeIfPresent(String.self, forKey: .label)
        extra = try decodeExtras(decoder, known: Self.known)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: K.self)
        try c.encode(id, forKey: .id)
        try c.encode(materialId, forKey: .materialId)
        try c.encode(w, forKey: .w)
        try c.encode(h, forKey: .h)
        try c.encode(qty, forKey: .qty)
        try c.encode(isOffcut, forKey: .isOffcut)
        try c.encodeIfPresent(label, forKey: .label)
        try encodeExtras(extra, to: encoder)
    }

    public var asSpec: StockSpec {
        StockSpec(id: id, materialId: materialId, w: w, h: h, qty: qty, isOffcut: isOffcut)
    }
}

public struct BandingDoc: Codable, Hashable, Sendable {
    public var top: Bool
    public var bottom: Bool
    public var left: Bool
    public var right: Bool
    public init(top: Bool = false, bottom: Bool = false, left: Bool = false, right: Bool = false) {
        self.top = top; self.bottom = bottom; self.left = left; self.right = right
    }
}

public struct PartDoc: Codable, Equatable, Sendable {
    public var id: String
    public var name: String
    public var materialId: String
    public var w: Units
    public var h: Units
    public var qty: Int
    public var rotation: RotationRule
    public var banding: BandingDoc?
    public var notes: String?
    public var extra: [String: JSONValue] = [:]

    static let known: Set<String> = ["id", "name", "materialId", "w", "h", "qty", "rotation", "banding", "notes"]
    enum K: String, CodingKey { case id, name, materialId, w, h, qty, rotation, banding, notes }

    public init(id: String, name: String, materialId: String, w: Units, h: Units, qty: Int,
                rotation: RotationRule = .allowed, banding: BandingDoc? = nil, notes: String? = nil) {
        self.id = id; self.name = name; self.materialId = materialId
        self.w = w; self.h = h; self.qty = qty
        self.rotation = rotation; self.banding = banding; self.notes = notes
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: K.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        materialId = try c.decode(String.self, forKey: .materialId)
        w = try c.decode(Units.self, forKey: .w)
        h = try c.decode(Units.self, forKey: .h)
        qty = try c.decode(Int.self, forKey: .qty)
        rotation = try c.decodeIfPresent(RotationRule.self, forKey: .rotation) ?? .allowed
        banding = try c.decodeIfPresent(BandingDoc.self, forKey: .banding)
        notes = try c.decodeIfPresent(String.self, forKey: .notes)
        extra = try decodeExtras(decoder, known: Self.known)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: K.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(materialId, forKey: .materialId)
        try c.encode(w, forKey: .w)
        try c.encode(h, forKey: .h)
        try c.encode(qty, forKey: .qty)
        try c.encode(rotation, forKey: .rotation)
        try c.encodeIfPresent(banding, forKey: .banding)
        try c.encodeIfPresent(notes, forKey: .notes)
        try encodeExtras(extra, to: encoder)
    }

    public var asSpec: PartSpec {
        PartSpec(id: id, name: name, materialId: materialId, w: w, h: h, qty: qty, rotation: rotation)
    }
}

public struct WorkshopProgressDoc: Codable, Equatable, Sendable {
    public var completedCutIds: [String]
    public init(completedCutIds: [String] = []) { self.completedCutIds = completedCutIds }
}

public struct PlanDoc: Codable, Equatable, Sendable {
    public var id: String
    public var createdAt: String
    public var engineVersion: String
    public var request: OptimizeRequest
    public var result: OptimizeResult
    public var stale: Bool
    public var workshopProgress: WorkshopProgressDoc?
    public var extra: [String: JSONValue] = [:]

    static let known: Set<String> = ["id", "createdAt", "engineVersion", "request", "result", "stale", "workshopProgress"]
    enum K: String, CodingKey { case id, createdAt, engineVersion, request, result, stale, workshopProgress }

    public init(id: String, createdAt: String, engineVersion: String,
                request: OptimizeRequest, result: OptimizeResult,
                stale: Bool = false, workshopProgress: WorkshopProgressDoc? = nil) {
        self.id = id; self.createdAt = createdAt; self.engineVersion = engineVersion
        self.request = request; self.result = result
        self.stale = stale; self.workshopProgress = workshopProgress
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: K.self)
        id = try c.decode(String.self, forKey: .id)
        createdAt = try c.decode(String.self, forKey: .createdAt)
        engineVersion = try c.decode(String.self, forKey: .engineVersion)
        request = try c.decode(OptimizeRequest.self, forKey: .request)
        result = try c.decode(OptimizeResult.self, forKey: .result)
        stale = try c.decodeIfPresent(Bool.self, forKey: .stale) ?? false
        workshopProgress = try c.decodeIfPresent(WorkshopProgressDoc.self, forKey: .workshopProgress)
        extra = try decodeExtras(decoder, known: Self.known)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: K.self)
        try c.encode(id, forKey: .id)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(engineVersion, forKey: .engineVersion)
        try c.encode(request, forKey: .request)
        try c.encode(result, forKey: .result)
        try c.encode(stale, forKey: .stale)
        try c.encodeIfPresent(workshopProgress, forKey: .workshopProgress)
        try encodeExtras(extra, to: encoder)
    }
}

public struct DefaultsDoc: Codable, Equatable, Sendable {
    public var kerf: Units
    public var trim: Units
    public var objective: Objective
    public init(kerf: Units = 300, trim: Units = 0, objective: Objective = .sheets) {
        self.kerf = kerf; self.trim = trim; self.objective = objective
    }
}

public struct ProjectDoc: Codable, Equatable, Sendable {
    public var schemaVersion: Int
    public var id: String
    public var name: String
    public var createdAt: String
    public var modifiedAt: String
    public var unitMode: UnitMode
    public var defaults: DefaultsDoc
    public var materials: [MaterialDoc]
    public var stocks: [StockDoc]
    public var parts: [PartDoc]
    public var plans: [PlanDoc]
    public var extra: [String: JSONValue] = [:]

    static let known: Set<String> = ["schemaVersion", "id", "name", "createdAt", "modifiedAt",
                                     "unitMode", "defaults", "materials", "stocks", "parts", "plans"]
    enum K: String, CodingKey { case schemaVersion, id, name, createdAt, modifiedAt, unitMode, defaults, materials, stocks, parts, plans }

    public init(id: String, name: String, createdAt: String, modifiedAt: String,
                unitMode: UnitMode = .metricMM, defaults: DefaultsDoc = DefaultsDoc(),
                materials: [MaterialDoc] = [], stocks: [StockDoc] = [],
                parts: [PartDoc] = [], plans: [PlanDoc] = []) {
        schemaVersion = cutprojSchemaVersion
        self.id = id; self.name = name; self.createdAt = createdAt; self.modifiedAt = modifiedAt
        self.unitMode = unitMode; self.defaults = defaults
        self.materials = materials; self.stocks = stocks; self.parts = parts; self.plans = plans
    }
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: K.self)
        schemaVersion = try c.decode(Int.self, forKey: .schemaVersion)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        createdAt = try c.decode(String.self, forKey: .createdAt)
        modifiedAt = try c.decode(String.self, forKey: .modifiedAt)
        unitMode = try c.decode(UnitMode.self, forKey: .unitMode)
        defaults = try c.decodeIfPresent(DefaultsDoc.self, forKey: .defaults) ?? DefaultsDoc()
        materials = try c.decodeIfPresent([MaterialDoc].self, forKey: .materials) ?? []
        stocks = try c.decodeIfPresent([StockDoc].self, forKey: .stocks) ?? []
        parts = try c.decodeIfPresent([PartDoc].self, forKey: .parts) ?? []
        plans = try c.decodeIfPresent([PlanDoc].self, forKey: .plans) ?? []
        extra = try decodeExtras(decoder, known: Self.known)
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: K.self)
        try c.encode(schemaVersion, forKey: .schemaVersion)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encode(modifiedAt, forKey: .modifiedAt)
        try c.encode(unitMode, forKey: .unitMode)
        try c.encode(defaults, forKey: .defaults)
        try c.encode(materials, forKey: .materials)
        try c.encode(stocks, forKey: .stocks)
        try c.encode(parts, forKey: .parts)
        try c.encode(plans, forKey: .plans)
        try encodeExtras(extra, to: encoder)
    }
}
