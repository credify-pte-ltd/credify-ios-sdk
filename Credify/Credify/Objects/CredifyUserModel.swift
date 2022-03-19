//
//  File.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

public struct CredifyUserModel: Codable {
    public let id: String
    public let firstName: String
    public let lastName: String
    public let fullName: String?
    public let email: String
    public var credifyId: String?
    public let countryCode: String
    public let phoneNumber: String
    
    public init(id: String,
                firstName: String,
                lastName: String,
                fullName: String? = nil,
                email: String,
                credifyId: String?,
                countryCode: String,
                phoneNumber: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.email = email
        self.credifyId = credifyId
        
        self.countryCode = countryCode
        self.phoneNumber = phoneNumber
    }
    
    public var isLastNameComesFirst: Bool {
//        if Locale.languageSupportLastFirstNameOrder.contains(CoreService.config.locale.code) {
//            return true
//        }
        return true
    }
    
    public var localizedName: String {
        if let fn = fullName {
            return fn
        }
        let result = isLastNameComesFirst ? "\(lastName) \(firstName)" : "\(firstName) \(lastName)"
        return result
    }
}
