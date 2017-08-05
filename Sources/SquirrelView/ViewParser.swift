//
//  ViewParser.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

import Regex

class ViewParser {
    static var data: [String: Any] = [:]

    let content: String

    static var commands: [ParseCommandProtocol] = [ValueParser(), ForParser()]

    static func get(name: String, from data: [String: Any] = data) -> Any? {
        if name.contains(".") {
            var names = name.components(separatedBy: ".")

            if names[1] == "reversed()" || names[1] == "count" {
                guard names.count == 2 else {
                    return nil
                }

                if let arr = data[names[0]] as? [Any] {
                    if names[1] == "count" {
                        return arr.count
                    } else {
                        return arr.reversed()
                    }
                } else if let dic = data[names[0]] as? [String: Any] {
                    if names[1] == "count" {
                        return dic.count
                    } else {
                        return nil
                    }
                } else {
                    return nil
                }
            }

            guard let newData = data[names[0]] as? [String: Any] else {
                return nil
            }

            names.remove(at: 0)
            return get(name: names.joined(separator: "."), from: newData)
        }
        return data[name]
    }

    init(text content: String) {
        self.content = content
        ViewParser.data["name"] = "Fedor"
//        ViewParser.data["posts"] = ["adin", "dva"]
//        ViewParser.data["asd"] = ["tata", "rata", "papa"]
    }

    static func parse(text cont: inout [String], prevChar: inout String, partial: Bool) throws -> String {
        var res = ""
        while cont.count > 0 {
            var char = cont[0]
            cont.remove(at: 0)

            if char == "\\" && prevChar != "\\" && cont.count > 0 {
                var pom = char
                var matches = 0
                var command: ParseCommandProtocol = ValueParser()
                repeat {
                    char = cont[0]
                    pom += char
                    cont.remove(at: 0)
                    if partial && pom == "\\}" {
                        prevChar = char
                        return res
                    }
                    commands.forEach({ (com) in
                        if com.prefix.hasPrefix(pom) {
                            matches += 1
                            command = com
                        }
                    })

                } while matches > 1 && cont.count > 0

                if matches == 1 {
                    var parsed = pom
                    while parsed != command.prefix {
                        guard cont.count > 0 else {
                            throw ParseError(kind: .unexpectedEnd, description: "Unexpected end while parsing: \(parsed)")
                        }
                        let char = cont[0]
                        cont.remove(at: 0)
                        parsed += char
                        prevChar = char
                    }
                    res += try command.parse(text: &cont, prevChar: &prevChar)
                } else {
                    prevChar = char
                    res += pom
                }

            } else {
                prevChar = char
                res += char
            }
        }
        return res
    }

    func parse() throws -> String {
        var cont = Array(content.characters).map({ String(describing: $0) })
        var prevChar = ""
        let res = try ViewParser.parse(text: &cont, prevChar: &prevChar, partial: false)
        return res
    }
}
