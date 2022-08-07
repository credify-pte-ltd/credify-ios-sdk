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
    // 25994: HouseCare - Add bannerUrl to the Campaign object
    public let bannerUrl: String?
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
                bannerUrl: String?,
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
        self.bannerUrl = bannerUrl
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
        case bannerUrl = "banner_url"
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
    public let consumerId: String
    public let customScopes: [Scope]?
    
    //NOTE: for use select package product in UI
    public var selectedProductCode: String?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case productTypeCode = "product_type_code"
        case displayName = "display_name"
        case description
        case detail
        case selectedProductCode
        case consumerId = "consumer_id"
        case customScopes = "custom_scopes"
    }
    
    public struct ProductDetail: Codable {
        public let packages: [InsurancePackageModel]?
        public let availableTerms: [AvailableTerms]?
        public let consumerDisbursementRequirements: [String]?
        public let description: String?
        public let title: String?
        public let downPayment: Downpayment?
        public let duration: Duration?
        public let maxAprPercent: Int?
        public let maxLoanAmount: FiatCurrency?
        public let minAprPercent: Int?
        public let minLoanAmount: FiatCurrency?
        public let policyUrl: String?
        public let providerDisbursementRequirements: [String]?
        
        public var insurancePackages: [InsurancePackageModel] {
            return packages ?? [InsurancePackageModel]()
        }
        
        public var terms: [AvailableTerms] {
            return availableTerms ?? [AvailableTerms]()
        }
        
        private enum CodingKeys: String, CodingKey {
            case packages
            case availableTerms = "available_terms"
            case consumerDisbursementRequirements = "consumer_disbursement_requirements"
            case description
            case title
            case downPayment = "down_payment"
            case duration
            case maxAprPercent = "max_apr_percent"
            case maxLoanAmount = "max_loan_amount"
            case minAprPercent = "min_apr_percent"
            case minLoanAmount = "min_loan_amount"
            case policyUrl = "policy_url"
            case providerDisbursementRequirements = "provider_disbursement_requirements"
        }
    }
}

public struct Downpayment : Codable {
    public let type: DownPaymentType
    public let amount: DownPaymentAmount
    
    private enum CodingKeys: String, CodingKey {
        case type
        case amount
    }
}

public enum DownPaymentType: String, Codable {
    case inAmount = "IN_AMOUNT"
    case overAmount = "OVER_AMOUNT"
}

public struct DownPaymentAmount : Codable {
    public let type: String?
    public let rate: Float?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case rate
    }
}

public struct AvailableTerms : Codable {
    public let duration: Duration?
    public let fee: AvailableTermsFee?
    public let interest: Float?
}


public struct Duration : Codable {
    public let value: Int64
    public let unit: String
}

public struct AvailableTermsFee : Codable {
    public let type: String
    public let rate: Float?
    public let fixedValue: FiatCurrency?
    
    private enum CodingKeys: String, CodingKey {
        case type
        case rate
        case fixedValue = "fixed_value"
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
    public let currency: CurrencyType
    
    public init(value: String, currency: CurrencyType) {
        self.value = value
        self.currency = currency
    }
}

public enum CurrencyType : String, Codable {
    case vnd = "VND"
    case usd = "USD"
    case jpy = "JPY"
}

public struct Scope: Codable {
    public let id: String?
    public let name: String
    public let displayName: String?
    public let description: String?
    public let price: Double?
    public let isOneTimeCharge: Bool?
    public let unit: String?
    public let claims: [Claim]?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case displayName = "display_name"
        case description
        case price
        case isOneTimeCharge = "is_one_time_charge"
        case unit
        case claims
    }
}

public struct Claim: Codable {
    public let id: String?
    public let scopeId: String?
    public let name: String
    public let displayName: String?
    public let description: String?
    public let valueType: ValueType
    public let isActive: Bool?
    public let minValue: String?
    public let maxValue: String?
    public let value: AnyValue?
    public let input: AnyValue?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case scopeId = "scope_id"
        case name
        case displayName = "display_name"
        case description
        case valueType = "value_type"
        case isActive = "is_active"
        case minValue = "min_value"
        case maxValue = "max_value"
        case value
        case input
    }
}

public enum ValueType: String, Codable {
    case boolean = "BOOLEAN"
    case object = "OBJECT"
    case text = "TEXT"
    case integer = "INTEGER"
    case float = "FLOAT"
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

/// The list of product types
public enum ProductType : String {
    // Insurance
    case insurance = "insurance"
    case healthInsurance = "health-insurance"
    case autoMobileInsurance = "automobile-insurance"
    case homeInsurance = "home-insurance"
    // Finance
//    case consumerFinancing = "consumer-financing"
//    case corporateFinancing = "corporate-financing"
//    case unsecuredLoanFinance = "unsecured-loan"
//    case securedLoanFinance = "secured-loan"
    // Credit card
//    case creditCard = "credit-card"
//    case traditionalCreditCard = "traditional"
//    case cbccCreditCard = "cbcc"
    // BNPL
    case consumerBNPL = "consumer-financing:unsecured-loan:bnpl"
}

public struct BNPLOfferInfo : Codable {
    public let offers: [OfferData]
    
    public let providers: [Organization]
    
    // NOTE: when getting list offer from consumer, credifyId maybe nil if user haven't account from Credify yet. After creating credify account from provider, we will have credifyId and we will assign it.
    public let credifyId: String?
    
    private enum CodingKeys: String, CodingKey {
        case offers
        case providers
        case credifyId = "credify_id"
    }
}

public enum Language : String {
    case vietnamese = "vi"
    case japanese = "ja"
    case english = "en"
}
