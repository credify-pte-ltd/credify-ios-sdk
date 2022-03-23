//
//  File.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Alamofire
import Foundation

protocol ResponseProtocol: Codable {}

protocol RequestProtocol {
    associatedtype Response: ResponseProtocol
    var baseUrl: String { get }
    var path: String { get }
    var method: Alamofire.HTTPMethod { get }
    var parameters: Alamofire.Parameters? { get }
    var headers: Alamofire.HTTPHeaders? { get }
}

extension RequestProtocol {
    var baseUrl: String {
        return Constants.API_URL
    }
    var encoding: Alamofire.ParameterEncoding {
        return JSONEncoding.default
    }
    var parameters: Alamofire.Parameters? {
        return nil
    }
    var headers: Alamofire.HTTPHeaders? {
        return nil
    }
}

struct ClientAuthenticationRequest: RequestProtocol {
    
    typealias Response = GetAccessTokenResponse
    var path = "v1/token"
    var method = HTTPMethod.post
    
    init(apiKey: String) {
//        headers?["X-API-KEY"] = apiKey
    }
}

/// Response of `GetAccessToken` and `ClientAuthenticationRequest`
struct GetAccessTokenResponse: ResponseProtocol {
    let success: Bool
    let data: AccessTokenData
    
    struct AccessTokenData: Codable {
        let accessToken: String
        
        private enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}


/// Gets offers list
struct GetOffersFromProviderRequest: RequestProtocol {
    typealias Response = OfferListRestResponse
    var path = "v1/claim-providers/offers"
    var method = Alamofire.HTTPMethod.post
    var parameters: Alamofire.Parameters? = [:]
    
    init(phoneNumber: String?, countryCode: String?, localId: String, credifyId: String?, productTypes: [String]) {
        parameters?["local_id"] = localId
        if let p = phoneNumber { parameters?["phone_number"] = p }
        if let c = countryCode { parameters?["country_code"] = c }
        if let i = credifyId { parameters?["credify_id"] = i }
        parameters?["product_types"] = productTypes
    }
}

/// Response of `GetOffersFromProviderRequest`
struct OfferListRestResponse: ResponseProtocol {
    let success: Bool
    let data: OfferListResponse
    
    struct OfferListResponse: Codable {
        let offers: [OfferData]
        let credifyId: String?
        
        private enum CodingKeys: String, CodingKey {
            case offers
            case credifyId = "credify_id"
        }
    }
}
