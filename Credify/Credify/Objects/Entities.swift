//
//  File.swift
//  
//
//  Created by Shu on 2022/03/12.
//

import Foundation

public struct OfferData: Codable {
    public let id: String
    public let code: String
    public var campaign: OfferCampaign
    public let evaluationResult: EvaluationResult?
    public let providerId: String?
    // NOTE: we need provider for show logo in initial offer screen
    public let provider: Organization?
    
    public init(id: String,
                code: String,
                campaign: OfferCampaign,
                evaluationResult: EvaluationResult?,
                providerId: String?,
                provider: Organization) {
        self.id = id
        self.code = code
        self.campaign = campaign
        self.evaluationResult = evaluationResult
        self.providerId = providerId
        self.provider = provider
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case code
        case campaign
        case evaluationResult = "evaluation_result"
        case providerId = "provider_id"
        case provider = "provider"
    }
}

public struct OfferListInfo : Codable {
    public let offers: [OfferData]
    
    // NOTE: when getting list offer from consumer, credifyId maybe nil if user haven't account from Credify yet. After creating credify account from provider, we will have credifyId and we will assign it.
    public let credifyId: String?
    
    private enum CodingKeys: String, CodingKey {
        case offers
        case credifyId = "credify_id"
    }
}

public struct EvaluationResult: Codable {
    public let rank: Int
    public let usedScopes: [String]
    public let requiredScopes: [String]
    
    public init(rank: Int,
                usedScopes: [String],
                requiredScopes: [String]) {
        self.rank = rank
        self.usedScopes = usedScopes
        self.requiredScopes = requiredScopes
    }
    private enum CodingKeys: String, CodingKey {
        case rank
        case usedScopes = "used_scopes"
        case requiredScopes = "requested_scopes"
    }
}


public struct OfferCampaign: Codable {
    public let id: String?
    public let consumer: Organization?
    public let name: String?
    public let description: String?
    public let isPublished: Bool?
    public let startAt: String? //Offer starting date
    public let endAt: String?
    public let extraSteps: Bool?
    public let levels: [String]?
    public let thumbnailUrl: String?
    public let verificationScopes: [String]?
    public let useReferral: Bool
    public var product: ProductModel?
    public var requiredStandardScopes: [String]?
    public var requiredBasicProfile: [BasicProfileType]?
    
    public init(id: String?,
                consumer: Organization?,
                name: String?,
                description: String?,
                isPublished: Bool?,
                startAt: String?,
                endAt: String?,
                extraSteps: Bool?,
                verificationScopes: [String]?,
                levels: [String]?,
                thumbnailUrl: String?,
                useReferral: Bool,
                product: ProductModel?,
                requiredStandardScopes: [String],
                requiredBasicProfile: [BasicProfileType]) {
        
        self.id = id
        self.consumer = consumer
        self.name = name
        self.description = description
        self.isPublished = isPublished
        self.startAt = startAt
        self.endAt = endAt
        self.extraSteps = extraSteps
        self.levels = levels
        self.verificationScopes = verificationScopes
        self.thumbnailUrl = thumbnailUrl
        self.useReferral = useReferral
        self.product = product
        self.requiredStandardScopes = requiredStandardScopes
        self.requiredBasicProfile = requiredBasicProfile
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case consumer
        case name
        case description
        case isPublished = "published"
        case startAt = "start_date"
        case endAt = "end_date"
        case extraSteps = "extra_steps"
        case levels
        case thumbnailUrl = "thumbnail_url"
        case verificationScopes = "verified_scopes"
        case useReferral = "use_referral"
        case product
        case requiredStandardScopes = "required_standard_scopes"
        case requiredBasicProfile = "required_basic_profile"
    }
}

public struct Organization: Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let logoUrlStr: String?
    public let appUrlStr: String?
    public let scopes: [String]?
    public let shareableBasicProfile: [BasicProfileType]?
    
    public init(id: String,
                name: String,
                description: String?,
                logoUrlStr: String,
                appUrlStr: String,
                scopes: [String]?,
                shareableBasicProfile: [BasicProfileType]?) {
        self.id = id
        self.name = name
        self.description = description
        self.logoUrlStr = logoUrlStr
        self.appUrlStr = appUrlStr
        self.scopes = scopes
        self.shareableBasicProfile = shareableBasicProfile
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case logoUrlStr = "logo_url"
        case appUrlStr = "app_url"
        case scopes
        case shareableBasicProfile = "shareable_basic_profile"
    }
}

public struct ProductModel: Codable {
    public let code: String
    public let productTypeCode: String
    public let displayName: String
    public let description: String?
    public let detail: ProductDetail?
    
    //NOTE: for use select package product in UI
    public var selectedProductCode: String?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case productTypeCode = "product_type_code"
        case displayName = "display_name"
        case description
        case detail
        case selectedProductCode
    }
    
    public struct ProductDetail: Codable {
        internal let packages: [InsurancePackageModel]?
        
        public var insurancePackages: [InsurancePackageModel] {
            return packages ?? [InsurancePackageModel]()
        }
    }
}

public struct InsurancePackageModel: Codable {
    public let code: String
    public let name: String
    public let premium: FiatCurrency?
    public let policyUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case name
        case premium
        case policyUrl = "policy_url"
    }
}

public struct FiatCurrency: Codable {
    public let value: String
    public let currency: String
}

public enum BasicProfileType: String, Codable {
    case name = "NAME"
    case email = "EMAIL"
    case phone = "PHONE"
    case gender = "GENDER"
    case address = "ADDRESS"
    case dob = "DOB"
}

//
// completed: the user redeemed offer successfully and the offer transaction status is COMPLETED.
// pending: the user redeemed offer successfully and the offer transaction status is PENDING.
// canceled: the user redeemed offer successfully and he canceled this offer afterwords.
// OR he clicked on the back button in any screens in the offer redemption flow.
//
public enum RedemptionResult: String {
    case pending
    case canceled
    case completed
}

enum OnboardingStatus : String {
    case completed = "COMPLETED"
    case pending = "PENDING"
    case canceled = "CANCELED"
    case failed = "FAILED"
}

/// 20771: Add Service Instance
public enum ProductType : String {
    // Insurance
    case insurance = "insurance"
    case healthInsurance = "health-insurance"
    case autoMobileInsurance = "automobile-insurance"
    case homeInsurance = "home-insurance"
    // Finance
    case consumerFinancing = "consumer-financing"
    case corporateFinancing = "corporate-financing"
    case unsecuredLoanFinance = "unsecured-loan"
    case securedLoanFinance = "secured-loan"
    // Credit card
    case creditCard = "credit-card"
    case traditionalCreditCard = "traditional"
    case cbccCreditCard = "cbcc"
    // BNPL
    case bnpl = "bnpl"
    case consumerBNPL = "consumer"
    case merchantBNPL = "merchant"
}
