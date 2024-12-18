//
//  Profile.swift
//
//
//  Created by Jeremy on 11/6/24.
//


import SwiftUI

import Core

import ComposableArchitecture


public struct Profile: Reducer {
  // MARK: - State
  public struct State: Equatable {
    public var title: String = "프로필"
    public var birthDate: Date
    public var includeTime: Bool
    
    public init(
        birthDate: Date = AppStorage.userBirthDate,
        includeTime: Bool = AppStorage.userIncludeTime
    ) {
        self.birthDate = birthDate
        self.includeTime = includeTime
    }
  }
  
  // MARK: - Action
  public enum Action: Equatable {
    case updateBirthDate(Date)
    case toggleIncludeTime
    case saveProfile
  }
  
  public init() {}
  
  // MARK: - Body
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .updateBirthDate(date):
        state.birthDate = date
        return .none
        
      case .toggleIncludeTime:
        state.includeTime.toggle()
        return .none
        
      case .saveProfile:
        AppStorage.userBirthDate = state.birthDate
        AppStorage.userIncludeTime = state.includeTime
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
    Form {
        Section(header: Text("기본 정보")) {
            DatePicker("생년월일",
                selection: viewStore.binding(
                    get: \.birthDate,
                    send: Profile.Action.updateBirthDate
                ),
                displayedComponents: viewStore.includeTime ? [.date, .hourAndMinute] : [.date]
            )
            
            Toggle("시간 포함",
                isOn: viewStore.binding(
                    get: \.includeTime,
                    send: { _ in .toggleIncludeTime }
                )
            )
        }
        
        Section {
            Button("저장") {
                viewStore.send(.saveProfile)
            }
        }
    }
    .navigationTitle(viewStore.title)
  }
}
