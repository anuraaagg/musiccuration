//
//  MusicWidgetLiveActivity.swift
//  MusicWidget
//
//  Created by Anurag Singh on 01/12/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MusicWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct MusicWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MusicWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension MusicWidgetAttributes {
    fileprivate static var preview: MusicWidgetAttributes {
        MusicWidgetAttributes(name: "World")
    }
}

extension MusicWidgetAttributes.ContentState {
    fileprivate static var smiley: MusicWidgetAttributes.ContentState {
        MusicWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: MusicWidgetAttributes.ContentState {
         MusicWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: MusicWidgetAttributes.preview) {
   MusicWidgetLiveActivity()
} contentStates: {
    MusicWidgetAttributes.ContentState.smiley
    MusicWidgetAttributes.ContentState.starEyes
}
