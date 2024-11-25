import Foundation

public struct GPTRequest: Encodable {
    let model: String
    let messages: [Message]
    let temperature: Double
    
    struct Message: Encodable {
        let role: String
        let content: String
    }
    
    static func create(birthDateTime: Date, additionalPrompt: String) -> GPTRequest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시"
        let birthDateString = dateFormatter.string(from: birthDateTime)
        
        let content = """
        다음은 사용자의 생년월일시 입니다: \(birthDateString)
        
        추가 요청사항: \(additionalPrompt)
        
        위 정보를 바탕으로 상세한 운세를 알려주세요.
        """
        
        return GPTRequest(
            model: "gpt-4",
            messages: [
                Message(role: "system", content: "당신은 전문적인 운세 상담가입니다. 사용자의 생년월일시를 바탕으로 정확하고 상세한 운세 정보를 제공해주세요."),
                Message(role: "user", content: content)
            ],
            temperature: 0.7
        )
    }
}
