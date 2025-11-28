//
//  PlayerControls.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import Combine
import SwiftUI

// MARK: - Glass Player (Main Component)

struct WaveformPlayerBar: View {
  @Binding var progress: CGFloat
  @Binding var isPlaying: Bool
  var artworkName: String?
  var accent: Color
  var onScrub: (CGFloat) -> Void

  @State private var rotation: Double = 0
  let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

  var body: some View {
    HStack(spacing: 16) {
      // Album Artwork
      ZStack {
        Circle()
          .fill(accent.opacity(0.3))

        if let name = artworkName {
          Image(name)
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
        }
      }
      .frame(width: 56, height: 56)
      .overlay(
        Circle()
          .stroke(Color.white.opacity(0.3), lineWidth: 2)
      )
      .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
      .rotationEffect(.degrees(rotation))
      .onReceive(timer) { _ in
        if isPlaying {
          rotation += 1.5
          // Auto-advance progress (simulate 3 minute song)
          if progress < 1.0 {
            progress += 0.02 / 180.0
          } else {
            isPlaying = false
            progress = 0
          }
        }
      }

      // Waveform
      Waveform(
        progress: $progress,
        isPlaying: $isPlaying,
        accent: accent,
        onScrub: onScrub
      )

      // Play/Pause Button
      Button(action: {
        isPlaying.toggle()
        if isPlaying {
          HapticsManager.shared.play()
        } else {
          HapticsManager.shared.pause()
        }
      }) {
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
          .font(.system(size: 20))
          .foregroundColor(.primary.opacity(0.8))
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 24, style: .continuous)
        .fill(.ultraThinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
    )
  }
}

// MARK: - Waveform

struct Waveform: View {
  @Binding var progress: CGFloat
  @Binding var isPlaying: Bool
  var accent: Color
  var onScrub: (CGFloat) -> Void

  @State private var bars: [CGFloat] = (0..<30).map { _ in CGFloat.random(in: 0.2...1) }

  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      ZStack(alignment: .leading) {
        // Background
        Capsule()
          .fill(Color.white.opacity(0.15))
          .frame(height: 40)

        // Waveform Bars
        HStack(spacing: 3) {
          ForEach(0..<bars.count, id: \.self) { index in
            Capsule()
              .fill(indexFraction(index) <= progress ? accent : Color.white.opacity(0.3))
              .frame(width: 3, height: 8 + bars[index] * 28)
          }
        }
        .padding(.horizontal, 10)
        .frame(height: 40)
        .contentShape(Rectangle())
        .gesture(scrubGesture(width: width))
      }
      // Removed onTapGesture as per user request to use the button instead
    }
    .frame(height: 40)
  }

  private func indexFraction(_ index: Int) -> CGFloat {
    CGFloat(index) / CGFloat(bars.count - 1)
  }

  private func scrubGesture(width: CGFloat) -> some Gesture {
    DragGesture(minimumDistance: 0)
      .onChanged { value in
        let position = max(0, min(width, value.location.x))
        progress = position / width
        onScrub(0)
      }
  }
}

// MARK: - Play Button (Optional - for future use)

struct PlayButton: View {
  @Binding var isPlaying: Bool

  var body: some View {
    Button {
      isPlaying.toggle()
    } label: {
      Image(systemName: isPlaying ? "pause.fill" : "play.fill")
        .font(.system(size: 18, weight: .heavy))
        .foregroundColor(Color.white)
        .frame(width: 46, height: 46)
        .background(
          Circle()
            .fill(Color.black)
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Progress Ring (Optional - for future use)

struct ProgressRing: View {
  var progress: CGFloat
  var color: Color

  var body: some View {
    Circle()
      .trim(from: 0, to: min(1, max(0, progress)))
      .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
      .foregroundStyle(color)
      .rotationEffect(.degrees(-90))
      .padding(6)
  }
}
