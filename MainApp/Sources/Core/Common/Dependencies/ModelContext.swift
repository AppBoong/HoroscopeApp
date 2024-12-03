import Foundation
import SwiftData
import Dependencies

private enum ModelContextKey: DependencyKey {
    static let liveValue: ModelContext = {
        let schema = Schema([
            HoroscopeItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let modelContainer = try! ModelContainer(for: schema, configurations: [modelConfiguration])
        return ModelContext(modelContainer)
    }()
}

extension DependencyValues {
    public var modelContext: ModelContext {
        get { self[ModelContextKey.self] }
        set { self[ModelContextKey.self] = newValue }
    }
} 