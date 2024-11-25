import Foundation
import os

public enum Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.app.horoscope"
    
    public static let network = os.Logger(subsystem: subsystem, category: "network")
    public static let storage = os.Logger(subsystem: subsystem, category: "storage")
    public static let ui = os.Logger(subsystem: subsystem, category: "ui")
    
    public static func debug(_ message: String, category: os.Logger = network) {
        #if DEBUG
        category.debug("📝 \(message)")
        #endif
    }
    
    public static func info(_ message: String, category: os.Logger = network) {
        category.info("ℹ️ \(message)")
    }
    
    public static func error(_ error: Error, category: os.Logger = network) {
        category.error("❌ \(error.localizedDescription)")
    }
    
    public static func warning(_ message: String, category: os.Logger = network) {
        category.warning("⚠️ \(message)")
    }
}
