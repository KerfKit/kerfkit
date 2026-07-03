// docs/04 §4 + docs/05 — 1D (doğrusal kesim) G/Ç modelleri (E2-S1).
// 2D ile aynı çıktı yapısı: placements + stats + unplaced + engineVersion.

public struct Stock1D: Codable, Sendable, Equatable {
    public var id: String
    public var materialId: String
    public var length: Units
    public var qty: Int
    public var isOffcut: Bool
    public init(id: String, materialId: String, length: Units, qty: Int, isOffcut: Bool = false) {
        self.id = id; self.materialId = materialId; self.length = length; self.qty = qty; self.isOffcut = isOffcut
    }
}

public struct Part1D: Codable, Sendable, Equatable {
    public var id: String
    public var name: String
    public var materialId: String
    public var length: Units
    public var qty: Int
    public init(id: String, name: String, materialId: String, length: Units, qty: Int) {
        self.id = id; self.name = name; self.materialId = materialId; self.length = length; self.qty = qty
    }
}

public struct Optimize1DRequest: Codable, Sendable, Equatable {
    public var unitMode: UnitMode
    public var kerf: Units
    public var objective: Objective
    public var seed: UInt64
    public var stocks: [Stock1D]
    public var parts: [Part1D]
    public init(unitMode: UnitMode, kerf: Units, objective: Objective, seed: UInt64,
                stocks: [Stock1D], parts: [Part1D]) {
        self.unitMode = unitMode; self.kerf = kerf; self.objective = objective
        self.seed = seed; self.stocks = stocks; self.parts = parts
    }
}

public struct Placement1D: Codable, Sendable, Equatable {
    public var partId: String
    public var stockIndex: Int
    public var offset: Units
    public var length: Units
    public init(partId: String, stockIndex: Int, offset: Units, length: Units) {
        self.partId = partId; self.stockIndex = stockIndex; self.offset = offset; self.length = length
    }
}

public struct Optimize1DResult: Codable, Sendable, Equatable {
    public var placements: [Placement1D]
    public var stats: PlanStats           // sheetCount = kullanılan stok boyu sayısı
    public var unplaced: [String]
    public var engineVersion: String
    public init(placements: [Placement1D], stats: PlanStats, unplaced: [String], engineVersion: String) {
        self.placements = placements; self.stats = stats; self.unplaced = unplaced; self.engineVersion = engineVersion
    }
}
