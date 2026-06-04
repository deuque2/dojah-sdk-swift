//
//  DJPageName.swift
//
//
//  Created by Isaac Iniongun on 07/12/2023.
//

import Foundation

enum DJPageName: String, Codable {
    case countries
    case userData = "user-data"
    case phoneNumber = "phone-number"
    case address
    case email
    case governmentData = "government-data"
    case governmentDataVerification = "government-data-verification"
    case businessData = "business-data"
    case selfie
    case id
    case businessID = "business-id"
    case additionalDocument = "additional-document"
    case index
    case idOptions = "id-options"
    case signature
    case customQuestions = "custom-questions"
}
