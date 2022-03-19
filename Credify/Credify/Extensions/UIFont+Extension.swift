//
//  UIFont.swift
//  
//
//  Created by Gioan Le on 17/03/2022.
//

import Foundation
import UIKit

extension UIFont {
    /// This is default font for application. In future, if we need to change font, just change font name.
    static func secondaryFont(style: UIFont.Style = .regular, ofSize size: CGFloat = 17) -> UIFont {
        switch style {
        case .thin:
            return UIFont(name: "RobotoSlab-Thin", size: size)!
        case .regular:
            return UIFont(name: "RobotoSlab-Regular", size: size)!
        case .medium:
            return UIFont(name: "RobotoSlab-Medium", size: size)!
        case .light:
            return UIFont(name: "RobotoSlab-Light", size: size)!
        case .bold:
            return UIFont(name: "RobotoSlab-Bold", size: size)!
        case .black:
            return UIFont(name: "RobotoSlab-Black", size: size)!
        }
    }
    
    static func primaryFont(style: UIFont.Style = .regular, ofSize size: CGFloat = 17) -> UIFont {
        switch style {
        case .thin:
            return UIFont(name: "Oswald-Regular", size: size)!
        case .regular:
            return UIFont(name: "Oswald-Regular", size: size)!
        case .medium:
            return UIFont(name: "Oswald-Regular", size: size)!
        case .light:
            return UIFont(name: "Oswald-Regular", size: size)!
        case .bold:
            return UIFont(name: "Oswald-Regular", size: size)!
        case .black:
            return UIFont(name: "Oswald-Regular", size: size)!
        }
    }
    
    enum Style {
        case thin
        case regular
        case medium
        case light
        case bold
        case black
    }
    
    enum Size {
        case big
        case normal
        case small
        case custom(size: CGFloat)
    }
}

extension UIFont: ExtensionCompatible {}

extension Extension where Base: UIFont {
    static var navigationFont: UIFont {
        return UIFont.primaryFont(style: .regular, ofSize: 21)
    }
    
    static var modalFont: UIFont {
        return UIFont.primaryFont(style: .regular, ofSize: 20)
    }
    
    static var buttonFont: UIFont {
        return UIFont.primaryFont(style: .regular, ofSize: 14)
    }
    
    static var sectionFont: UIFont {
        return UIFont.primaryFont(style: .regular, ofSize: 16)
    }
    
    static func textFont(size: UIFont.Size = .normal , style: UIFont.Style = .regular) -> UIFont {
        var fontSize : CGFloat = 16
        switch size {
        case .big:
            fontSize = 18
        case .normal:
            fontSize = 14
        case .small:
            fontSize = 13
        case .custom(let size):
            fontSize = size
        }
        return UIFont.secondaryFont(style: .regular, ofSize: fontSize)
    }
}

extension UIFont {
    static func register(fileNameString: String) throws {
        let frameworkBundle = Bundle.serviceX
        guard let resourceBundleURL = frameworkBundle.path(forResource: fileNameString, ofType: nil) else {
            throw FontError.fontPathNotFound
        }
        guard let fontData = NSData(contentsOfFile: resourceBundleURL),
              let dataProvider = CGDataProvider.init(data: fontData) else {
            throw FontError.invalidFontFile
        }
        guard let fontRef = CGFont.init(dataProvider) else {
            throw FontError.initFontError
        }
        var errorRef: Unmanaged<CFError>? = nil
        guard CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) else   {
            throw FontError.registerFailed
        }
    }
    
    static func loadFonts() {
        do {
            try UIFont.register(fileNameString: "Oswald-Regular.ttf")
            try UIFont.register(fileNameString: "RobotoSlab-Black.ttf")
            try UIFont.register(fileNameString: "RobotoSlab-Bold.ttf")
            try UIFont.register(fileNameString: "RobotoSlab-Light.ttf")
            try UIFont.register(fileNameString: "RobotoSlab-Medium.ttf")
            try UIFont.register(fileNameString: "RobotoSlab-Regular.ttf")
            try UIFont.register(fileNameString: "RobotoSlab-Thin.ttf")
        } catch let error {
            print(error)
        }
    }
}

enum FontError: Error {
  case invalidFontFile
  case fontPathNotFound
  case initFontError
  case registerFailed
}
