import Foundation
import Moya

public enum GPTTarget {
    case getHoroscope(request: GPTRequest)
}

extension GPTTarget: TargetType {
  public var baseURL: URL {
        return URL(string: "https://api.openai.com/v1")!
    }
    
  public var path: String {
        switch self {
        case .getHoroscope:
            return "/chat/completions"
        }
    }
    
  public var method: Moya.Method {
        switch self {
        case .getHoroscope:
            return .post
        }
    }
    
  public var task: Moya.Task {
        switch self {
        case .getHoroscope(let request):
            return .requestJSONEncodable(request)
        }
    }
    
  public var headers: [String : String]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(Configuration.gptAPIKey)"
        ]
    }
}
