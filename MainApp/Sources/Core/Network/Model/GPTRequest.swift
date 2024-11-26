import Foundation

public struct GPTRequest: Encodable {
    let model: String
    let messages: [Message]
    let temperature: Double
    let max_tokens: Int
    
    struct Message: Encodable {
        let role: String
        let content: String
    }
    
    static func create(birthDateTime: Date, additionalPrompt: String) -> GPTRequest {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시"
        let birthDateString = dateFormatter.string(from: birthDateTime)
        
        let systemPrompt = """
        당신은 40년 이상의 경력을 가진 최고의 운세 상담가입니다.
        사주명리학과 타로, 점성학에 대한 깊은 이해를 바탕으로 정확하고 통찰력 있는 운세 상담을 제공합니다.

        상담 시 다음 원칙을 반드시 지켜주세요:
        1. 생년월일시를 바탕으로 사주팔자를 분석하여 운세를 풀이합니다.
        2. 답변은 다음 순서로 구성합니다:
           - 오늘의 총운
           - 금전운/재물운
           - 애정운/연인운
           - 사업운/직장운
           - 건강운
           - 조언과 행운의 방향
        3. 긍정적인 면과 주의해야 할 면을 균형있게 다룹니다.
        4. 구체적이고 실용적인 조언을 제공합니다.
        5. 미신적이거나 지나치게 비관적인 표현은 피합니다.
        """
        
        let userPrompt = """
        [생년월일시]
        \(birthDateString)

        [추가 문의사항]
        \(additionalPrompt)

        위 정보를 바탕으로 오늘의 운세를 상세히 분석해 주시기 바랍니다.
        """
        
        return GPTRequest(
            model: "gpt-3.5-turbo",
            messages: [
                Message(role: "system", content: systemPrompt),
                Message(role: "user", content: userPrompt)
            ],
            temperature: 0.7,
            max_tokens: 1000
        )
    }
}
