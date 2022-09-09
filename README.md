# credify-ios-sdk

Credify serviceX iOS SDK.

## Requirements

- iOS 10+
- Swift 5.3+
- Xcode 12.0+
- Credify SDK 0.9.0+
- Credify SDK 0.8.0 or lower. Please follow [this guideline](./ReadMe/README-v0.8.0-and-lower.md)

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
import Alamofire // This is not required, but used for demo

let API_KEY = "your api key"
let APP_NAME = "your app name"
let API_PUSH_CLAIMS = "your API endpoint to push claim tokens"

class SampleViewController: UIViewController {

    private let offer = serviceX.Offer()
    private var user: CredifyUserModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = serviceXConfig(apiKey: API_KEY, env: .sandbox, appName: APP_NAME)
        serviceX.configure(config)
        
        user = CredifyUserModel(id: "internal ID in your system", firstName: "Vũ", lastName: "Nguyển", email: "vu.nguyen@gmail.com", credifyId: nil, countryCode: "+84", phoneNumber: "0381239876")
    }
    
    /// To using this method you have to get the offers on your side
    /// Your backend have to provide an API for this
    /// When you want to start offer redemption flow you involke this method and pass the "offerCode" as the parameter.
    func startOffer(_ offerCode: String) {
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
        
        offer.presentOfferModallyByCode(from: self, offerCode: offerCode, userProfile: user, pushClaimTokensTask: task) { [weak self] result in
            self?.dismiss(animated: true) {
                print("Done")
            }
        }
    }

}
```

> **Important**: For the `pushClaimTokensTask` callback, you need to keep `credifyId` on your side. You have to send the `credifyId` to Credify SDK when you use the methods that require `credifyId`. E.g: call `offer.presentOfferModallyByCode` method or create `CredifyUserModel` model.

### Promotion offer list(available on v0.6.0)

Using below are example for show promotions offer list.

```swift
import UIKit
import Credify
import Alamofire // This is not required, but used for demo

let API_KEY = "your api key"
let APP_NAME = "your app name"
let API_PUSH_CLAIMS = "your API endpoint to push claim tokens"

class SampleViewController: UIViewController {

    private let offer = serviceX.Offer()
    private var user: CredifyUserModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = serviceXConfig(apiKey: API_KEY, env: .sandbox, appName: APP_NAME)
        serviceX.configure(config)
        
        user = CredifyUserModel(id: "internal ID in your system", firstName: "Vũ", lastName: "Nguyển", email: "vu.nguyen@gmail.com", credifyId: nil, countryCode: "+84", phoneNumber: "0381239876")
    }
    
    /// To using this method you have to get the offers on your side
    /// Your backend have to provide an API for this
    /// When you want to show the offers you involke this method and pass the "offerCodes" list as the parameter.
    func showPromotionOffers(_ offerCodes: [String]) {
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
        offer.presentPromotionOffersModallyByCodes(from: self, offerCodes: offerCodes, userProfile: user, pushClaimTokensTask: task) { [weak self] result in
            self?.dismiss(animated: true) {
                print("Done")
            }
        }
    }
```      

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

    /// To using this method you have to get the offers on your side
    /// Your backend have to provide an API for this
    /// When you want to start the BNPL flow you involke this method and pass the "offerCode" list and selected "packageCode"(optional, you can pass nil for now) as the parameters.
    /// You need to create "orderInfo" on your side.
    func startBNPL(_ offerCodes: [String], _ packageCode: String?, _orderInfo: OrderInfo) {
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
        
        bnpl.presentOfferModallyByCode(
            from: self,
            offerCodes: offerCodes,
            packageCode: packageCode,
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

> **Important**: For the `pushClaimTokensTask` callback, you need to keep `credifyId` on your side. You have to send the `credifyId` to Credify SDK when you use the methods that require `credifyId`. E.g: call `bnpl.presentOfferModallyByCode` method or create `CredifyUserModel` model.

### The Service detail

Using the below code for showing the Service detail page. It will show all the BNPL details which the user has used.

```swift
import UIKit
import Credify

class SampleViewController: UIViewController {
    private let passport = serviceX.Passport()
    private var user: CredifyUserModel!
    private let marketId: String // Your orgnization id that you have registered with Credify
    private let productTypes: [ProductType] // You need to initialize this field

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = serviceXConfig(apiKey: API_KEY, env: .sandbox, appName: APP_NAME)
        serviceX.configure(config)
        
        user = CredifyUserModel(id: "internal ID in your system", firstName: "Vũ", lastName: "Nguyển", email: "vu.nguyen@gmail.com", credifyId: nil, countryCode: "+84", phoneNumber: "0381239876")
    }

    /// This renders passport page
    func showServiceInstance() {
        passport.showDetail(
            from: self,
            user: user!,
            marketId: marketId,
            productTypes: []
        ) {
            print("page dismissed")
        }
    }
}

```

### Setting language

Using `serviceX.setLanguage` to setup the language that will be used for the localization in the SDK.

```
serviceX.setLanguage(Language)
```

## License

Credify iOS SDK is released under the MIT License. See LICENSE for details.
