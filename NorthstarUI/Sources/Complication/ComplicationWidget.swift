import WidgetKit
import SwiftUI
import NorthstarKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let metric: Metric
}

struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, metric: MetricProvider().metrics[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: .now, metric: MetricProvider().metrics[0]))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let provider = MetricProvider()
            await provider.fetch()
            let entry = SimpleEntry(date: .now, metric: provider.metrics[0])
            completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60))))
        }
    }
}

struct ComplicationView: View {
    var entry: SimpleEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(displayValue)
                .widgetAccentable()
            
        case .accessoryCircular:
            Text(displayValue)
                .font(.system(.title2, design: .rounded).bold())
                .widgetAccentable()
                .containerBackground(.clear, for: .widget)
            
        case .accessoryRectangular:
            Text(displayValue)
                .font(.system(.largeTitle, design: .rounded).bold())
                .widgetAccentable()
                .frame(maxWidth: .infinity, alignment: .leading)
                .containerBackground(.clear, for: .widget)
            
        case .accessoryCorner:
            Text(displayValue)
                .font(.system(.title2, design: .rounded).bold())
                .widgetAccentable()
                .containerBackground(.clear, for: .widget)
            
        default:
            Text(displayValue)
                .widgetAccentable()
                .containerBackground(.clear, for: .widget)
        }
    }
    
    private var displayValue: String {
        entry.metric.value.isEmpty ? "—" : entry.metric.value
    }
}

@main
struct NorthstarComplication: Widget {
    let kind = "NorthstarComplication"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SimpleProvider()) { entry in
            ComplicationView(entry: entry)
        }
        .configurationDisplayName("Northstar")
        .description("Your key metric at a glance.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
