//
//  PostMessageUtilsTest.swift
//  CredifyTests
//
//  Created by Gioan Le on 22/03/2022.
//

import Foundation
import XCTest
@testable import Credify

class PostMessageUtilsTest : XCTestCase {
    func testParseBase64Payload() throws {
        // Raw data
        // let expectedResult: [String: Any] = [
        //    "data":"This is the payload"
        // ]
        let expectedKey = "data"
        let expectedValue = "This is the payload"
        
        
        let dict: [String: Any] = [
            "action": "actionLogin",
            "payloadType": "Base64",
            "payload": "eyJkYXRhIjoiVGhpcyBpcyB0aGUgcGF5bG9hZCJ9"
        ]
        
        let result = PostMessageUtils.parsePayload(dict: dict)
        
        assert(result!.contains(where: { (key: String, value: Any) in
            key == expectedKey && (value as! String) == expectedValue
        }))
    }
    
    func testParseNotBase64Payload() throws {
        // Raw data
        // let expectedResult: [String: Any] = [
        //    "data":"This is the payload"
        // ]
        let expectedKey = "data"
        let expectedValue = "This is the payload"
        
        
        let dict: [String: Any] = [
            "action": "actionLogin",
            "payload": [
                "data": "This is the payload"
            ]
        ]
        
        let result = PostMessageUtils.parsePayload(dict: dict)
        
        assert(result!.contains(where: { (key: String, value: Any) in
            key == expectedKey && (value as! String) == expectedValue
        }))
    }
}
