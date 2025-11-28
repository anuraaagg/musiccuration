//
//  ContentView.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import MusicKit
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
  @State private var selectedCharacter: CharacterSticker = CharacterStickerLibrary.all[0]
  @State private var isEngraving = false
  @State private var showWelcome = true

  var body: some View {
    if showWelcome {
      WelcomeView(onSignIn: {
        withAnimation(.easeInOut(duration: 0.8)) {
          showWelcome = false
        }
      })
      .transition(.opacity)
    } else {
      GeometryReader { proxy in
        ZStack {
          background

          // Determine which view to show based on daily check
          if !hasEngravedToday() && activeMode == .today {
            // Show engrave screen if not done today
            AddTrackView(
              selectedCharacter: $selectedCharacter,
              isEngraving: isEngraving,
              onCancel: { /* No cancel for default view */  },
              onEngrave: engraveNewTrack
            )
          } else {
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
                selectedCharacter: $selectedCharacter,
                isEngraving: isEngraving,
                onCancel: openTodayView,
                onEngrave: engraveNewTrack
              )
              .transition(.move(edge: .bottom))
            }
          }
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
        .animation(.spring(response: 0.55, dampingFraction: 0.85), value: activeMode)
      }
      .preferredColorScheme(.light)
      .transition(.opacity)
    }
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

  private func hasEngravedToday() -> Bool {
    let today = Calendar.current.startOfDay(for: Date())
    let trackDate = Calendar.current.startOfDay(for: currentTrack.engravedDate)
    return today == trackDate
  }

  private func engraveNewTrack(_ song: Song) {
    isEngraving = true
    HapticsManager.shared.selectionTick()

    // Simulate engraving delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      let newTrack = Track(
        title: song.title,
        artist: song.artistName,
        dayIndex: selectedDayIndex,
        weekIndex: currentWeek.number,
        accent: selectedCharacter.accent,
        character: selectedCharacter,
        artworkName: nil,
        sourceURL: nil,
        appleMusicID: song.id.rawValue,
        previewURL: song.previewAssets?.first?.url,
        engravedDate: Date()
      )

      weeks[currentWeekIndex].tracks[selectedDayIndex] = newTrack

      HapticsManager.shared.engraveSuccess()

      selectedCharacter = CharacterStickerLibrary.randomSticker() ?? CharacterStickerLibrary.all[0]
      isEngraving = false
      activeMode = .today
    }
  }
}

#Preview {
  ContentView()
}
