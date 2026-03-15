import Foundation

enum CompanyType: CaseIterable {
    case businessName
    case incorporatedTrustees
    case limitedPartnership
    case limitedLiabilityPartnership

    var serverKey: String {
        switch self {
        case .businessName: return "BUSINESS_NAME"
        case .incorporatedTrustees: return "INCORPORATED_TRUSTEES"
        case .limitedPartnership: return "LIMITED_PARTNERSHIP"
        case .limitedLiabilityPartnership: return "LIMITED_LIABILITY_PARTNERSHIP"
        }
    }

    var title: String {
        switch self {
        case .businessName: return "Business Name"
        case .incorporatedTrustees: return "Incorporated Trustees"
        case .limitedPartnership: return "Limited Partnership"
        case .limitedLiabilityPartnership: return "Limited Liability Partnership"
        }
    }

    static var titles: [String] {
        return CompanyType.allCases.map { $0.title }
    }
}
