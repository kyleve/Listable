//
//  Initialization.swift
//  ListableUI
//
//  Created by Nick Sillik on 10/28/20.
//

import Foundation

public struct Listable {
  public static func initialize() {
    _ = KeyboardObserver.shared

    KeyboardObserver.didSetupSharedInstanceDuringAppStartup = true
  }
}
