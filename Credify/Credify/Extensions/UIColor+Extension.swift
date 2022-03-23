//
//  UIColor.swift
//  
//
//  Created by Gioan Le on 17/03/2022.
//

import UIKit

extension UIColor {
    // From here: https://stackoverflow.com/questions/24263007/how-to-use-hex-color-values
    static func fromHex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count != 6) {
            return UIColor.black
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension UIColor: ExtensionCompatible {}

extension Extension where Base: UIColor {
    static var backgroundDark: String {
        return "#FFFFFF"
    }
    
    static var backgroundLight: String {
        return "#FFFFFF"
    }
    
    static var primary: String {
        return "#AB2185"
    }
    
    static var primaryDarker: String {
        return "#5A24B3"
    }
    
    static var text: String {
        return "#333333"
    }
    
    static var error: String {
        return "#FF3838"
    }
    
    static var primaryText: String {
        return "#333333"
    }
    
    static var secondaryText: String {
        return "#999999"
    }
    
    static var buttonText: String {
        return "#FFFFFF"
    }
    
    static var secondaryActive: String {
        return "#9147D7"
    }
    
    static var secondaryDisable: String {
        return "#E0E0E0"
    }
    
    static var backgroundComponent: String {
        return "#F0E9F9"
    }
    
    static var primaryButtonTextColor: String {
        return "#FFFFFF"
    }
    
    static var primaryButtonBrandyStart: String {
        return "#AB2185"
    }
    
    static var primaryButtonBrandyEnd: String {
        return "#5A24B3"
    }
    
    static var primaryIconColor: String {
        return "#FFFFFF"
    }
}
