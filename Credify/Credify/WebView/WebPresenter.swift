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
    case serviceInstance
    case bnpl(offer: OfferData?, user: CredifyUserModel, orderId: String)
    
    var url: URL {
        switch self {
        case .mypage(user: _):
            return URL(string: "\(Constants.WEB_URL)/login")!
        case .offer(offer: _, user: _):
            return URL(string: "\(Constants.WEB_URL)/initial")!
        case .serviceInstance:
            return URL(string: "\(Constants.WEB_URL)/service-instance")!
        case .bnpl(offer: _, user: _, orderId: _):
            return URL(string: "\(Constants.WEB_URL)/bnpl")!
        }
    }
}

protocol WebPresenterProtocol {
    var receiveHandlers: [ReceiveMessageHandler] { get }
    func shouldClose(messageName: String) -> Bool
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
        ]
    }
    
    
    func shouldClose(messageName: String) -> Bool {
        guard let type = ReceiveMessageHandler(rawValue: messageName) else {
            return false
        }
        if case .actionClose = type {
            return true
        }
        return false
    }
    
    func handleMessage(_ webView: WKWebView, name: String, body: [String: Any]?) {
        guard let type = ReceiveMessageHandler(rawValue: name) else {
            return
        }
        
        switch type {
        case .initialLoadCompleted:
            // TODO: This is not called. We need to have communication from passport web app
            print(context)
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
                
                doPostMessage(
                    webView,
                    type: ACTION_TYPE,
                    action: SendMessageHandler.startRedemption.rawValue,
                    payload: [
                        "offer": offerDict.keysToCamelCase(),
                        "profile": userDict
                    ]
                )
            }
            // TODO: other context
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
            
            AppState.shared.credifyId = credifyId

            task(credifyId) { result in
                self.postPushedClaimMessage(webView, isSuccess: result)
            }
        case .offerTransactionStatusChanged:
            guard let dict = body else { return }
            guard let payload = PostMessageUtils.parsePayload(dict: dict), let status = payload["status"] as? String else {
                return
            }
            guard let onboardingStatus = OnboardingStatus(rawValue: status) else { return }
            
            switch onboardingStatus {
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
        }
    }
    
    func hanldeCompletionHandler() {
        switch context {
        case .mypage(_):
            AppState.shared.dismissCompletion?()
        case .offer(_, _):
            AppState.shared.redemptionResult?(offerTransactionStatus)
        case .bnpl(offer: _, user: _, orderId: _):
            AppState.shared.redemptionResult?(offerTransactionStatus)
        case .serviceInstance:
            break
        }
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
}
