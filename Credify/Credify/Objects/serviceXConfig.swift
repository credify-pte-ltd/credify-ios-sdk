//
//  File.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

public struct serviceXConfig {
    let apiKey: String
    let env: CredifyEnvs
    let appName: String
    let theme: serviceXTheme
    let userAgent: String
    
    public init(apiKey: String,
                env: CredifyEnvs = .sandbox,
                appName: String,
                theme: serviceXTheme = serviceXTheme.default,
                userAgent: String? = nil) {
        if apiKey.isEmpty { fatalError("Api key must not be empty") }
        self.apiKey = apiKey
        self.env = env
        self.appName = appName
        self.theme = theme
        self.userAgent = userAgent ?? "servicex/ios/\((Bundle.serviceX.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown")"
    }
}
