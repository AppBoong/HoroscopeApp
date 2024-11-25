import Foundation
import Moya

public final class NetworkLoggerPlugin: PluginType {
    public init() {}
    
    public func willSend(_ request: RequestType, target: TargetType) {
        #if DEBUG
        print("🚀 Request: \(request.request?.url?.absoluteString ?? "")")
        print("📝 Headers: \(request.request?.allHTTPHeaderFields ?? [:])")
        if let body = request.request?.httpBody,
           let str = String(data: body, encoding: .utf8) {
            print("📦 Body: \(str)")
        }
        #endif
    }
    
    public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        #if DEBUG
        switch result {
        case .success(let response):
            print("✅ Response: \(response.statusCode)")
            if let json = try? response.mapString() {
                print("📦 Data: \(json)")
            }
        case .failure(let error):
            print("❌ Error: \(error.localizedDescription)")
        }
        #endif
    }
}
