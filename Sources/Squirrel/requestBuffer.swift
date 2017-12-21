//
//  requestBuffer.swift
//  Squirrel
//
//  Created by Filip Klembara on 12/21/17.
//

import Socket
import Foundation
extension Request {
    class Buffer {
        private var buffer: [UInt8]

        // swiftlint:disable:next nesting
        enum Delimeter {
            case crlf
            case space
        }

        init(buffer: Data) {
            self.buffer = buffer.reversed()
        }

        func read(until delimeter: Delimeter, allowEmpty: Bool) throws -> Data {
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
        func read(bytes: Int) -> Data {
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

        func read(until sequence: Data, allowEmpty: Bool) throws -> Data {
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

        func readString(until delimeter: Delimeter, allowEmpty: Bool = false)
            throws -> String {
                let data = try read(until: delimeter, allowEmpty: allowEmpty)
                guard let string = String(data: data, encoding: .utf8) else {
                    throw DataError(kind: .dataEncodingError)
                }
                return string
        }
    }

    class SocketBuffer {
        private var buffer: [UInt8]
        private let socket: Socket
        private static let readWait: UInt = 1000

        // swiftlint:disable:next nesting
        enum Delimeter {
            case crlf
            case space
        }

        init(socket: Socket) {
            self.socket = socket
            buffer = []
            try? refreshBuffer()
        }

        func read(until delimeter: Delimeter, allowEmpty: Bool) throws -> Data {
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

        private func waitRefreshBuffer() throws {
            guard try Socket.wait(for: [socket], timeout: SocketBuffer.readWait) != nil else {
                throw HTTPError(status: .requestTimeout)
            }
            try refreshBuffer()
        }

        private func refreshBuffer() throws {
            var readData = Data()
            let _ = try socket.read(into: &readData)
            if readData.count > 0 {
                buffer = readData.reversed() + buffer
            }
        }

        func read(bytes: Int) throws -> Data {
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

        func readString(until delimeter: Delimeter,
                        allowEmpty: Bool = false) throws -> String {

            let data = try read(until: delimeter, allowEmpty: allowEmpty)
            guard let string = String(data: data, encoding: .utf8) else {
                throw DataError(kind: .dataEncodingError)
            }
            return string
        }
    }
}
