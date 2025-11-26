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
