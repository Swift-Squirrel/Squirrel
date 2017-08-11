public protocol ViewProtocol {
    mutating func getContent() throws -> String

    init(name: String)
}
