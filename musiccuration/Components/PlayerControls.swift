//
//  PlayerControls.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import SwiftUI

struct WaveformPlayerBar: View {
  @Binding var progress: CGFloat
  @Binding var isPlaying: Bool
  var artworkName: String?
  var accent: Color
  var onScrub: (CGFloat) -> Void

  var body: some View {
    HStack(spacing: 18) {
      ZStack {
        Circle()
          .fill(Color.white.opacity(0.6))
        Group {
          if let name = artworkName {
            Image(name)
              .resizable()
              .scaledToFill()
          }
        }
      }
      .frame(width: 50, height: 50)
      .clipShape(Circle())
      .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))

      Waveform(progress: $progress, isPlaying: $isPlaying, accent: accent, onScrub: onScrub)

      Button {
        // share stub
      } label: {
        Image(systemName: "square.and.arrow.up")
          .font(.system(size: 18, weight: .semibold))
          .foregroundStyle(.secondary)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 28, style: .continuous)
        .fill(.thinMaterial)
        .overlay(
          RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(
            Color.white.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 10)
    )
  }
}

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

struct Waveform: View {
  @Binding var progress: CGFloat
  @Binding var isPlaying: Bool
  var accent: Color
  var onScrub: (CGFloat) -> Void

  let bars = (0..<30).map { _ in CGFloat.random(in: 0.2...1) }

  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color.white.opacity(0.25))
          .frame(height: 36)

        HStack(spacing: 4) {
          ForEach(0..<bars.count, id: \.self) { index in
            Capsule()
              .fill(indexFraction(index) <= progress ? accent : Color.white.opacity(0.4))
              .frame(width: 4, height: 6 + bars[index] * 24)
          }
        }
        .padding(.horizontal, 8)
        .frame(height: 36)
        .contentShape(Rectangle())
        .gesture(scrubGesture(width: width))
      }
      .onTapGesture {
        isPlaying.toggle()
      }
    }
    .frame(height: 36)
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
