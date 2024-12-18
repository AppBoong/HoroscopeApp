import Foundation
import Moya

public protocol NetworkProviding {
    func request<T: TargetType>(_ target: T) async throws -> Data
}

public final class NetworkProvider: NetworkProviding {
    private let provider: MoyaProvider<MultiTarget>
    
    public init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30  // 30초 타임아웃
        configuration.timeoutIntervalForResource = 30
        
        let session = Session(configuration: configuration)
        
        let plugins: [PluginType] = []
        
        self.provider = MoyaProvider<MultiTarget>(session: session, plugins: plugins)
    }
    
    public func request<T: TargetType>(_ target: T) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(MultiTarget(target)) { result in
                switch result {
                case let .success(response):
                    continuation.resume(returning: response.data)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
