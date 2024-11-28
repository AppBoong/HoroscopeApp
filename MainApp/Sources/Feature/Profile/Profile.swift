//
//  Profile.swift
//
//
//  Created by Jeremy on 11/6/24.
//


import SwiftUI
import ComposableArchitecture


public struct Profile: Reducer {
  // MARK: - State
  public struct State: Equatable {
    public init() {}
    
    public var title: String = "프로필"
    public var name: String = ""
    public var birthDate: Date = Date()
  }
  
  // MARK: - Action
  public enum Action: Equatable {
    case updateName(String)
    case updateBirthDate(Date)
  }
  
  public init() {}
  
  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .updateName(name):
        state.name = name
        return .none
        
      case let .updateBirthDate(date):
        state.birthDate = date
        return .none
      }
    }
  }
}

public struct ProfileView: View {
  // MARK: - Property
  public let store: StoreOf<Profile>
  
  
  public init(store: StoreOf<Profile>) {
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
  private func content(_ viewStore: ViewStoreOf<Profile>) -> some View {
    VStack(spacing: 20) {
      Text(viewStore.title)
        .font(.title)
        .padding()
      
      TextField("이름을 입력하세요", text: viewStore.binding(
        get: \.name,
        send: Profile.Action.updateName
      ))
      .textFieldStyle(RoundedBorderTextFieldStyle())
      .padding(.horizontal)
      
      DatePicker(
        "생년월일",
        selection: viewStore.binding(
          get: \.birthDate,
          send: Profile.Action.updateBirthDate
        ),
        displayedComponents: [.date]
      )
      .padding(.horizontal)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
    .background(Color(.systemBackground))
  }
}
