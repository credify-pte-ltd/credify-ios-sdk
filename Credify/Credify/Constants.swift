//
//  File.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

struct Constants {
    static let SDK_VERSION = "0.7.0"
    
    static var API_URL: String {
        switch AppState.shared.config?.env ?? .sandbox {
        case .dev:
            return "https://dev-api.credify.ninja"
        case .sit:
            return "https://sit-api.credify.ninja"
        case .uat:
            return "https://uat-api.credify.dev"
        case .sandbox:
            return "https://sandbox-api.credify.dev"
        case .production:
            return "https://api.credify.one"
        }
    }
    
    static var WEB_URL: String {
        switch AppState.shared.config?.env ?? .sandbox {
        case .dev:
            return "https://dev-passport.credify.ninja"
        case .sit:
            return "https://sit-passport.credify.ninja"
        case .uat:
            return "https://uat-passport.credify.dev"
        case .sandbox:
            return "https://sandbox-passport.credify.dev"
        case .production:
            return "https://passport.credify.one"
        }
    }
    
    /// Offer
    internal static var OFFER_SHOWING_CLOSE_BUTTON_URLS: [String] {
        let webUrl = WEB_URL
        
        return [
            "\(webUrl)/bad-request",
            "\(webUrl)/initial",
            "\(webUrl)/redeem-success",
            "\(webUrl)/canceled-offer",
            "\(webUrl)/vib-offer-referral",
            "\(webUrl)/ocb-offer-referral",
        ]
    }
}
