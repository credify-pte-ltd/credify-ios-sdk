//
//  File.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

class AppState {
    static let shared = AppState()
    
    private init() {}
    
    var config: serviceXConfig? = nil
    
    var user: CredifyUserModel? = nil
    var pushClaimTokensTask: ((String, ((Bool) -> Void)?) -> Void)? = nil
    var redemptionResult: ((RedemptionResult) -> Void)? = nil
    var dismissCompletion: (() -> Void)? = nil
    var bnplRedemptionResult: ((_ status: RedemptionResult,_ orderId: String,_ isPaymentCompleted: Bool) -> Void)? = nil
}
