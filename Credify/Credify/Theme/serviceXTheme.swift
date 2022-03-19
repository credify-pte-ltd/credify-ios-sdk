//
//  serviceXTheme.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation
import UIKit

public struct serviceXTheme {
    public let color: ThemeColor
//    public let font: ThemeFont
//    public let icon: ThemeIcon
    
    public let inputFieldRadius: Double
    public let pageHeaderRadius: Double
    public let modalRadius: Double
    public let buttonRadius: Double
    
    public let shadowHeight: CGFloat
    public let shadowColor: UIColor?
    
    public init(color: ThemeColor = ThemeColor.default,
//                font: ThemeFont = ThemeFont.default,
//                icon: ThemeIcon = ThemeIcon.default,
                inputFieldRadius: Double = serviceXTheme.default.inputFieldRadius,
                pageHeaderRadius: Double = serviceXTheme.default.pageHeaderRadius,
                modalRadius: Double = serviceXTheme.default.modalRadius,
                buttonRadius: Double = serviceXTheme.default.buttonRadius,
                shadowHeight: CGFloat = serviceXTheme.default.shadowHeight,
                shadowColor: UIColor? = serviceXTheme.default.shadowColor) {
        self.color = color
//        self.font = font
//        self.icon = icon
        self.inputFieldRadius = inputFieldRadius
        self.pageHeaderRadius = pageHeaderRadius
        self.modalRadius = modalRadius
        self.buttonRadius = buttonRadius
        self.shadowHeight = shadowHeight
        self.shadowColor = shadowColor
    }
    
    public static var `default`: serviceXTheme {
        return serviceXTheme(color: ThemeColor.default,
//                             font: ThemeFont.default,
//                             icon: ThemeIcon.default,
                             inputFieldRadius: 5.0,
                             pageHeaderRadius: 30.0,
                             modalRadius: 10.0,
                             buttonRadius: 50.0,
                             shadowHeight: 0.0,
                             shadowColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.1))
    }
}
