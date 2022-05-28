//
//  String+Extension.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

extension String {
    func camelCased(with separator: Character) -> String {
        return self.lowercased()
            .split(separator: separator)
            .enumerated()
            .map { $0.offset > 0 ? $0.element.capitalized : $0.element.lowercased() }
            .joined()
    }
    
    /// Return a text defined in localization files depending upon a location of each user.
    func localized(bundle: Bundle = .serviceX, tableName: String = "Localizable", defaultValue: String = "") -> String {
        var dv = defaultValue
        if defaultValue.isEmpty {
            dv = "**\(self)**"
        }
        // Concept Language IDs:
        // https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html#//apple_ref/doc/uid/10000171i-CH15
        // 24002: Passport of redeemed list- Start over link on a pending offer
        if let languageCode = LocaleUtils.languageCode,
           let languagePath = bundle.path(forResource: languageCode, ofType: "lproj"),
           let languageBundle = Bundle(path: languagePath) {
            return NSLocalizedString(self, tableName: tableName, bundle: languageBundle, value:dv, comment: "")
        }
        return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: dv, comment: "")
    }
    
    var isBlankOrEmpty: Bool {
        get {
            return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}
