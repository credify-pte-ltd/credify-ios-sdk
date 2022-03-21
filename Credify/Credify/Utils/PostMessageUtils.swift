//
//  PostMessageUtils.swift
//  Credify
//
//  Created by Gioan Le on 21/03/2022.
//

import Foundation

class PostMessageUtils {
    static func parsePayload(dict: [String: Any]) -> [String: Any]? {
        if dict.isEmpty {
            return nil
        }
        
        guard let payloadTypeStr = dict["payloadType"] as? String, let payloadType = PayloadType(rawValue: payloadTypeStr) else {
            return dict["payload"] as? [String: Any]
        }
        
        if payloadType == PayloadType.base64 {
            guard let payload = dict["payload"] as? String else {
                return nil
            }
            return Dictionary<String, Any>.fromBase64(base64: payload)
        }
        return dict["payload"] as? [String: Any]
    }
}
