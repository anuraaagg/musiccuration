//
//  VinylDisc.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import SwiftUI

struct VinylDisc: View {
  let track: Track
  var scratchRotation: Angle

  var body: some View {
    GeometryReader { geometry in
      let size = min(geometry.size.width, geometry.size.height)
      let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

      ZStack {
        // Main black vinyl disc
        Circle()
          .fill(
            RadialGradient(
              gradient: Gradient(colors: [.black, Color.black.opacity(0.2)]),
              center: .center,
              startRadius: size * 0.1,
              endRadius: size * 0.5
            )
          )
          .overlay(
            Circle()
              .stroke(Color.white.opacity(0.2), lineWidth: size * 0.0035)
              .blur(radius: size * 0.01)
          )

        // Decorative rings
        Circle()
          .strokeBorder(Color.white.opacity(0.25), lineWidth: size * 0.0035)
          .padding(size * 0.057)  // approx 16/280
        Circle()
          .strokeBorder(Color.white.opacity(0.2), lineWidth: size * 0.0035)
          .padding(size * 0.114)  // approx 32/280

        // Concentric groove rings
        ForEach(0..<12, id: \.self) { i in
          Circle()
            .stroke(Color.white.opacity(0.06), lineWidth: size * 0.0035)
            .padding(size * (0.157 + CGFloat(i) * 0.028))  // approx (44 + i*8)/280
        }

        // Sweeping highlight
        AngularGradient(
          gradient: Gradient(colors: [
            Color.white.opacity(0.18), Color.clear, Color.clear, Color.white.opacity(0.12),
          ]), center: .center
        )
        .mask(
          Circle()
            .stroke(lineWidth: size * 0.5)
            .padding(size * 0.07)
        )
        .blur(radius: size * 0.007)

        // Album Art Label
        Circle()
          .fill(track.accent.opacity(0.9))
          .frame(width: size * 0.39, height: size * 0.39)  // 110/280
          .overlay(
            Group {
              if let name = track.artworkName {
                Image(name)
                  .resizable()
                  .scaledToFill()
              } else {
                Image(track.character.imageName)
                  .resizable()
                  .scaledToFill()
              }
            }
            .clipShape(Circle())
            .padding(size * 0.02)
          )

        // Center Hole
        Circle()
          .fill(Color.white.opacity(0.85))
          .frame(width: size * 0.078)  // 22/280
      }
      .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
      .rotationEffect(scratchRotation)
      .shadow(color: .black.opacity(0.15), radius: size * 0.07, x: 0, y: size * 0.07)
    }
  }
}

struct VinylPlaceholder: View {
  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 36, style: .continuous)
        .fill(.ultraThinMaterial)
      if let sticker = CharacterStickerLibrary.all.first {
        VinylDisc(
          track: Track(
            title: "Placeholder",
            artist: "Artist",
            dayIndex: 0,
            weekIndex: 0,
            accent: sticker.accent,
            character: sticker,
            artworkName: "VinylLabel01",
            sourceURL: nil
          ),
          scratchRotation: .degrees(0)
        )
        .opacity(0.6)
      }
    }
    .padding(.horizontal, 60)
  }
}
