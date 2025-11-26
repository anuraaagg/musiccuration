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
            onPinchIn()
          }
          .padding(.bottom, 50)

        // Mini Daily Vinyls
        HStack(spacing: 12) {
          ForEach(week.tracks.indices, id: \.self) { index in
            VinylDisc(track: week.tracks[index], scratchRotation: .degrees(0))
              .frame(width: 48, height: 48)
              .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 4)
              .overlay(
                Circle().stroke(
                  Color.white.opacity(selectedDayIndex == index ? 0.5 : 0.0),
                  lineWidth: 1.5
                )
              )
              .opacity(selectedDayIndex == index ? 1 : 0.6)
              .scaleEffect(selectedDayIndex == index ? 1.05 : 0.95)
              .onTapGesture {
                selectedDayIndex = index
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
    .gesture(horizontalDragGesture)
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
}
