//
//  ContentView.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import SwiftUI

// MARK: - Root Content View

struct ContentView: View {
  @State private var weeks: [Week] = SampleData.weeks
  @State private var currentWeekIndex: Int = 0
  @State private var selectedDayIndex: Int = 5
  @State private var activeMode: ViewingMode = .today
  @State private var isPlaying: Bool = false
  @State private var playbackProgress: CGFloat = 0.35
  @State private var scratchRotation: Angle = .degrees(0)
  @State private var newTrackTitle: String = ""
  @State private var newTrackArtist: String = ""
  @State private var newTrackLink: String = ""

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        background

        switch activeMode {
        case .today:
          TodayView(
            track: currentTrack,
            weekNumber: currentWeek.number,
            dayOfWeek: selectedDayIndex + 1,
            progress: $playbackProgress,
            isPlaying: $isPlaying,
            scratchRotation: $scratchRotation,
            onSwipeDown: openWeekView,
            onSwipeUp: openAddView,
            onScrub: scrubbed
          )
        case .week:
          WeekAlbumView(
            week: currentWeek,
            weeks: weeks,
            selectedDayIndex: $selectedDayIndex,
            currentWeekIndex: $currentWeekIndex,
            onPinchIn: openTodayView
          )
          .transition(.move(edge: .top))
        case .add:
          AddTrackView(
            title: $newTrackTitle,
            artist: $newTrackArtist,
            link: $newTrackLink,
            onCancel: openTodayView,
            onEngrave: engraveNewTrack
          )
          .transition(.move(edge: .bottom))
        }
      }
      .frame(width: proxy.size.width, height: proxy.size.height)
      .animation(.spring(response: 0.55, dampingFraction: 0.85), value: activeMode)
    }
    .preferredColorScheme(.light)
  }

  private var background: some View {
    LinearGradient(
      colors: [Color.white, Color(red: 0.94, green: 0.95, blue: 0.97)],
      startPoint: .top,
      endPoint: .bottom
    )
    .ignoresSafeArea()
  }

  private var currentWeek: Week {
    weeks[currentWeekIndex]
  }

  private var currentTrack: Track {
    currentWeek.tracks[selectedDayIndex]
  }

  private func scrubbed(_ delta: CGFloat) {
    playbackProgress = max(0, min(1, playbackProgress + delta))
  }

  private func openWeekView() {
    activeMode = .week
  }

  private func openTodayView() {
    activeMode = .today
  }

  private func openAddView() {
    activeMode = .add
  }

  private func engraveNewTrack() {
    guard !newTrackTitle.isEmpty else { return }
    guard let character = CharacterStickerLibrary.randomSticker() else { return }

    let newTrack = Track(
      title: newTrackTitle,
      artist: newTrackArtist.isEmpty ? "Unknown Artist" : newTrackArtist,
      dayIndex: selectedDayIndex,
      weekIndex: currentWeek.number,
      accent: character.accent,
      character: character,
      artworkName: nil,
      sourceURL: URL(string: newTrackLink)
    )

    weeks[currentWeekIndex].tracks[selectedDayIndex] = newTrack
    newTrackTitle = ""
    newTrackArtist = ""
    newTrackLink = ""
    activeMode = .today
  }
}

#Preview {
  ContentView()
}
