//
//  WeekAlbumView.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import SwiftUI

struct WeekAlbumView: View {
  let week: Week
  let weeks: [Week]
  @Binding var selectedDayIndex: Int
  @Binding var currentWeekIndex: Int
  var onPinchIn: () -> Void

  @GestureState private var dragOffset: CGFloat = 0

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

      VStack(spacing: 0) {
        Spacer()
          .frame(height: 60)

        // Week Header
        VStack(spacing: 8) {
          Text("Week \(String(format: "%02d", week.number))")
            .font(.system(size: 36, weight: .bold))
          Text(week.dateRange)
            .font(.system(size: 16))
            .foregroundColor(.secondary)
        }
        .padding(.bottom, 40)

        // Large Album Vinyl
        VinylDisc(track: week.tracks[selectedDayIndex], scratchRotation: .degrees(0))
          .frame(width: 280, height: 280)
          .onTapGesture {
            HapticsManager.shared.selectionTick()
            onPinchIn()
          }
          .gesture(
            MagnificationGesture()
              .onEnded { value in
                if value > 1.2 {  // Zoom in
                  HapticsManager.shared.selectionTick()
                  onPinchIn()
                }
              }
          )
          .padding(.bottom, 20)

        // Song Info
        VStack(spacing: 4) {
          Text(week.tracks[selectedDayIndex].title)
            .font(.system(size: 20, weight: .bold))
            .lineLimit(1)
            .foregroundColor(.primary)

          Text(week.tracks[selectedDayIndex].artist)
            .font(.system(size: 16, weight: .medium))
            .lineLimit(1)
            .foregroundColor(.secondary)
        }
        .padding(.bottom, 30)

        // Mini Daily Vinyls
        HStack(spacing: 12) {
          ForEach(week.tracks.indices, id: \.self) { index in
            VinylDisc(track: week.tracks[index], scratchRotation: .degrees(0))
              .frame(width: 48, height: 48)
              .overlay(
                Circle().stroke(
                  week.tracks[index].accent,
                  lineWidth: selectedDayIndex == index ? 3 : 2
                )
                .padding(-2)
              )
              .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 4)
              .opacity(selectedDayIndex == index ? 1 : 0.7)
              .scaleEffect(selectedDayIndex == index ? 1.05 : 0.95)
              .onTapGesture {
                selectedDayIndex = index
                HapticsManager.shared.selectionTick()
              }
          }

          // Empty slots for remaining days
          ForEach(week.tracks.count..<7, id: \.self) { _ in
            Circle()
              .strokeBorder(
                Color.secondary.opacity(0.3),
                style: StrokeStyle(lineWidth: 2, dash: [5])
              )
              .frame(width: 48, height: 48)
          }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 24)

        // Week Navigation
        HStack(spacing: 16) {
          Button(action: {
            if currentWeekIndex > 0 {
              currentWeekIndex -= 1
            }
          }) {
            Image(systemName: "chevron.left")
              .font(.system(size: 20))
              .foregroundColor(.primary)
              .frame(width: 40, height: 40)
              .background(Circle().fill(.ultraThinMaterial))
          }

          Text("Week \(week.number)")
            .font(.system(size: 16, weight: .medium))
            .frame(width: 80)

          Button(action: {
            if currentWeekIndex < weeks.count - 1 {
              currentWeekIndex += 1
            }
          }) {
            Image(systemName: "chevron.right")
              .font(.system(size: 20))
              .foregroundColor(.primary)
              .frame(width: 40, height: 40)
              .background(Circle().fill(.ultraThinMaterial))
          }
        }
        .padding(12)
        .background(
          Capsule()
            .fill(.ultraThinMaterial)
        )
        .padding(.bottom, 16)

        // Back hint
        Text("Tap vinyl to return to today")
          .font(.system(size: 14))
          .foregroundColor(.secondary)

        Spacer()
          .frame(height: 40)
      }
    }
    .gesture(
      DragGesture()
        .updating($dragOffset) { value, state, _ in
          state = value.translation.width
        }
        .onEnded { value in
          // Check dominant axis
          if abs(value.translation.width) > abs(value.translation.height) {
            // Horizontal Swipe -> Change Week
            if value.translation.width < -80, currentWeekIndex < weeks.count - 1 {
              currentWeekIndex += 1
              HapticsManager.shared.selectionTick()
            } else if value.translation.width > 80, currentWeekIndex > 0 {
              currentWeekIndex -= 1
              HapticsManager.shared.selectionTick()
            }
          } else {
            // Vertical Swipe Up -> Return to Home
            if value.translation.height < -100 {
              HapticsManager.shared.selectionTick()
              onPinchIn()
            }
          }
        }
    )
  }

}
