//
//  LocaleUtils.swift
//  
//
//  Created by Gioan Le on 28/05/2022.
//

import Foundation

class LocaleUtils {
    static let languageSupportLastFirstNameOrder = ["vi", "ja"]
    
    static var languageCode: String? {
        get {
            // From client setting
            if let language = AppState.shared.language {
                return language.rawValue
            }
            
            // From device
            if let deviceLanguage = Locale.preferredLanguages.first?.split(separator: "-").first {
                return String(deviceLanguage)
            }
            
            return nil
        }
    }
    
    static var isShowLastFirstNameOrder: Bool {
        get {
            if let languageCode = languageCode {
                return languageSupportLastFirstNameOrder.contains(languageCode)
            }
            return false
        }
    }
}
