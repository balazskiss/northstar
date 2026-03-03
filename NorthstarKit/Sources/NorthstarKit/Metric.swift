import Foundation

public struct Metric: Codable, Equatable, Sendable {
    public let id: UUID
    public let value: String
    public let description: String
    public let lastUpdatedAt: Date

    public init(id: UUID, value: String, description: String, lastUpdatedAt: Date) {
        self.id = id
        self.value = value
        self.description = description
        self.lastUpdatedAt = lastUpdatedAt
    }
}
