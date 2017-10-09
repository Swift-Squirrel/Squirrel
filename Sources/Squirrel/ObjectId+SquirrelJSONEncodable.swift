//
//  ObjectId+SquirrelJSONEncodable.swift
//  SquirrelJSON
//
//  Created by Filip Klembara on 10/9/17.
//

import SquirrelConnector
import SquirrelJSON

extension ObjectId: SquirrelJSONEncodable {
    public var encodedValue: Any {
        return hexString
    }
}
