// docs/04 §7 + docs/05 — motor G/Ç modelleri. Tüm boyutlar Int64 (docs/04 §2).
public typealias Units = Int64

public enum UnitMode: String, Codable, Sendable {
    case metricMM = "metric_mm"          // 1 birim = 0.01 mm
    case imperialFrac64 = "imperial_frac64" // 1 birim = 1/6400 inç
}

public enum Objective: String, Codable, Sendable { case sheets, waste, cuts }
public enum RotationRule: String, Codable, Sendable { case allowed, fixed }

public struct StockSpec: Codable, Sendable, Equatable {
    public var id: String
    public var materialId: String
    public var w: Units
    public var h: Units
    public var qty: Int
    public var isOffcut: Bool
    public init(id: String, materialId: String, w: Units, h: Units, qty: Int, isOffcut: Bool = false) {
        self.id = id; self.materialId = materialId; self.w = w; self.h = h; self.qty = qty; self.isOffcut = isOffcut
    }
}

public struct PartSpec: Codable, Sendable, Equatable {
    public var id: String
    public var name: String
    public var materialId: String
    public var w: Units
    public var h: Units
    public var qty: Int
    public var rotation: RotationRule
    public init(id: String, name: String, materialId: String, w: Units, h: Units, qty: Int, rotation: RotationRule = .allowed) {
        self.id = id; self.name = name; self.materialId = materialId; self.w = w; self.h = h; self.qty = qty; self.rotation = rotation
    }
}

public struct OptimizeRequest: Codable, Sendable, Equatable {
    public var unitMode: UnitMode
    public var kerf: Units
    public var trim: Units
    public var objective: Objective
    public var seed: UInt64
    public var stocks: [StockSpec]
    public var parts: [PartSpec]
    public init(unitMode: UnitMode, kerf: Units, trim: Units, objective: Objective, seed: UInt64, stocks: [StockSpec], parts: [PartSpec]) {
        self.unitMode = unitMode; self.kerf = kerf; self.trim = trim
        self.objective = objective; self.seed = seed; self.stocks = stocks; self.parts = parts
    }
}

public struct Placement: Codable, Sendable, Equatable {
    public var partId: String
    public var sheetIndex: Int
    public var x: Units
    public var y: Units
    public var w: Units
    public var h: Units
    public var rotated: Bool
    public init(partId: String, sheetIndex: Int, x: Units, y: Units, w: Units, h: Units, rotated: Bool) {
        self.partId = partId; self.sheetIndex = sheetIndex; self.x = x; self.y = y; self.w = w; self.h = h; self.rotated = rotated
    }
}

public struct PlanStats: Codable, Sendable, Equatable {
    public var sheetCount: Int
    public var wasteBps: Int   // 1/100 % — Int, platform paritesi için
    public var cutCount: Int
    public init(sheetCount: Int, wasteBps: Int, cutCount: Int) {
        self.sheetCount = sheetCount; self.wasteBps = wasteBps; self.cutCount = cutCount
    }
}

public struct OptimizeResult: Codable, Sendable, Equatable {
    public var placements: [Placement]
    public var stats: PlanStats
    public var unplaced: [String]
    public var engineVersion: String
    public init(placements: [Placement], stats: PlanStats, unplaced: [String], engineVersion: String) {
        self.placements = placements; self.stats = stats; self.unplaced = unplaced; self.engineVersion = engineVersion
    }
}

public struct ValidationIssue: Codable, Sendable, Equatable {
    public enum Kind: String, Codable, Sendable {
        case nonPositiveDimension, nonPositiveQuantity, partExceedsStock, unknownMaterial, negativeKerfOrTrim
        case dimensionTooLarge, totalStockAreaTooLarge // docs/04 §2 motor sınırları (E1-S1c)
    }
    public var kind: Kind
    public var subjectId: String
    public var message: String
    public init(kind: Kind, subjectId: String, message: String) {
        self.kind = kind; self.subjectId = subjectId; self.message = message
    }
}
