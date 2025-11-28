//
//  MusicModels.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import Foundation
import SwiftUI

struct Track: Identifiable, Hashable, Equatable {
  let id: UUID
  let title: String
  let artist: String
  let dayIndex: Int
  let weekIndex: Int
  let accent: Color
  let character: CharacterSticker
  let artworkName: String?
  let sourceURL: URL?
  
  // MusicKit fields
  let appleMusicID: String?
  let previewURL: URL?
  let engravedDate: Date

  init(
    id: UUID = UUID(), title: String, artist: String, dayIndex: Int, weekIndex: Int, accent: Color,
    character: CharacterSticker, artworkName: String?, sourceURL: URL?,
    appleMusicID: String? = nil, previewURL: URL? = nil, engravedDate: Date = Date()
  ) {
    self.id = id
    self.title = title
    self.artist = artist
    self.dayIndex = dayIndex
    self.weekIndex = weekIndex
    self.accent = accent
    self.character = character
    self.artworkName = artworkName
    self.sourceURL = sourceURL
    self.appleMusicID = appleMusicID
    self.previewURL = previewURL
    self.engravedDate = engravedDate
  }

  static func == (lhs: Track, rhs: Track) -> Bool { lhs.id == rhs.id }
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct CharacterSticker: Identifiable, Hashable, Equatable {
  let id: UUID
  let name: String
  let imageName: String
  let accent: Color

  init(id: UUID = UUID(), name: String, imageName: String, accent: Color) {
    self.id = id
    self.name = name
    self.imageName = imageName
    self.accent = accent
  }

  static func == (lhs: CharacterSticker, rhs: CharacterSticker) -> Bool { lhs.id == rhs.id }
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Week: Identifiable, Hashable, Equatable {
  let id: UUID
  let number: Int
  let dateRange: String
  var tracks: [Track]

  init(id: UUID = UUID(), number: Int, dateRange: String, tracks: [Track]) {
    self.id = id
    self.number = number
    self.dateRange = dateRange
    self.tracks = tracks
  }

  var coverAccent: Color {
    tracks.first?.accent ?? .gray
  }

  static func == (lhs: Week, rhs: Week) -> Bool { lhs.id == rhs.id }
  func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct CharacterStickerLibrary {
  static let all: [CharacterSticker] = [
    CharacterSticker(
      name: "Nova", imageName: "VinylLabel01", accent: Color(red: 0.98, green: 0.36, blue: 0.56)),
    CharacterSticker(
      name: "Orbit", imageName: "VinylLabel02", accent: Color(red: 0.64, green: 0.76, blue: 0.95)),
    CharacterSticker(
      name: "Luma", imageName: "VinylLabel03", accent: Color(red: 0.99, green: 0.82, blue: 0.36)),
    CharacterSticker(
      name: "Vale", imageName: "VinylLabel04", accent: Color(red: 0.70, green: 0.88, blue: 0.86)),
    CharacterSticker(
      name: "Flux", imageName: "VinylLabel05", accent: Color(red: 1.00, green: 0.41, blue: 0.35)),
    CharacterSticker(
      name: "Rei", imageName: "VinylLabel06", accent: Color(red: 1.00, green: 0.53, blue: 0.34)),
    CharacterSticker(
      name: "Moss", imageName: "VinylLabel07", accent: Color(red: 0.96, green: 0.65, blue: 0.76)),
    CharacterSticker(
      name: "Ivy", imageName: "VinylLabel08", accent: Color(red: 0.98, green: 0.76, blue: 0.58)),
    CharacterSticker(
      name: "Wren", imageName: "VinylLabel09", accent: Color(red: 0.87, green: 0.54, blue: 0.95)),
    CharacterSticker(
      name: "Ash", imageName: "VinylLabel10", accent: Color(red: 0.60, green: 0.70, blue: 0.96)),
  ]

  static func randomSticker() -> CharacterSticker? {
    all.randomElement()
  }
}

enum SampleData {
  static let tracks: [Track] = (0..<7).map { index in
    let sticker = CharacterStickerLibrary.all[index]
    return Track(
      title: SampleTrackLibrary.titles[index % SampleTrackLibrary.titles.count],
      artist: SampleTrackLibrary.artists[index % SampleTrackLibrary.artists.count],
      dayIndex: index,
      weekIndex: 8,
      accent: sticker.accent,
      character: sticker,
      artworkName: String(format: "VinylLabel%02d", index + 1),
      sourceURL: nil
    )
  }

  static let weeks: [Week] = [
    Week(number: 8, dateRange: "Jun 29 – Feb 4", tracks: tracks),
    Week(number: 9, dateRange: "Feb 5 – Feb 11", tracks: tracks.shuffled()),
  ]
}

enum SampleTrackLibrary {
  static let titles = [
    "Blank Looks", "Elastic Morning", "Slow Orbit", "Neon Past",
    "Soft Static", "Late Bloom", "Night Pilot", "Day Drift",
    "Signal Dust", "Amber Notes",
  ]
  static let artists = [
    "mt vision", "Ryan", "Rei", "Dias", "Sora", "Inez", "Aero", "Lina", "Nio", "Gray",
  ]
}
