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

      // Debounce: wait 300ms
      try? await Task.sleep(nanoseconds: 300_000_000)

      guard !Task.isCancelled else {
        isSearching = false
        return
      }

      do {
        // Search for songs, albums, AND artists
        var searchRequest = MusicCatalogSearchRequest(
          term: query,
          types: [Song.self, Album.self, Artist.self]
        )
        searchRequest.limit = 20

        print("📡 Sending search request for songs, albums, and artists...")
        let searchResponse = try await searchRequest.response()

        print("✅ Search completed:")
        print("   Songs: \(searchResponse.songs.count)")
        print("   Albums: \(searchResponse.albums.count)")
        print("   Artists: \(searchResponse.artists.count)")

        guard !Task.isCancelled else {
          isSearching = false
          return
        }

        // Collect all songs from different sources
        var allSongs: [Song] = []

        // Direct song results
        allSongs.append(contentsOf: Array(searchResponse.songs))

        // Get songs from top albums
        for album in searchResponse.albums.prefix(3) {
          if let tracks = album.tracks {
            // Filter tracks that are songs (Track can be Song or MusicVideo)
            let songs = tracks.compactMap { track -> Song? in
              if case .song(let song) = track {
                return song
              }
              return nil
            }
            allSongs.append(contentsOf: songs.prefix(5))
          }
        }

        // Get top songs from artists
        for artist in searchResponse.artists.prefix(2) {
          do {
            let artistRequest = MusicCatalogResourceRequest<Artist>(
              matching: \.id, equalTo: artist.id)
            let detailedArtist = try await artistRequest.response().items.first

            if let topSongs = detailedArtist?.topSongs {
              allSongs.append(contentsOf: Array(topSongs.prefix(5)))
            }
          } catch {
            print("⚠️ Could not fetch artist top songs: \(error.localizedDescription)")
          }
        }

        // Remove duplicates and limit results
        let uniqueSongs = Array(Set(allSongs)).prefix(20)
        searchResults = Array(uniqueSongs)

        if searchResults.isEmpty {
          print("⚠️ No results found for query: \(query)")
        } else {
          print("🎵 Total unique songs found: \(searchResults.count)")
          print("🎵 First result: \(searchResults[0].title) by \(searchResults[0].artistName)")
        }

        isSearching = false
      } catch {
        print("❌ Search error: \(error.localizedDescription)")
        print("❌ Error type: \(type(of: error))")
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
