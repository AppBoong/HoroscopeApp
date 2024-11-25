import Foundation
import Moya

public protocol NetworkProviding {
    func request<T: TargetType>(_ target: T) async throws -> Data
}

public final class NetworkProvider: NetworkProviding {
    private let provider: MoyaProvider<MultiTarget>
    
    public init() {
        self.provider = MoyaProvider<MultiTarget>()
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
