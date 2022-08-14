//
//  serviceXConfig.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation


/// This is serviceX configuration
public struct serviceXConfig {
    let apiKey: String
    let marketId: String
    let env: CredifyEnvs
    let appName: String
    let theme: serviceXTheme
    let userAgent: String
    
    
    /// This is constructor to create serviceX configuration
    /// - Parameters:
    ///   - apiKey: API key that you can generate on the Dashboard
    ///   - env: Environment that you want to use
    ///   - appName: Your application name
    ///   - theme: For the UI customization.
    public init(apiKey: String,
                marketId: String,
                env: CredifyEnvs = .sandbox,
                appName: String,
                theme: serviceXTheme? = nil,
                userAgent: String? = nil) {
        if apiKey.isEmpty { fatalError("Api key must not be empty") }
        if marketId.isEmpty { fatalError("marketId key must not be empty") }
        
        self.apiKey = apiKey
        self.marketId = marketId
        self.env = env
        self.appName = appName
        self.theme = theme ?? serviceXTheme.default
        self.userAgent = userAgent ?? "servicex/ios/\(Constants.SDK_VERSION)"
    }
}
