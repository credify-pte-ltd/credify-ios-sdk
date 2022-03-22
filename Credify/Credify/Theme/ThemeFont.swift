//
//  ThemeFont.swift
//  
//
//  Created by Gioan Le on 17/03/2022.
//

import Foundation
import UIKit

/// This is for custom font
public struct ThemeFont : Codable {
    public let primaryFontFamily: String
    public let secondaryFontFamily: String
    
    public let bigTitleFontSize: Int
    public let bigTitleFontLineHeight: Int
    
    public let modelTitleFontSize: Int
    public let modelTitleFontLineHeight: Int
    
    public let sectionTitleFontSize: Int
    public let sectionTitleFontLineHeight: Int
    
    public let bigFontSize: Int
    public let bigFontLineHeight: Int
    
    public let normalFontSize: Int
    public let normalFontLineHeight: Int
    
    public let smallFontSize: Int
    public let smallFontLineHeight: Int
    
    public let boldFontSize: Int
    public let boldFontLineHeight: Int
    
    
    /// Constructor for init this object
    /// - Parameters:
    ///   - primaryFontFamily: Big title / Page title / Modal title / Section title / Buttons
    ///   - secondaryFontFamily: Normal text / Small text / Bold text
    ///   - bigTitleFontSize: Big title font size
    ///   - bigTitleFontLineHeight: Big title line height
    ///   - modelTitleFontSize: Model title font size
    ///   - modelTitleFontLineHeight: Model title line height
    ///   - sectionTitleFontSize: Section font size
    ///   - sectionTitleFontLineHeight: Section title line height
    ///   - bigFontSize: Big text title font size
    ///   - bigFontLineHeight: Big text line height
    ///   - normalFontSize: Normal text size
    ///   - normalFontLineHeight: Normal text line height
    ///   - smallFontSize: Small text size
    ///   - smallFontLineHeight: Small text line height
    ///   - boldFontSize: Bold text size
    ///   - boldFontLineHeight: Bold text line height
    public init(primaryFontFamily: String = ThemeFont.default.primaryFontFamily,
                secondaryFontFamily: String = ThemeFont.default.secondaryFontFamily,
                bigTitleFontSize: Int = ThemeFont.default.bigTitleFontSize,
                bigTitleFontLineHeight: Int = ThemeFont.default.bigTitleFontLineHeight,
                modelTitleFontSize: Int = ThemeFont.default.modelTitleFontSize,
                modelTitleFontLineHeight: Int = ThemeFont.default.modelTitleFontLineHeight,
                sectionTitleFontSize: Int = ThemeFont.default.sectionTitleFontSize,
                sectionTitleFontLineHeight: Int = ThemeFont.default.sectionTitleFontLineHeight,
                bigFontSize: Int = ThemeFont.default.bigFontSize,
                bigFontLineHeight: Int = ThemeFont.default.bigFontLineHeight,
                normalFontSize: Int = ThemeFont.default.normalFontSize,
                normalFontLineHeight: Int = ThemeFont.default.normalFontLineHeight,
                smallFontSize: Int = ThemeFont.default.smallFontSize,
                smallFontLineHeight: Int = ThemeFont.default.smallFontLineHeight,
                boldFontSize: Int = ThemeFont.default.boldFontSize,
                boldFontLineHeight: Int = ThemeFont.default.boldFontLineHeight) {
        self.primaryFontFamily = primaryFontFamily
        self.secondaryFontFamily = secondaryFontFamily
        self.bigTitleFontSize = bigTitleFontSize
        self.bigTitleFontLineHeight = bigTitleFontLineHeight
        self.modelTitleFontSize = modelTitleFontSize
        self.modelTitleFontLineHeight = modelTitleFontLineHeight
        self.sectionTitleFontSize = sectionTitleFontSize
        self.sectionTitleFontLineHeight = sectionTitleFontLineHeight
        self.bigFontSize = bigFontSize
        self.bigFontLineHeight = bigFontLineHeight
        self.normalFontSize = normalFontSize
        self.normalFontLineHeight = normalFontLineHeight
        self.smallFontSize = smallFontSize
        self.smallFontLineHeight = smallFontLineHeight
        self.boldFontSize = boldFontSize
        self.boldFontLineHeight = boldFontLineHeight
    }
    
    public static var `default`: ThemeFont {
        return ThemeFont(primaryFontFamily: "Roboto",
                         secondaryFontFamily: "Roboto",
                         bigTitleFontSize: 21,
                         bigTitleFontLineHeight: 31,
                         modelTitleFontSize: 20,
                         modelTitleFontLineHeight: 29,
                         sectionTitleFontSize: 16,
                         sectionTitleFontLineHeight: 21,
                         bigFontSize: 18,
                         bigFontLineHeight: 26,
                         normalFontSize: 14,
                         normalFontLineHeight: 18,
                         smallFontSize: 13,
                         smallFontLineHeight: 20,
                         boldFontSize: 15,
                         boldFontLineHeight: 21)
    }
}
