//
//  File.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

internal class AppState {
    static let shared = AppState()
    
    private init() {}
    
    var config: serviceXConfig? = nil
    
    var bnplOfferInfo: BNPLOfferInfo? = nil
    
    var pushClaimTokensTask: ((String, ((Bool) -> Void)?) -> Void)? = nil
    var redemptionResult: ((RedemptionResult) -> Void)? = nil
    var dismissCompletion: (() -> Void)? = nil
    var bnplRedemptionResult: ((_ status: RedemptionResult,_ orderId: String,_ isPaymentCompleted: Bool) -> Void)? = nil
    
    /// Offer: for show/hide the close and back buttons
    var offerShowingCloseButtonUrls: [String] = []
    
    /// BNPL: for show/hide the close and back buttons
    var bnplShowingCloseButtonUrls: [String] = []
    
    /// My page: for show/hide the close and back buttons
    var myPageShowingCloseButtonUrls: [String] = []
    
    /// Service Instance: for show/hide the close and back buttons
    var serviceInstanceShowingCloseButtonUrls: [String] = []
}
