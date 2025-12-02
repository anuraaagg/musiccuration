//
//  SongSearchSheet.swift
//  musiccuration
//
//  Created by Anurag Singh on 27/11/25.
//

import MusicKit
import SwiftUI

struct SongSearchSheet: View {
  @ObservedObject private var musicKit = MusicKitManager.shared
  @State private var searchText = ""
  @State private var selectedSong: Song?
  @State private var showExpandedView = false
  @FocusState private var isSearchFocused: Bool

  let onSongSelected: (Song) -> Void

  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        // Search Bar
        HStack(spacing: 12) {
          Image(systemName: "magnifyingglass")
            .font(.system(size: 18))
            .foregroundColor(.secondary)

          TextField("Search for a song...", text: $searchText)
            .textFieldStyle(.plain)
            .autocorrectionDisabled()
            .font(.system(size: 17))
            .focused($isSearchFocused)

          if !searchText.isEmpty {
            Button(action: {
              searchText = ""
            }) {
              Image(systemName: "xmark.circle.fill")
                .font(.system(size: 18))
                .foregroundColor(.secondary)
            }
          }
        }
        .padding(14)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6))
        )
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(Color(.systemGray4).opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 12)

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

  private var authorizationStatusText: String {
    switch musicKit.authorizationStatus {
    case .notDetermined:
      return "Not Determined"
    case .denied:
      return "Denied"
    case .restricted:
      return "Restricted"
    case .authorized:
      return "Authorized"
    @unknown default:
      return "Unknown"
    }
  }

  // MARK: - Search Results List

  private var searchResultsList: some View {
    Group {
      if musicKit.isSearching {
        VStack(spacing: 20) {
          Spacer()
          ProgressView()
            .scaleEffect(1.5)
            .tint(.blue)

          Text("Searching...")
            .font(.subheadline)
            .foregroundColor(.secondary)
          Spacer()
        }
      } else if let errorMessage = musicKit.lastErrorMessage {
        VStack(spacing: 12) {
          Spacer()
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 50))
            .foregroundColor(.orange)
          Text("Search Failed")
            .font(.headline)
          Text(errorMessage)
            .font(.caption)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
          Spacer()
        }
      } else if searchText.isEmpty {
        VStack(spacing: 16) {
          Spacer()
          Image(systemName: "music.note.list")
            .font(.system(size: 70))
            .foregroundColor(.gray.opacity(0.3))

          VStack(spacing: 8) {
            Text("Search for Your Favorite Songs")
              .font(.title3)
              .fontWeight(.medium)
              .foregroundColor(.primary)

            Text("Find songs, artists, or albums")
              .font(.subheadline)
              .foregroundColor(.secondary)
          }
          Spacer()
        }
        .padding()
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
                  // Dismiss keyboard first
                  isSearchFocused = false

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
        ArtworkImage(artwork, width: 260, height: 260)
          .clipShape(RoundedRectangle(cornerRadius: 24))
          .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
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

      // Play/Pause Button (compact)
      Button(action: {
        Task {
          await musicKit.togglePlayback(for: song)
        }
      }) {
        Image(systemName: musicKit.isPlaying(song: song) ? "pause.circle.fill" : "play.circle.fill")
          .font(.system(size: 44))
          .foregroundColor(.primary.opacity(0.7))
      }
      .padding(.top, 12)

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
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
          // Liquid glass thumbnail
          RoundedRectangle(cornerRadius: 10)
            .fill(
              LinearGradient(
                colors: [
                  Color.gray.opacity(0.12),
                  Color.gray.opacity(0.06),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 60, height: 60)
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
            )
            .overlay(
              Image(systemName: "music.note")
                .font(.system(size: 20))
                .foregroundColor(.secondary.opacity(0.4))
            )
            .overlay(
              RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
            )
        }

        // Song Info
        VStack(alignment: .leading, spacing: 2) {
          Text(song.title)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.primary)
            .lineLimit(1)

          Text(song.artistName)
            .font(.system(size: 13))
            .foregroundColor(.secondary)
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
