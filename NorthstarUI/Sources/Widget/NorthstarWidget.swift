import WidgetKit
import SwiftUI
import NorthstarKit

// MARK: - Timeline Entry

struct MetricEntry: TimelineEntry {
    let date: Date
    let metric: Metric
}

// MARK: - Timeline Provider

struct MetricTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> MetricEntry {
        MetricEntry(date: .distantPast, metric: MetricProvider().metrics[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (MetricEntry) -> Void) {
        completion(MetricEntry(date: .distantPast, metric: MetricProvider().metrics[0]))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MetricEntry>) -> Void) {
        Task {
            let provider = MetricProvider()
            await provider.fetch()
            let entry = MetricEntry(date: .now, metric: provider.metrics[0])
            completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60))))
        }
    }
}

// MARK: - View

struct NorthstarWidgetView: View {
    var entry: MetricEntry

    var body: some View {
        VStack(spacing: 4) {
            Text(entry.metric.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(entry.metric.value)
                .font(.system(.largeTitle, design: .rounded).bold())
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Widget

@main
struct NorthstarWidget: Widget {
    let kind = "NorthstarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MetricTimelineProvider()) { entry in
            NorthstarWidgetView(entry: entry)
        }
        .configurationDisplayName("Northstar")
        .description("Your key metric at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
