import SwiftUI
import ComposableArchitecture

public struct HoroscopeDetailView: View {
  let id: String
  
  public init(id: String) {
    self.id = id
  }
  
  public var body: some View {
    Text("Horoscope Detail View - ID: \(id)")
  }
}
