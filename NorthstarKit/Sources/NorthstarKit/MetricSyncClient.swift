import Foundation

public struct MetricSyncClient: Sendable {
    private let baseURL: URL
    private let anonKey: String
    
    public enum SyncError: Error {
        case invalidURL
        case invalidResponse
        case httpError(statusCode: Int)
    }
    
    /// Initialize the metric sync client
    /// - Parameters:
    ///   - baseURL: The base URL for your Supabase project
    ///   - anonKey: Your Supabase anonymous key
    public init(baseURL: String, anonKey: String) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid base URL: \(baseURL)")
        }
        self.baseURL = url
        self.anonKey = anonKey
    }
    
    /// Sync a single metric by ID
    /// - Parameter id: The UUID of the metric to sync
    /// - Returns: The updated metric
    public func sync(id: UUID) async throws -> Metric {
        let metrics = try await sync(ids: [id])
        guard let metric = metrics.first else {
            throw SyncError.invalidResponse
        }
        return metric
    }
    
    /// Sync multiple metrics by their IDs
    /// - Parameter ids: An array of UUIDs for the metrics to sync
    /// - Returns: An array of updated metrics
    public func sync(ids: [UUID]) async throws -> [Metric] {
        try await withThrowingTaskGroup(of: Metric.self) { group in
            // Add a task for each metric ID
            for id in ids {
                group.addTask {
                    try await fetchMetric(id: id)
                }
            }
            
            // Collect all results
            var metrics: [Metric] = []
            for try await metric in group {
                metrics.append(metric)
            }
            
            return metrics
        }
    }
    
    /// Fetch a single metric from the API
    private func fetchMetric(id: UUID) async throws -> Metric {
        guard let url = URL(string: "/functions/v1/metrics/\(id.uuidString)", relativeTo: baseURL) else {
            throw SyncError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check HTTP status code
        if let httpResponse = response as? HTTPURLResponse {
            guard (200...299).contains(httpResponse.statusCode) else {
                throw SyncError.httpError(statusCode: httpResponse.statusCode)
            }
        }
        
        // Decode the metric
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Metric.self, from: data)
    }
}
