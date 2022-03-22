//
//  serviceXTheme.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation
import UIKit

public struct serviceXTheme : Encodable {
    public let color: ThemeColor
    public let font: ThemeFont
    public let inputFieldRadius: Double
    public let pageHeaderRadius: Double
    public let modelRadius: Double
    public let buttonRadius: Double
    public let boxShadow: String
    
    /// - Parameters:
    ///   - color: Custom color
    ///   - font: Custom font
    ///   - inputFieldRadius: Input field radius
    ///   - pageHeaderRadius: Page's header radius
    ///   - modelRadius: Model radius
    ///   - buttonRadius: Button radius
    ///   - boxShadow: Shadow for a component. Ex: "0px 4px 30px rgba(0, 0, 0, 0.1)". For more information, visit here: https://www.w3schools.com/cssref/css3_pr_box-shadow.asp
    public init(color: ThemeColor = ThemeColor.default,
                font: ThemeFont = ThemeFont.default,
                inputFieldRadius: Double = serviceXTheme.default.inputFieldRadius,
                pageHeaderRadius: Double = serviceXTheme.default.pageHeaderRadius,
                modelRadius: Double = serviceXTheme.default.modelRadius,
                buttonRadius: Double = serviceXTheme.default.buttonRadius,
                boxShadow: String = serviceXTheme.default.boxShadow) {
        self.color = color
        self.font = font
        self.inputFieldRadius = inputFieldRadius
        self.pageHeaderRadius = pageHeaderRadius
        self.modelRadius = modelRadius
        self.buttonRadius = buttonRadius
        self.boxShadow = boxShadow
    }
    
    private enum CodingKeys: String, CodingKey {
        case color, font, inputFieldRadius, pageHeaderRadius, modelRadius, buttonRadius, boxShadow
    }
    
    public static var `default`: serviceXTheme {
        return serviceXTheme(color: ThemeColor.default,
                             font: ThemeFont.default,
                             inputFieldRadius: 5.0,
                             pageHeaderRadius: 30.0,
                             modelRadius: 10.0,
                             buttonRadius: 50.0,
                             boxShadow: "0px 4px 30px rgba(0, 0, 0, 0.1)")
    }
}
