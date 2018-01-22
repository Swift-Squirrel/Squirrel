//
//  requestBuffer.swift
//  Squirrel
//
//  Created by Filip Klembara on 12/21/17.
//

import Socket
import Foundation
import SquirrelCore

public enum BufferDelimeter {
    case crlf
    case space
}

public protocol Buffer {
    func read(until delimeter: BufferDelimeter, allowEmpty: Bool) throws -> Data
    func read(bytes: Int) throws -> Data
    func readString(until delimeter: BufferDelimeter, allowEmpty: Bool) throws -> String
}

extension Request {

    public class StaticBuffer: Buffer {
        private var buffer: [UInt8]

        // swiftlint:disable:next nesting


        public init(buffer: Data) {
            self.buffer = buffer.reversed()
        }

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
                        let _ = buffer.popLast()
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
        public func read(bytes: Int) throws -> Data {
            //            let res = buffer.dropLast(bytes)
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

        public func readString(until delimeter: BufferDelimeter,
                        allowEmpty: Bool = false) throws -> String {
                let data = try read(until: delimeter, allowEmpty: allowEmpty)
                guard let string = String(data: data, encoding: .utf8) else {
                    throw DataError(kind: .dataEncodingError)
                }
                return string
        }
    }

    public class SocketBuffer: Buffer {
        private var buffer: [UInt8]
        private let socket: Socket
        public static var readWait: UInt = 3000
        public static var initWait: UInt = 20000
        public static var bufferSize: UInt = 4096 {
            didSet {
                _bufferSize = Int(bufferSize)
            }
        }
        private static var _bufferSize = 4096

        public init(socket: Socket) throws {
            self.socket = socket
            buffer = []
            try wait(miliseconds: SocketBuffer.initWait)
            try refreshBuffer()
        }

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
                            let _ = buffer.popLast()
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

        public func readString(until delimeter: BufferDelimeter,
                        allowEmpty: Bool = false) throws -> String {

            let data = try read(until: delimeter, allowEmpty: allowEmpty)
            guard let string = String(data: data, encoding: .utf8) else {
                throw DataError(kind: .dataEncodingError)
            }
            return string
        }
    }

    struct SocketError: HTTPErrorConvertible, SquirrelError {
        var asHTTPError: HTTPError {
            switch kind {
            case .timeout:
                return HTTPError(status: .requestTimeout, description: description)
            case .clientClosedConnection:
                fatalError(description)
            }
        }

        enum Kind {
            case timeout
            case clientClosedConnection
        }
        let kind: Kind
        let description: String
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
