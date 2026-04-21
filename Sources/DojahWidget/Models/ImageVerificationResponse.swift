//
//  ImageVerificationResponse.swift
//
//
//  Created by Isaac Iniongun on 30/01/2024.
//

import Foundation

struct ImageVerificationResponse: Codable {
    let person: ImageVerificationValue?
    let id: Business?
    let overall: ImageVerificationValue?
    let business: Business?
    let device, ip, referenceID: String?

    enum CodingKeys: String, CodingKey {
        case person, id, overall, business, device, ip
        case referenceID = "reference_id"
    }
}

struct Business: Codable {
    let rcNo, confidence, names: String?
    let url: String?
    let date: String?
    
    enum CodingKeys: String, CodingKey {
        case rcNo = "rc_no"
        case confidence, names, url, date
    }
}

struct ImageVerificationValue: Codable {
    let url: String?
    let confidenceValue: String?

    enum CodingKeys: String, CodingKey {
        case url
        case confidenceValue = "confidence_value"
    }

    init(url: String?, confidenceValue: String?) {
        self.url = url
        self.confidenceValue = confidenceValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decodeIfPresent(String.self, forKey: .url)

        // Attempt to decode confidence_value as Double, Int, or String, then convert to String
        if let doubleVal = try? container.decode(Double.self, forKey: .confidenceValue) {
            confidenceValue = String(doubleVal)
        } else if let intVal = try? container.decode(Int.self, forKey: .confidenceValue) {
            confidenceValue = String(intVal)
        } else if let stringVal = try? container.decode(String.self, forKey: .confidenceValue) {
            confidenceValue = stringVal
        } else {
            confidenceValue = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(confidenceValue, forKey: .confidenceValue)
    }
}
