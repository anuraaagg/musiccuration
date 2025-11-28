//
//  HapticsManager.swift
//  musiccuration
//
//  Created by Anurag Singh on 26/11/25.
//

import UIKit

class HapticsManager {
  static let shared = HapticsManager()

  private init() {}

  // Generators
  private let impactLight = UIImpactFeedbackGenerator(style: .light)
  private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
  private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
  private let selection = UISelectionFeedbackGenerator()
  private let notification = UINotificationFeedbackGenerator()

  func prepare() {
    impactLight.prepare()
    impactMedium.prepare()
    impactHeavy.prepare()
    selection.prepare()
    notification.prepare()
  }

  // Play -> medium tap
  func play() {
    impactMedium.impactOccurred()
  }

  // Pause -> light tap
  func pause() {
    impactLight.impactOccurred()
  }

  // Vinyl scratching -> soft ticks
  func scratch() {
    selection.selectionChanged()
  }

  // Engrave success -> heavy thump
  func engraveSuccess() {
    impactHeavy.impactOccurred()
  }

  // Mini vinyl tap -> light selection tick
  func selectionTick() {
    selection.selectionChanged()
  }

  // Error -> error vibration
  func error() {
    notification.notificationOccurred(.error)
  }

  // Success -> success vibration
  func success() {
    notification.notificationOccurred(.success)
  }
}
