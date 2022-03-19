//
//  ThemeColor.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import UIKit

public struct ThemeColor {
    /// Page’s header / Buttons
    let primaryBrandyStart: UIColor
    
    /// Page’s header / Buttons
    let primaryBrandyEnd: UIColor
    
    /// Primary text
    let primaryText: UIColor
    
    /// Links / Border-color / Emphasized content / Check box / Radio button / Title
    let secondaryActive: UIColor
    
    /// Secondary text
    let secondaryText: UIColor
    
    /// Background color for important content
    let secondaryComponentBackground: UIColor
    
    /// Background color for SDK
    let secondaryBackground: UIColor
    
    init (primaryBrandyStart: UIColor = ThemeColor.default.primaryBrandyStart,
                 primaryBrandyEnd: UIColor = ThemeColor.default.primaryBrandyEnd,
                 primaryText: UIColor = ThemeColor.default.primaryText,
                 secondaryActive: UIColor = ThemeColor.default.secondaryActive,
                 secondaryText: UIColor = ThemeColor.default.secondaryText,
                 secondaryComponentBackground: UIColor = ThemeColor.default.secondaryComponentBackground,
                 secondaryBackground: UIColor = ThemeColor.default.secondaryBackground) {
        self.primaryBrandyStart = primaryBrandyStart
        self.primaryBrandyEnd = primaryBrandyEnd
        self.primaryText = primaryText
        self.secondaryActive = secondaryActive
        self.secondaryText = secondaryText
        self.secondaryComponentBackground = secondaryComponentBackground
        self.secondaryBackground = secondaryBackground
        
    }
    
    public static var `default`: ThemeColor {
        return ThemeColor(
            primaryBrandyStart: UIColor.ex.primary,
            primaryBrandyEnd: UIColor.ex.primaryDarker,
            primaryText: UIColor.ex.primaryText,
            secondaryActive: UIColor.ex.secondaryActive,
            secondaryText: UIColor.ex.secondaryText,
            secondaryComponentBackground: UIColor.ex.backgroundLight,
            secondaryBackground: UIColor.ex.backgroundLight
        )
    }
}
