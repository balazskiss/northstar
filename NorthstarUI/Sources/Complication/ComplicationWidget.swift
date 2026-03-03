import WidgetKit
import SwiftUI
import NorthstarKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let value: String
}

struct SimpleProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, value: "—")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: .now, value: "—"))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let value: String
            do {
                let metrics = try await TimeAPIClient().fetch()
                value = metrics.first(where: { $0.id == TimeAPIClient.MetricID.time })?.value ?? "—"
            } catch {
                value = "—"
            }
            let entry = SimpleEntry(date: .now, value: value)
            completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60))))
        }
    }
}

struct ComplicationView: View {
    var entry: SimpleEntry

    var body: some View {
        Text(entry.value)
            .containerBackground(.clear, for: .widget)
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
