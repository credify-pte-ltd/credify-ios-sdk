//
//  ValidationUtils.swift
//  
//
//  Created by Gioan Le on 27/05/2022.
//

import Foundation
import UIKit

class ValidationUtils {
    static func isPhoneValid(countryCode: String, phoneNumber: String) -> Bool {
        let trimmedCountryCode = countryCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedCountryCode.isEmpty && trimmedNumber.count >= 8 && trimmedNumber.count <= 12
    }
    
    static func showErrorIfShowMyPageFails(from: UIViewController, user: CredifyUserModel) -> Bool {
        let tableName = "serviceX"
        var errorMessage = ""
        
        // Phone number
        if !ValidationUtils.isPhoneValid(countryCode: user.countryCode, phoneNumber: user.phoneNumber) {
            errorMessage.append(String(format:"FieldIsInvalid".localized(tableName: tableName), "\'Phone number\'"))
            errorMessage.append(" ")
        }
        
        if !errorMessage.isBlankOrEmpty {
            UIUtils.alert(
                from: from,
                title: "Error".localized(tableName: tableName),
                errorMessage: errorMessage,
                actionText: "OK".localized(tableName: tableName)
            )
            return false
        }
        
        return true
    }
    
    static func showErrorIfShowDetailPageFails(from: UIViewController, user: CredifyUserModel, marketId: String) -> Bool {
        let tableName = "serviceX"
        var errorMessage = ""
        
        // Market id
        if marketId.isBlankOrEmpty {
            errorMessage.append(String(format:"FieldIsRequired".localized(tableName: tableName), "\'Market Id\'"))
            errorMessage.append(" ")
        }
        
        // Phone number
        if !ValidationUtils.isPhoneValid(countryCode: user.countryCode, phoneNumber: user.phoneNumber) {
            errorMessage.append(String(format:"FieldIsInvalid".localized(tableName: tableName), "\'Phone number\'"))
            errorMessage.append(" ")
        }
        
        if !errorMessage.isBlankOrEmpty {
            UIUtils.alert(
                from: from,
                title: "Error".localized(tableName: tableName),
                errorMessage: errorMessage,
                actionText: "OK".localized(tableName: tableName)
            )
            return false
        }
        
        return true
    }
    
    static func showErrorIfBNPLUnavailable(
        from: UIViewController,
        offers: [OfferData],
        providers: [Organization]
    ) -> Bool {
        let tableName = "serviceX"
        
        let isBNPLAvailable = !offers.isEmpty || !providers.isEmpty
        if !isBNPLAvailable {
            print("BNPL is not available for this user. You should call BNPL().getBNPLAvailability function to check it.")
            UIUtils.alert(
                from: from,
                title: "Error".localized(tableName: tableName),
                errorMessage: "BNPLIsNotAvailable".localized(tableName: tableName),
                actionText: "OK".localized(tableName: tableName)
            )
            return false
        }
        
        return true
    }
    
    static func showErrorIfOfferCannotStart(from: UIViewController, user: CredifyUserModel) -> Bool {
        let tableName = "serviceX"
        var errorMessage = ""
        
        // Market user id
        if user.id.isBlankOrEmpty {
            errorMessage.append(String(format:"FieldIsRequired".localized(tableName: tableName), "\'User Id\'"))
            errorMessage.append(" ")
        }
        
        // Phone number
        if !ValidationUtils.isPhoneValid(countryCode: user.countryCode, phoneNumber: user.phoneNumber) {
            errorMessage.append(String(format:"FieldIsInvalid".localized(tableName: tableName), "\'Phone number\'"))
            errorMessage.append(" ")
        }
        
        if !errorMessage.isBlankOrEmpty {
            UIUtils.alert(
                from: from,
                title: "Error".localized(tableName: tableName),
                errorMessage: errorMessage,
                actionText: "OK".localized(tableName: tableName)
            )
            return false
        }
        
        return true
    }
}
