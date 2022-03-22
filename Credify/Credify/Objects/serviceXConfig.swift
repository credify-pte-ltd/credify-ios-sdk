//
//  serviceXConfig.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation


/// This is serviceX configiration
public struct serviceXConfig {
    let apiKey: String
    let env: CredifyEnvs
    let appName: String
    let theme: serviceXTheme
    let userAgent: String
    
    
    /// This is constructor to create serviceX configuration
    /// - Parameters:
    ///   - apiKey: Your API that gets from the Dashboard
    ///   - env: Environment that you want to test
    ///   - appName: Your application name
    ///   - theme: For the UI customization.
    public init(apiKey: String,
                env: CredifyEnvs = .sandbox,
                appName: String,
                theme: serviceXTheme? = nil,
                userAgent: String? = nil) {
        if apiKey.isEmpty { fatalError("Api key must not be empty") }
        self.apiKey = apiKey
        self.env = env
        self.appName = appName
        self.theme = theme ?? serviceXTheme.default
        self.userAgent = userAgent ?? "servicex/ios/\((Bundle.serviceX.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown")"
    }
}
