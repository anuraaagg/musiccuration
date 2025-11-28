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

      print("🔍 Starting search for: \(query)")
      print("🔐 Authorization status: \(authorizationStatus)")

      // Check Country Code
      do {
        let countryCode = try await MusicDataRequest.currentCountryCode
        print("🌍 Current Country Code: \(countryCode)")
      } catch {
        print("⚠️ Could not get country code: \(error.localizedDescription)")
      }

      // Debounce: wait 300ms
      try? await Task.sleep(nanoseconds: 300_000_000)

      guard !Task.isCancelled else {
        isSearching = false
        return
      }

      do {
        // 1. Try Complex Search (Songs, Albums, Artists)
        print("📡 Attempting complex search...")
        var searchRequest = MusicCatalogSearchRequest(
          term: query,
          types: [Song.self, Album.self, Artist.self]
        )
        searchRequest.limit = 20

        let searchResponse = try await searchRequest.response()
        print("✅ Complex search response received")

        // Collect all songs
        var allSongs: [Song] = []
        allSongs.append(contentsOf: Array(searchResponse.songs))

        for album in searchResponse.albums.prefix(3) {
          if let tracks = album.tracks {
            let songs = tracks.compactMap { track -> Song? in
              if case .song(let song) = track { return song }
              return nil
            }
            allSongs.append(contentsOf: songs.prefix(5))
          }
        }

        for artist in searchResponse.artists.prefix(2) {
          // Simplified artist fetch to reduce failure points
          let artistRequest = MusicCatalogResourceRequest<Artist>(
            matching: \.id, equalTo: artist.id)
          if let detailedArtist = try? await artistRequest.response().items.first,
            let topSongs = detailedArtist.topSongs
          {
            allSongs.append(contentsOf: Array(topSongs.prefix(5)))
          }
        }

        let uniqueSongs = Array(Set(allSongs)).prefix(20)
        searchResults = Array(uniqueSongs)

        // 2. Fallback: If no results, try simple song-only search
        if searchResults.isEmpty {
          print("⚠️ Complex search yielded no songs. Attempting simple fallback...")
          var simpleRequest = MusicCatalogSearchRequest(term: query, types: [Song.self])
          simpleRequest.limit = 20
          let simpleResponse = try await simpleRequest.response()
          searchResults = Array(simpleResponse.songs)
          print("✅ Simple fallback found \(searchResults.count) songs")
        }

        if searchResults.isEmpty {
          print("⚠️ No results found for query: \(query)")
        } else {
          print("🎵 Total unique songs found: \(searchResults.count)")
          print("🎵 First result: \(searchResults[0].title) by \(searchResults[0].artistName)")
        }

        isSearching = false
      } catch {
        print("❌ Search error: \(error.localizedDescription)")
        print("❌ Error details: \(error)")
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
