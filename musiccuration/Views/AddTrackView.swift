//
//  AddTrackView.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import SwiftUI

struct AddTrackView: View {
  @Binding var title: String
  @Binding var artist: String
  @Binding var link: String
  var onCancel: () -> Void
  var onEngrave: () -> Void

  @State private var isEngraving: Bool = false

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

      VStack(spacing: 32) {
        Spacer()

        // Title
        Text("Engrave Today's Song")
          .font(.system(size: 28, weight: .bold))

        // Blank Vinyl Preview
        VinylPlaceholder()
          .frame(width: 240, height: 240)
          .scaleEffect(isEngraving ? 1.1 : 1.0)
          .animation(.easeInOut(duration: 1.5), value: isEngraving)

        // Input Section
        VStack(spacing: 24) {
          VStack(alignment: .leading, spacing: 16) {
            Text("Song Details")
              .font(.system(size: 14, weight: .medium))

            VStack(spacing: 12) {
              TextField("Song title", text: $title)
                .padding(16)
                .background(
                  RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                )

              TextField("Artist", text: $artist)
                .padding(16)
                .background(
                  RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                )

              TextField("Link or URL (optional)", text: $link)
                .padding(16)
                .background(
                  RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                )
            }
          }
          .padding(24)
          .background(
            RoundedRectangle(cornerRadius: 16)
              .fill(.ultraThinMaterial)
          )

          // Engrave Button
          Button(action: handleEngrave) {
            Text(isEngraving ? "Engraving..." : "Press to Engrave")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 56)
              .background(
                RoundedRectangle(cornerRadius: 14)
                  .fill(Color(red: 0.96, green: 0.47, blue: 0.42))
              )
          }
          .disabled(title.isEmpty || isEngraving)
          .opacity(title.isEmpty || isEngraving ? 0.5 : 1.0)
        }
        .padding(.horizontal, 24)

        // Hint
        VStack(spacing: 4) {
          Text("Choose the song that represents your day.")
          Text("You can only pick one.")
        }
        .font(.system(size: 14))
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)

        Spacer()
      }

      // Close Button
      VStack {
        HStack {
          Spacer()
          Button(action: onCancel) {
            Image(systemName: "xmark")
              .font(.system(size: 20))
              .foregroundColor(.primary)
              .frame(width: 40, height: 40)
              .background(Circle().fill(.ultraThinMaterial))
          }
          .padding(24)
        }
        Spacer()
      }
    }
  }

  func handleEngrave() {
    isEngraving = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
      onEngrave()
      isEngraving = false
    }
  }
}
