//
//  PostMessageModel.swift
//  Credify
//
//  Created by Gioan Le on 21/03/2022.
//

import Foundation
import SwiftUI

internal let ACTION_TYPE = "CREDIFY-MOBILE-SDK"

internal enum PayloadType : String {
    case base64 = "Base64"
    case object = "Object"
}

internal enum SendMessageHandler: String {
    case startRedemption
    case pushClaimCompleted
    case actionLogin
    case showPromotionOffers
}

internal enum ReceiveMessageHandler: String {
    case initialLoadCompleted
    case createUserCompleted
    case offerTransactionStatusChanged
    case actionClose
    case bnplPaymentComplete
    case sendPathsForShowingCloseButton
    case loginLoadCompleted
    case promotionOfferLoadCompleted
    case openRedirectUrl
}

internal class StartBnplMessage: Codable {
    let offerCodes: [String]
    let packageCode: String?
    let profile: CredifyUserModel
    let order: OrderInfo
    let marketId: String
    let theme: serviceXTheme?
    
    init(
        offerCodes: [String],
        packageCode: String?,
        profile: CredifyUserModel,
        order: OrderInfo,
        marketId: String,
        theme: serviceXTheme?
    ) {
        self.offerCodes = offerCodes
        self.packageCode = packageCode
        self.profile = profile
        self.order = order
        self.marketId = marketId
        self.theme = theme
    }
}

internal class ShowPromotionOfferMessage: Codable {
    let offerCodes: [String]
    let profile: CredifyUserModel
    let theme: serviceXTheme?
    
    init(
        offerCodes: [String],
        profile: CredifyUserModel,
        theme: serviceXTheme?
    ) {
        self.offerCodes = offerCodes
        self.profile = profile
        self.theme = theme
    }
}
