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
    
    public init(apiKey: String,
                env: CredifyEnvs = .sandbox,
                appName: String,
                theme: serviceXTheme = serviceXTheme.default) {
        if apiKey.isEmpty { fatalError("Api key must not be empty") }
        self.apiKey = apiKey
        self.env = env
        self.appName = appName
        self.theme = theme
    }
}
