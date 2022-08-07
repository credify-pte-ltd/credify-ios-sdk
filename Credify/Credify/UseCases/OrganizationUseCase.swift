//
//  OrganizationUseCase.swift
//  
//
//  Created by Gioan Le on 05/04/2022.
//

import Foundation

protocol OrganizationUseCaseProtocol {
    func getConnectedBnplProviders(credifyId: String, completion: @escaping (Result<[ConnectedProvider], CredifyError>) -> Void)
}

class OrganizationUseCase : OrganizationUseCaseProtocol {
    func getConnectedBnplProviders(credifyId: String, completion: @escaping (Result<[ConnectedProvider], CredifyError>) -> Void) {
        let request = GetCompletedBnplProviderRequest(credifyId: credifyId)
        
        APIClient.shared.call(request: request, success: { (res: CompletedBnplProviderListRestResponse) in
            completion(.success(res.data.providers))
        }, failure: { error in
            completion(.failure(error))
        })
    }
}
