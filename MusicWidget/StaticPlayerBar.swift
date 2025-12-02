//
//  StaticPlayerBar.swift
//  MusicWidgetExtension
//
//  Created by Anurag Singh on 01/12/25.
//

import AppIntents
import SwiftUI

struct StaticPlayerBar: View {
  var progress: CGFloat
  var accent: Color

  var body: some View {
    VStack(spacing: 6) {
      // Waveform Visualization
      HStack(spacing: 3) {
        ForEach(0..<20, id: \.self) { index in
          Capsule()
            .fill(indexFraction(index) <= progress ? accent : Color.secondary.opacity(0.2))
            .frame(width: 4, height: 10 + CGFloat.random(in: 0.2...1) * 14)
        }
      }
      .frame(height: 32)
      .frame(maxWidth: .infinity, alignment: .leading)

      // Controls
      HStack(spacing: 20) {
        Button(intent: PreviousTrackIntent()) {
          Image(systemName: "backward.fill")
            .font(.system(size: 20))
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)

        Button(intent: PlayPauseIntent()) {
          Image(systemName: "play.fill")
            .font(.system(size: 28))
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)

        Button(intent: NextTrackIntent()) {
          Image(systemName: "forward.fill")
            .font(.system(size: 20))
            .foregroundColor(.primary)
        }
        .buttonStyle(.plain)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func indexFraction(_ index: Int) -> CGFloat {
    CGFloat(index) / 14.0
  }
}
