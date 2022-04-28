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
    func handleMessage(_: WKWebView, name: String, body: [String: Any]?)
    func hanldeCompletionHandler()
    func isBackButtonVisible(urlObj: URL?) -> Bool
    func isCloseButtonVisible(urlObj: URL?) -> Bool
    func doPostMessageForLoggingIn(webView: WKWebView)
    func isLoading(webView: WKWebView, onResult: @escaping (Bool) -> Void)
}

class WebPresenter: WebPresenterProtocol {
    private let LOADING_COMPONENT_ID = "credify-main-loading-component"
    
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
            .sendPathsForShowingCloseButton,
        ]
    }
    
    
    func shouldClose(messageName: String) -> Bool {
        guard let type = ReceiveMessageHandler(rawValue: messageName) else {
            return false
        }
        return type == .actionClose || type == .bnplPaymentComplete
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
                    order: OrderInfo(
                        orderId: orderId
                    ),
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
        case .sendPathsForShowingCloseButton:
            handleSendPathsForShowingCloseButton(body: body)
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
    
    func isBackButtonVisible(urlObj: URL?) -> Bool {
        if urlObj == nil {
            return true
        }
        
        let url = urlObj!.absoluteString
        
        // For the redirect url case(after redeem offer)
        if !url.starts(with: Constants.WEB_URL) {
            return true
        }
        
        switch context {
        case .offer(_, _):
            // Both buttons are hidden in the Offer Pending page
            if url.starts(with: "\(Constants.WEB_URL)/pending-offer") {
                return false
            }
            
            return !isCloseButtonVisible(urlObj: urlObj)
        default:
            return !isCloseButtonVisible(urlObj: urlObj)
        }
    }
    
    func isCloseButtonVisible(urlObj: URL?) -> Bool {
        if urlObj == nil {
            return true
        }
        
        let url = urlObj!.absoluteString
        
        // For the redirect url case(after redeem offer)
        if !url.starts(with: Constants.WEB_URL) {
            return true
        }
        
        let appState = AppState.shared
        
        switch context {
        case .mypage(_):
            // E.g: https://dev-passport.credify.ninja/
            if url.starts(with: "\(Constants.WEB_URL)/") && urlObj!.lastPathComponent == "/" {
                return true
            }
            
            return appState.myPageShowingCloseButtonUrls.first { item in
                url.starts(with: item)
            } != nil
        case .offer(_, _):
            return appState.offerShowingCloseButtonUrls.first { item in
                url.starts(with: item)
            } != nil
        case .bnpl(_, _, _, _):
            // E.g: https://dev-passport.credify.ninja/bpnl
            if url.starts(with: "\(Constants.WEB_URL)/bnpl") && urlObj!.lastPathComponent == "bnpl" {
                return true
            }
            
            return appState.bnplShowingCloseButtonUrls.first { item in
                url.starts(with: item)
            } != nil
        case .serviceInstance:
            return appState.serviceInstanceShowingCloseButtonUrls.first { item in
                url.starts(with: item)
            } != nil
        }
    }
    
    func doPostMessageForLoggingIn(webView: WKWebView) {
        if "\(Constants.WEB_URL)/login".starts(with: (webView.url?.absoluteString ?? "")) {
            handleMessage(webView, name: ReceiveMessageHandler.initialLoadCompleted.rawValue, body: nil)
        }
    }
    
    func isLoading(webView: WKWebView, onResult: @escaping (Bool) -> Void) {
        webView.evaluateJavaScript("document.getElementById('\(LOADING_COMPONENT_ID)') !== null") { result, error in
            guard let isLoading = result as? Bool else {
                onResult(false)
                return
            }
            
            onResult(isLoading)
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
        
        DispatchQueue.main.async {
            webView.evaluateJavaScript(js)
        }
    }
    
    private func extractOnboardingStatus(body: [String: Any]?) -> OnboardingStatus? {
        guard let dict = body else { return nil}
        guard let payload = PostMessageUtils.parsePayload(dict: dict), let status = payload["status"] as? String else {
            return nil
        }
        guard let onboardingStatus = OnboardingStatus(rawValue: status) else { return nil}
        return onboardingStatus
    }
    
    private func handleSendPathsForShowingCloseButton(body: [String: Any]?) {
        guard let dict = body else { return }
        guard let payload = PostMessageUtils.parsePayload(dict: dict) else {
            return
        }
        
        let appState = AppState.shared
        
        if let normalOffer = payload["normalOffer"] as? [String] {
            appState.offerShowingCloseButtonUrls = normalOffer.map({ item in
                return "\(Constants.WEB_URL)\(item)"
            })
        }
        
        if let bnpl = payload["bnpl"] as? [String] {
            appState.bnplShowingCloseButtonUrls = bnpl.map({ item in
                return "\(Constants.WEB_URL)\(item)"
            })
        }
        
        if let passport = payload["passport"] as? [String] {
            appState.myPageShowingCloseButtonUrls = passport.map({ item in
                return "\(Constants.WEB_URL)\(item)"
            })
        }
        
        if let serviceInstance = payload["serviceInstance"] as? [String] {
            appState.serviceInstanceShowingCloseButtonUrls = serviceInstance.map({ item in
                return "\(Constants.WEB_URL)\(item)"
            })
        }
    }
}
