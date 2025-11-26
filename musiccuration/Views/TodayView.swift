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

  @State private var dragOffset: CGSize = .zero

  var body: some View {
    ZStack {
      // Background Gradient
      LinearGradient(
        colors: [
          Color(UIColor.systemBackground),
          Color(UIColor.secondarySystemBackground)
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()

      VStack(spacing: 48) {
        Spacer()

        // Vinyl Disc
        VinylDisc(track: track, scratchRotation: scratchRotation)
          .frame(width: 280, height: 280)
          .gesture(
            DragGesture()
              .onChanged { value in
                dragOffset = value.translation
                // Rotate vinyl based on horizontal drag
                let rotationDelta = value.translation.width * 0.5
                scratchRotation = .degrees(scratchRotation.degrees + rotationDelta * 0.1)
              }
              .onEnded { value in
                // Swipe down -> Week View
                if value.translation.height > 100 {
                  onSwipeDown()
                }
                // Swipe up -> Add Track
                else if value.translation.height < -100 {
                  onSwipeUp()
                }
                dragOffset = .zero
              }
          )

        // Track Info
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

        // Player Controls
        WaveformPlayerBar(
          progress: $progress,
          isPlaying: $isPlaying,
          artworkName: track.artworkName,
          accent: track.accent,
          onScrub: onScrub
        )
        .padding(.horizontal, 24)

        // Gesture Hints
        VStack(spacing: 8) {
          Text("↓ Swipe down for week view")
          Text("↑ Swipe up to add track")
          Text("↻ Drag vinyl to scratch")
        }
        .font(.system(size: 14))
        .foregroundColor(.secondary)

        Spacer()
      }
    }
  }
}
