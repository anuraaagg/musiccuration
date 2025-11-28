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

      #if targetEnvironment(simulator)
        // SIMULATOR MOCK MODE
        print("� Running on Simulator - Using Mock Data")
        try? await Task.sleep(nanoseconds: 500_000_000)  // Fake network delay

        self.searchResults = self.generateMockSongs().filter {
          $0.title.localizedCaseInsensitiveContains(query)
            || $0.artistName.localizedCaseInsensitiveContains(query)
        }

        if self.searchResults.isEmpty {
          // If query doesn't match mocks, just return all mocks so user sees something
          self.searchResults = self.generateMockSongs()
        }

        print("✅ Mock search found \(self.searchResults.count) songs")
        isSearching = false
        return
      #else

        // REAL DEVICE SEARCH
        print("�🔐 Authorization status: \(authorizationStatus)")

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
      #endif
    }
  }

  // MARK: - Mock Data

  private func generateMockSongs() -> [Song] {
    // Helper to create a Song from JSON
    func mockSong(id: String, title: String, artist: String, album: String) -> Song? {
      let json = """
        {
          "id": "\(id)",
          "type": "songs",
          "href": "/v1/catalog/us/songs/\(id)",
          "attributes": {
            "name": "\(title)",
            "artistName": "\(artist)",
            "albumName": "\(album)",
            "url": "https://music.apple.com/us/song/\(id)",
            "playParams": {
              "id": "\(id)",
              "kind": "song"
            },
            "previews": [{"url": "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview115/v4/9e/03/90/9e0390d9-2909-0e42-0542-4d229d220120/mzaf_1346766467630881180.plus.aac.p.m4a"}],
            "artwork": {
              "width": 3000,
              "height": 3000,
              "url": "https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/73/58/aa/7358aa28-5a8b-10e0-8215-49866d67e841/19UMGIM53909.rgb.jpg/{w}x{h}bb.jpg",
              "bgColor": "111111",
              "textColor1": "ffffff",
              "textColor2": "eeeeee",
              "textColor3": "dddddd",
              "textColor4": "cccccc"
            }
          }
        }
        """
      guard let data = json.data(using: .utf8) else { return nil }
      do {
        return try JSONDecoder().decode(Song.self, from: data)
      } catch {
        print("❌ Mock Decoding Error for \(title): \(error)")
        return nil
      }
    }

    let mocks = [
      mockSong(id: "1001", title: "Blinding Lights", artist: "The Weeknd", album: "After Hours"),
      mockSong(id: "1002", title: "Shape of You", artist: "Ed Sheeran", album: "Divide"),
      mockSong(id: "1003", title: "Levitating", artist: "Dua Lipa", album: "Future Nostalgia"),
      mockSong(
        id: "1004", title: "Stay", artist: "The Kid LAROI & Justin Bieber", album: "F*CK LOVE 3"),
      mockSong(id: "1005", title: "Montero", artist: "Lil Nas X", album: "Montero"),
      mockSong(id: "1006", title: "Peaches", artist: "Justin Bieber", album: "Justice"),
      mockSong(id: "1007", title: "Drivers License", artist: "Olivia Rodrigo", album: "SOUR"),
      mockSong(id: "1008", title: "Good 4 U", artist: "Olivia Rodrigo", album: "SOUR"),
      mockSong(id: "1009", title: "Kiss Me More", artist: "Doja Cat", album: "Planet Her"),
      mockSong(id: "1010", title: "Bad Habits", artist: "Ed Sheeran", album: "Equals"),
    ]

    let validMocks = mocks.compactMap { $0 }
    print("✅ Generated \(validMocks.count) mock songs")
    return validMocks
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
