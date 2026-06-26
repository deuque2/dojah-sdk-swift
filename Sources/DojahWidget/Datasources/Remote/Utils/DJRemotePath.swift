//
//  DJRemotePath.swift
//
//
//  Created by Isaac Iniongun on 02/12/2023.
//

import Foundation

enum DJRemotePath {
    case none
    case preAuth
    case auth
    case ipCheck
    case saveIP
    case events
    case ninLookup
    case bvnLookup
    case bvnAdvanceLookup
    case vninLookup
    case basicPhoneNumberLookup
    case advancedPhoneNumberLookup
    case driversLicenseLookup
    case requestOTP
    case validateOTP
    case userData
    case imageAnalysis
    case imageCheck
    case verifyImage
    case files
    case baseAddress
    case address
    case decision
    case cac
    case tin
    case metadata
    
    var path: String {
        switch self {
        case .none:
            return ""
        case .preAuth:
            return "widget/pre-auth"
        case .auth:
            return "widget/auth"
        case .ipCheck:
            return "api/v1/ip"
        case .saveIP:
            return "widget/kyc/checks"
        case .events:
            return "widget/kyc/events"
        case .ninLookup:
            return "widget/kyc/nin"
        case .bvnLookup:
            return "widget/kyc/bvn"
        case .bvnAdvanceLookup:
            return "widget/kyc/bvn/advance"
        case .vninLookup:
            return "widget/kyc/vnin"
        case .basicPhoneNumberLookup:
            return "widget/kyc/mobile/basic"
        case .advancedPhoneNumberLookup:
            return "widget/kyc/mobile/advance"
        case .driversLicenseLookup:
            return "widget/kyc/dl"
        case .requestOTP:
            return "widget/sms/otp"
        case .validateOTP:
            return "widget/sms/otp/validate"
        case .userData:
            return "widget/kyc/user-data"
        case .imageAnalysis:
            return "widget/kyc/image/analysis"
        case .imageCheck:
            return "widget/kyc/image/check"
        case .verifyImage:
            return "widget/kyc/image/verify"
        case .files:
            return "widget/kyc/files"
        case .baseAddress:
            return "widget/kyc/base-address"
        case .address:
            return "widget/kyc/address"
        case .decision:
            return "widget/decision"
        case .cac:
            return "widget/kyc/cac"
        case .tin:
            return "widget/kyc/tin"
        case .metadata:
            return "widget/kyc/metadata"
            
        }
    }
    
    var absolutePath: String {
        //"https://api-dev.dojah.services/\(path)" //Dev
        "https://api.dojah.io/\(path)" //Prod
    }
}

import Foundation
