//
//  App.swift
//
//
//  Created by Jeremy on 11/8/24.
//

import SwiftUI
import ComposableArchitecture

import Feature

public struct HoroscopeApp: App {
  
  public init() {}
  
  public var body: some Scene {
    WindowGroup {
      RootView(
        store: Store(
          initialState: Root.State(),
          reducer: { Root() }
        )
      )
    }
  }
}
