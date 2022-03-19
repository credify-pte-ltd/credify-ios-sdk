import UIKit


/// Credify serviceX SDK entry point
///
/// - Authors: Credify Pte. Ltd.
/// - Requires: iOS 10
public struct serviceX {
    
    /// This configures your app
    /// - Parameters:
    ///   - config: serviceXConfig
    /// - Returns: Void
    public static func configure(_ config: serviceXConfig) {
        AppState.shared.config = config
//        let sdkVersion = (Bundle.serviceX.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "unknown"
//        let userAgent = "servicex/ios/\(sdkVersion)"
    }
    
    
    /// Passport features
    /// You can open my account page for your users.
    /// `serviceX.Passport()`
    public struct Passport {
        public init() {}
        
        /// This opens mypage for your user.
        ///
        /// - Parameters:
        ///   - from: ViewController that renders a new view from
        ///   - user: User object
        ///   - completion: Completion handler
        public func showMypage(from: UIViewController, user: CredifyUserModel, completion: @escaping (() -> Void)) {
            AppState.shared.dismissCompletion = completion
            let context = PassportContext.mypage(user: user)
            let vc = WebViewController.instantiate(context: context)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.interactivePopGestureRecognizer?.isEnabled = false // disable navigation bar swipe back
            from.present(navigationController, animated: true)
        }
        
        
        /// This opens detail page that describes a product.
        /// (e.g., insurance detail for users who have purchased an insurance package through serviceX)
        ///
        /// - Parameter from: ViewController that renders a new view from
        public func showDetail(from: UIViewController) {
            // TODO: Update more params
            let context = PassportContext.serviceInstance
            let vc = WebViewController.instantiate(context: context)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.interactivePopGestureRecognizer?.isEnabled = false // disable navigation bar swipe back
            from.present(navigationController, animated: true)
        }
    }
    
    
    /// Offer features
    /// You can kick offer redemption for your users.
    public struct Offer {
        private let useCase = OfferUseCase()
        
        public init() {}
        
        
        /// This loads all the offers that meet specified conditions.
        /// - Parameters:
        ///   - user: User object
        ///   - productTypes: Products list
        ///   - completion: Completion handler. You can access to offers list in this handler.
        public func getOffers(user: CredifyUserModel? = nil, productTypes: [String] = [], completion: @escaping ((Result<[OfferData], CredifyError>) -> Void)) {
            return useCase.getOffers(phoneNumber: user?.phoneNumber, countryCode: user?.countryCode, internalId: user?.id ?? "", credifyId: user?.credifyId, productTypes: productTypes, completion: completion)
        }
        
        
        /// This kicks off offer redemption flow.
        /// - Parameters:
        ///   - from: ViewController that renders a new view from
        ///   - offer: Offer object
        ///   - userProfile: User object
        ///   - pushClaimTokensTask: A task that calls your push claim token API. This SDK needs to receive success status of this task.
        ///   - completionHandler: Completion handler. You can get notified about the result of the offer redemption flow.
        public func presentModally(from: UIViewController,
                                   offer: OfferData,
                                   userProfile: CredifyUserModel,
                                   pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
                                   completionHandler: @escaping (RedemptionResult) -> Void) {
            var u = userProfile
            AppState.shared.pushClaimTokensTask = pushClaimTokensTask
            AppState.shared.redemptionResult = completionHandler
            if (userProfile.credifyId ?? "").isEmpty {
                u.credifyId = AppState.shared.credifyId ?? offer.credifyId
            }
            
            let context = PassportContext.offer(offer: offer, user: u)
            let vc = WebViewController.instantiate(context: context)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.interactivePopGestureRecognizer?.isEnabled = false // disable navigation bar swipe back
            from.present(navigationController, animated: true)
        }
    }
    
    
    /// BNPL features
    /// `serviceX.BNPL()`
    public struct BNPL {
        private let useCase = OfferUseCase()
        
        public init() {}
        
        
        /// This loads all the offers that meet specified conditions.
        /// - Parameters:
        ///   - user: User object
        ///   - completion: Completion handler. You can access to BNPL offers list in this handler.
        public func getOffers(user: CredifyUserModel? = nil, completion: @escaping ((Result<[OfferData], CredifyError>) -> Void)) {
            // TODO: handle non-offer case
            
            useCase.getOffers(phoneNumber: user?.phoneNumber, countryCode: user?.countryCode, internalId: user?.id ?? "", credifyId: user?.credifyId, productTypes: ["bnpl"], completion: completion)
        }
        
        
        /// This kicks off BNPL flow
        /// - Parameters:
        ///   - from: ViewController that renders a new view from
        ///   - offer: <#offer description#>
        ///   - userProfile: <#userProfile description#>
        ///   - orderId: Order ID. This is to be created by your backend before starting this process.
        ///   - pushClaimTokensTask: A task that calls your push claim token API. This SDK needs to receive success status of this task.
        ///   - completionHandler: Completion handler. You can get notified about the result of the BNPL flow.
        public func presentModally(from: UIViewController,
                                   offer: OfferData,
                                   userProfile: CredifyUserModel,
                                   orderId: String,
                                   pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
                                   completionHandler: @escaping (RedemptionResult) -> Void) {
            AppState.shared.pushClaimTokensTask = pushClaimTokensTask
            AppState.shared.redemptionResult = completionHandler
            if (AppState.shared.credifyId ?? "").isEmpty {
                AppState.shared.credifyId = userProfile.credifyId ?? offer.credifyId
            }
            
            let context = PassportContext.bnpl(offer: offer, user: userProfile, orderId: orderId)
            let vc = WebViewController.instantiate(context: context)
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.interactivePopGestureRecognizer?.isEnabled = false // disable navigation bar swipe back
            from.present(navigationController, animated: true)
        }
    }
}
