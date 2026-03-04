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
