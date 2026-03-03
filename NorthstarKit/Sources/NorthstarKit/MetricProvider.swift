import Foundation
import Combine

public final class MetricProvider: ObservableObject, @unchecked Sendable {
    @Published public var metrics: [Metric] = [
        Metric(id: TimeAPIClient.MetricID.time,      value: "", description: "Time", lastUpdatedAt: .distantPast),
        Metric(id: TimeAPIClient.MetricID.date,      value: "", description: "Date", lastUpdatedAt: .distantPast),
        Metric(id: TimeAPIClient.MetricID.dayOfWeek, value: "", description: "Day",  lastUpdatedAt: .distantPast),
    ]

    private let client = TimeAPIClient()

    public init() {}

    public func fetch() async {
        do {
            let fetched = try await client.fetch()
            await MainActor.run { metrics = fetched }
        } catch {
            // keep existing metrics on failure
        }
    }
}
