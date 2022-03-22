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
}

internal enum ReceiveMessageHandler: String {
    case initialLoadCompleted
    case createUserCompleted
    case offerTransactionStatusChanged
    case actionClose
}
