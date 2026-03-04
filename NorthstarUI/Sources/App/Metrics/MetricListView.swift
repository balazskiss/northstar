import SwiftUI
import NorthstarKit

struct MetricListView: View {
    @ObservedObject var provider: MetricProvider
    
    var body: some View {
        List(provider.metrics, id: \.id) { metric in
            MetricRow(metric: metric)
        }
    }
}
