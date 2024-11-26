import Foundation
import Dependencies

public struct GPTClient {
    public var getHoroscope: @Sendable (Date, String, Bool) async throws -> GPTResponse
}

extension GPTClient: DependencyKey {
    public static let liveValue = GPTClient(
        getHoroscope: { birthDateTime, additionalPrompt, includeTime in
            let service = GPTService()
            return try await service.getHoroscope(birthDateTime: birthDateTime, additionalPrompt: additionalPrompt, includeTime: includeTime)
        }
    )
}

extension DependencyValues {
    public var gptClient: GPTClient {
        get { self[GPTClient.self] }
        set { self[GPTClient.self] = newValue }
    }
}
