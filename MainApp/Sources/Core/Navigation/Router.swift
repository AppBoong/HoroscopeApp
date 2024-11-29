import Foundation
import ComposableArchitecture
import SwiftUI

public struct Router: Reducer {
  public struct State: Equatable {
    public var path: [AppPath]
    public var presentedSheet: AppPath?
    public var presentedFullScreen: AppPath?
    
    public init(
      path: [AppPath] = [],
      presentedSheet: AppPath? = nil,
      presentedFullScreen: AppPath? = nil
    ) {
      self.path = path
      self.presentedSheet = presentedSheet
      self.presentedFullScreen = presentedFullScreen
    }
  }
  
  public enum Action: Equatable {
    case pushPath(AppPath)
    case popPath
    case popToRoot
    case presentSheet(AppPath?)
    case presentFullScreen(AppPath?)
    case handleDeepLink(URL)
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .pushPath(path):
        state.path.append(path)
        return .none
        
      case .popPath:
        _ = state.path.popLast()
        return .none
        
      case .popToRoot:
        state.path.removeAll()
        return .none
        
      case let .presentSheet(path):
        state.presentedSheet = path
        return .none
        
      case let .presentFullScreen(path):
        state.presentedFullScreen = path
        return .none
        
      case let .handleDeepLink(url):
        // DeepLink 처리 로직
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
          return .none
        }
        
        if components.scheme == "horoscope" {
          switch components.path {
          case "/history":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
              state.path.append(.horoscope(.history))
            }
          default:
            break
          }
        }
        
        return .none
      }
    }
  }
}
