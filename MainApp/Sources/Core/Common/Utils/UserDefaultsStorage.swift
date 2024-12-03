import Foundation

@propertyWrapper
public struct UserDefaultsStorage<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let storage: UserDefaults
    
    public init(key: String, defaultValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }
    
    public var wrappedValue: T {
        get {
            guard let data = storage.data(forKey: key) else {
                return defaultValue
            }
            
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            storage.set(data, forKey: key)
        }
    }
}

// Usage Example:
public final class AppStorage {
    @UserDefaultsStorage(key: "last_refresh_date", defaultValue: nil)
    public static var lastRefreshDate: Date?
    
    @UserDefaultsStorage(key: "user_zodiac_sign", defaultValue: "")
    public static var userZodiacSign: String
    
    @UserDefaultsStorage(key: "user_birth_date", defaultValue: Date())
    public static var userBirthDate: Date
    
    @UserDefaultsStorage(key: "user_include_time", defaultValue: false)
    public static var userIncludeTime: Bool
    
    @UserDefaultsStorage(key: "user_tone_style", defaultValue: ToneStyle.lee.rawValue)
    public static var userToneStyle: String
}
