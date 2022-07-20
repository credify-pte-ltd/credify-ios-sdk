# credify-ios-sdk

Credify serviceX iOS SDK.

## Requirements

- iOS 10+
- Swift 5.3+
- Xcode 12.0+

## How to install

### Swift Package Manager

The [Swift Package Manager](https://www.swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the swift compiler.

Once you have your Swift package set up, adding Credify as a dependency is as easy as adding it to the dependencies value of your `Package.swift`.

```bash
dependencies: [
    .package(url: "https://github.com/credify-pte-ltd/credify-ios-sdk", .upToNextMajor(from: "0.1.0"))
]
```

### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Alamofire into your Xcode project using CocoaPods, specify it in your `Podfile`:

```bash
pod "Credify"
```

## How to use

### Offer

```swift
import UIKit
import Credify
import Alamofire // This is not requred, but used for demo

let API_KEY = "your api key"
let APP_NAME = "your app name"
let API_PUSH_CLAIMS = "your API endpoint to push claim tokens"

class SampleViewController: UIViewController {

    private let offer = serviceX.Offer()
    private var user: CredifyUserModel!
    private var offerList: [OfferData] = [OfferData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = serviceXConfig(apiKey: API_KEY, env: .sandbox, appName: APP_NAME)
        serviceX.configure(config)
        
        user = CredifyUserModel(id: "internal ID in your system", firstName: "Vũ", lastName: "Nguyển", email: "vu.nguyen@gmail.com", credifyId: nil, countryCode: "+84", phoneNumber: "0381239876")
    }

    /// This loads offers list. Please call this whenever you want.
    func loadOffers() {
        offer.getOffers(user: user, productTypes: []) { [weak self] result in
            switch result {
            case .success(let offers):
                self?.offerList = offers
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

}
```

> **Important**: For the `pushClaimTokensTask` callback, you need to keep `credifyId` on your side. You have to send the `credifyId` to Credify SDK when you use the methods that require `credifyId`. E.g: call `offer.presentModally` method or create `CredifyUserModel` model.

### Passport

```swift
import UIKit
import Credify

class SampleViewController: UIViewController {

    private let passport = serviceX.Passport()
    private var user: CredifyUserModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = serviceXConfig(apiKey: API_KEY, env: .sandbox, appName: APP_NAME)
        serviceX.configure(config)
        
        user = CredifyUserModel(id: "internal ID in your system", firstName: "Vũ", lastName: "Nguyển", email: "vu.nguyen@gmail.com", credifyId: nil, countryCode: "+84", phoneNumber: "0381239876")
    }

    /// This renders passport page
    func showPassport() {
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
        passport.showMypage(from: self, user: user, pushClaimTokensTask: task) {
            print("page dismissed")
        }
    }
}

```

### BNPL

```swift
import UIKit
import Credify

class SampleViewController: UIViewController {

    private let bnpl = serviceX.BNPL()
    private var user: CredifyUserModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = serviceXConfig(apiKey: API_KEY, env: .sandbox, appName: APP_NAME)
        serviceX.configure(config)
        
        user = CredifyUserModel(id: "internal ID in your system", firstName: "Vũ", lastName: "Nguyển", email: "vu.nguyen@gmail.com", credifyId: nil, countryCode: "+84", phoneNumber: "0381239876")
    }
    
    /// This will check whether BNPL is available or not
    /// You need to create "orderInfo" on your side.
    func getBNPLAvailability(orderInfo: OrderInfo) {
        bnpl.getBNPLAvailability(user: self.user) { result in
            switch result {
            case .success((let isAvailable, let credifyId)):
                if isAvailable {
                    // This will start BNPL flow
                    self.startBNPL(orderInfo: OrderInfo)
                    return
                }
                
                // BNPL is not available
            case .failure(let error):
                // Error
                break
            }
        }
    }

    /// This starts Credify SDK
    /// You need to create "orderInfo" on your side.
    func startBNPL(orderInfo: OrderInfo) {
        let task: ((String, ((Bool) -> Void)?) -> Void) = { credifyId, result in
            // Using Alamofire
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
        
        bnpl.presentModally(
                from: self,
                userProfile: self.user,
                orderInfo: orderInfo,
                pushClaimTokensTask: task
        ) { [weak self] status, orderId, isPaymentCompleted in
            self?.dismiss(animated: false) {
                print("Status: \(status.rawValue), order id: \(orderId), payment completed: \(isPaymentCompleted)")
            }
        }
    }
}

```

> **Important**: For the `pushClaimTokensTask` callback, you need to keep `credifyId` on your side. You have to send the `credifyId` to Credify SDK when you use the methods that require `credifyId`. E.g: call `bnpl.presentModally` method or create `CredifyUserModel` model.

### Setting language

Using `serviceX.setLanguage` to setup the language that will be used for the localization in the SDK.

```
serviceX.setLanguage(Language)
```

## License

Credify iOS SDK is released under the MIT License. See LICENSE for details.
