//
//  SongSearchSheet.swift
//  musiccuration
//
//  Created by Anurag Singh on 27/11/25.
//

import MusicKit
import SwiftUI

struct SongSearchSheet: View {
  @StateObject private var musicKit = MusicKitManager()
  @State private var searchText = ""
  @State private var selectedSong: Song?
  @State private var showExpandedView = false

  let onSongSelected: (Song) -> Void

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Search Bar
        HStack {
          Image(systemName: "magnifyingglass")
            .foregroundColor(.gray)

          TextField("Search for a song...", text: $searchText)
            .textFieldStyle(.plain)
            .autocorrectionDisabled()

          if !searchText.isEmpty {
            Button(action: { searchText = "" }) {
              Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
            }
          }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding()

        // Content
        if showExpandedView, let song = selectedSong {
          // Expanded Song Preview
          expandedSongView(song: song)
        } else {
          // Search Results List
          searchResultsList
        }
      }
      .navigationTitle("Search Songs")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
    .onChange(of: searchText) { _, newValue in
      musicKit.searchSongs(query: newValue)
    }
    .task {
      await musicKit.requestAuthorization()
    }
  }

  // MARK: - Search Results List

  private var searchResultsList: some View {
    Group {
      if musicKit.isSearching {
        VStack {
          Spacer()
          ProgressView()
            .scaleEffect(1.5)
          Text("Searching...")
            .foregroundColor(.gray)
            .padding(.top)
          Spacer()
        }
      } else if searchText.isEmpty {
        VStack {
          Spacer()
          Image(systemName: "music.note.list")
            .font(.system(size: 60))
            .foregroundColor(.gray.opacity(0.5))
          Text("Search for a song")
            .font(.title3)
            .foregroundColor(.gray)
            .padding(.top, 8)
          Spacer()
        }
      } else if musicKit.searchResults.isEmpty {
        VStack {
          Spacer()
          Image(systemName: "magnifyingglass")
            .font(.system(size: 60))
            .foregroundColor(.gray.opacity(0.5))
          Text("No songs found")
            .font(.title3)
            .foregroundColor(.gray)
            .padding(.top, 8)
          Text("Try a different search")
            .font(.caption)
            .foregroundColor(.gray.opacity(0.7))
          Spacer()
        }
      } else {
        ScrollView {
          LazyVStack(spacing: 0) {
            ForEach(musicKit.searchResults, id: \.id) { song in
              SongRow(
                song: song,
                isPlaying: musicKit.isPlaying(song: song),
                onTap: {
                  withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    selectedSong = song
                    showExpandedView = true
                  }
                  musicKit.stopPreview()
                },
                onPlayPause: {
                  Task {
                    await musicKit.togglePlayback(for: song)
                  }
                }
              )

              if song.id != musicKit.searchResults.last?.id {
                Divider()
                  .padding(.leading, 80)
              }
            }
          }
        }
      }
    }
  }

  // MARK: - Expanded Song View

  private func expandedSongView(song: Song) -> some View {
    VStack(spacing: 24) {
      Spacer()

      // Album Art
      if let artwork = song.artwork {
        ArtworkImage(artwork, width: 280, height: 280)
          .cornerRadius(20)
          .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
      } else {
        RoundedRectangle(cornerRadius: 20)
          .fill(Color.gray.opacity(0.2))
          .frame(width: 280, height: 280)
          .overlay(
            Image(systemName: "music.note")
              .font(.system(size: 80))
              .foregroundColor(.gray)
          )
      }

      // Song Info
      VStack(spacing: 8) {
        Text(song.title)
          .font(.title2)
          .fontWeight(.bold)
          .multilineTextAlignment(.center)

        Text(song.artistName)
          .font(.title3)
          .foregroundColor(.gray)
          .multilineTextAlignment(.center)
      }
      .padding(.horizontal)

      // Play/Pause Button
      Button(action: {
        Task {
          await musicKit.togglePlayback(for: song)
        }
      }) {
        HStack(spacing: 12) {
          Image(systemName: musicKit.isPlaying(song: song) ? "pause.fill" : "play.fill")
            .font(.system(size: 20))
          Text(musicKit.isPlaying(song: song) ? "Pause Preview" : "Play Preview")
            .font(.system(size: 18, weight: .semibold))
        }
        .foregroundColor(.black)
        .padding(.horizontal, 32)
        .padding(.vertical, 16)
        .background(
          RoundedRectangle(cornerRadius: 100)
            .fill(.ultraThinMaterial)
            .overlay(
              RoundedRectangle(cornerRadius: 100)
                .fill(
                  LinearGradient(
                    colors: [Color.white.opacity(0.7), Color.white.opacity(0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                )
            )
        )
        .overlay(
          RoundedRectangle(cornerRadius: 100)
            .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
        )
      }

      Spacer()

      // Select Button
      FrostedGlassButton(
        title: "Select This Song",
        accentColor: .purple,
        action: {
          musicKit.stopPreview()
          onSongSelected(song)
          dismiss()
        }
      )
      .padding(.horizontal)

      // Back Button
      Button(action: {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
          showExpandedView = false
          selectedSong = nil
        }
        musicKit.stopPreview()
      }) {
        Text("Back to Results")
          .font(.system(size: 16))
          .foregroundColor(.gray)
      }
      .padding(.bottom, 20)
    }
  }
}

// MARK: - Song Row Component

struct SongRow: View {
  let song: Song
  let isPlaying: Bool
  let onTap: () -> Void
  let onPlayPause: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 12) {
        // Album Art
        if let artwork = song.artwork {
          ArtworkImage(artwork, width: 60, height: 60)
            .cornerRadius(8)
        } else {
          RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 60, height: 60)
            .overlay(
              Image(systemName: "music.note")
                .foregroundColor(.gray)
            )
        }

        // Song Info
        VStack(alignment: .leading, spacing: 4) {
          Text(song.title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.primary)
            .lineLimit(1)

          Text(song.artistName)
            .font(.system(size: 14))
            .foregroundColor(.gray)
            .lineLimit(1)
        }

        Spacer()

        // Play/Pause Button
        Button(action: onPlayPause) {
          Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
            .font(.system(size: 32))
            .foregroundColor(.purple)
        }
        .buttonStyle(.plain)
      }
      .padding(.horizontal)
      .padding(.vertical, 12)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  SongSearchSheet(onSongSelected: { _ in })
}
