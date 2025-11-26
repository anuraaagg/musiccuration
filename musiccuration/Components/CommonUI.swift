//
//  CommonUI.swift
//  musiccuration
//
//  Created by Anurag Singh on 25/11/25.
//

import SwiftUI

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
