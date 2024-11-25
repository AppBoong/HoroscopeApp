import Foundation
import Moya

public protocol GPTServiceProtocol {
    func getHoroscope(birthDateTime: Date, additionalPrompt: String) async throws -> GPTResponse
}

public final class GPTService: GPTServiceProtocol {
    private let provider = MoyaProvider<GPTTarget>()
    
    public init() {}
    
    public func getHoroscope(birthDateTime: Date, additionalPrompt: String) async throws -> GPTResponse {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        
        let systemPrompt = """
        당신은 전문 점성술사입니다. 
        유저의 생년월일시를 기반으로 운세를 봐주세요.
        결과는 친근하고 따뜻한 어조로 작성해주세요.
        """
        
        let userPrompt = """
        저의 생년월일시는 \(dateFormatter.string(from: birthDateTime))입니다.
        \(additionalPrompt)
        """
        
        let request = GPTRequest(
            model: "gpt-4",
            messages: [
                .init(role: "system", content: systemPrompt),
                .init(role: "user", content: userPrompt)
            ],
            temperature: 0.7
        )
        
        let target = GPTTarget.getHoroscope(request: request)
        
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        let gptResponse = try response.map(GPTResponse.self)
                        continuation.resume(returning: gptResponse)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
