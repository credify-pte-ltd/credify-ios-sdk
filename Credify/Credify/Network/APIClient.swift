//
//  APIClient.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation
import Alamofire

class APIClient {
    static let shared = APIClient()

    private init() {}
    
    private var token: String = ""

    func call<T: RequestProtocol>(request: T, success: @escaping (T.Response) -> Void, failure: @escaping (CredifyError) -> Void) {
        let baseUrl = request.baseUrl
        let path = request.path
        let requestUrl = "\(baseUrl)/\(path)"
        let method = request.method
        let encoding = request.encoding
        let parameters = request.parameters

        if token.isEmpty {
            guard let orgApiKey = AppState.shared.config?.apiKey else {
                failure(.requestError(message: "Please set your API key."))
                return
            }
            
            let r = ClientAuthenticationRequest(apiKey: orgApiKey)
            let tokenRequestUrl = "\(r.baseUrl)/\(r.path)"
            let tokenRequestHeaders: HTTPHeaders = [
                "X-API-KEY": orgApiKey
            ]
            AF.request(tokenRequestUrl, method: .post, parameters: nil, headers: tokenRequestHeaders)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(_):
                        do {
                            guard let data = response.data else { return }
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(ClientAuthenticationRequest.Response.self, from: data)
                            self.token = result.data.accessToken
                            
                            let headers: HTTPHeaders = [
                                "Authorization": "Bearer \(self.token)"
                            ]
                            
                            AF.request(requestUrl, method: method, parameters: parameters, encoding: encoding, headers: headers)
                                .validate(statusCode: 200..<300)
                                .responseData { response in
                                    switch response.result {
                                    case .success(_):
                                        do {
                                            guard let data = response.data else { return }
                                            let decoder = JSONDecoder()
                                            let result = try decoder.decode(T.Response.self, from: data)
                                            success(result)
                                        } catch {
                                            failure(.parseError)
                                        }
                                    case .failure(let e):
                                        failure(.requestError(message: e.errorDescription ?? "Network error"))
                                    }
                                }
                            
                        } catch {
                            failure(.parseError)
                        }
                    case .failure(let e):
                        if (e.responseCode == 400) {
                            failure(.apiKeyError)
                        } else {
                            failure(.requestError(message: "Generating access token API failed."))
                        }
                    }
                }
        } else {
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token)"
            ]
            AF.request(requestUrl, method: method, parameters: parameters, encoding: encoding, headers: headers)
                .validate(statusCode: 200..<300)
                .responseData { response in
                    switch response.result {
                    case .success(_):
                        do {
                            guard let data = response.data else { return }
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(T.Response.self, from: data)
                            success(result)
                        } catch {
                            failure(.parseError)
                        }
                    case .failure(let e):
                        if e.responseCode == 401 {
                            // If token is expired, it will regenerate a token.
                            self.token = ""
                            self.call(request: request, success: success, failure: failure)
                        } else {
                            failure(.requestError(message: e.errorDescription ?? "Network error"))
                        }
                    }
                }
        }
    }
}
