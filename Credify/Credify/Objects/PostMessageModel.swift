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
    let offers: [OfferData]
    let profile: CredifyUserModel
    let order: OrderInfo
    let completeBnplProviders: [Organization]
    let theme: serviceXTheme?
    
    init(
        offers: [OfferData],
        profile: CredifyUserModel,
        order: OrderInfo,
        completeBnplProviders: [Organization],
        theme: serviceXTheme?
    ) {
        self.offers = offers
        self.profile = profile
        self.order = order
        self.completeBnplProviders = completeBnplProviders
        self.theme = theme
    }
}

internal class ShowPromotionOfferMessage: Codable {
    let offers: [OfferData]
    let profile: CredifyUserModel
    let theme: serviceXTheme?
    
    init(
        offers: [OfferData],
        profile: CredifyUserModel,
        theme: serviceXTheme?
    ) {
        self.offers = offers
        self.profile = profile
        self.theme = theme
    }
}
