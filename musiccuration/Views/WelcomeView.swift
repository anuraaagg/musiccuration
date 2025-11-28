//
//  WelcomeView.swift
//  musiccuration
//
//  Created by Anurag Singh on 26/11/25.
//

import SwiftUI

struct WelcomeView: View {
  var onSignIn: () -> Void
  
  @State private var currentMessageIndex = 0
  @State private var isSigningIn = false
  @State private var isButtonPressed = false
  
  // Animation Settings - Adjust these values
  private let rotationSpeed: Double = 0.5 // 0.5x speed
  private let circleSpacing: Double = 0.20 // Circle distance
  
  let funMessages = [
    "Discover your perfect playlist",
    "Music that matches your vibe",
    "Let's find your sound",
    "Your musical journey starts here"
  ]
  
  var body: some View {
    ZStack {
      // White Background
      Color.white
        .ignoresSafeArea()
      
      VStack(spacing: 0) {
        Spacer()
        
        // Vinyl Circle Animation Area
        ZStack {
          ConcentricVinylCircles(
            rotationSpeed: rotationSpeed,
            circleSpacing: circleSpacing
          )
        }
        .frame(height: 400)
        
        Spacer()
        
        // Fun Message
        Text(funMessages[currentMessageIndex])
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(.black.opacity(0.8))
          .multilineTextAlignment(.center)
          .padding(.horizontal, 40)
          .frame(height: 60)
          .onAppear {
            startMessageRotation()
          }
        
        Spacer().frame(height: 40)
        
        // Frosted Glass Sign in Button
        Button(action: signInTapped) {
          HStack(spacing: 10) {
            Image(systemName: "applelogo")
              .font(.system(size: 20, weight: .semibold))
            Text("Sign in with Apple Music")
              .font(.system(size: 18, weight: .semibold))
          }
          .foregroundColor(.black)
          .padding(.horizontal, 32)
          .padding(.vertical, 18)
          .background(
            ZStack {
              // Frosted glass background
              RoundedRectangle(cornerRadius: 100)
                .fill(.ultraThinMaterial)
                .overlay(
                  RoundedRectangle(cornerRadius: 100)
                    .fill(
                      LinearGradient(
                        colors: [
                          Color.white.opacity(0.7),
                          Color.white.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                      )
                    )
                )
              
              // Bubble effect when pressed
              if isButtonPressed {
                Circle()
                  .fill(
                    RadialGradient(
                      colors: [
                        Color.white.opacity(0.8),
                        Color.white.opacity(0.0)
                      ],
                      center: .center,
                      startRadius: 0,
                      endRadius: 100
                    )
                  )
                  .scaleEffect(isButtonPressed ? 2.0 : 0.1)
                  .opacity(isButtonPressed ? 0 : 1)
                  .animation(.easeOut(duration: 0.6), value: isButtonPressed)
              }
            }
          )
          .overlay(
            RoundedRectangle(cornerRadius: 100)
              .stroke(
                LinearGradient(
                  colors: [
                    Color.white.opacity(0.8),
                    Color.white.opacity(0.3)
                  ],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
              )
          )
          .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
          .scaleEffect(isButtonPressed ? 0.95 : 1.0)
          .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isButtonPressed)
        }
        .simultaneousGesture(
          DragGesture(minimumDistance: 0)
            .onChanged { _ in
              if !isButtonPressed {
                isButtonPressed = true
                // Haptic feedback on press
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
              }
            }
            .onEnded { _ in
              isButtonPressed = false
            }
        )
        
        Spacer().frame(height: 60)
      }
    }
  }
  
  private func startMessageRotation() {
    Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
      withAnimation(.easeInOut(duration: 0.5)) {
        currentMessageIndex = (currentMessageIndex + 1) % funMessages.count
      }
    }
  }
  
  private func signInTapped() {
    HapticsManager.shared.selectionTick()
    
    withAnimation(.easeInOut(duration: 0.3)) {
      isSigningIn = true
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
      onSignIn()
    }
  }
}

// Concentric Vinyl Circles Component
struct ConcentricVinylCircles: View {
  let rotationSpeed: Double
  let circleSpacing: Double
  
  @State private var rotationAngle: Double = 0
  
  let characterImages = (1...10).map { "VinylLabel\(String(format: "%02d", $0))" }
  
  var body: some View {
    GeometryReader { geometry in
      let size = min(geometry.size.width, geometry.size.height)
      let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
      
      ZStack {
        // Center Icon (Music Note)
        ZStack {
          Circle()
            .fill(
              LinearGradient(
                colors: [Color.purple.opacity(0.8), Color.pink.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(width: 80, height: 80)
          
          Image(systemName: "music.note")
            .font(.system(size: 40, weight: .bold))
            .foregroundColor(.white)
        }
        .position(center)
        
        // Inner Ring - 6 vinyls
        ForEach(0..<6, id: \.self) { index in
          let angle = (Double(index) / 6.0) * 2 * .pi + rotationAngle * 0.01 * rotationSpeed
          let radius = size * 0.25
          let x = center.x + cos(angle) * radius
          let y = center.y + sin(angle) * radius
          
          Image(characterImages[index % characterImages.count])
            .resizable()
            .scaledToFill()
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .overlay(
              Circle()
                .stroke(Color.white, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.15), radius: 8)
            .position(x: x, y: y)
        }
        
        // Outer Ring - 9 vinyls
        ForEach(0..<9, id: \.self) { index in
          let angle = (Double(index) / 9.0) * 2 * .pi - rotationAngle * 0.008 * rotationSpeed
          let radius = size * (0.25 + circleSpacing)
          let x = center.x + cos(angle) * radius
          let y = center.y + sin(angle) * radius
          
          Image(characterImages[(index + 3) % characterImages.count])
            .resizable()
            .scaledToFill()
            .frame(width: 85, height: 85)
            .clipShape(Circle())
            .overlay(
              Circle()
                .stroke(Color.white, lineWidth: 3)
            )
            .shadow(color: .black.opacity(0.15), radius: 8)
            .position(x: x, y: y)
        }
      }
      .onAppear {
        startRotation()
      }
    }
  }
  
  private func startRotation() {
    Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
      rotationAngle += 1
    }
  }
}

#Preview {
  WelcomeView(onSignIn: {})
}
