
import SwiftUI
import ComposableArchitecture

import Feature

struct Root: Reducer {
  struct State: Equatable {
    var horoscope: Horoscope.State = .init()
    var profile: Profile.State = .init()
  }
  
  enum Action: Equatable {
    case horoscope(Horoscope.Action)
    case profile(Profile.Action)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .horoscope, .profile:
        return .none
      }
    }
    Scope(state: \.horoscope, action: /Action.horoscope) {
      Horoscope()
    }
    Scope(state: \.profile, action: /Action.profile) {
      Profile()
    }
  }
}

struct RootView: View {
  // MARK: - Property
  let store: StoreOf<Root>
  
  // MARK: - Body
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      content
    }
  }
  
  // MARK: - Views
  @ViewBuilder
  private var content: some View {
    TabView {
      HoroscopeView(
        store: store.scope(
          state: \.horoscope,
          action: Root.Action.horoscope
        )
      )
      .tabItem {
        Image(systemName: "star")
        Text("운세")
      }
      
      ProfileView(
        store: store.scope(
          state: \.profile,
          action: Root.Action.profile
        )
      )
      .tabItem {
        Image(systemName: "person")
        Text("프로필")
      }
    }
  }
}
