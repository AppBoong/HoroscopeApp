import Foundation
import Dependencies

public struct GPTClient {
    public var getHoroscope: @Sendable (Date, String) async throws -> GPTResponse
}

extension GPTClient: DependencyKey {
    public static let liveValue = GPTClient(
        getHoroscope: { birthDateTime, additionalPrompt in
            let service = GPTService()
            return try await service.getHoroscope(birthDateTime: birthDateTime, additionalPrompt: additionalPrompt)
        }
    )
}

extension DependencyValues {
    public var gptClient: GPTClient {
        get { self[GPTClient.self] }
        set { self[GPTClient.self] = newValue }
    }
}
