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
    }
    
    public static func setLanguage(_ language: Language) {
        AppState.shared.language = language
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
        public func showMypage(
            from: UIViewController,
            user: CredifyUserModel,
            pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
            completion: @escaping (() -> Void)
        ) {
            if !ValidationUtils.showErrorIfShowMyPageFails(from: from, user: user) {
                return
            }
            
            AppState.shared.pushClaimTokensTask = pushClaimTokensTask
            AppState.shared.dismissCompletion = completion
            
            let context = PassportContext.mypage(user: user)
            let vc = WebViewController.instantiate(context: context)
            let navigationController = UIUtils.createUINavigationController(vc: vc)
            from.present(navigationController, animated: true)
        }
        
        
        /// This opens detail page that describes a product.
        /// (e.g., insurance detail for users who have purchased an insurance package through serviceX)
        ///
        /// - Parameter
        ///  - from: ViewController that renders a new view from
        ///  - user: User object
        ///  - marketId: The market ID
        ///  - productTypes: Product type list
        public func showDetail(
            from: UIViewController,
            user: CredifyUserModel,
            marketId: String,
            productTypes: [ProductType],
            completion: @escaping (() -> Void)
        ) {
            if !ValidationUtils.showErrorIfShowDetailPageFails(from: from, user: user, marketId: marketId) {
                return
            }
            
            AppState.shared.dismissCompletion = completion
            let context = PassportContext.serviceInstance(user: user, marketId: marketId, productTypes: productTypes)
            let vc = WebViewController.instantiate(context: context)
            let navigationController = UIUtils.createUINavigationController(vc: vc)
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
        @available(*, deprecated, message: "It'll be removed in the future.")
        public func getOffers(
            user: CredifyUserModel? = nil,
            productTypes: [ProductType] = [],
            completion: @escaping ((Result<OfferListInfo, CredifyError>) -> Void)
        ) {
            return useCase.getOffers(
                phoneNumber: user?.phoneNumber,
                countryCode: user?.countryCode,
                internalId: user?.id ?? "",
                credifyId: user?.credifyId,
                productTypes: productTypes.map({ type in type.rawValue }),
                completion: completion
            )
        }
        
        
        /// This kicks off offer redemption flow.
        /// - Parameters:
        ///   - from: ViewController that renders a new view from
        ///   - offer: Offer object
        ///   - userProfile: User object
        ///   - pushClaimTokensTask: A task that calls your push claim token API. This SDK needs to receive success status of this task.
        ///   - completionHandler: Completion handler. You can get notified about the result of the offer redemption flow.
        @available(*, deprecated, message: "Using presentByOfferCodeModally method instead")
        public func presentModally(from: UIViewController,
                                   offer: OfferData,
                                   userProfile: CredifyUserModel,
                                   pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
                                   completionHandler: @escaping (RedemptionResult) -> Void) {
            presentOfferByCodeModally(
                from: from,
                offerCode: offer.code,
                userProfile: userProfile,
                pushClaimTokensTask: pushClaimTokensTask,
                completionHandler: completionHandler
            )
        }
        
        /// This kicks off offer redemption flow.
        /// - Parameters:
        ///   - from: ViewController that renders a new view from
        ///   - offerCode: This is the offer code
        ///   - userProfile: User object
        ///   - pushClaimTokensTask: A task that calls your push claim token API. This SDK needs to receive success status of this task.
        ///   - completionHandler: Completion handler. You can get notified about the result of the offer redemption flow.
        public func presentOfferByCodeModally(
            from: UIViewController,
            offerCode: String,
            userProfile: CredifyUserModel,
            pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
            completionHandler: @escaping (RedemptionResult) -> Void
        ) {
            if !ValidationUtils.showErrorIfOfferCannotStart(from: from, user: userProfile) {
                return
            }
            
            AppState.shared.pushClaimTokensTask = pushClaimTokensTask
            AppState.shared.redemptionResult = completionHandler
            
            let context = PassportContext.offer(offerCode: offerCode, user: userProfile)
            let vc = WebViewController.instantiate(context: context)
            let navigationController = UIUtils.createUINavigationController(vc: vc)
            from.present(navigationController, animated: true)
        }
        
        @available(*, deprecated, message: "Using presentPromotionOffersByCodesModally method instead")
        public func presentPromotionOffersModally(
            from: UIViewController,
            offers: [OfferData],
            userProfile: CredifyUserModel,
            pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
            completionHandler: @escaping (RedemptionResult) -> Void
        ) {
            presentPromotionOffersByCodesModally(
                from: from,
                offerCodes: offers.map({ item in item.code }),
                userProfile: userProfile,
                pushClaimTokensTask: pushClaimTokensTask,
                completionHandler: completionHandler
            )
        }
        
        /// This will show offer list.
        /// - Parameters:
        ///   - from: ViewController that renders a new view from
        ///   - offerCodes: This is  offer code list
        ///   - userProfile: User object
        ///   - pushClaimTokensTask: A task that calls your push claim token API. This SDK needs to receive success status of this task.
        ///   - completionHandler: Completion handler. You can get notified about the result of the offer redemption flow.
        public func presentPromotionOffersByCodesModally(
            from: UIViewController,
            offerCodes: [String],
            userProfile: CredifyUserModel,
            pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
            completionHandler: @escaping (RedemptionResult) -> Void
        ) {
            if !ValidationUtils.showErrorIfOfferCannotStart(from: from, user: userProfile) {
                return
            }
            
            // If there is no offer then we just return, don't need to show an error to the user
            if offerCodes.isEmpty {
                print("'offers' is empty")
                return
            }
            
            let vc = ModalViewController.instantiate() {
                self.presentOffers(
                    from: from,
                    offerCodes: offerCodes,
                    userProfile: userProfile,
                    pushClaimTokensTask: pushClaimTokensTask,
                    completionHandler: completionHandler
                )
            }
            let navigationController = UIUtils.createUINavigationController(vc: vc)
            from.present(navigationController, animated: true)
        }
        
        private func presentOffers(
            from: UIViewController,
            offerCodes: [String],
            userProfile: CredifyUserModel,
            pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
            completionHandler: @escaping (RedemptionResult) -> Void
        ) {
            AppState.shared.pushClaimTokensTask = pushClaimTokensTask
            AppState.shared.redemptionResult = completionHandler
            
            let context = PassportContext.promotionOffers(offerCodes: offerCodes, user: userProfile)
            let vc = WebViewController.instantiate(context: context)
            let navigationController = UIUtils.createUINavigationController(vc: vc)
            from.present(navigationController, animated: true)
        }
    }
    
    /// BNPL features
    /// `serviceX.BNPL()`
    public struct BNPL {
        private let useCase = OfferUseCase()
        private let organizationUseCase = OrganizationUseCase()
        
        public init() {}
        
        /// This loads all the offers and connected providers that meet specified conditions.
        /// - Parameters:
        ///   - user: User object
        ///   - completion: Completion handler. You can access to BNPL offers and connected providers list in this handler.
        private func getOffersAndConnectedProviders(
            user: CredifyUserModel?,
            completion: @escaping ((Result<BNPLOfferInfo, CredifyError>) -> Void)
        ) {
            // Get offer list
            useCase.getOffers(
                phoneNumber: user?.phoneNumber,
                countryCode: user?.countryCode,
                internalId: user?.id ?? "",
                credifyId: user?.credifyId,
                productTypes: [ProductType.consumerBNPL.rawValue]
            ) { offersResult in
                switch offersResult {
                case .success(let offersInfo):
                    let offers = offersInfo.offers
                    let credifyId = offersInfo.credifyId
                    
                    if (credifyId ?? "").isEmpty {
                        completion(.success(BNPLOfferInfo(offers: offers, providers: [], credifyId: credifyId)))
                        return
                    }
                    
                    // Get connected provider list
                    organizationUseCase.getConnectedBnplProviders(credifyId: credifyId!) { providersResult in
                        switch providersResult {
                        case .success(let providersInfo):
                            completion(.success(BNPLOfferInfo(offers: offers, providers: providersInfo, credifyId: credifyId)))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                    
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        /// This will check that BNPL is available for this user or not
        /// If yes, you can call BNPL().presentModally method to start BNPL flow
        /// If no, you should not
        /// - Parameters:
        ///   - user: User object
        ///   - completion: Completion handler. BNPL is available for this user or not
        @available(*, deprecated, message: "It'll be removed in the future.")
        public func getBNPLAvailability(
            user: CredifyUserModel?,
            completion: @escaping ((Result<(available: Bool, credifyId: String?), CredifyError>) -> Void)
        ) {
            self.getOffersAndConnectedProviders(user: user) { bnplResult in
                switch bnplResult {
                case .success(let bnplInfo):
                    let isBNPLAvailable = !bnplInfo.offers.isEmpty || !bnplInfo.providers.isEmpty
                    completion(.success((isBNPLAvailable, bnplInfo.credifyId)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        
        /// This kicks off BNPL flow
        /// - Parameters:
        ///   - from: ViewController that renders a new view from
        ///   - userProfile: User's information
        ///   - orderId: Order ID. This is to be created by your backend before starting this process.
        ///   - pushClaimTokensTask: A task that calls your push claim token API. This SDK needs to receive success status of this task.
        ///   - completionHandler: Completion handler. You can get notified about the result of the BNPL flow.
        @available(*, deprecated, message: "Using presentBNPLByCodesModally method instead")
        public func presentModally(from: UIViewController,
                                   userProfile: CredifyUserModel,
                                   orderInfo: OrderInfo,
                                   pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
                                   completionHandler: @escaping (_ status: RedemptionResult,_ orderId: String, _ isPaymentCompleted: Bool) -> Void) {
            if !ValidationUtils.showErrorIfOfferCannotStart(from: from, user: userProfile) {
                return
            }
            
            self.getOffersAndConnectedProviders(user: userProfile) { bnplResult in
                switch bnplResult {
                case .success(let bnplInfo):
                    let offers = bnplInfo.offers
                    let connectedProviders = bnplInfo.providers
                    
                    if !ValidationUtils.showErrorIfBNPLUnavailable(from: from, offers:offers, providers: connectedProviders) {
                        return
                    }
                    
                    self.presentBNPLByCodesModally(
                        from: from,
                        offerCodes: offers.map({ item in item.code }),
                        packageCode: nil,
                        userProfile: userProfile,
                        orderInfo: orderInfo,
                        pushClaimTokensTask: pushClaimTokensTask,
                        completionHandler: completionHandler
                    )
                case .failure(_):
                    let tableName = "serviceX"
                    UIUtils.alert(
                        from: from,
                        title: "Error".localized(tableName: tableName),
                        errorMessage: "BNPLIsNotAvailable".localized(tableName: tableName),
                        actionText: "OK".localized(tableName: tableName)
                    )
                }
            }
        }
        
        public func presentBNPLByCodesModally(
            from: UIViewController,
            offerCodes: [String],
            packageCode: String?,
            userProfile: CredifyUserModel,
            orderInfo: OrderInfo,
            pushClaimTokensTask: @escaping ((String, ((Bool) -> Void)?) -> Void),
            completionHandler: @escaping (_ status: RedemptionResult,_ orderId: String, _ isPaymentCompleted: Bool) -> Void
        ) {
            if !ValidationUtils.showErrorIfOfferCannotStart(from: from, user: userProfile) {
                return
            }
            
            let appState = AppState.shared
        
            appState.pushClaimTokensTask = pushClaimTokensTask
            appState.bnplRedemptionResult = completionHandler
            
            let context = PassportContext.bnpl(
                offerCodes: offerCodes,
                packageCode: packageCode,
                user: userProfile,
                orderInfo: orderInfo
            )
            let vc = WebViewController.instantiate(context: context)
            let navigationController = UIUtils.createUINavigationController(vc: vc)
            from.present(navigationController, animated: true)
        }
    }
}
