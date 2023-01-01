//
//  StringUtilTest.swift
//  Credify
//
//  Created by Gioan Le on 28/12/2022.
//

import Foundation
import XCTest
@testable import Credify

class StringUtilTest : XCTestCase {
    func testAddLocaleToUrl_emptyString() throws {
        let url = ""
        let language = Language.vietnamese
        let result = StringUtil.addLocaleToUrl(url: url, language: language)
        XCTAssertEqual(result, "")
    }
    
    func testAddLocaleToUrl_withoutLanguage() throws {
        let url = "https://google.com"
        let result = StringUtil.addLocaleToUrl(url: url, language: nil)
        XCTAssertEqual(result, url)
    }

    func testAddLocaleToUrl_withLanguage() throws {
        let url = "https://google.com"
        let result = StringUtil.addLocaleToUrl(url: url, language: Language.vietnamese)
        XCTAssertEqual(result, "\(url)/vi-VN")
    }

    func testAddLocaleToUrl_withLanguage_withSlashAtTheEndUrl() throws {
        let url = "https://google.com/"
        let result = StringUtil.addLocaleToUrl(url: url, language: Language.vietnamese)
        XCTAssertEqual(result, "\(url)vi-VN")
    }

    func testAddLocaleToUrl_withLanguage_withLocalAtEndUrl() throws {
        let url = "https://google.com/ja-JP"
        let result = StringUtil.addLocaleToUrl(url: url, language: Language.vietnamese)
        XCTAssertEqual(result, url)
    }
}
