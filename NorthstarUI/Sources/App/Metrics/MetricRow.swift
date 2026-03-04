import SwiftUI
import NorthstarKit

struct MetricRow: View {
    let metric: Metric

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(metric.title)
                    .font(.headline)
                Spacer()
                Text(metric.value.isEmpty ? "—" : metric.value)
                    .font(.system(.title2, design: .rounded).bold())
                    .foregroundStyle(metric.value.isEmpty ? .secondary : .primary)
            }
            
            if let description = metric.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(lastUpdatedText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    MetricSyncStateView(state: metric.syncState)
                    Text(syncStateText)
                        .font(.caption)
                        .foregroundStyle(syncStateColor)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var lastUpdatedText: String {
        if metric.lastUpdatedAt == .distantPast {
            return "Updated: Never"
        }
        return "Updated: \(metric.lastUpdatedAt.formatted(.relative(presentation: .named)))"
    }
    
    private var syncStateText: String {
        switch metric.syncState {
        case .idle:
            if metric.lastSyncedAt == .distantPast {
                return "Not synced yet"
            }
            return "Synced: \(metric.lastSyncedAt.formatted(.relative(presentation: .named)))"
        case .syncing:
            return "Syncing..."
        case .synced(let date):
            return "Synced: \(date.formatted(.relative(presentation: .named)))"
        case .failed(let error):
            return "Sync failed: \(error)"
        }
    }
    
    private var syncStateColor: Color {
        switch metric.syncState {
        case .idle, .synced:
            return .secondary
        case .syncing:
            return .blue
        case .failed:
            return .red
        }
    }
}
