import SwiftUI
import NorthstarKit

struct ContentView: View {
    @StateObject private var provider = MetricProvider()
    @State private var isLoading = false

    var body: some View {
        List {
            ForEach(provider.metrics, id: \.id) { metric in
                VStack(alignment: .leading, spacing: 2) {
                    Text(metric.title)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(metric.value.isEmpty ? "—" : metric.value)
                        .font(.system(.body, design: .rounded).bold())
                        .foregroundStyle(metric.value.isEmpty ? .secondary : .primary)
                }
                .padding(.vertical, 2)
            }
            Button {
                Task { await refresh() }
            } label: {
                HStack {
                    Spacer()
                    if isLoading {
                        ProgressView()
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    Spacer()
                }
            }
            .disabled(isLoading)
        }
        .navigationTitle("Northstar")
        .task {
            await refresh()
        }
    }

    private func refresh() async {
        isLoading = true
        await provider.fetch()
        isLoading = false
    }
}
