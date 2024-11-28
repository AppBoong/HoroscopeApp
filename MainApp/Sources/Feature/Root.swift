import SwiftUI
import ComposableArchitecture

import Core

public struct Root: Reducer {
  public struct State: Equatable {
    public var router: Router.State
    public var horoscope: Horoscope.State
    public var profile: Profile.State
    
    public init(
      router: Router.State = .init(),
      horoscope: Horoscope.State = .init(),
      profile: Profile.State = .init()
    ) {
      self.router = router
      self.horoscope = horoscope
      self.profile = profile
    }
  }
  
  @CasePathable
  public enum Action: Equatable {
    case router(Router.Action)
    case horoscope(Horoscope.Action)
    case profile(Profile.Action)
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .horoscope(.routeToDetail):
        return .send(
          .router(
            .pushPath(
              .horoscope(
                .detail(
                  id: "1"
                )
              )
            )
          )
        )
        
      case .router,
          .horoscope,
          .profile:
        return .none
      }
    }
    
    Scope(state: \.router, action: \.router) {
      Router()
    }
    
    Scope(state: \.horoscope, action: \.horoscope) {
      Horoscope()
    }
    Scope(state: \.profile, action: \.profile) {
      Profile()
    }
  }
}

public struct RootView: View {
  private let store: StoreOf<Root>
  @State private var selectedTab: Int = 0
  
  public init(store: StoreOf<Root>) {
    self.store = store
  }
  
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      TabView(selection: $selectedTab) {
        NavigationStack(
          path: viewStore.binding(
            get: \.router.path,
            send: { _ in .router(.popToRoot) }
          )
        ) {
          HoroscopeView(
            store: store.scope(
              state: \.horoscope,
              action: \.horoscope
            )
          )
          .navigationDestination(for: AppPath.self) { path in
            switch path {
            case let .horoscope(path):
              switch path {
              case let .detail(id):
                HoroscopeDetailView(id: id)
                  .navigationBarBackButtonHidden(false)
              case .settings:
                HoroscopeSettingsView()
                  .navigationBarBackButtonHidden(false)
              }
            case .profile:
              EmptyView()
            }
          }
        }
        .tabItem {
          Image(systemName: "star.fill")
          Text("Horoscope")
        }
        .tag(0)
        
        NavigationStack(
          path: viewStore.binding(
            get: \.router.path,
            send: { _ in .router(.popToRoot) }
          )
        ) {
          ProfileView(
            store: store.scope(
              state: \.profile,
              action: \.profile
            )
          )
          .navigationDestination(for: AppPath.self) { path in
            switch path {
            case .horoscope:
              EmptyView()
            case let .profile(path):
              switch path {
              case .main:
                ProfileView(store: store.scope(
                  state: \.profile,
                  action: \.profile
                ))
              }
            }
          }
        }
        .tabItem {
          Image(systemName: "person.fill")
          Text("Profile")
        }
        .tag(1)
      }
      .sheet(
        item: viewStore.binding(
          get: \.router.presentedSheet,
          send: { .router(.presentSheet($0)) }
        )
      ) { path in
        NavigationStack {
          switch path {
          case let .horoscope(path):
            switch path {
            case let .detail(id):
              HoroscopeDetailView(id: id)
            case .settings:
              HoroscopeSettingsView()
            }
          case let .profile(path):
            switch path {
            case .main:
              ProfileView(store: store.scope(
                state: \.profile,
                action: \.profile
              ))
            }
          }
        }
      }
      .fullScreenCover(
        item: viewStore.binding(
          get: \.router.presentedFullScreen,
          send: { .router(.presentFullScreen($0)) }
        )
      ) { path in
        NavigationStack {
          switch path {
          case let .horoscope(path):
            switch path {
            case let .detail(id):
              HoroscopeDetailView(id: id)
            case .settings:
              HoroscopeSettingsView()
            }
          case let .profile(path):
            switch path {
            case .main:
              ProfileView(store: store.scope(
                state: \.profile,
                action: \.profile
              ))
            }
          }
        }
      }
    }
  }
}
