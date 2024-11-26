//
//  Horoscope.swift
//
//
//  Created by Jeremy on 11/6/24.
//

import SwiftUI
import ComposableArchitecture
import Core
import Moya

public struct Horoscope: Reducer {
    public enum HoroscopeError: LocalizedError, Equatable {
        case networkError
        case decodingError
        case unknownError(String)
        
        public var errorDescription: String? {
            switch self {
            case .networkError:
                return "네트워크 연결에 실패했습니다."
            case .decodingError:
                return "데이터 처리에 실패했습니다."
            case .unknownError(let message):
                return message
            }
        }
        
        public static func == (lhs: HoroscopeError, rhs: HoroscopeError) -> Bool {
            switch (lhs, rhs) {
            case (.networkError, .networkError),
                 (.decodingError, .decodingError):
                return true
            case let (.unknownError(lhsMessage), .unknownError(rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
    
    public struct State: Equatable {
        public var selectedDate: Date
        public var includeTime: Bool
        public var horoscopeResult: String
        public var isLoading: Bool
        public var errorMessage: String?
        
        public init(
            selectedDate: Date = Date(),
            includeTime: Bool = false,
            horoscopeResult: String = "",
            isLoading: Bool = false,
            errorMessage: String? = nil
        ) {
            self.selectedDate = selectedDate
            self.includeTime = includeTime
            self.horoscopeResult = horoscopeResult
            self.isLoading = isLoading
            self.errorMessage = errorMessage
        }
    }
    
    public enum Action: Equatable {
        case selectDate(Date)
        case toggleIncludeTime
        case getHoroscope
        case horoscopeResponse(Result<GPTResponse, HoroscopeError>)
    }
    
    @Dependency(\.gptClient) var gptClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .selectDate(date):
                state.selectedDate = date
                return .none
                
            case .toggleIncludeTime:
                state.includeTime.toggle()
                return .none
                
            case .getHoroscope:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run { [date = state.selectedDate, includeTime = state.includeTime] send in
                    do {
                        let response = try await gptClient.getHoroscope(date, "", includeTime)
                        await send(.horoscopeResponse(.success(response)))
                    } catch {
                        let horoscopeError: HoroscopeError
                        if let moyaError = error as? MoyaError {
                            switch moyaError {
                            case .underlying(_, _):
                                horoscopeError = .networkError
                            case .jsonMapping(_), .objectMapping(_, _):
                                horoscopeError = .decodingError
                            default:
                                horoscopeError = .unknownError(error.localizedDescription)
                            }
                        } else {
                            horoscopeError = .unknownError(error.localizedDescription)
                        }
                        await send(.horoscopeResponse(.failure(horoscopeError)))
                    }
                }
                
            case let .horoscopeResponse(.success(response)):
                state.isLoading = false
                state.horoscopeResult = response.choices.first?.message.content ?? ""
                return .none
                
            case let .horoscopeResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}

public struct HoroscopeView: View {
    let store: StoreOf<Horoscope>
    
    public init(store: StoreOf<Horoscope>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView {
                VStack(spacing: 20) {
                    dateSelectionSection(viewStore)
                  
                    resultSection(viewStore)
                    .onTapGesture {
                        hideKeyboard()
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
    
    private func dateSelectionSection(_ viewStore: ViewStoreOf<Horoscope>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("생년월일 선택")
                .font(.headline)
            
            DatePicker("생년월일",
                      selection: viewStore.binding(
                        get: \.selectedDate,
                        send: Horoscope.Action.selectDate
                      ),
                      displayedComponents: [.date])
            .datePickerStyle(.graphical)
            .labelsHidden()
            
          HStack(spacing: 5) {
            Text("태어난 시간 포함")
            
            Spacer()
            
            
            
            Toggle(
              isOn: viewStore.binding(
                get: \.includeTime,
                send: Horoscope.Action.toggleIncludeTime
              ), label: {
                if viewStore.includeTime {
                  DatePicker("시간",
                             selection: viewStore.binding(
                              get: \.selectedDate,
                              send: Horoscope.Action.selectDate
                             ),
                             displayedComponents: [.hourAndMinute])
                  .datePickerStyle(.graphical)
                  .labelsHidden()
                }
              }
            )
            .toggleStyle(SwitchToggleStyle(tint: .blue))
          }
          .frame(height: 40)
        }
    }
    
    private func resultSection(_ viewStore: ViewStoreOf<Horoscope>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                viewStore.send(.getHoroscope)
            }) {
                if viewStore.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("운세 보기")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewStore.isLoading)
            
            if !viewStore.horoscopeResult.isEmpty {
                Text("운세 결과")
                    .font(.headline)
                
                Text(viewStore.horoscopeResult)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            
            if let error = viewStore.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Keyboard Helper
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
