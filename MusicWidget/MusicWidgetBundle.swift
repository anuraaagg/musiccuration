//
//  MusicWidgetBundle.swift
//  MusicWidget
//
//  Created by Anurag Singh on 01/12/25.
//

import WidgetKit
import SwiftUI

@main
struct MusicWidgetBundle: WidgetBundle {
    var body: some Widget {
        MusicWidget()
        MusicWidgetControl()
        MusicWidgetLiveActivity()
    }
}
