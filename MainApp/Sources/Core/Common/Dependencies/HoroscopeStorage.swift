import Foundation
import SwiftData
import Dependencies

public struct HoroscopeStorage {
    private let context: ModelContext
    
    public init(context: ModelContext) {
        self.context = context
    }
    
    public var save: @Sendable (HoroscopeItem) async throws -> Void {
        get {
            { item in
                self.context.insert(item)
                try self.context.save()
            }
        }
    }
    
    public var delete: @Sendable (HoroscopeItem) async throws -> Void {
        get {
            { item in
                self.context.delete(item)
                try self.context.save()
            }
        }
    }
    
    public var fetchAll: @Sendable () async throws -> [HoroscopeItem] {
        get {
            {
                let descriptor = FetchDescriptor<HoroscopeItem>(
                    sortBy: [SortDescriptor<HoroscopeItem>(
                        \HoroscopeItem.createdAt,
                        order: .reverse
                    )]
                )
                return try self.context.fetch(descriptor)
            }
        }
    }
    
    public var fetchRecent: @Sendable (Int) async throws -> [HoroscopeItem] {
        get {
            { limit in
                var descriptor = FetchDescriptor<HoroscopeItem>(
                    sortBy: [SortDescriptor<HoroscopeItem>(
                        \HoroscopeItem.createdAt,
                        order: .reverse
                    )]
                )
                descriptor.fetchLimit = limit
                return try self.context.fetch(descriptor)
            }
        }
    }
}

extension HoroscopeStorage: DependencyKey {
    public static let liveValue: HoroscopeStorage = {
        let schema = Schema([HoroscopeItem.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let modelContainer = try! ModelContainer(for: schema, configurations: [modelConfiguration])
        let context = ModelContext(modelContainer)
        return HoroscopeStorage(context: context)
    }()
}

extension DependencyValues {
    public var horoscopeStorage: HoroscopeStorage {
        get { self[HoroscopeStorage.self] }
        set { self[HoroscopeStorage.self] = newValue }
    }
} 