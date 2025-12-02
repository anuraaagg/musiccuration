//
//  MusicWidget.swift
//  MusicWidget
//
//  Created by Anurag Singh on 01/12/25.
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), track: SampleData.tracks[0])
  }

  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry = SimpleEntry(date: Date(), track: SampleData.tracks[0])
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    var entries: [SimpleEntry] = []

    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for hourOffset in 0..<5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      // In a real app, we would fetch the actual current track here
      // For now, we rotate through sample tracks
      let trackIndex =
        (Calendar.current.component(.hour, from: entryDate)) % SampleData.tracks.count
      let entry = SimpleEntry(date: entryDate, track: SampleData.tracks[trackIndex])
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let track: Track
}

struct MusicWidgetEntryView: View {
  var entry: Provider.Entry
  @Environment(\.widgetFamily) var family

  var body: some View {
    GeometryReader { geometry in
      ZStack {
        // Background handled by containerBackground modifier in WidgetConfiguration

        if family == .systemMedium {
          HStack(spacing: 0) {
            // Left: Vinyl (Square)
            ZStack {
              VinylDisc(track: entry.track, scratchRotation: .degrees(0))
                .padding(16)  // Increased padding -> Smaller Vinyl
            }
            .frame(width: geometry.size.height, height: geometry.size.height)

            // Right: Info & Controls
            VStack(alignment: .leading, spacing: 12) {
              VStack(alignment: .leading, spacing: 4) {
                Text(entry.track.title)
                  .font(.system(size: 17, weight: .bold))
                  .lineLimit(1)
                  .foregroundColor(.primary)

                Text(entry.track.artist)
                  .font(.system(size: 14, weight: .medium))
                  .lineLimit(1)
                  .foregroundColor(.secondary)
              }

              StaticPlayerBar(progress: 0.35, accent: entry.track.accent)
            }
            .padding(.trailing, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .center)
          }
        } else {
          // Small Layout (Compact)
          VStack(spacing: 0) {
            Spacer(minLength: 0)

            VinylDisc(track: entry.track, scratchRotation: .degrees(0))
              .frame(width: geometry.size.height * 0.7, height: geometry.size.height * 0.7)

            Spacer(minLength: 0)

            VStack(spacing: 2) {
              Text(entry.track.title)
                .font(.system(size: 12, weight: .bold))
                .lineLimit(1)
              Text(entry.track.artist)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
            }
            .padding(.bottom, 12)
          }
        }
      }
    }
  }
}

struct MusicWidget: Widget {
  let kind: String = "MusicWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      if #available(iOS 17.0, *) {
        MusicWidgetEntryView(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        MusicWidgetEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("Now Playing")
    .description("See what's spinning.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

#Preview(as: .systemSmall) {
  MusicWidget()
} timeline: {
  SimpleEntry(date: .now, track: SampleData.tracks[0])
  SimpleEntry(date: .now, track: SampleData.tracks[1])
}
