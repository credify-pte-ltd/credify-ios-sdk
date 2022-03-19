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

enum MessageHandler: String {
    case initialLoadCompleted
    case createUserCompleted
    case startRedemption
    case offerTransactionStatusChanged
    case actionClose
}

protocol WebPresenterProtocol {
    var handlers: [MessageHandler] { get }
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
    
    var handlers: [MessageHandler] {
        return [
            .initialLoadCompleted,
            .createUserCompleted,
            .startRedemption,
            .offerTransactionStatusChanged,
            .actionClose,
        ]
    }
    
    func shouldClose(messageName: String) -> Bool {
        guard let type = MessageHandler(rawValue: messageName) else {
            return false
        }
        if case .actionClose = type {
            return true
        }
        return false
    }
    
    func handleMessage(_ webView: WKWebView, name: String, body: [String: Any]?) {
        guard let type = MessageHandler(rawValue: name) else {
            return
        }
        
        switch type {
        case .initialLoadCompleted:
            // TODO: This is not called. We need to have communication from passport web app
            print(context)
            if case let .mypage(user) = context {
                let data: [String: String] = [
                    "action": "ACTION_LOGIN",
                    "phone_number": user.phoneNumber,
                    "country_code": user.countryCode,
                    "full_name": user.localizedName
                ]
                print(data.json)
                let js = "(function() { window.postMessage('\(data.json)','*'); })();"
                webView.evaluateJavaScript(js)
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
                let data: [String: Any] = [
                    "type": "CREDIFY-WEB-SDK",
                    "action": "startRedemption",
                    "payload": [
                        "offer": offerDict.keysToCamelCase(),
                        "profile": userDict
                    ]
                ]
                
                // The payload will break line instead of "\n"  when using the postMessage
                // That's why the web app cannot parse json data
                
                // In valid json without replacing. It's just example, not full json data
                // === Example json:===
                /*
                   "description":"BẢO HIỂM NHÀ 365 Cam kết luôn đồng hành, mang đến cho bạn sự an tâm trước các rủi ro về ngôi nhà, mái ấm yêu thương của gia đình bạn.
                                   
                                   
                    Phí bảo hiểm hiểm cạnh tranh
                    Thủ tục đăng ký nhanh chóng, đơn giản"
                 */

                // I found this way to fix it, if we have a better way I will update it later.
                let json = data.json.replacingOccurrences(of: "\\n", with: "<br>")
                let js = "(function() { window.postMessage('\(json)','*'); })();"
                
                webView.evaluateJavaScript(js)
            }
            // TODO: other context
        case .startRedemption:
            break
        case .createUserCompleted:
            guard let dict = body else { return }
            guard let payload = dict["payload"] as? [String: Any], let credifyId = payload["credifyId"] as? String else {
                return
            }
            guard let task = AppState.shared.pushClaimTokensTask else {
                return
            }
            
            AppState.shared.credifyId = credifyId

            task(credifyId) { result in
                if result {
                    let data: [String: Any] = [
                        "type": "CREDIFY-WEB-SDK",
                        "action": "pushClaimCompleted",
                        "payload": [
                            "isSuccess": true
                        ]
                    ]
                    let js = "(function() { window.postMessage('\(data.json)','*'); })();"
                    webView.evaluateJavaScript(js)
                } else {
                    print("Push claim token failed")
                }
                
            }
        case .offerTransactionStatusChanged:
            guard let dict = body else { return }
            guard let payload = dict["payload"] as? [String: Any], let status = payload["status"] as? String else {
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
}
