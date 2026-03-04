import Foundation
import Combine

public final class MetricProvider: ObservableObject, @unchecked Sendable {
    public static let signupsMetricID = UUID(uuidString: "58cb9fa1-a90f-48a1-9f5e-a1548cf714d7")!
    
    @Published public var metrics: [Metric] = [
        Metric(
            id: signupsMetricID,
            title: "Signups today",
            value: "",
            description: "Total number of new user signups today",
            lastUpdatedAt: .distantPast
        ),
    ]

    private let syncClient: MetricSyncClient?

    public init() {
        // Read configuration from environment variables or Info.plist
        let baseURL = Self.getSupabaseBaseURL()
        let anonKey = Self.getSupabaseAnonKey()
        
        if let baseURL = baseURL, let anonKey = anonKey {
            self.syncClient = MetricSyncClient(baseURL: baseURL, anonKey: anonKey)
        } else {
            self.syncClient = nil
        }
    }
    
    // MARK: - Configuration
    
    private static func getSupabaseBaseURL() -> String? {
        // Try environment variable first
        if let url = ProcessInfo.processInfo.environment["SUPABASE_URL"] {
            return url
        }
        
        // Try Info.plist
        if let url = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String {
            return url
        }
        
        // Default for local development
        #if DEBUG
        return SupabaseConfig.defaultBaseURL
        #else
        return nil
        #endif
    }
    
    private static func getSupabaseAnonKey() -> String? {
        // Try environment variable first
        if let key = ProcessInfo.processInfo.environment["SUPABASE_ANON_KEY"] {
            return key
        }
        
        // Try Info.plist
        if let key = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String {
            return key
        }
        
        // Default for local development
        #if DEBUG
        return SupabaseConfig.defaultAnonKey
        #else
        return nil
        #endif
    }

    public func fetch() async {
        await syncMetric(id: Self.signupsMetricID)
    }
    
    /// Sync metrics from Supabase
    public func syncMetrics(ids: [UUID]) async {
        guard let syncClient = syncClient else { return }
        
        // Mark all metrics as syncing
        await MainActor.run {
            for id in ids {
                if let index = metrics.firstIndex(where: { $0.id == id }) {
                    metrics[index] = metrics[index].withSyncingState()
                }
            }
        }
        
        do {
            let synced = try await syncClient.sync(ids: ids)
            let syncTime = Date()
            await MainActor.run {
                // Update metrics with synced data and sync timestamp
                for syncedMetric in synced {
                    if let index = metrics.firstIndex(where: { $0.id == syncedMetric.id }) {
                        metrics[index] = syncedMetric.withSyncTimestamp(syncTime)
                    }
                }
            }
        } catch {
            // Mark failed metrics
            await MainActor.run {
                for id in ids {
                    if let index = metrics.firstIndex(where: { $0.id == id }) {
                        metrics[index] = metrics[index].withFailedState(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    /// Sync a single metric from Supabase
    public func syncMetric(id: UUID) async {
        guard let syncClient = syncClient else { return }
        
        // Mark metric as syncing
        await MainActor.run {
            if let index = metrics.firstIndex(where: { $0.id == id }) {
                metrics[index] = metrics[index].withSyncingState()
            }
        }
        
        do {
            let synced = try await syncClient.sync(id: id)
            let syncTime = Date()
            await MainActor.run {
                if let index = metrics.firstIndex(where: { $0.id == synced.id }) {
                    metrics[index] = synced.withSyncTimestamp(syncTime)
                }
            }
        } catch {
            // Mark metric as failed
            await MainActor.run {
                if let index = metrics.firstIndex(where: { $0.id == id }) {
                    metrics[index] = metrics[index].withFailedState(error.localizedDescription)
                }
            }
        }
    }
}
