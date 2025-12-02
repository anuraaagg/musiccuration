//
//  FrostedGlassButton.swift
//  musiccuration
//
//  Created by Anurag Singh on 27/11/25.
//

import SwiftUI

struct FrostedGlassButton: View {
  let title: String
  let icon: String?
  let accentColor: Color?
  let isEnabled: Bool
  let action: () -> Void

  @State private var isPressed = false

  init(
    title: String,
    icon: String? = nil,
    accentColor: Color? = nil,
    isEnabled: Bool = true,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.icon = icon
    self.accentColor = accentColor
    self.isEnabled = isEnabled
    self.action = action
  }

  var body: some View {
    Button(action: handleTap) {
      HStack(spacing: 8) {
        if let icon = icon {
          Image(systemName: icon)
            .font(.system(size: 16, weight: .medium))
        }
        Text(title)
          .font(.system(size: 16, weight: .medium))
      }
      .foregroundColor(isEnabled ? .black : .black.opacity(0.4))
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(
        ZStack {
          // Frosted glass background
          RoundedRectangle(cornerRadius: 100)
            .fill(.ultraThinMaterial)
            .overlay(
              RoundedRectangle(cornerRadius: 100)
                .fill(
                  LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                )
            )

          // Bubble effect when pressed
          if isPressed {
            Circle()
              .fill(
                RadialGradient(
                  colors: [
                    (accentColor ?? .white).opacity(0.8),
                    (accentColor ?? .white).opacity(0.0),
                  ],
                  center: .center,
                  startRadius: 0,
                  endRadius: 100
                )
              )
              .scaleEffect(isPressed ? 2.0 : 0.1)
              .opacity(isPressed ? 0 : 1)
              .animation(.easeOut(duration: 0.6), value: isPressed)
          }
        }
      )
      .overlay(
        RoundedRectangle(cornerRadius: 100)
          .stroke(
            LinearGradient(
              colors: borderColors,
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1.5
          )
      )
      .shadow(color: .black.opacity(isEnabled ? 0.1 : 0.05), radius: 20, x: 0, y: 10)
      .scaleEffect(isPressed ? 0.95 : 1.0)
      .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
      .opacity(isEnabled ? 1.0 : 0.6)
    }
    .disabled(!isEnabled)
    .simultaneousGesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in
          if !isPressed && isEnabled {
            isPressed = true
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
          }
        }
        .onEnded { _ in
          isPressed = false
        }
    )
  }

  private var gradientColors: [Color] {
    if let accent = accentColor {
      return [
        accent.opacity(0.4),
        accent.opacity(0.2),
      ]
    } else {
      return [
        Color.white.opacity(0.7),
        Color.white.opacity(0.4),
      ]
    }
  }

  private var borderColors: [Color] {
    if let accent = accentColor {
      return [
        accent.opacity(0.8),
        accent.opacity(0.4),
      ]
    } else {
      return [
        Color.white.opacity(0.8),
        Color.white.opacity(0.3),
      ]
    }
  }

  private func handleTap() {
    guard isEnabled else { return }
    action()
  }
}

#Preview {
  VStack(spacing: 20) {
    FrostedGlassButton(
      title: "Search for a Song",
      icon: "magnifyingglass",
      action: {}
    )

    FrostedGlassButton(
      title: "Press to Engrave",
      accentColor: .pink,
      action: {}
    )

    FrostedGlassButton(
      title: "Disabled Button",
      isEnabled: false,
      action: {}
    )
  }
  .padding()
  .background(Color.gray.opacity(0.2))
}
