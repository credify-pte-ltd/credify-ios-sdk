//
//  StringUtil.swift
//  Credify
//
//  Created by Gioan Le on 28/12/2022.
//

import Foundation

class StringUtil {
    static func addLocaleToUrl(url: String, language: Language?) -> String {
        if (url.isEmpty || language == nil) {
            return url
        }
        
        let strArr = url.components(separatedBy: "/")
        if (strArr.count == 0) {
            return url
        }
        
        let lastPath = strArr[strArr.count - 1]
        if (LocaleUtils.supportedLocales.values.contains(lastPath)) {
            return url
        }
        
        guard let localeStr = LocaleUtils.getLocaleStringByLanguage(language: language!) else {
            return url
        }

        if (url.hasSuffix("/")) {
            return "\(url)\(localeStr)"
        } else {
            return  "\(url)/\(localeStr)"
        }
    }
}
