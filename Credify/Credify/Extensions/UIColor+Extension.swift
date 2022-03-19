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
    static var backgroundDark: UIColor {
        return UIColor.fromHex("#FFFFFF")
    }
    
    static var backgroundLight: UIColor {
        return UIColor.fromHex("#FFFFFF")
    }
    
    static var primary: UIColor {
        return UIColor.fromHex("#AB2185")
    }
    
    static var primaryDarker: UIColor {
        return UIColor.fromHex("#5A24B3")
    }
    
    static var text: UIColor {
        return UIColor.fromHex("#333333")
    }
    
    static var error: UIColor {
        return UIColor.fromHex("#FF3838")
    }
    
    static var primaryText: UIColor {
        return UIColor.fromHex("#333333")
    }
    
    static var secondaryText: UIColor {
        return UIColor.fromHex("#999999")
    }
    
    static var buttonText: UIColor {
        return UIColor.fromHex("#FFFFFF")
    }
    
    static var secondaryActive: UIColor {
        return UIColor.fromHex("#9147D7")
    }
    
    static var backgroundComponent: UIColor {
        return UIColor.fromHex("#F0E9F9")
    }
}
