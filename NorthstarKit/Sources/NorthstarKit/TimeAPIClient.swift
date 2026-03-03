import Foundation

public struct TimeAPIClient: Sendable {
    // Stable IDs for each metric this client provides
    public enum MetricID {
        public static let time       = UUID(uuidString: "00000001-0000-0000-0000-000000000000")!
        public static let date       = UUID(uuidString: "00000002-0000-0000-0000-000000000000")!
        public static let dayOfWeek  = UUID(uuidString: "00000003-0000-0000-0000-000000000000")!
    }

    private static let url = URL(string: "https://timeapi.io/api/time/current/zone?timeZone=UTC")!

    public init() {}

    public func fetch() async throws -> [Metric] {
        let (data, _) = try await URLSession.shared.data(from: Self.url)
        let response = try JSONDecoder().decode(TimeAPIResponse.self, from: data)
        return response.asMetrics()
    }
}

// MARK: - Private

private struct TimeAPIResponse: Decodable {
    let hour: Int
    let minute: Int
    let seconds: Int
    let date: String
    let dayOfWeek: String

    func asMetrics() -> [Metric] {
        let now = Date()
        let time = String(format: "%02d:%02d:%02d", hour, minute, seconds)
        return [
            Metric(id: TimeAPIClient.MetricID.time,      value: time,      description: "Time", lastUpdatedAt: now),
            Metric(id: TimeAPIClient.MetricID.date,      value: date,      description: "Date", lastUpdatedAt: now),
            Metric(id: TimeAPIClient.MetricID.dayOfWeek, value: dayOfWeek, description: "Day",  lastUpdatedAt: now),
        ]
    }
}
