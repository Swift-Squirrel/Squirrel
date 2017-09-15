//
//  JSON+ExpressibleBy.swift
//  SquirrelJSONEncoding
//
//  Created by Filip Klembara on 9/15/17.
//

// MARK: String
extension JSON : ExpressibleByStringLiteral {

    /// Construct from string literal
    ///
    /// - Parameter value: string value
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }

    /// Construct from string literal
    ///
    /// - Parameter value: string literal
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }

    /// Construct from string literal
    ///
    /// - Parameter value: string literal
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}


// MARK: - Dictionary
extension JSON: ExpressibleByDictionaryLiteral {

    /// Construct from dictionary literal
    ///
    /// - Parameter elements: Dictionary literal
    public init(dictionaryLiteral elements: (String, JSON)...) {
        var elems = [String: JSON]()
        elements.forEach { (string, json) in
            elems[string] = json
        }
        self.init(elems)
    }

    /// Construct from dictionary literal
    ///
    /// - Parameter elements: Dictionary literal
    public init?(dictionaryLiteral elements: (String, Any)...) {
        var elems = [String: Any]()
        elements.forEach { (string, any) in
            elems[string] = any
        }
        self.init(dictionary: elems)
    }
}

// MARK: - Array
extension JSON: ExpressibleByArrayLiteral {

    /// Construct from array literal
    ///
    /// - Parameter elements: Elements
    public init(arrayLiteral elements: JSON...) {
        self.init(elements)
    }

    /// Construct from array literal
    ///
    /// - Parameter elements: Elements
    public init?(arrayLiteral elements: Any...) {
        self.init(array: elements)
    }
}

// MARK: - Int
extension JSON: ExpressibleByIntegerLiteral {
    /// Construct from integer literal
    ///
    /// - Parameter value: Integer literal
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

// MARK: - Double
extension JSON: ExpressibleByFloatLiteral {
    /// Construct from float literal
    ///
    /// - Parameter value: float literal
    public init(floatLiteral value: Double) {
        self.init(Double(value))
    }
}

// MARK: - Bool
extension JSON: ExpressibleByBooleanLiteral {
    /// Construct from bool literal
    ///
    /// - Parameter value: Bool literal
    public init(booleanLiteral value: Bool) {
        self.init(value)
    }
}

// MARK: - Nil
extension JSON: ExpressibleByNilLiteral {
    /// Construct from Nil literal
    ///
    /// - Parameter nilLiteral: Nil literal
    public init(nilLiteral: ()) {
        self.init()
    }
}
