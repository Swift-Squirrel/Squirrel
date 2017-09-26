//
//  DefaultErrorHandlers.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/18/17.
//

import NutView

struct ViewErrors: ErrorHandlerProtocol {
    func getResponse(for error: Error) -> Response? {
        guard let error = error as? NutError else {
            return nil
        }
        let response: Response?
        switch error.kind {
        case .notExists(let name):
            response = try? Response(html: htmlTemplate(
                title: "Nut file does not exists",
                body: "File name: <i>\(name)</i>"))
        }
        guard let resp = response else {
            return Response(
                status: .internalError,
                body: ("Error in ViewErrors: ErrorHandlerProtocol, "
                    + "getResponse(for:)").data(using: .utf8)!)
        }
        return resp
    }
}

struct ViewNutErrors: ErrorHandlerProtocol {
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    func getResponse(for error: Error) -> Response? {
        guard  let error = error as? NutParserError else {
            return nil
        }
        func temp(title: String?, body: String) -> String {
            let fileName = error.name ?? "Uknown file"
            let res = """
            <h4>File: <i>\(fileName)</i></h4>
            <h4>Line: \(error.line)</h4>
            <div>
            \(body)
            </div>
            """
            return htmlTemplate(title: title, body: res)
        }
        let html: String
        switch error.kind {
        case .evaluationError(let infix, let message):
            let body = "Evaluation error in '\(infix)' (\(message))".escaped
            html = temp(title: "Evaluation error", body: body)
        case .expressionError:
            html = temp(title: "Expression Error", body: "")
        case .missingValue(let name):
            html = temp(title: "Missing value", body: "Missing value for \(name.escaped)")
        case .syntaxError(let expected, let got):
            let body = """
            Expecting one of:
            <ul style="list-style: none">
            \(expected.map({ "<li>\($0.escaped)</li>\n" }))
            </ul>
            But got: '\(got.escaped)'
            """
            html = temp(title: "Syntax Error", body: body)
        case .unexpectedBlockEnd:
            html = temp(title: "Unexpected block end", body: "Unexpected '\\}'".escaped)
        case .unexpectedEnd(let reading):
            html = temp(
                title: "Unexpected end",
                body: ("Unexpected end of file or using another command "
                    + "while reading: '\(reading)'").escaped)
        case .unknownInternalError(let commandName):
            html = temp(
                title: "Unknown internal error",
                body: "Uknown error in '\(commandName)'".escaped)
        case .wrongChainedVariable(let name, let command, let regex):
            html = temp(
                title: "Wrong variable name",
                body: ("Variable '\(name)' in '\(command)' does not match "
                    + "regular expression: \(regex)").escaped)
        case .wrongSimpleVariable(let name, let command, let regex):
            html = temp(
                title: "Wrong variable name",
                body: ("Variable '\(name)' in '\(command)' does not match "
                + "regular expression: \(regex)").escaped)
        case .wrongValue(let name, let expected, let got):
            html = temp(
                title: "Wrong value",
                body: ("Wrong value for '\(name)', expected type was '\(expected)' "
                    + "but got '\(got)'").escaped)
        }
        guard let response = try? Response(html: html) else {
            return Response(
                status: .internalError,
                body: ("Error in ViewNutErrors: ErrorHandlerProtocol, "
                    + "getResponse(for:)").data(using: .utf8)!)
        }
        return response
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}

struct BasicErrors: ErrorHandlerProtocol {
    func getResponse(for error: Error) -> Response? {
        guard let error = error as? HTTPError else {
            return nil
        }
        let body = htmlTemplate(title: error.status.description, body: error.description)
        if let response = try? Response(status: .ok, html: body) {
            return response
        } else {
            return Response(status: .internalError)
        }

    }
}
