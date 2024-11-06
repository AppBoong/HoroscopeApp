//
//  Horoscope.swift
//
//
//  Created by Jeremy on 11/6/24.
//


import SwiftUI
import ComposableArchitecture

public struct Horoscope: Reducer {
  // MARK: - State
  public struct State: Equatable {
    public init() {}
    
    public var title: String = "운세"
    public var zodiacSign: String = ""
    public var dailyHoroscope: String = ""
  }
  
  // MARK: - Action
  public enum Action: Equatable {
    
    case updateZodiacSign(String)
    case fetchHoroscope
    case horoscopeResponse(String)
  }
  
  public init() {}
  
  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .updateZodiacSign(sign):
        state.zodiacSign = sign
        return .none
        
      case .fetchHoroscope:
        return .none
        
      case let .horoscopeResponse(horoscope):
        state.dailyHoroscope = horoscope
        return .none
      }
    }
  }
}


public struct HoroscopeView: View {
  // MARK: - Property
  public let store: StoreOf<Horoscope>
  
  public init(store: StoreOf<Horoscope>) {
    self.store = store  
  } 
  
  // MARK: - Body
  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      content(viewStore)
    }
  }
  
  // MARK: - Views
  @ViewBuilder
  private func content(_ viewStore: ViewStoreOf<Horoscope>) -> some View {
    VStack {
      Text(viewStore.title)
        .font(.title)
        .padding()
      
      if !viewStore.zodiacSign.isEmpty {
        Text(viewStore.zodiacSign)
          .font(.headline)
        
        Text(viewStore.dailyHoroscope)
          .padding()
      }
    }
  }
}
