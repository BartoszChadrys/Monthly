//
//  MonthlyWidget.swift
//  MonthlyWidget
//
//  Created by Bartek Chadryś on 22/07/2024.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DayEntry {
        DayEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DayEntry) -> ()) {
        let entry = DayEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [DayEntry] = []

        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDate = Calendar.current.startOfDay(for: entryDate)
            let entry = DayEntry(date: startOfDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct DayEntry: TimelineEntry {
    let date: Date
}

struct MonthlyWidgetEntryView : View {
    @Environment(\.showsWidgetContainerBackground) var isShowingBackground
    var entry: DayEntry
    var config: MonthConfig
    
    init(entry: DayEntry) {
        self.entry = entry
        self.config = MonthConfig.determineConfig(from: entry.date)
    }

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text(config.emojiText)
                    .font(.title)
                Text(entry.date.weekFormatted)
                    .font(.title3)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(isShowingBackground ? config.weekdayTextColor.opacity(0.6) : .white)
                Spacer()
            }
            .id(entry.date)
            .transition(.push(from: .trailing))
            .animation(.bouncy, value: entry.date)
            
            Text(entry.date.dayFormatted)
                .font(.system(size: 80, weight: .heavy))
                .foregroundStyle(isShowingBackground ? config.dayTextColor.opacity(0.8) : .white)
                .contentTransition(.numericText())
        }
        .containerBackground(config.backgroundColor.gradient, for: .widget)
    }
}

struct MonthlyWidget: Widget {
    let kind: String = "MonthlyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                MonthlyWidgetEntryView(entry: entry)
            } else {
                MonthlyWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Monthly Style Widget")
        .description("The theme of the widget changes based on month.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    MonthlyWidget()
} timeline: {
    let firstDate = DateComponents(calendar: Calendar.current, year: 2024, month: 12, day: 24)
    let secondDate = DateComponents(calendar: Calendar.current, year: 2024, month: 12, day: 31)
    DayEntry(date: Calendar.current.date(from: firstDate)!)
    DayEntry(date: Calendar.current.date(from: secondDate)!)
}

extension Date {
    var weekFormatted: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    
    var dayFormatted: String {
        self.formatted(.dateTime.day())
    }
}
