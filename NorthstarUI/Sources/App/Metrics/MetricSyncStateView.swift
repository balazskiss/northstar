import SwiftUI
import NorthstarKit

struct MetricSyncStateView: View {
    let state: MetricSyncState
    
    var body: some View {
        switch state {
        case .idle, .synced:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
        case .syncing:
            ProgressView()
                .controlSize(.mini)
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.caption)
        }
    }
}
