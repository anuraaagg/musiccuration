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
  @State private var lastDragValue: CGFloat = 0
  @State private var lastHapticValue: CGFloat = 0

  var body: some View {
    ZStack {
      // Background Gradient
      LinearGradient(
        colors: [
          Color(UIColor.systemBackground),
          Color(UIColor.secondarySystemBackground),
        ],
        startPoint: .top,
        endPoint: .bottom
      )
      .ignoresSafeArea()

      VStack(spacing: 48) {
        // Top Bar with Share
        HStack {
          Spacer()
          if let url = track.sourceURL {
            ShareLink(item: url) {
              Image(systemName: "square.and.arrow.up")
                .font(.system(size: 20))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.ultraThinMaterial))
            }
            .simultaneousGesture(
              TapGesture().onEnded {
                HapticsManager.shared.selectionTick()
              })
          }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)

        Spacer()

        // Vinyl Disc
        VinylDisc(track: track, scratchRotation: scratchRotation)
          .frame(width: 280, height: 280)
          .onTapGesture(count: 2) {
            // Double tap -> Restart
            progress = 0
            isPlaying = true
            HapticsManager.shared.play()
          }
          .gesture(
            DragGesture()
              .onChanged { value in
                // Calculate delta
                let delta = value.translation.width - lastDragValue
                lastDragValue = value.translation.width

                // Rotate vinyl based on delta
                scratchRotation = .degrees(scratchRotation.degrees + delta * 0.5)

                // Haptic feedback for scratching (distance based)
                if abs(value.translation.width - lastHapticValue) > 15 {
                  HapticsManager.shared.scratch()
                  lastHapticValue = value.translation.width
                }
              }
              .onEnded { value in
                lastDragValue = 0
                lastHapticValue = 0

                // Check dominant axis for swipe
                if abs(value.translation.height) > abs(value.translation.width) {
                  // Vertical Swipe
                  if value.translation.height > 100 {
                    HapticsManager.shared.selectionTick()
                    onSwipeDown()
                  } else if value.translation.height < -100 {
                    HapticsManager.shared.selectionTick()
                    onSwipeUp()
                  }
                } else {
                  // Horizontal Flick / Inertia
                  if abs(value.predictedEndTranslation.width) > 200 {
                    let velocity = value.predictedEndTranslation.width
                    withAnimation(.easeOut(duration: 1.5)) {
                      scratchRotation = .degrees(scratchRotation.degrees + velocity * 0.5)
                    }
                    HapticsManager.shared.selectionTick()
                  }
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
          Text("↻ Drag vinyl to scratch • Double tap to restart")
        }
        .font(.system(size: 14))
        .foregroundColor(.secondary)

        Spacer()
      }
    }
    .gesture(
      DragGesture()
        .onEnded { value in
          // Global Vertical Swipe
          if abs(value.translation.height) > abs(value.translation.width) {
            if value.translation.height > 50 {
              HapticsManager.shared.selectionTick()
              onSwipeDown()
            } else if value.translation.height < -50 {
              HapticsManager.shared.selectionTick()
              onSwipeUp()
            }
          }
        }
    )
  }
}
