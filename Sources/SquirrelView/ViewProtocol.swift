public protocol ViewProtocol {
    mutating func getContent() throws -> String

    init<T>(name: String, with object: T?) throws
}
