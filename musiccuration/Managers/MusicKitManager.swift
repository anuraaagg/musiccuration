//
//  MusicKitManager.swift
//  musiccuration
//
//  Created by Anurag Singh on 27/11/25.
//

import Combine
import Foundation
import MusicKit

@MainActor
class MusicKitManager: ObservableObject {
  static let shared = MusicKitManager()
  
  @Published var authorizationStatus: MusicAuthorization.Status = .notDetermined
  @Published var searchResults: [Song] = []
  @Published var isSearching: Bool = false
  @Published var currentlyPlayingSong: Song?

  private var searchTask: Task<Void, Never>?
  private var player: ApplicationMusicPlayer = ApplicationMusicPlayer.shared

  private init() {
    authorizationStatus = MusicAuthorization.currentStatus
  }

  // MARK: - Authorization

  func requestAuthorization() async {
    let status = await MusicAuthorization.request()
    authorizationStatus = status
  }

  // MARK: - Search

  func searchSongs(query: String) {
    // Cancel previous search
    searchTask?.cancel()

    guard !query.isEmpty else {
      searchResults = []
      return
    }

    searchTask = Task {
      isSearching = true

      // Debounce: wait 300ms
      try? await Task.sleep(nanoseconds: 300_000_000)

      guard !Task.isCancelled else {
        isSearching = false
        return
      }

      do {
        var searchRequest = MusicCatalogSearchRequest(term: query, types: [Song.self])
        searchRequest.limit = 20

        let searchResponse = try await searchRequest.response()

        guard !Task.isCancelled else {
          isSearching = false
          return
        }

        searchResults = Array(searchResponse.songs)
        isSearching = false
      } catch {
        print("Search error: \\(error.localizedDescription)")
        searchResults = []
        isSearching = false
      }
    }
  }

  // MARK: - Playback

  func playPreview(song: Song) async {
    do {
      // Stop current playback
      player.stop()

      // Set queue with the song
      player.queue = [song]

      // Play
      try await player.play()

      currentlyPlayingSong = song
    } catch {
      print("Playback error: \\(error.localizedDescription)")
    }
  }

  func stopPreview() {
    player.stop()
    currentlyPlayingSong = nil
  }

  func togglePlayback(for song: Song) async {
    if currentlyPlayingSong?.id == song.id {
      // Same song - toggle play/pause
      if player.state.playbackStatus == .playing {
        player.pause()
      } else {
        try? await player.play()
      }
    } else {
      // Different song - play it
      await playPreview(song: song)
    }
  }

  func isPlaying(song: Song) -> Bool {
    return currentlyPlayingSong?.id == song.id && player.state.playbackStatus == .playing
  }
}
