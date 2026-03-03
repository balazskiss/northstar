import SwiftUI
import NorthstarKit

struct ContentView: View {
    @StateObject private var provider = MetricProvider()
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            List(provider.metrics, id: \.id) { metric in
                MetricRow(metric: metric)
            }
            .navigationTitle("Northstar")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await refresh() }
                    } label: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(isLoading)
                }
            }
            .task {
                await refresh()
            }
        }
    }

    private func refresh() async {
        isLoading = true
        await provider.fetch()
        isLoading = false
    }
}

// MARK: - MetricRow

private struct MetricRow: View {
    let metric: Metric

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(metric.description)
                    .font(.headline)
                Spacer()
                Text(metric.value.isEmpty ? "—" : metric.value)
                    .font(.system(.title2, design: .rounded).bold())
                    .foregroundStyle(metric.value.isEmpty ? .secondary : .primary)
            }
            Text(lastUpdatedText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private var lastUpdatedText: String {
        if metric.lastUpdatedAt == .distantPast {
            return "Not yet synced"
        }
        return "Updated \(metric.lastUpdatedAt.formatted(.relative(presentation: .named)))"
    }
}
