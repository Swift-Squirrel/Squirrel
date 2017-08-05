public protocol ViewProtocol {
    func getContent() throws -> String

    init(name: String)
}
