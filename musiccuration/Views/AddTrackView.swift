//
//  AddTrackView.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import MusicKit
import SwiftUI

struct AddTrackView: View {
  @Binding var selectedCharacter: CharacterSticker
  @State private var selectedSong: Song?
  @State private var showSearchSheet = false
  var isEngraving: Bool
  var onCancel: () -> Void
  var onEngrave: (Song) -> Void

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

      VStack(spacing: 24) {
        Spacer()
          .frame(height: 20)

        // Title
        Text("Engrave Today's Song")
          .font(.system(size: 28, weight: .bold))

        // Square Vinyl Case
        SquareVinylCase(character: selectedCharacter, isEngraving: isEngraving)
          .frame(width: 280, height: 280)
          .padding(.bottom, 8)

        // Character Selector
        CharacterSelectorView(selectedCharacter: $selectedCharacter)
          .padding(.horizontal, 24)

        // Selected Song Display or Search Button
        VStack(spacing: 16) {
          if let song = selectedSong {
            // Selected Song Card
            VStack(spacing: 12) {
              HStack(spacing: 12) {
                // Album Art
                if let artwork = song.artwork {
                  ArtworkImage(artwork, width: 60, height: 60)
                    .cornerRadius(8)
                } else {
                  RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 60)
                }

                // Song Info
                VStack(alignment: .leading, spacing: 4) {
                  Text(song.title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)

                  Text(song.artistName)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                }

                Spacer()

                // Change Button
                Button(action: { showSearchSheet = true }) {
                  Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(selectedCharacter.accent)
                }
              }
              .padding()
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(.ultraThinMaterial)
              )
            }
          } else {
            // Search Button
            FrostedGlassButton(
              title: "Search for a Song",
              icon: "magnifyingglass",
              action: { showSearchSheet = true }
            )
          }

          // Engrave Button
          FrostedGlassButton(
            title: isEngraving ? "Engraving..." : "Press to Engrave",
            accentColor: selectedCharacter.accent,
            isEnabled: selectedSong != nil && !isEngraving,
            action: {
              if let song = selectedSong {
                onEngrave(song)
              }
            }
          )
        }
        .padding(.horizontal, 24)

        // Hint
        VStack(spacing: 4) {
          Text("Choose the song that represents your day.")
          Text("You can only pick one.")
        }
        .font(.system(size: 13))
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)

        Spacer()
      }

      Spacer()
    }
    .sheet(isPresented: $showSearchSheet) {
      SongSearchSheet(onSongSelected: { song in
        selectedSong = song
      })
    }
    .gesture(
      DragGesture()
        .onEnded { value in
          if value.translation.height > 100 {
            HapticsManager.shared.selectionTick()
            onCancel()
          }
        }
    )
  }
}
