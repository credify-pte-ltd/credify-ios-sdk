//
//  ViewController.swift
//  ExampleApp
//
//  Created by Shu on 2022/03/19.
//

import UIKit
import Credify
import Alamofire

let API_KEY = "7kx6vx9p9gZmqrtvHjRTOiSXMkAfZB3s5u3yjLehQHQCtjWrjAk9XlQHR2IOqpuR"
let APP_NAME = "TestService"
let API_PUSH_CLAIMS = "https://dev-demo-api.credify.ninja/service-j/push-claims"

class ViewController: UIViewController {

    @IBOutlet weak var button: UIButton!
    private let offer = serviceX.Offer()
    private var user: CredifyUserModel!
    private var offerList: [OfferData] = [OfferData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        button.isEnabled = false
        
        let config = serviceXConfig(apiKey: API_KEY, env: .dev, appName: APP_NAME)
        serviceX.configure(config)
        
        user = CredifyUserModel(id: "123", firstName: "Sh", lastName: "Test", email: "vu.nguyen@gmail.com", credifyId: nil, countryCode: "84", phoneNumber: "0381239876")
        
        loadOffers()
    }

    /// This loads offers list. Please call this whenever you want.
    func loadOffers() {
        offer.getOffers(user: user, productTypes: []) { [weak self] result in
            switch result {
            case .success(let offers):
                self?.offerList = offers
                self?.button.isEnabled = true
                print(offers)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// This starts Credify SDK
    func startOffer(_ offerData: OfferData) {
        let task: ((String, ((Bool) -> Void)?) -> Void) = { credifyId, result in
            AF.request(API_PUSH_CLAIMS,
                       method: .post,
                       parameters: ["id": self.user.id, "credify_id": credifyId],
                       encoding: JSONEncoding.default).responseJSON { data in
                switch data.result {
                case .success:
                    result?(true)
                case .failure:
                    result?(false)
                }
            }
        }
        offer.presentModally(from: self, offer: offerData, userProfile: user, pushClaimTokensTask: task) { [weak self] result in
            self?.dismiss(animated: true) {
                print("Done")
            }
        }
    }
    @IBAction func clickButton(_ sender: Any) {
        let offers = offerList.filter { offer in
            !offer.campaign.useReferral
        }
        
        if !offers.isEmpty {
            startOffer(offers[0])
        }
    }
    
}
