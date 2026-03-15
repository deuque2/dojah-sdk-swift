//
//  DJIPAddressResponse.swift
//
//
//  Created by Isaac Iniongun on 07/12/2023.
//

import Foundation

struct DJIPAddressResponse: Codable {
    let entity: DJIPAddressEntity?
}

struct DJIPAddressEntity: Codable {
    let lon: Double?
    let zip: String?
    let mobile, hosting: Bool?
    let entityAs: String?
    let isp, query: String?
    let proxy: Bool?
    let lat: Double?
    let city, district, timezone, org: String?
    let country, countryCode, status, regionName: String?
    let region: String?
    let continent, continentCode: String?
    let offset: Int?
    let currency: String?
    let reverse: String?
    let asname: String?

    enum CodingKeys: String, CodingKey {
        case lon, zip, mobile, hosting
        case entityAs = "as"
        case isp, query, proxy, lat, city, district, timezone, org, country, countryCode, status, regionName
        case region, continent, continentCode, offset, currency, reverse, asname
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        lon = try container.decodeIfPresent(Double.self, forKey: .lon)
        zip = try container.decodeIfPresent(String.self, forKey: .zip)
        mobile = try container.decodeIfPresent(Bool.self, forKey: .mobile)
        hosting = try container.decodeIfPresent(Bool.self, forKey: .hosting)

        // Decode "as" as either Int or String, store as String
        if let asInt = try? container.decode(Int.self, forKey: .entityAs) {
            entityAs = String(asInt)
        } else {
            entityAs = try container.decodeIfPresent(String.self, forKey: .entityAs)
        }

        isp = try container.decodeIfPresent(String.self, forKey: .isp)
        query = try container.decodeIfPresent(String.self, forKey: .query)
        proxy = try container.decodeIfPresent(Bool.self, forKey: .proxy)
        lat = try container.decodeIfPresent(Double.self, forKey: .lat)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        district = try container.decodeIfPresent(String.self, forKey: .district)
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        org = try container.decodeIfPresent(String.self, forKey: .org)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        regionName = try container.decodeIfPresent(String.self, forKey: .regionName)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        continent = try container.decodeIfPresent(String.self, forKey: .continent)
        continentCode = try container.decodeIfPresent(String.self, forKey: .continentCode)
        offset = try container.decodeIfPresent(Int.self, forKey: .offset)
        currency = try container.decodeIfPresent(String.self, forKey: .currency)
        reverse = try container.decodeIfPresent(String.self, forKey: .reverse)
        asname = try container.decodeIfPresent(String.self, forKey: .asname)
    }
}
