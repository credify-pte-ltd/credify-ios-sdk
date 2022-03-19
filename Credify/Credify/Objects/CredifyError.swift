//
//  File.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

/// Errors in Credify SDK
public enum CredifyError: Error {
    /// API key has something wrong
    case apiKeyError
    /// Parsing API failed
    case parseError
    /// Request error
    case requestError(message: String)
}

extension CredifyError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .apiKeyError:
            return "API key is not valid. Please make sure you have a correct API key."
        case .parseError:
            return "Parsing failed. The API response is not as expected."
        case .requestError(let reason):
            return reason
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .apiKeyError:
            return "API key is not valid. Please make sure you have a correct API key."
        case .parseError:
            return "Parsing failed. The API response is not as expected."
        case .requestError(let reason):
            return reason
        }
    }
}
