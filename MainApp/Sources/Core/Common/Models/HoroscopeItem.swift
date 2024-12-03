import Foundation
import SwiftData

@Model
public final class HoroscopeItem {
    public var id: UUID
    public var date: Date
    public var content: String
    public var toneStyle: String
    public var includeTime: Bool
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        date: Date,
        content: String,
        toneStyle: String,
        includeTime: Bool,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.content = content
        self.toneStyle = toneStyle
        self.includeTime = includeTime
        self.createdAt = createdAt
    }
} 