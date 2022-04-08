//
//  EntitiesTest.swift
//  
//
//  Created by Gioan Le on 07/04/2022.
//

import Foundation
import XCTest
import Credify

class EntitiesTest : XCTestCase {
    class TestModel: Codable {
        public let value: AnyValue
    }
    
    private func decode(json: String) -> TestModel? {
        return try? JSONDecoder().decode(TestModel.self, from: json.data(using: String.Encoding.utf8)!)
    }
    
    private func encode(model: TestModel) -> String? {
        let data = try? JSONEncoder().encode(model)
        if data == nil {
            return nil
        }
        return String(bytes: data!, encoding: String.Encoding.utf8)
    }
    
    func testString() throws {
        let json = "{\"value\":\"This is string\"}"
        
        let model = self.decode(json: json)
        XCTAssertNotNil(model)
        
        let jsonEncoded = self.encode(model: model!)
        XCTAssertEqual(json, jsonEncoded)
    }
    
    func testInt() throws {
        let json = "{\"value\":987654321}"
        
        let model = self.decode(json: json)
        XCTAssertNotNil(model)
        
        let jsonEncoded = self.encode(model: model!)
        XCTAssertEqual(json, jsonEncoded)
    }
    
    func testDouble() throws {
        let json = "{\"value\":987654.321}"
        
        let model = self.decode(json: json)
        XCTAssertNotNil(model)
        
        let jsonEncoded = self.encode(model: model!)
        XCTAssertEqual(json, jsonEncoded)
    }
    
    /**
     *   {
     *     "value": {
     *       "value1": 10,
     *       "value2": 10.4,
     *       "value3": "This is string",
     *       "value4": [
     *         {
     *           "value41": 1,
     *           "value42": "This is string in an array"
     *         },
     *         {
     *           "value41": 2,
     *           "value42": "This is string in an array"
     *         }
     *       ]
     *     }
     *   }
     */
    func testObject() throws {
        let json = "{\"value\":{\"value1\":10,\"value2\":10.4,\"value3\":\"This is string\",\"value4\":[{\"value41\":1,\"value42\":\"This is string in an array\"},{\"value41\":2,\"value42\":\"This is string in an array\"}]}}"
        
        let model = self.decode(json: json)
        XCTAssertNotNil(model)
        
        let jsonEncoded = self.encode(model: model!)
        print(jsonEncoded ?? "Json decode failed")
        
        XCTAssertGreaterThan(jsonEncoded?.count ?? 0, 0)
    }
}
