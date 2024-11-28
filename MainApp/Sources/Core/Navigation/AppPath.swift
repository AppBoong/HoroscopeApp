import Foundation
import ComposableArchitecture

public enum AppPath: Equatable, Hashable, Identifiable {
  case horoscope(HoroscopePath)
  case profile(ProfilePath)
  
  public var id: String {
    switch self {
    case .horoscope(let path):
      return "horoscope-\(path)"
    case .profile(let path):
      return "profile-\(path)"
    }
  }
}

public enum HoroscopePath: Equatable, Hashable {
  case detail(id: String)
  case settings
}

public enum ProfilePath: Equatable, Hashable {
  case main
}
