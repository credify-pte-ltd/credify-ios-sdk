//
//  WebViewUtils.swift
//  
//
//  Created by Gioan Le on 27/05/2022.
//

import Foundation

class WebViewUtils {
    static func isPendingOrCanceledPage(url: String) -> Bool {
        return isPendingPage(url: url) || isCanceledPage(url: url)
    }
    
    static func isPendingPage(url: String) -> Bool {
        return url.starts(with: "\(Constants.WEB_URL)/pending-offer")
    }
    
    static func isCanceledPage(url: String) -> Bool {
        return url.starts(with: "\(Constants.WEB_URL)/canceled-offer")
    }
    
    static var buildScriptToUpdateAppLanguage: String? {
        get {
            if let language = AppState.shared.language {
                return "window.appLanguage = '\(language.rawValue)';"
            }
            
            return nil
        }
    }
    
    /// 24002: Passport of redeemed list- Start over link on a pending offer
    /// https://stackoverflow.com/questions/40452034/disable-zoom-in-wkwebview
    static let scriptToDisableZoomIn = "var meta = document.createElement('meta');" +
        "meta.name = 'viewport';" +
        "meta.content = 'width=device-width, initial-scale=1, maximum-scale=1, shrink-to-fit=no, user-scalable=no';" +
        "var head = document.getElementsByTagName('head')[0];" +
        "head.appendChild(meta);"
}
