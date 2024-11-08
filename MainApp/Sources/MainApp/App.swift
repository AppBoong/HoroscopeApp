//
//  App.swift
//
//
//  Created by Jeremy on 11/8/24.
//

import SwiftUI
import ComposableArchitecture

public struct HoroscopeApp: App {
  public init() {}
  
  public var body: some Scene {
    WindowGroup {
      NavigationStack {
        RootView(
          store: Store(
            initialState: Root.State(),
            reducer: { Root() }
          )
        )
      }
    }
  }
}
