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

public struct HoroscopeMain: Reducer {
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
    public var toneStyle: Core.ToneStyle
    public var horoscopeResult: String
    public var isLoading: Bool
    public var errorMessage: String?
    public var recentHoroscopes: [HoroscopeItem] = []
    public var historyState: HoroscopeHistory.State?
    
    public init(
      selectedDate: Date = Date(),
      includeTime: Bool = false,
      toneStyle: Core.ToneStyle = .lee,
      horoscopeResult: String = "",
      isLoading: Bool = false,
      errorMessage: String? = nil,
      historyState: HoroscopeHistory.State? = nil
    ) {
      self.selectedDate = selectedDate
      self.includeTime = includeTime
      self.toneStyle = toneStyle
      self.horoscopeResult = horoscopeResult
      self.isLoading = isLoading
      self.errorMessage = errorMessage
      self.historyState = historyState
    }
  }
  
  @CasePathable
  public enum Action: Equatable {
    case selectDate(Date)
    case toggleIncludeTime
    case selectToneStyle(Core.ToneStyle)
    case getHoroscope
    case horoscopeResponse(Result<GPTResponse, HoroscopeError>)
    case routeToHistory
    case saveHoroscope
    case loadRecentHoroscopes
    case recentHoroscopesResponse(Result<[HoroscopeItem], HoroscopeError>)
    case history(HoroscopeHistory.Action)
  }
  
  @Dependency(\.gptClient) var gptClient
  @Dependency(\.horoscopeStorage) var storage
  
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
        
      case let .selectToneStyle(style):
        state.toneStyle = style
        return .none
        
      case .getHoroscope:
        state.isLoading = true
        state.errorMessage = nil
        
        return .run { [date = state.selectedDate, includeTime = state.includeTime, toneStyle = state.toneStyle] send in
          do {
            let response = try await gptClient.getHoroscope(date, "", includeTime, toneStyle)
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
        
        let item = HoroscopeItem(
          date: state.selectedDate,
          content: state.horoscopeResult,
          toneStyle: state.toneStyle.rawValue,
          includeTime: state.includeTime
        )
        
        return .run { send in
          do {
            try await storage.save(item)
            await send(.loadRecentHoroscopes)
          } catch {
            Logger.error(error, category: Logger.storage)
          }
        }
        
      case let .horoscopeResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
        
      case .routeToHistory:
        state.historyState = HoroscopeHistory.State()
        return .none
        
      case .saveHoroscope:
        let item = HoroscopeItem(
          date: state.selectedDate,
          content: state.horoscopeResult,
          toneStyle: state.toneStyle.rawValue,
          includeTime: state.includeTime
        )
        
        return .run { send in
          do {
            try await storage.save(item)
            await send(.loadRecentHoroscopes)
          } catch {
            await send(.recentHoroscopesResponse(.failure(.unknownError(error.localizedDescription))))
          }
        }
        
      case .loadRecentHoroscopes:
        return .run { send in
          do {
            let items = try await storage.fetchRecent(5)
            await send(.recentHoroscopesResponse(.success(items)))
          } catch {
            await send(.recentHoroscopesResponse(.failure(.unknownError(error.localizedDescription))))
          }
        }
        
      case let .recentHoroscopesResponse(.success(items)):
        state.recentHoroscopes = items
        return .none
        
      case let .recentHoroscopesResponse(.failure(error)):
        state.errorMessage = error.localizedDescription
        return .none
        
      case .history:
        return .none
      }
    }
    .ifLet(\.historyState, action: \.history) {
      HoroscopeHistory()
    }
  }
}

public struct HoroscopeMainView: View {
  let store: StoreOf<HoroscopeMain>
  
  public init(store: StoreOf<HoroscopeMain>) {
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
          
          Button {
            viewStore.send(.routeToHistory)
          } label: {
            Text("이전 운세")
          }
        }
        .padding()
      }
      .scrollDismissesKeyboard(.interactively)
    }
  }
  
  private func dateSelectionSection(_ viewStore: ViewStoreOf<HoroscopeMain>) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("생년월일")
        
        Spacer()
        
        DatePicker("",
                   selection: viewStore.binding(
                    get: \.selectedDate,
                    send: HoroscopeMain.Action.selectDate
                   ),
                   displayedComponents: [.date])
        .datePickerStyle(.compact)
        .labelsHidden()
      }
     
      
      HStack {
        Text("태어난 시간 포함")
        
        Spacer()
        
        Toggle(
          isOn:  viewStore.binding(
            get: \.includeTime,
            send: HoroscopeMain.Action.toggleIncludeTime
          ),
          label: {
            if viewStore.includeTime {
              DatePicker("시간",
                         selection: viewStore.binding(
                          get: \.selectedDate,
                          send: HoroscopeMain.Action.selectDate
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
      
      HStack {
        Text("답변 스타일")
        
        Spacer()
        
        Picker("",
               selection: viewStore.binding(
          get: \.toneStyle,
          send: HoroscopeMain.Action.selectToneStyle
        )) {
          ForEach(Core.ToneStyle.allCases, id: \.self) { style in
            Text(style.rawValue)
              .tag(style)
          }
        }
        .pickerStyle(.automatic)
      }
    }
  }
  
  private func resultSection(_ viewStore: ViewStoreOf<HoroscopeMain>) -> some View {
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
