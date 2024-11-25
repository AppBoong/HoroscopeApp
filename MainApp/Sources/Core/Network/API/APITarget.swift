import Foundation
import Moya

public protocol APITarget: TargetType {
    var baseURL: URL { get }
    var path: String { get }
    var method: Moya.Method { get }
    var task: Moya.Task { get }
    var headers: [String: String]? { get }
}

public extension APITarget {
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
