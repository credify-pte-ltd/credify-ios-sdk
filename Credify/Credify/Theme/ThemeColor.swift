//
//  ThemeColor.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import UIKit


/// Theme customization
public struct ThemeColor : Codable {
    /// Page’s header background
    public let primaryBrandyStart: String
    
    /// Page’s header background
    public let primaryBrandyEnd: String
    
    /// Primary text
    public let primaryText: String
    
    /// Links / Border-color / Emphasized content / Check box / Radio button / Title
    public let secondaryActive: String
    
    // For disabled component color
    public let secondaryDisable: String
    
    /// Secondary text
    public let secondaryText: String
    
    /// Background color for important content
    public let secondaryComponentBackground: String
    
    /// Background color for SDK
    public let secondaryBackground: String
    
    /// Buttons text color
    public let primaryButtonTextColor: String
    
    /// Buttons background
    public let primaryButtonBrandyStart: String
    
    /// Buttons background
    public let primaryButtonBrandyEnd: String
    
    /// Navigation icon color
    public let primaryIconColor: String
    
    
    /// Constructor for init this object
    /// - Parameters:
    ///   - primaryBrandyStart: Page’s header background
    ///   - primaryBrandyEnd: Page’s header background
    ///   - primaryText: Primary text
    ///   - secondaryActive: Links / Border-color / Emphasized content / Check box / Radio button / Title
    ///   - secondaryDisable: For disabled component color
    ///   - secondaryText: Secondary text
    ///   - secondaryComponentBackground: Highline / important component background
    ///   - secondaryBackground: Page background color
    ///   - primaryButtonTextColor: Primary buttons text color
    ///   - primaryButtonBrandyStart: Buttons background
    ///   - primaryButtonBrandyEnd: Buttons background
    ///   - primaryIconColor: Navigation icon color
    public init (
        primaryBrandyStart: String = ThemeColor.default.primaryBrandyStart,
        primaryBrandyEnd: String = ThemeColor.default.primaryBrandyEnd,
        primaryText: String = ThemeColor.default.primaryText,
        secondaryActive: String = ThemeColor.default.secondaryActive,
        secondaryDisable: String = ThemeColor.default.secondaryDisable,
        secondaryText: String = ThemeColor.default.secondaryText,
        secondaryComponentBackground: String = ThemeColor.default.secondaryComponentBackground,
        secondaryBackground: String = ThemeColor.default.secondaryBackground,
        primaryButtonTextColor: String = ThemeColor.default.primaryButtonTextColor,
        primaryButtonBrandyStart: String = ThemeColor.default.primaryButtonBrandyStart,
        primaryButtonBrandyEnd: String = ThemeColor.default.primaryButtonBrandyEnd,
        primaryIconColor: String = ThemeColor.default.primaryIconColor
    ) {
        self.primaryBrandyStart = primaryBrandyStart
        self.primaryBrandyEnd = primaryBrandyEnd
        self.primaryText = primaryText
        self.secondaryActive = secondaryActive
        self.secondaryDisable = secondaryDisable
        self.secondaryText = secondaryText
        self.secondaryComponentBackground = secondaryComponentBackground
        self.secondaryBackground = secondaryBackground
        self.primaryButtonTextColor = primaryButtonTextColor
        self.primaryButtonBrandyStart = primaryButtonBrandyStart
        self.primaryButtonBrandyEnd = primaryButtonBrandyEnd
        self.primaryIconColor = primaryIconColor
    }
    
    public static var `default`: ThemeColor {
        return ThemeColor(
            primaryBrandyStart: UIColor.ex.primary,
            primaryBrandyEnd: UIColor.ex.primaryDarker,
            primaryText: UIColor.ex.primaryText,
            secondaryActive: UIColor.ex.secondaryActive,
            secondaryDisable: UIColor.ex.secondaryDisable,
            secondaryText: UIColor.ex.secondaryText,
            secondaryComponentBackground: UIColor.ex.backgroundLight,
            secondaryBackground: UIColor.ex.backgroundLight,
            primaryButtonTextColor: UIColor.ex.primaryButtonTextColor,
            primaryButtonBrandyStart: UIColor.ex.primaryButtonBrandyStart,
            primaryButtonBrandyEnd: UIColor.ex.primaryButtonBrandyEnd,
            primaryIconColor: UIColor.ex.primaryIconColor
        )
    }
}
