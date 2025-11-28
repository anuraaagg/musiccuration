//
//  FloatingVinyl.swift
//  musiccuration
//
//  Created by Anurag Singh on 26/11/25.
//

import Foundation
import SwiftUI

struct FloatingVinyl: Identifiable {
  let id = UUID()
  var position: CGPoint
  var zDepth: CGFloat  // 0 (back) ... 1 (front)
  var size: CGFloat
  var rotation: Angle
  var rotationSpeed: Double  // degrees per second
  var orbitCenter: CGPoint
  var orbitRadiusX: CGFloat
  var orbitRadiusY: CGFloat
  var orbitPhase: CGFloat  // 0...2π
  var orbitSpeed: Double  // radians per second
  let characterImageName: String

  // Spiral animation properties
  var spawnTime: Double  // Reference time when vinyl was spawned
  var spiralAngle: Double  // Angle in the spiral
  var spiralSpeed: Double  // How fast it spirals outward
  var lifetime: Double  // How long before it goes off-screen

  var isDragging: Bool = false
  var velocity: CGSize = .zero

  init(
    position: CGPoint,
    zDepth: CGFloat,
    size: CGFloat,
    characterImageName: String,
    customRotationSpeed: Double? = nil,
    orbitCenter: CGPoint? = nil,
    orbitRadiusX: CGFloat? = nil,
    orbitRadiusY: CGFloat? = nil,
    orbitPhase: CGFloat? = nil,
    orbitSpeed: Double? = nil,
    spawnTime: Double = 0,
    spiralAngle: Double? = nil,
    spiralSpeed: Double? = nil,
    lifetime: Double = 8.0
  ) {
    self.position = position
    self.zDepth = zDepth
    self.size = size
    self.characterImageName = characterImageName
    self.spawnTime = spawnTime
    self.spiralAngle = spiralAngle ?? Double.random(in: 0...(2 * .pi))
    self.spiralSpeed = spiralSpeed ?? Double.random(in: 0.3...0.6)
    self.lifetime = lifetime

    // Randomize animation parameters
    self.rotation = .degrees(Double.random(in: 0...360))
    self.rotationSpeed =
      customRotationSpeed ?? (Double.random(in: 3...8) * (Bool.random() ? 1 : -1))
    self.orbitCenter = orbitCenter ?? position
    self.orbitRadiusX = orbitRadiusX ?? CGFloat.random(in: 15...30)
    self.orbitRadiusY = orbitRadiusY ?? (orbitRadiusX ?? CGFloat.random(in: 15...30))
    self.orbitPhase = orbitPhase ?? CGFloat.random(in: 0...(2 * .pi))
    self.orbitSpeed = orbitSpeed ?? Double.random(in: 0.1...0.3)
  }
}
