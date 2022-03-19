//
//  File.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

protocol OfferUseCaseProtocol {
    func getOffers(phoneNumber: String?, countryCode: String?, internalId: String, credifyId: String?, productTypes: [String], completion: @escaping (Result<[OfferData], CredifyError>) -> Void)
}

class OfferUseCase: OfferUseCaseProtocol {
    func getOffers(phoneNumber: String?, countryCode: String?, internalId: String, credifyId: String?, productTypes: [String], completion: @escaping (Result<[OfferData], CredifyError>) -> Void) {
        let req = GetOffersFromProviderRequest(phoneNumber: phoneNumber,
                                               countryCode: countryCode,
                                               localId: internalId,
                                               credifyId: credifyId,
                                               productTypes: productTypes)
        
        APIClient.shared.call(request: req, success: { (res: OfferListRestResponse) in
            completion(.success(res.data.offers))
        }, failure: { error in
            completion(.failure(error))
        })
    }
}
