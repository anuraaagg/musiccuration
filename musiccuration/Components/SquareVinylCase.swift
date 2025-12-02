//
//  SquareVinylCase.swift
//  musiccuration
//
//  Created by Anurag Singh on 26/11/25.
//

import SwiftUI

struct SquareVinylCase: View {
  let character: CharacterSticker
  var isEngraving: Bool = false

  @State private var shimmerOffset: CGFloat = -1.0
  @State private var dragTranslation: CGSize = .zero
  @State private var isDragging: Bool = false

  var body: some View {
    GeometryReader { geometry in
      let size = geometry.size.width

      ZStack {
        // Liquid Glass Background
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .fill(.ultraThinMaterial)
          .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
              .fill(Color.white.opacity(0.1))
          )
          .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
              .stroke(
                LinearGradient(
                  colors: [
                    Color.white.opacity(0.3),
                    Color.white.opacity(0.1),
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: 1
              )
          )
          .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
          .frame(width: size, height: size)

        // Inner Shadow Effect
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .fill(
            LinearGradient(
              colors: [
                Color.black.opacity(0.05),
                Color.clear,
                Color.clear,
                Color.black.opacity(0.03),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .padding(1)
          .frame(width: size, height: size)

        // Holographic Reflective Overlay
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .fill(
            LinearGradient(
              colors: [
                Color.white.opacity(0.0),
                Color.cyan.opacity(0.15),
                Color.purple.opacity(0.12),
                Color.pink.opacity(0.15),
                Color.white.opacity(0.0),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .offset(x: shimmerOffset * size, y: shimmerOffset * size * 0.5)
          .blur(radius: 20)
          .blendMode(.overlay)
          .mask(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
          )
          .frame(width: size, height: size)
          .onAppear {
            withAnimation(
              .linear(duration: 3)
                .repeatForever(autoreverses: true)
            ) {
              shimmerOffset = 1.0
            }
          }

        // Interactive Glare Effect (appears on drag)
        Rectangle()
          .frame(width: size * 1.2, height: size * 0.2)
          .foregroundColor(.white)
          .blendMode(.overlay)
          .blur(radius: 40)
          .offset(
            x: -dragTranslation.width / 1.5,
            y: -dragTranslation.height / 1.5
          )
          .rotationEffect(.degrees(45))
          .opacity(isDragging ? 0.6 : 0)
          .mask(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
          )

        // Specular Highlight (simulates light reflection)
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .fill(
            RadialGradient(
              colors: [
                Color.white.opacity(0.3),
                Color.white.opacity(0.0),
              ],
              center: .topLeading,
              startRadius: 0,
              endRadius: size * 0.8
            )
          )
          .blendMode(.overlay)
          .frame(width: size, height: size)

        // Paper Texture Overlay
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .fill(
            LinearGradient(
              colors: [
                Color.white.opacity(0.02),
                Color.black.opacity(0.01),
                Color.white.opacity(0.015),
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .overlay(
            // Subtle grain effect
            Canvas { context, size in
              for _ in 0..<50 {
                let x = CGFloat.random(in: 0...size.width)
                let y = CGFloat.random(in: 0...size.height)
                let rect = CGRect(x: x, y: y, width: 1, height: 1)
                context.fill(Path(rect), with: .color(.white.opacity(0.05)))
              }
            }
          )
          .frame(width: size, height: size)

        // Vinyl Disc with Parallax Movement
        VinylDisc(
          track: Track(
            title: "Preview",
            artist: "Artist",
            dayIndex: 0,
            weekIndex: 0,
            accent: character.accent,
            character: character,
            artworkName: "VinylLabel01",
            sourceURL: nil
          ),
          scratchRotation: .degrees(0)
        )
        .frame(width: size * 0.7, height: size * 0.7)
        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 0)  // Subtle rim shadow
        .offset(
          x: dragTranslation.width / 10,  // Increased movement for "floating" feel
          y: dragTranslation.height / 10
        )
        .rotationEffect(.degrees(isEngraving ? 360 : 0))
        .animation(
          isEngraving ? .linear(duration: 2).repeatForever(autoreverses: false) : .default,
          value: isEngraving
        )

        // Decorative Stickers (randomly placed)
        Group {
          // Music note sticker
          Text("🎵")
            .font(.system(size: size * 0.12))
            .rotationEffect(.degrees(-15))
            .offset(x: size * 0.28, y: -size * 0.32)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)

          // Star sticker
          Text("⭐")
            .font(.system(size: size * 0.1))
            .rotationEffect(.degrees(20))
            .offset(x: -size * 0.3, y: -size * 0.35)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)

          // Heart sticker
          Text("💖")
            .font(.system(size: size * 0.08))
            .rotationEffect(.degrees(-8))
            .offset(x: size * 0.32, y: size * 0.3)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)

          // Sparkle sticker
          Text("✨")
            .font(.system(size: size * 0.09))
            .rotationEffect(.degrees(12))
            .offset(x: -size * 0.35, y: size * 0.28)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)

          // Album sticker
          Text("💿")
            .font(.system(size: size * 0.08))
            .rotationEffect(.degrees(-25))
            .offset(x: size * 0.25, y: -size * 0.25)
            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        }
        .opacity(0.7)

        // Outer Glow
        RoundedRectangle(cornerRadius: 24, style: .continuous)
          .fill(Color.white.opacity(0.001))
          .frame(width: size, height: size)
          .shadow(
            color: character.accent.opacity(isDragging ? 0.4 : 0.2),
            radius: isDragging ? 24 : 16,
            x: 0,
            y: 0
          )
      }
      .frame(width: size, height: size)  // Ensure ZStack fills the GeometryReader
      .compositingGroup()
      .rotation3DEffect(
        .degrees(isDragging ? 12 : 0),
        axis: (
          x: -dragTranslation.height,
          y: dragTranslation.width,
          z: 0.0
        )
      )
      .gesture(
        DragGesture()
          .onChanged { value in
            withAnimation(.easeOut(duration: 0.15)) {
              dragTranslation = value.translation
              isDragging = true
            }
          }
          .onEnded { _ in
            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
              dragTranslation = .zero
              isDragging = false
            }
          }
      )
    }
  }
}
