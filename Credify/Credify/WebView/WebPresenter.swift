//
//  WebPresenter.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation
import WebKit
import SwiftUI

enum PassportContext {
    case mypage(user: CredifyUserModel)
    case offer(offer: OfferData, user: CredifyUserModel)
    case serviceInstance(user: CredifyUserModel, marketId: String, productTypes: [ProductType])
    case bnpl(offers: [OfferData], user: CredifyUserModel, orderId: String, completedBnplProviders: [Organization])
    
    var url: URL {
        switch self {
        case .mypage(user: _):
            return URL(string: "\(Constants.WEB_URL)/login")!
        case .offer(offer: _, user: _):
            return URL(string: "\(Constants.WEB_URL)/initial")!
        case .serviceInstance(user: _, let marketId, let productTypes):
            var params = [(String, String)]()
            params.append(("market-id", marketId))
            for item in productTypes {
                params.append(("product-types[]", item.rawValue))
            }
            let urlParams = params.map { "\($0)=\($1)" }.joined(separator: "&")
            
            return URL(string: "\(Constants.WEB_URL)/service-instance?\(urlParams)")!
        case .bnpl(offers: _, user: _, orderId: _, completedBnplProviders: _):
            return URL(string: "\(Constants.WEB_URL)/bnpl")!
        }
    }
}

protocol WebPresenterProtocol {
    var receiveHandlers: [ReceiveMessageHandler] { get }
    func shouldClose(messageName: String) -> Bool
    func shouldHideBackButton(messageName: String, body: [String: Any]?) -> Bool
    func handleMessage(_: WKWebView, name: String, body: [String: Any]?)
    func hanldeCompletionHandler()
}

class WebPresenter: WebPresenterProtocol {
    private let context: PassportContext
    
    init(context: PassportContext) {
        self.context = context
    }
    
    private var offerTransactionStatus: RedemptionResult = .canceled
    
    var receiveHandlers: [ReceiveMessageHandler] {
        return [
            .initialLoadCompleted,
            .createUserCompleted,
            .offerTransactionStatusChanged,
            .actionClose,
            .bnplPaymentComplete,
        ]
    }
    
    
    func shouldClose(messageName: String) -> Bool {
        guard let type = ReceiveMessageHandler(rawValue: messageName) else {
            return false
        }
        return type == .actionClose || type == .bnplPaymentComplete
    }
    
    func shouldHideBackButton(messageName: String, body: [String: Any]?) -> Bool {
        guard let type = ReceiveMessageHandler(rawValue: messageName) else {
            return false
        }
        
        if type == .offerTransactionStatusChanged {
            return extractOnboardingStatus(body: body) == .canceled
        }
        
        return false
    }
    
    func handleMessage(_ webView: WKWebView, name: String, body: [String: Any]?) {
        guard let type = ReceiveMessageHandler(rawValue: name) else {
            return
        }
        
        switch type {
        case .initialLoadCompleted:
            if case let .mypage(user) = context {
                doPostMessage(
                    webView,
                    type: ACTION_TYPE,
                    action: SendMessageHandler.actionLogin.rawValue,
                    payload: [
                        "phoneNumber": user.phoneNumber,
                        "countryCode": user.countryCode,
                        "fullName": user.localizedName
                    ]
                )
            }
            if case let .serviceInstance(user, _, _) = context {
                doPostMessage(
                    webView,
                    type: ACTION_TYPE,
                    action: SendMessageHandler.actionLogin.rawValue,
                    payload: [
                        "phoneNumber": user.phoneNumber,
                        "countryCode": user.countryCode,
                        "fullName": user.localizedName
                    ]
                )
            }
            if case let .offer(offer, user) = context {
                guard let offerJsonData = try? offer.jsonData(), let userJsonData = try? user.jsonData() else {
                    return
                }
                guard let offerJson = try? JSONSerialization.jsonObject(with: offerJsonData, options: []), let userJson = try? JSONSerialization.jsonObject(with: userJsonData, options: []) else {
                    return
                }
                guard let offerDict = offerJson as? [String: Any], let userDict = userJson as? [String: Any] else {
                    return
                }
                
                // Theme
                var themeDict: [String: Any]? = nil
                let themeData: Data? = try? AppState.shared.config?.theme.jsonData()
                if themeData != nil {
                    let themeJson = try? JSONSerialization.jsonObject(with: themeData!, options: [])
                    themeDict = themeJson as? [String: Any]
                }
                
                doPostMessage(
                    webView,
                    type: ACTION_TYPE,
                    action: SendMessageHandler.startRedemption.rawValue,
                    payload: themeDict != nil ? [
                        "offer": offerDict.keysToCamelCase(),
                        "profile": userDict,
                        "theme": themeDict!
                    ] : [
                        "offer": offerDict.keysToCamelCase(),
                        "profile": userDict,
                    ]
                )
            }
            if case let .bnpl(offers, user, orderId, completedBnplProviders) = context {
                let message = StartBnplMessage(
                    offers: offers,
                    profile: user,
                    orderId: orderId,
                    completeBnplProviders: completedBnplProviders,
                    theme: AppState.shared.config?.theme
                )
                
                guard let messageJsonData = try? message.jsonData() else {
                    return
                }
                
                guard let messageJson = try? JSONSerialization.jsonObject(with: messageJsonData, options: []) else {
                    return
                }
                
                guard let messageDict = messageJson as? [String: Any] else {
                    return
                }
                
                doPostMessage(
                    webView,
                    type: ACTION_TYPE,
                    action: SendMessageHandler.startRedemption.rawValue,
                    payload: messageDict
                )
            }
        case .createUserCompleted:
            guard let dict = body else { return }
            guard let payload = PostMessageUtils.parsePayload(dict: dict), let credifyId = payload["credifyId"] as? String else {
                self.postPushedClaimMessage(webView, isSuccess: false)
                return
            }
            guard let task = AppState.shared.pushClaimTokensTask else {
                self.postPushedClaimMessage(webView, isSuccess: false)
                return
            }

            task(credifyId) { result in
                self.postPushedClaimMessage(webView, isSuccess: result)
            }
        case .offerTransactionStatusChanged:
            let onboardingStatus = extractOnboardingStatus(body: body)
            if onboardingStatus == nil {
                return
            }
            
            switch onboardingStatus! {
            case .completed:
                offerTransactionStatus = .completed
            case .pending:
                offerTransactionStatus = .pending
            case .canceled:
                offerTransactionStatus = .canceled
            case .failed:
                // Do nothing => default is canceled
                break
            }
        case .actionClose:
            hanldeCompletionHandler()
        case .bnplPaymentComplete:
            // TODO we maybe need to update this when the BNPL proxy integrate with real flow
            switch context {
            case .bnpl(offers: _, user: _, let orderId, completedBnplProviders: _):
                hanldeBnplCompletionHandler(status: offerTransactionStatus, orderId: orderId, isPaymentCompleted: true)
            default:
                break
            }
        }
    }
    
    func hanldeCompletionHandler() {
        let appState = AppState.shared
        
        switch context {
        case .mypage(_):
            appState.dismissCompletion?()
            appState.dismissCompletion = nil
        case .offer(_, _):
            appState.redemptionResult?(offerTransactionStatus)
            appState.redemptionResult = nil
        case .bnpl(offers: _, user: _, let orderId, completedBnplProviders: _):
            // TODO we maybe need to update this when the BNPL proxy integrate with real flow
            hanldeBnplCompletionHandler(status: offerTransactionStatus, orderId: orderId, isPaymentCompleted: false)
        case .serviceInstance:
            appState.dismissCompletion?()
            appState.dismissCompletion = nil
            break
        }
    }
    
    private func hanldeBnplCompletionHandler(
        status: RedemptionResult,
        orderId: String,
        isPaymentCompleted: Bool
    ) {
        let appState = AppState.shared
        
        // TODO we maybe need to update this when the BNPL proxy integrate with real flow
        appState.bnplRedemptionResult?(status, orderId, isPaymentCompleted)
        
        appState.bnplOfferInfo = nil
        appState.bnplRedemptionResult = nil
    }
    
    private func postPushedClaimMessage(_ webView: WKWebView, isSuccess: Bool) {
        self.doPostMessage(
            webView,
            type: ACTION_TYPE,
            action: SendMessageHandler.pushClaimCompleted.rawValue,
            payload: [
                "isSuccess": isSuccess
            ]
        )
    }
    
    private func doPostMessage(
        _ webView: WKWebView,
        type: String,
        action: String,
        payload: [String: Any]
    ) {
        let data: [String: Any] = [
            "type": type,
            "action": action,
            "payloadType": PayloadType.base64.rawValue,
            "payload": payload.jsonBase64
        ]
        
        let js = "(function() { window.postMessage('\(data.json)','*'); })();"
        webView.evaluateJavaScript(js)
    }
    
    private func extractOnboardingStatus(body: [String: Any]?) -> OnboardingStatus? {
        guard let dict = body else { return nil}
        guard let payload = PostMessageUtils.parsePayload(dict: dict), let status = payload["status"] as? String else {
            return nil
        }
        guard let onboardingStatus = OnboardingStatus(rawValue: status) else { return nil}
        return onboardingStatus
    }
}
