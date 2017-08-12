public protocol ViewProtocol {
    mutating func getContent() throws -> String

    init<T>(name: String, object: T?) throws
}
