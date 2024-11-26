import Foundation
import Moya

public protocol GPTServiceProtocol {
    func getHoroscope(birthDateTime: Date, additionalPrompt: String, includeTime: Bool) async throws -> GPTResponse
}

public final class GPTService: GPTServiceProtocol {
    private let provider: NetworkProviding
    
    public init(provider: NetworkProviding = NetworkProvider()) {
        self.provider = provider
    }
    
    public func getHoroscope(birthDateTime: Date, additionalPrompt: String, includeTime: Bool) async throws -> GPTResponse {
        let request = GPTRequest.create(birthDateTime: birthDateTime, additionalPrompt: additionalPrompt, includeTime: includeTime)
        let target = GPTTarget.getHoroscope(request: request)
        
        do {
            let data = try await provider.request(target)
            let decoder = JSONDecoder()
            return try decoder.decode(GPTResponse.self, from: data)
        } catch {
            throw error
        }
    }
}
