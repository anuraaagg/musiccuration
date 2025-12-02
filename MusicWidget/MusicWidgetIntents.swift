//
//  MusicWidgetIntents.swift
//  MusicWidgetExtension
//
//  Created by Anurag Singh on 01/12/25.
//

import AppIntents
import SwiftUI

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct PlayPauseIntent: AudioPlaybackIntent {
  static var title: LocalizedStringResource = "Play/Pause"
  static var description = IntentDescription("Toggles playback state.")

  func perform() async throws -> some IntentResult {
    // In a real app, this would communicate with the main app or SystemMusicPlayer
    // For this prototype, we'll just return success to simulate the interaction
    return .result()
  }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct NextTrackIntent: AudioPlaybackIntent {
  static var title: LocalizedStringResource = "Next Track"
  static var description = IntentDescription("Skips to the next track.")

  func perform() async throws -> some IntentResult {
    return .result()
  }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct PreviousTrackIntent: AudioPlaybackIntent {
  static var title: LocalizedStringResource = "Previous Track"
  static var description = IntentDescription("Skips to the previous track.")

  func perform() async throws -> some IntentResult {
    return .result()
  }
}
