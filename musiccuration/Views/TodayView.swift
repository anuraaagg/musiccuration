//
//  TodayView.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import SwiftUI

enum ViewingMode {
  case today, week, add
}

struct TodayView: View {
  let track: Track
  let weekNumber: Int
  let dayOfWeek: Int
  @Binding var progress: CGFloat
  @Binding var isPlaying: Bool
  @Binding var scratchRotation: Angle
  var onSwipeDown: () -> Void
  var onSwipeUp: () -> Void
  var onScrub: (CGFloat) -> Void

  @GestureState private var dragTranslation: CGSize = .zero
  @GestureState private var rotation: Angle = .degrees(0)

  var body: some View {
    VStack(spacing: 24) {
      Spacer()
      VinylDisc(track: track, scratchRotation: scratchRotation + rotation)
        .padding(.top, 40)
        .overlay(
          ProgressRing(progress: progress, color: track.accent)
            .opacity(0.7)
            .allowsHitTesting(false)
        )
        .gesture(rotationGesture)
        .onTapGesture(count: 2) { progress = 0 }

      VStack(spacing: 6) {
        Text(track.title)
          .font(.system(.title2, design: .rounded))
          .fontWeight(.semibold)
        Text("\(track.artist) • Week \(weekNumber)")
          .font(.callout)
          .foregroundStyle(.secondary)
        Text("Day \(dayOfWeek) of 7")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      WaveformPlayerBar(
        progress: $progress,
        isPlaying: $isPlaying,
        artworkName: track.artworkName,
        accent: track.accent,
        onScrub: onScrub
      )
      .padding(.horizontal, 32)
      .padding(.top, 12)
      Spacer()
    }
    .padding(.bottom, 32)
    .contentShape(Rectangle())
    .gesture(verticalSwipeGesture)
  }

  private var verticalSwipeGesture: some Gesture {
    DragGesture(minimumDistance: 20, coordinateSpace: .local)
      .updating($dragTranslation) { value, state, _ in
        state = value.translation
      }
      .onEnded { value in
        if value.translation.height > 80 {
          onSwipeDown()
        } else if value.translation.height < -80 {
          onSwipeUp()
        }
      }
  }

  private var rotationGesture: some Gesture {
    RotationGesture()
      .updating($rotation) { value, state, _ in
        state = value
        onScrub(value.degrees / 360.0)
      }
      .onEnded { value in
        scratchRotation += value
      }
  }
}
