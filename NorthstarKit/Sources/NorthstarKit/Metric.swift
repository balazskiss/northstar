import Foundation

public enum MetricSyncState: Codable, Equatable, Sendable {
    case idle
    case syncing
    case synced(Date)
    case failed(String)
    
    public var isSyncing: Bool {
        if case .syncing = self { return true }
        return false
    }
    
    public var lastSyncDate: Date? {
        if case .synced(let date) = self { return date }
        return nil
    }
}

public struct Metric: Codable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let value: String
    public let description: String?
    public let lastUpdatedAt: Date
    public let lastSyncedAt: Date
    public let syncState: MetricSyncState

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case value
        case description
        case lastUpdatedAt = "updated_at"
    }

    public init(
        id: UUID,
        title: String,
        value: String,
        description: String? = nil,
        lastUpdatedAt: Date,
        lastSyncedAt: Date = .distantPast,
        syncState: MetricSyncState = .idle
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.description = description
        self.lastUpdatedAt = lastUpdatedAt
        self.lastSyncedAt = lastSyncedAt
        self.syncState = syncState
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        lastUpdatedAt = try container.decode(Date.self, forKey: .lastUpdatedAt)
        
        // Handle value as either Int or String
        if let intValue = try? container.decode(Int.self, forKey: .value) {
            value = String(intValue)
        } else {
            value = try container.decode(String.self, forKey: .value)
        }
        
        // These fields don't come from the API, set defaults
        lastSyncedAt = .distantPast
        syncState = .idle
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(lastUpdatedAt, forKey: .lastUpdatedAt)
        
        // Try to encode as Int if possible, otherwise as String
        if let intValue = Int(value) {
            try container.encode(intValue, forKey: .value)
        } else {
            try container.encode(value, forKey: .value)
        }
        
        // Note: lastSyncedAt and syncState are not encoded to match API format
    }
    
    /// Create a copy of this metric with an updated lastSyncedAt timestamp
    public func withSyncTimestamp(_ date: Date = Date()) -> Metric {
        Metric(
            id: id,
            title: title,
            value: value,
            description: description,
            lastUpdatedAt: lastUpdatedAt,
            lastSyncedAt: date,
            syncState: .synced(date)
        )
    }
    
    /// Create a copy of this metric with a syncing state
    public func withSyncingState() -> Metric {
        Metric(
            id: id,
            title: title,
            value: value,
            description: description,
            lastUpdatedAt: lastUpdatedAt,
            lastSyncedAt: lastSyncedAt,
            syncState: .syncing
        )
    }
    
    /// Create a copy of this metric with a failed state
    public func withFailedState(_ error: String) -> Metric {
        Metric(
            id: id,
            title: title,
            value: value,
            description: description,
            lastUpdatedAt: lastUpdatedAt,
            lastSyncedAt: lastSyncedAt,
            syncState: .failed(error)
        )
    }
}
