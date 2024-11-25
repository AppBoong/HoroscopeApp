import Foundation
import Moya

public extension MoyaProvider {
    static func defaultProvider() -> MoyaProvider {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        
        let session = Session(configuration: configuration)
        
        return MoyaProvider(
            session: session,
            plugins: [
                NetworkLoggerPlugin()
            ]
        )
    }
    
    func request(_ target: Target) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            self.request(target) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: response)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
