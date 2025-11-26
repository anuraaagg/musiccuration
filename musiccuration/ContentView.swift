//
//  ContentView.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import SwiftUI
import UIKit

// MARK: - Data Models

struct Track: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    let dayIndex: Int
    let weekIndex: Int
    let accent: Color
    let character: CharacterSticker
    let artworkName: String?
    let sourceURL: URL?
}

struct CharacterSticker: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let accent: Color
}

struct Week: Identifiable, Hashable {
    let id = UUID()
    let number: Int
    let dateRange: String
    var tracks: [Track]

    var coverAccent: Color {
        tracks.first?.accent ?? .gray
    }
}

// MARK: - Root Content View

struct ContentView: View {
    @State private var weeks: [Week] = SampleData.weeks
    @State private var currentWeekIndex: Int = 0
    @State private var selectedDayIndex: Int = 5
    @State private var activeMode: ViewingMode = .today
    @State private var isPlaying: Bool = false
    @State private var playbackProgress: CGFloat = 0.35
    @State private var scratchRotation: Angle = .degrees(0)
    @State private var newTrackTitle: String = ""
    @State private var newTrackArtist: String = ""
    @State private var newTrackLink: String = ""

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                background

                switch activeMode {
                case .today:
                    TodayView(
                        track: currentTrack,
                        weekNumber: currentWeek.number,
                        dayOfWeek: selectedDayIndex + 1,
                        progress: $playbackProgress,
                        isPlaying: $isPlaying,
                        scratchRotation: $scratchRotation,
                        onSwipeDown: openWeekView,
                        onSwipeUp: openAddView,
                        onScrub: scrubbed
                    )
                case .week:
                    WeekAlbumView(
                        week: currentWeek,
                        weeks: weeks,
                        selectedDayIndex: $selectedDayIndex,
                        currentWeekIndex: $currentWeekIndex,
                        onPinchIn: openTodayView
                    )
                    .transition(.move(edge: .top))
                case .add:
                    AddTrackView(
                        title: $newTrackTitle,
                        artist: $newTrackArtist,
                        link: $newTrackLink,
                        onCancel: openTodayView,
                        onEngrave: engraveNewTrack
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .animation(.spring(response: 0.55, dampingFraction: 0.85), value: activeMode)
        }
        .preferredColorScheme(.light)
    }

    private var background: some View {
        LinearGradient(
            colors: [Color.white, Color(red: 0.94, green: 0.95, blue: 0.97)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    private var currentWeek: Week {
        weeks[currentWeekIndex]
    }

    private var currentTrack: Track {
        currentWeek.tracks[selectedDayIndex]
    }

    private func scrubbed(_ delta: CGFloat) {
        playbackProgress = max(0, min(1, playbackProgress + delta))
    }

    private func openWeekView() {
        activeMode = .week
    }

    private func openTodayView() {
        activeMode = .today
    }

    private func openAddView() {
        activeMode = .add
    }

    private func engraveNewTrack() {
        guard !newTrackTitle.isEmpty else { return }
        guard let character = CharacterStickerLibrary.randomSticker() else { return }

        let newTrack = Track(
            title: newTrackTitle,
            artist: newTrackArtist.isEmpty ? "Unknown Artist" : newTrackArtist,
            dayIndex: selectedDayIndex,
            weekIndex: currentWeek.number,
            accent: character.accent,
            character: character,
            artworkName: nil,
            sourceURL: URL(string: newTrackLink)
        )

        weeks[currentWeekIndex].tracks[selectedDayIndex] = newTrack
        newTrackTitle = ""
        newTrackArtist = ""
        newTrackLink = ""
        activeMode = .today
    }
}

// MARK: - Viewing Modes

enum ViewingMode {
    case today, week, add
}

// MARK: - Today View

struct TodayView: View {
    let track: Track
    let weekNumber: Int
    let dayOfWeek: Int
    @Binding var progress: CGFloat
    @Binding var isPlaying: Bool
    @Binding var scratchRotation: Angle
    var onSwipeDown: () -> Void
    var onSwipeUp: () -> Void
    var onScrub: (CGFloat) -> Void

    @GestureState private var dragTranslation: CGSize = .zero
    @GestureState private var rotation: Angle = .degrees(0)

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            VinylDisc(track: track, scratchRotation: scratchRotation + rotation)
                .padding(.top, 40)
                .overlay(
                    ProgressRing(progress: progress, color: track.accent)
                        .opacity(0.7)
                        .allowsHitTesting(false)
                )
                .gesture(rotationGesture)
                .onTapGesture(count: 2) { progress = 0 }

            VStack(spacing: 6) {
                Text(track.title)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                Text("\(track.artist) • Week \(weekNumber)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text("Day \(dayOfWeek) of 7")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            WaveformPlayerBar(
                progress: $progress,
                isPlaying: $isPlaying,
                artworkName: track.artworkName,
                accent: track.accent,
                onScrub: onScrub
            )
            .padding(.horizontal, 32)
            .padding(.top, 12)
            Spacer()
        }
        .padding(.bottom, 32)
        .contentShape(Rectangle())
        .gesture(verticalSwipeGesture)
    }

    private var verticalSwipeGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .updating($dragTranslation) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                if value.translation.height > 80 {
                    onSwipeDown()
                } else if value.translation.height < -80 {
                    onSwipeUp()
                }
            }
    }

    private var rotationGesture: some Gesture {
        RotationGesture()
            .updating($rotation) { value, state, _ in
                state = value
                onScrub(value.degrees / 360.0)
            }
            .onEnded { value in
                scratchRotation += value
            }
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    var progress: CGFloat
    var color: Color
    var body: some View {
        Circle()
            .trim(from: 0, to: min(1, max(0, progress)))
            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .foregroundStyle(color)
            .rotationEffect(.degrees(-90))
            .padding(6)
    }
}

// MARK: - Week View

struct WeekAlbumView: View {
    let week: Week
    let weeks: [Week]
    @Binding var selectedDayIndex: Int
    @Binding var currentWeekIndex: Int
    var onPinchIn: () -> Void

    @GestureState private var dragOffset: CGFloat = 0
    @GestureState private var magnification: CGFloat = 1

    var body: some View {
        VStack(spacing: 24) {
            Text(String(format: "Week %02d", week.number))
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.semibold)
            Text(week.dateRange)
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer(minLength: 12)

            VinylDisc(track: week.tracks[selectedDayIndex], scratchRotation: .degrees(0))
                .frame(width: 280, height: 280)
                .padding(.top, 8)
                .gesture(pinchingGesture)

            Spacer(minLength: 24)

            miniTracksRow

            Spacer(minLength: 24)

            HStack {
                Text(String(format: "Week %02d", max(1, week.number - 1)))
                Spacer()
                Text(String(format: "Week %02d", week.number + 1))
            }
            .font(.headline)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 32)
        }
        .padding(.top, 40)
        .gesture(horizontalDragGesture)
    }

    private var miniTracksRow: some View {
        HStack(spacing: 18) {
            ForEach(week.tracks.indices, id: \.self) { index in
                let miniTrack = week.tracks[index]
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedDayIndex = index
                    }
                } label: {
                    VinylDisc(track: miniTrack, scratchRotation: .degrees(0))
                        .frame(width: 54, height: 54)
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 4)
                        .overlay(Circle().stroke(Color.white.opacity(selectedDayIndex == index ? 0.5 : 0.0), lineWidth: 1.5))
                        .opacity(selectedDayIndex == index ? 1 : 0.6)
                        .scaleEffect(selectedDayIndex == index ? 1.05 : 0.95)
                }
                .buttonStyle(.plain)
            }
        }
        .offset(x: CGFloat(week.tracks.count - 1 - 2 * selectedDayIndex) * 36)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedDayIndex)
    }

    private var horizontalDragGesture: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                if value.translation.width < -80, currentWeekIndex < weeks.count - 1 {
                    currentWeekIndex += 1
                } else if value.translation.width > 80, currentWeekIndex > 0 {
                    currentWeekIndex -= 1
                }
            }
    }

    private var pinchingGesture: some Gesture {
        MagnificationGesture()
            .updating($magnification) { value, state, _ in
                state = value
            }
            .onEnded { value in
                if value < 0.9 {
                    onPinchIn()
                }
            }
    }
}

// MARK: - Add Track View

struct AddTrackView: View {
    @Binding var title: String
    @Binding var artist: String
    @Binding var link: String
    var onCancel: () -> Void
    var onEngrave: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 6)
                .padding(.top, 12)

            Text("Add today's track")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)

            VStack(spacing: 16) {
                FloatingField("Song title", text: $title)
                FloatingField("Artist", text: $artist)
                FloatingField("Link or URL (optional)", text: $link)
            }
            .padding(.horizontal, 24)

            VinylPlaceholder()
                .frame(width: 220, height: 220)

            Button(action: onEngrave) {
                Text("Press to engrave")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(title.isEmpty ? Color.gray.opacity(0.3) : Color.black)
                    )
                    .foregroundStyle(title.isEmpty ? .secondary : Color.white)
            }
            .disabled(title.isEmpty)
            .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Material.ultraThin)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 120 {
                        onCancel()
                    }
                }
        )
    }
}

// MARK: - Reusable Views

struct VinylDisc: View {
    let track: Track
    var scratchRotation: Angle

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.black, Color.black.opacity(0.2)]),
                        center: .center,
                        startRadius: 30,
                        endRadius: 140
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        .blur(radius: 3)
                )

            Circle()
                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                .padding(16)
            Circle()
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                .padding(32)

            // Concentric groove rings
            ForEach(0..<12, id: \.self) { i in
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    .padding(CGFloat(44 + i * 8))
            }

            // Sweeping highlight
            AngularGradient(gradient: Gradient(colors: [Color.white.opacity(0.18), Color.clear, Color.clear, Color.white.opacity(0.12)]), center: .center)
                .mask(
                    Circle()
                        .stroke(lineWidth: 140)
                        .padding(20)
                )
                .blur(radius: 2)

            Circle()
                .fill(track.accent.opacity(0.9))
                .frame(width: 110, height: 110)
                .overlay(
                    Group {
                        if let name = track.artworkName, UIImage(named: name) != nil {
                            Image(name)
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(track.character.imageName)
                                .resizable()
                                .scaledToFill()
                        }
                    }
                    .clipShape(Circle())
                    .padding(6)
                )
            Circle()
                .fill(Color.white.opacity(0.85))
                .frame(width: 22)
        }
        .rotationEffect(scratchRotation)
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 20)
    }
}

struct WaveformPlayerBar: View {
    @Binding var progress: CGFloat
    @Binding var isPlaying: Bool
    var artworkName: String?
    var accent: Color
    var onScrub: (CGFloat) -> Void

    var body: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.6))
                Group {
                    if let name = artworkName, UIImage(named: name) != nil {
                        Image(name).resizable().scaledToFill()
                    }
                }
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 1))

            Waveform(progress: $progress, isPlaying: $isPlaying, accent: accent, onScrub: onScrub)

            Button {
                // share stub
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.thinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 28, style: .continuous).stroke(Color.white.opacity(0.25), lineWidth: 1))
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 10)
        )
    }
}

struct PlayButton: View {
    @Binding var isPlaying: Bool

    var body: some View {
        Button {
            isPlaying.toggle()
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(Color.white)
                .frame(width: 46, height: 46)
                .background(
                    Circle()
                        .fill(Color.black)
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                )
        }
        .buttonStyle(.plain)
    }
}

struct Waveform: View {
    @Binding var progress: CGFloat
    @Binding var isPlaying: Bool
    var accent: Color
    var onScrub: (CGFloat) -> Void

    let bars = (0..<30).map { _ in CGFloat.random(in: 0.2...1) }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(height: 36)

                HStack(spacing: 4) {
                    ForEach(0..<bars.count, id: \.self) { index in
                        Capsule()
                            .fill(indexFraction(index) <= progress ? accent : Color.white.opacity(0.4))
                            .frame(width: 4, height: 6 + bars[index] * 24)
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: 36)
                .contentShape(Rectangle())
                .gesture(scrubGesture(width: width))
            }
            .onTapGesture {
                isPlaying.toggle()
            }
        }
        .frame(height: 36)
    }

    private func indexFraction(_ index: Int) -> CGFloat {
        CGFloat(index) / CGFloat(bars.count - 1)
    }

    private func scrubGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let position = max(0, min(width, value.location.x))
                progress = position / width
                onScrub(0)
            }
    }
}

struct FloatingField: View {
    let placeholder: String
    @Binding var text: String

    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
    }
}

struct VinylPlaceholder: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(.ultraThinMaterial)
            if let sticker = CharacterStickerLibrary.all.first {
                VinylDisc(
                    track: Track(
                        title: "Placeholder",
                        artist: "Artist",
                        dayIndex: 0,
                        weekIndex: 0,
                        accent: sticker.accent,
                        character: sticker,
                        artworkName: "VinylLabel01",
                        sourceURL: nil
                    ),
                    scratchRotation: .degrees(0)
                )
                .opacity(0.6)
            }
        }
        .padding(.horizontal, 60)
    }
}

// MARK: - Sample Data
struct CharacterStickerLibrary {
    static let all: [CharacterSticker] = [
        CharacterSticker(name: "Nova", imageName: "character01", accent: Color(red: 0.98, green: 0.36, blue: 0.56)),
        CharacterSticker(name: "Orbit", imageName: "character02", accent: Color(red: 0.64, green: 0.76, blue: 0.95)),
        CharacterSticker(name: "Luma", imageName: "character03", accent: Color(red: 0.99, green: 0.82, blue: 0.36)),
        CharacterSticker(name: "Vale", imageName: "character04", accent: Color(red: 0.70, green: 0.88, blue: 0.86)),
        CharacterSticker(name: "Flux", imageName: "character05", accent: Color(red: 1.00, green: 0.41, blue: 0.35)),
        CharacterSticker(name: "Rei", imageName: "character06", accent: Color(red: 1.00, green: 0.53, blue: 0.34)),
        CharacterSticker(name: "Moss", imageName: "character07", accent: Color(red: 0.96, green: 0.65, blue: 0.76)),
        CharacterSticker(name: "Ivy", imageName: "character08", accent: Color(red: 0.98, green: 0.76, blue: 0.58)),
        CharacterSticker(name: "Wren", imageName: "character09", accent: Color(red: 0.87, green: 0.54, blue: 0.95)),
        CharacterSticker(name: "Ash", imageName: "character10", accent: Color(red: 0.60, green: 0.70, blue: 0.96))
    ]

    static func randomSticker() -> CharacterSticker? {
        all.randomElement()
    }
}

enum SampleData {
    static let tracks: [Track] = CharacterStickerLibrary.all.enumerated().map { index, sticker in
        Track(
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
        Week(number: 9, dateRange: "Feb 5 – Feb 11", tracks: tracks.shuffled())
    ]
}

enum SampleTrackLibrary {
    static let titles = [
        "Blank Looks", "Elastic Morning", "Slow Orbit", "Neon Past",
        "Soft Static", "Late Bloom", "Night Pilot", "Day Drift",
        "Signal Dust", "Amber Notes"
    ]
    static let artists = [
        "mt vision", "Ryan", "Rei", "Dias", "Sora", "Inez", "Aero", "Lina", "Nio", "Gray"
    ]
}

#Preview {
    ContentView()
}
