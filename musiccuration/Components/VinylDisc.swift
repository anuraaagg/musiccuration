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
    ZStack {
      Circle()
        .fill(
          RadialGradient(
            gradient: Gradient(colors: [.black, Color.black.opacity(0.2)]),
            center: .center,
            startRadius: 30,
            endRadius: 140
          )
        )
        .overlay(
          Circle()
            .stroke(Color.white.opacity(0.2), lineWidth: 1)
            .blur(radius: 3)
        )

      Circle()
        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
        .padding(16)
      Circle()
        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        .padding(32)

      // Concentric groove rings
      ForEach(0..<12, id: \.self) { i in
        Circle()
          .stroke(Color.white.opacity(0.06), lineWidth: 1)
          .padding(CGFloat(44 + i * 8))
      }

      // Sweeping highlight
      AngularGradient(
        gradient: Gradient(colors: [
          Color.white.opacity(0.18), Color.clear, Color.clear, Color.white.opacity(0.12),
        ]), center: .center
      )
      .mask(
        Circle()
          .stroke(lineWidth: 140)
          .padding(20)
      )
      .blur(radius: 2)

      Circle()
        .fill(track.accent.opacity(0.9))
        .frame(width: 110, height: 110)
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
          .padding(6)
        )
      Circle()
        .fill(Color.white.opacity(0.85))
        .frame(width: 22)
    }
    .rotationEffect(scratchRotation)
    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 20)
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
