//
//  requestBuffer.swift
//  Squirrel
//
//  Created by Filip Klembara on 12/21/17.
//

import Socket
import Foundation
import SquirrelCore

/// Buffer delimeters
///
/// - crlf: CRLF
/// - space: Space character
public enum BufferDelimeter {
    case crlf
    case space
}

/// Buffer protocol
public protocol Buffer {
    func read(until delimeter: BufferDelimeter, allowEmpty: Bool) throws -> Data
    func read(bytes: Int) throws -> Data
    func readString(until delimeter: BufferDelimeter, allowEmpty: Bool) throws -> String
}

// MARK: - Request + buffer
extension Request {

    /// Static buffer (reads from data)
    public class StaticBuffer: Buffer {
        private var buffer: [UInt8]

        /// Buffer with fully buffered data
        ///
        /// - Parameter buffer: Buffer data
        public init(buffer: Data) {
            self.buffer = buffer.reversed()
        }

        /// Reads data until deliemeter,
        /// if delimeter is at the start of buffer and allowEmpty is false throws
        ///
        /// - Parameters:
        ///   - delimeter: Delimeter
        ///   - allowEmpty: Allow empty result
        /// - Returns: Data between start and delimeter
        /// - Throws: `RequestError` if delimeter not found or result
        ///     is empty and allowEmpty is false
        public func read(until delimeter: BufferDelimeter, allowEmpty: Bool) throws -> Data {
            var res = Data()
            var found = false
            switch delimeter {
            case .space:
                while let current = buffer.popLast() {
                    if current != 0x20 {
                        res.append(current)
                    } else {
                        found = true
                        break
                    }
                }
            case .crlf:
                while let current = buffer.popLast() {
                    if current == 0xD && buffer.last == 0xA {
                        _ = buffer.popLast()
                        found = true
                        break
                    }
                    res.append(current)
                }
            }
            guard found else {
                buffer.append(contentsOf: res.reversed())
                throw RequestError(kind: .headParseError)
            }
            if res.isEmpty && !allowEmpty {
                throw RequestError(kind: .headParseError)
            }
            return res
        }

        /// Read maximum n bytes from buffer
        ///
        /// - Parameter bytes: number of bytes to read
        /// - Returns: Data with 0-bytes elements
        /// - Throws: Nothing
        public func read(bytes: Int) throws -> Data {
            let endIndex = buffer.endIndex
            var startIndex = endIndex - bytes
            if startIndex < buffer.startIndex {
                startIndex = buffer.startIndex
            }
            let range = startIndex..<endIndex
            let res = buffer[range]
            let n = endIndex - startIndex
            buffer.removeLast(n)
            return Data(bytes: res.reversed())
        }

        /// Read from buffer until sequence,
        /// if delimeter is at the start of buffer and allowEmpty is false throws
        ///
        /// - Parameters:
        ///   - sequence: delimeter sequence
        ///   - allowEmpty: allow empty
        /// - Returns: Data between start and delimeter
        /// - Throws: `RequestError` if delimeter not found or result
        ///     is empty and allowEmpty is false
        public func read(until sequence: Data, allowEmpty: Bool) throws -> Data {
            var found = false
            var bufferIndex = buffer.endIndex - 1
            let bufferStart = buffer.startIndex
            while bufferIndex >= bufferStart {
                if buffer[bufferIndex] == sequence.first {
                    var localBufferIndex = bufferIndex
                    var sequenceIndex = sequence.startIndex
                    let sequenceEnd = sequence.endIndex
                    while sequenceIndex < sequenceEnd
                        && localBufferIndex >= bufferStart
                        && sequence[sequenceIndex] == buffer[localBufferIndex] {
                            sequenceIndex += 1
                            localBufferIndex -= 1
                    }
                    if sequenceIndex == sequenceEnd {
                        found = true
                        break
                    }
                }
                bufferIndex -= 1
            }
            guard found else {
                throw RequestError(kind: .headParseError)
            }
            let start = bufferIndex + 1
            let end = buffer.endIndex
            let res = buffer[start..<end]
            if res.count == sequence.count && !allowEmpty {
                throw RequestError(kind: .headParseError)
            }

            let n = sequence.count + buffer.endIndex - bufferIndex - 1
            buffer.removeLast(n)
            return Data(bytes: res.reversed())
        }

        /// Read data until delimeter and cast them to utf8 string
        ///
        /// - Parameters:
        ///   - delimeter: delimeter
        ///   - allowEmpty: Allow epmty result
        /// - Returns: String
        /// - Throws: `RequestError`
        public func readString(until delimeter: BufferDelimeter,
                               allowEmpty: Bool = false) throws -> String {
                let data = try read(until: delimeter, allowEmpty: allowEmpty)
                guard let string = String(data: data, encoding: .utf8) else {
                    throw DataError(kind: .dataEncodingError)
                }
                return string
        }
    }

    /// Buffer with data loaded from `Socket`
    public class SocketBuffer: Buffer {
        private var buffer: [UInt8]
        private let socket: Socket
        /// Maximum time between readings
        public static var readWait: UInt = 3000
        /// Maximum time waiting for first data
        public static var initWait: UInt = 20000
        /// Buffer size
        public static var bufferSize: UInt = 4096 {
            didSet {
                _bufferSize = Int(bufferSize)
            }
        }
        private static var _bufferSize = 4096

        /// Inits buffer
        ///
        /// - Parameter socket: Socket used to read data
        /// - Throws: `Socket.Error`
        public init(socket: Socket) throws {
            self.socket = socket
            buffer = []
            try wait(miliseconds: SocketBuffer.initWait)
            try refreshBuffer()
        }

        /// Reads data until deliemeter,
        /// if delimeter is at the start of buffer and allowEmpty is false throws
        ///
        /// - Parameters:
        ///   - delimeter: Delimeter
        ///   - allowEmpty: Allow empty result
        /// - Returns: Data between start and delimeter
        /// - Throws: `RequestError` if delimeter not found or result
        ///     is empty and allowEmpty is false
        public func read(until delimeter: BufferDelimeter, allowEmpty: Bool) throws -> Data {
            var res = Data()
            var found = false
            repeat {
                switch delimeter {
                case .space:
                    while let current = buffer.popLast() {
                        if current != 0x20 {
                            res.append(current)
                        } else {
                            found = true
                            break
                        }
                    }
                case .crlf:
                    while let current = buffer.popLast() {
                        if current == 0xD && buffer.last == 0xA {
                            _ = buffer.popLast()
                            found = true
                            break
                        }
                        res.append(current)
                    }
                }
                if !found {
                    if !res.isEmpty {
                        buffer.append(res.last!)
                    }
                    try waitRefreshBuffer()
                }
            } while !found
            if res.isEmpty && !allowEmpty {
                throw RequestError(kind: .headParseError)
            }
            return res
        }

        private func wait(miliseconds: UInt) throws {
            let sock = [socket]
            guard try Socket.wait(for: sock, timeout: miliseconds) != nil else {
                log.verbose("Reading from socket timed out")
                throw SocketError(kind: .timeout)
            }
        }

        private func waitRefreshBuffer() throws {
            try wait(miliseconds: SocketBuffer.readWait)
            try refreshBuffer()
        }

        private func refreshBuffer() throws {
            var readData = Data()
            readData.reserveCapacity(Int(SocketBuffer._bufferSize))
            let count = try socket.read(into: &readData)

            guard count > 0 else {
                throw SocketError(kind: .clientClosedConnection)
            }

            buffer = readData.reversed() + buffer
        }

        /// Read maximum n bytes from buffer
        ///
        /// - Parameter bytes: number of bytes to read
        /// - Returns: Data with 0-bytes elements
        /// - Throws: `Socket.Error`
        public func read(bytes: Int) throws -> Data {
            while bytes > buffer.count {
                try waitRefreshBuffer()
            }
            let endIndex = buffer.endIndex
            let startIndex = endIndex - bytes
            let range = startIndex..<endIndex
            let res = buffer[range]
            let n = endIndex - startIndex
            buffer.removeLast(n)
            return Data(bytes: res.reversed())
        }

        /// Read data until delimeter and cast them to utf8 string
        ///
        /// - Parameters:
        ///   - delimeter: delimeter
        ///   - allowEmpty: Allow epmty result
        /// - Returns: String
        /// - Throws: `RequestError`
        public func readString(until delimeter: BufferDelimeter,
                               allowEmpty: Bool = false) throws -> String {

            let data = try read(until: delimeter, allowEmpty: allowEmpty)
            guard let string = String(data: data, encoding: .utf8) else {
                throw DataError(kind: .dataEncodingError)
            }
            return string
        }
    }

    /// SocketError
    public struct SocketError: HTTPErrorConvertible, SquirrelError {
        /// Returns HTTPError representation
        public var asHTTPError: HTTPError {
            switch kind {
            case .timeout:
                return HTTPError(status: .requestTimeout, description: description)
            case .clientClosedConnection:
                fatalError(description)
            }
        }

        /// Error kind
        ///
        /// - timeout: Waiting timed out
        /// - clientClosedConnection: Client closed connection
        public enum Kind {
            case timeout
            case clientClosedConnection
        }
        /// Error kind
        public let kind: Kind
        /// Error description
        public let description: String

        init (kind: Kind) {
            self.kind = kind
            switch kind {
            case .clientClosedConnection:
                description = "Client closed connection"
            case .timeout:
                description = "Request timed out"
            }
        }
    }
}
