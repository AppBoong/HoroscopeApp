import SwiftUI
import ComposableArchitecture

struct Root: Reducer {
  struct State: Equatable {
    var horoscope: Horoscope.State = .init()
    var profile: Profile.State = .init()
  }
  
  @CasePathable
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
    Scope(state: \.horoscope, action: \.horoscope) {
      Horoscope()
    }
    Scope(state: \.profile, action: \.profile) {
      Profile()
    }
  }
}

struct RootView: View {
  // MARK: - Property
  let store: StoreOf<Root>
  
  @State private var selectedTab: Int = 0
  // MARK: - Body
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      content
    }
  }
  
  // MARK: - Views
  @ViewBuilder
  private var content: some View {
    TabView(selection: $selectedTab) {
      HoroscopeView(
        store: store.scope(
          state: \.horoscope,
          action: \.horoscope
        )
      )
      .tabItem {
        Image(systemName: "star")
        Text("운세")
      }
      .tag(0)
      
      ProfileView(
        store: store.scope(
          state: \.profile,
          action: \.profile
        )
      )
      .tabItem {
        Image(systemName: "person")
        Text("프로필")
      }
      .tag(1)
    }
  }
}
