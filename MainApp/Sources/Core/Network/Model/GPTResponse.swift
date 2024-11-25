import Foundation

public struct GPTResponse: Decodable, Equatable {
  public let id: String
  public let choices: [Choice]
    
    public struct Choice: Decodable, Equatable {
      public let message: Message
      public let finishReason: String
        
        enum CodingKeys: String, CodingKey {
            case message
            case finishReason = "finish_reason"
        }
    }
    
    public struct Message: Decodable, Equatable {
      public let role: String
      public let content: String
    }
    
    public var horoscopeContent: String {
        choices.first?.message.content ?? "운세 정보를 불러오는데 실패했습니다."
    }
}
