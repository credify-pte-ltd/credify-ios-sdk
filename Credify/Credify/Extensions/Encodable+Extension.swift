//
//  Encodable+Extension.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

@available(iOS 10.0, *)
extension Encodable {

    /// Encode into JSON and return `Data`
    func jsonData() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
}

