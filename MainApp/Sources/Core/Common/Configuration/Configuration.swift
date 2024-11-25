import Foundation

public enum Configuration {
    public static var gptAPIKey: String {
        guard let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiKey = dict["GPT_API_KEY"] as? String else {
            fatalError("APIKeys.plist 파일에서 GPT_API_KEY를 찾을 수 없습니다.")
        }
        return apiKey
    }
}
