//
//  DJGovernmentIDType.swift
//
//
//  Created by Isaac Iniongun on 12/12/2023.
//

import Foundation

enum DJGovernmentIDType: String, Codable {
    case bvn = "BVN"
    case nin = "NIN"
    case vnin = "VNIN"
    case dl = "DL"
    case mobile = "MOBILE"
    case dlID = "DL_ID"
    case passportID = "PASSPORT_ID"
    case nationalID = "NATIONAL_ID"
    case residencePermit = "RESIDENCE_PERMIT"
    case customID = "CUSTOM_ID"
    case ngVotersCard = "NG-VCARD"
    case ngNINSlip = "NG-NIN-SLIP"
    case ngPass = "NG-PASS"
    case ngDLI = "NG-DLI"
    case ngNational = "NG-NAT"
    case ghDL = "GH-DL"
    case ghVotersCard = "GH-VOTER"
    case tzNIN = "TZ-NIN"
    case ugID = "UG-ID"
    case ugTELCO = "UG-TELCO"
    case keDL = "KE-DL"
    case keID = "KE-ID"
    case keKRA = "KE-KRA"
    case saDL = "SA-DL"
    case saID = "SA-ID"
    case cacRCNumber = "RC-NUMBER"
    case tin = "TIN"
    case aoNin = "ao-nin"
    case zaId = "za-id"
    case bvnAdvance
    
    var remotePath: DJRemotePath {
        switch self {
        case .bvn:
            return .bvnLookup
        case .bvnAdvance:
            return .bvnAdvanceLookup
        case .nin:
            return .ninLookup
        case .vnin:
            return .vninLookup
        case .mobile:
            return .basicPhoneNumberLookup
        default:
            return .none
        }
    }
    
    var lookupParameterKeyName: String {
        switch self {
        case .bvn, .bvnAdvance:
            return "bvn"
        case .nin:
            return "nin"
        case .vnin:
            return "vnin"
        case .mobile:
            return "phone_number"
        default:
            return ""
        }
    }
    
    var isFrontAndBack: Bool {
        [.dl, .dlID, .nationalID, .ngVotersCard, .ngDLI, .ngNational].contains(self)
    }
    
    var isNGNIN: Bool {
        [.nin, .ngNINSlip, .vnin].contains(self)
    }
}
