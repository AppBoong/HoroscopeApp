import SwiftUI

import Core

import ComposableArchitecture

public struct HoroscopeHistory: Reducer {
    public struct State: Equatable {
        var horoscopes: [HoroscopeItem] = []
        var errorMessage: String?
        var isLoading: Bool = false
        
        public init() {}
    }
    
    @CasePathable
    public enum Action: Equatable {
        case onAppear
        case loadHoroscopes
        case horoscopesResponse(TaskResult<[HoroscopeItem]>)
        case deleteHoroscope(HoroscopeItem)
        case dismissError
    }
    
    @Dependency(\.horoscopeStorage) var storage
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .send(.loadHoroscopes)
                
            case .loadHoroscopes:
                return .run { send in
                    await send(.horoscopesResponse(TaskResult {
                        try await storage.fetchAll()
                    }))
                }
                
            case let .horoscopesResponse(.success(items)):
                state.horoscopes = items
                state.errorMessage = nil
                state.isLoading = false
                return .none
                
            case let .horoscopesResponse(.failure(error)):
                state.errorMessage = error.localizedDescription
                state.isLoading = false
                return .none
                
            case let .deleteHoroscope(item):
                state.isLoading = true
                return .run { send in
                    do {
                        try await storage.delete(item)
                        await send(.loadHoroscopes)
                    } catch {
                        await send(.horoscopesResponse(.failure(error)))
                    }
                }
                
            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}

public struct HoroscopeHistoryView: View {
    let store: StoreOf<HoroscopeHistory>
    
    public init(store: StoreOf<HoroscopeHistory>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            Group {
                if viewStore.isLoading {
                    ProgressView()
                } else {
                    List {
                        ForEach(viewStore.horoscopes, id: \.id) { item in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(item.date.toString())
                                        .font(.headline)
                                    Spacer()
                                    Text(item.toneStyle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(item.content)
                                    .font(.body)
                                    .lineLimit(3)
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewStore.send(.deleteHoroscope(item))
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .refreshable {
                        await viewStore.send(.loadHoroscopes).finish()
                    }
                }
            }
            .navigationTitle("운세 기록")
            .alert(
                "오류",
                isPresented: viewStore.binding(
                    get: { $0.errorMessage != nil },
                    send: .dismissError
                ),
                actions: { Button("확인") {} },
                message: { Text(viewStore.errorMessage ?? "") }
            )
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
