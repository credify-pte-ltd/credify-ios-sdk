//
//  ThemeFont.swift
//  
//
//  Created by Gioan Le on 17/03/2022.
//

import Foundation
import UIKit

public struct ThemeFont {
    /// Big title / Page title /
    public let primaryPageTitle: UIFont
    public let primaryModalTitle: UIFont
    public let primarySectionTitle: UIFont
    public let primaryButtonTitle: UIFont
    
    public let secondaryNormalText: UIFont
    public let secondarySmallText: UIFont
    public let secondaryBigText: UIFont
    public let secondaryBoldText: UIFont
    
    public init(primaryPageTitle: UIFont = ThemeFont.default.primaryPageTitle,
                primaryModalTitle: UIFont = ThemeFont.default.primaryModalTitle,
                primarySectionTitle: UIFont = ThemeFont.default.primarySectionTitle,
                primaryButtonTitle: UIFont = ThemeFont.default.primaryButtonTitle,
                secondaryNormalText: UIFont = ThemeFont.default.secondaryNormalText,
                secondarySmallText: UIFont = ThemeFont.default.secondarySmallText,
                secondaryBigText: UIFont = ThemeFont.default.secondaryBigText,
                secondaryBoldText: UIFont = ThemeFont.default.secondaryBoldText) {
        self.primaryPageTitle = primaryPageTitle
        self.primaryModalTitle = primaryModalTitle
        self.primarySectionTitle = primarySectionTitle
        self.primaryButtonTitle = primaryButtonTitle
        self.secondaryNormalText = secondaryNormalText
        self.secondarySmallText = secondarySmallText
        self.secondaryBigText = secondaryBigText
        self.secondaryBoldText = secondaryBoldText
    }
    
    public static var `default`: ThemeFont {
        UIFont.loadFonts()
        return ThemeFont(primaryPageTitle: UIFont.ex.navigationFont,
                         primaryModalTitle: UIFont.ex.modalFont,
                         primarySectionTitle: UIFont.ex.sectionFont,
                         primaryButtonTitle: UIFont.ex.buttonFont,
                         secondaryNormalText: UIFont.ex.textFont(size: .normal, style: .regular),
                         secondarySmallText: UIFont.ex.textFont(size: .small, style: .regular),
                         secondaryBigText: UIFont.ex.textFont(size: .big, style: .regular),
                         secondaryBoldText: UIFont.ex.textFont(size: .custom(size: 15.0), style: .bold))
    }
}
