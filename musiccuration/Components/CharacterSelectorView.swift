//
//  CharacterSelectorView.swift
//  musiccuration
//
//  Created by Anurag Singh on 26/11/25.
//

import SwiftUI

struct CharacterSelectorView: View {
  @Binding var selectedCharacter: CharacterSticker

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Choose Character")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.secondary)
        .padding(.leading, 4)

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(CharacterStickerLibrary.all, id: \.id) { character in
            CharacterButton(
              character: character,
              isSelected: selectedCharacter.id == character.id,
              action: {
                selectedCharacter = character
                HapticsManager.shared.selectionTick()
              }
            )
          }
        }
        .padding(.horizontal, 4)
      }
    }
  }
}

struct CharacterButton: View {
  let character: CharacterSticker
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      ZStack {
        // Background Circle
        Circle()
          .fill(character.accent.opacity(0.2))
          .frame(width: 52, height: 52)

        // Character Image or Fallback
        ZStack {
          // Try to load the image
          if let uiImage = UIImage(named: character.imageName) {
            Image(uiImage: uiImage)
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 40, height: 40)  // Reduced from 44 to prevent cropping when scaled
          } else {
            // Fallback: Show character initial
            Text(String(character.name.prefix(1)))
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(character.accent)
          }
        }

        // Selection Ring
        if isSelected {
          Circle()
            .stroke(character.accent, lineWidth: 2.5)
            .frame(width: 52, height: 52)
            .shadow(color: character.accent.opacity(0.4), radius: 6, x: 0, y: 0)
        }
      }
    }
    .buttonStyle(.plain)
    .scaleEffect(isSelected ? 1.05 : 1.0)  // Reduced from 1.1 to prevent cropping
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
  }
}
