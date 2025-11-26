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
  @GestureState private var magnification: CGFloat = 1

  var body: some View {
    VStack(spacing: 24) {
      Text(String(format: "Week %02d", week.number))
        .font(.system(.largeTitle, design: .rounded))
        .fontWeight(.semibold)
      Text(week.dateRange)
        .font(.callout)
        .foregroundStyle(.secondary)

      Spacer(minLength: 12)

      VinylDisc(track: week.tracks[selectedDayIndex], scratchRotation: .degrees(0))
        .frame(width: 280, height: 280)
        .padding(.top, 8)
        .gesture(pinchingGesture)

      Spacer(minLength: 24)

      miniTracksRow

      Spacer(minLength: 24)

      HStack {
        Text(String(format: "Week %02d", max(1, week.number - 1)))
        Spacer()
        Text(String(format: "Week %02d", week.number + 1))
      }
      .font(.headline)
      .foregroundStyle(.secondary)
      .padding(.horizontal, 32)
    }
    .padding(.top, 40)
    .gesture(horizontalDragGesture)
  }

  private var miniTracksRow: some View {
    HStack(spacing: 12) {
      ForEach(week.tracks.indices, id: \.self) { index in
        let miniTrack = week.tracks[index]
        Button {
          selectedDayIndex = index
        } label: {
          VinylDisc(track: miniTrack, scratchRotation: .degrees(0))
            .frame(width: 48, height: 48)
            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 4)
            .overlay(
              Circle().stroke(
                Color.white.opacity(selectedDayIndex == index ? 0.5 : 0.0), lineWidth: 1.5)
            )
            .opacity(selectedDayIndex == index ? 1 : 0.6)
            .scaleEffect(selectedDayIndex == index ? 1.05 : 0.95)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.horizontal, 16)
  }

  private var horizontalDragGesture: some Gesture {
    DragGesture()
      .updating($dragOffset) { value, state, _ in
        state = value.translation.width
      }
      .onEnded { value in
        if value.translation.width < -80, currentWeekIndex < weeks.count - 1 {
          currentWeekIndex += 1
        } else if value.translation.width > 80, currentWeekIndex > 0 {
          currentWeekIndex -= 1
        }
      }
  }

  private var pinchingGesture: some Gesture {
    MagnificationGesture()
      .updating($magnification) { value, state, _ in
        state = value
      }
      .onEnded { value in
        if value < 0.9 {
          onPinchIn()
        }
      }
  }
}
