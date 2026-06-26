//
//  GovernmentDataLookupResponse.swift
//
//
//  Created by Isaac Iniongun on 12/12/2023.
//

import Foundation

struct GovernmentDataLookupEntity: Codable {
    let customerID, bvn, bvnAdvance, firstName, lastName, middleName: String?
    let gender, dateOfBirth, phoneNumber1, image: String?
    let email, enrollmentBank, enrollmentBranch, levelOfAccount: String?
    let lgaOfOrigin, lgaOfResidence, maritalStatus, nameOnCard: String?
    let nationality, nin, phoneNumber2, registrationDate: String?
    let residentialAddress, stateOfOrigin, stateOfResidence, title: String?
    let watchListed: String?
    let firstname, middlename, surname: String?
    let maidenname, telephoneno, state, place: String?
    let profession, height: String?
    let birthdate, birthstate, birthcountry, centralID: String?
    let documentno, educationallevel, employmentstatus, nokFirstname: String?
    let nokLastname, nokMiddlename, nokAddress1, nokAddress2: String?
    let nokLGA, nokState, nokTown, nokPostalcode: String?
    let othername, pfirstname, photo, pmiddlename: String?
    let psurname, nspokenlang, ospokenlang, religion: String?
    let residenceTown, residenceLGA, residenceState, residencestatus: String?
    let residenceAddressLine1, residenceAddressLine2, selfOriginLGA, selfOriginPlace: String?
    let selfOriginState, signature: String?
    let trackingID: String?
    let msisdn, phoneNumberMiddleName, address: String?
    let addressCity, addressState: String?
    let uuid, licenseNo: String?
    let issuedDate, expiryDate: String?
    let stateOfIssue, birthDate: String?
    let status: Int?
    
    func dataCollectedParam(idEnum: String, countryCode: String) -> String {
        let params: [String?] = [customerID, idEnum, countryCode, firstName ?? firstname, middleName ?? middlename ?? phoneNumberMiddleName, lastName, dateOfBirth]
        // 'customer_id|bvn|NG|firstname|middlename|lastname|dob'
        return params.compactMap { $0 }.joined(separator: "|")
    }

    enum CodingKeys: String, CodingKey {
        case customerID = "customer", bvn, bvnAdvance
        case firstName = "first_name"
        case lastName = "last_name"
        case middleName = "middle_name"
        case gender
        case dateOfBirth = "date_of_birth"
        case phoneNumber1 = "phone_number1"
        case image, email
        case enrollmentBank = "enrollment_bank"
        case enrollmentBranch = "enrollment_branch"
        case levelOfAccount = "level_of_account"
        case lgaOfOrigin = "lga_of_origin"
        case lgaOfResidence = "lga_of_residence"
        case maritalStatus = "marital_status"
        case nameOnCard = "name_on_card"
        case nationality, nin
        case phoneNumber2 = "phone_number2"
        case registrationDate = "registration_date"
        case residentialAddress = "residential_address"
        case stateOfOrigin = "state_of_origin"
        case stateOfResidence = "state_of_residence"
        case title
        case watchListed = "watch_listed"
        case firstname, middlename, surname, maidenname, telephoneno, state, place
        case profession, height, birthdate, birthstate, birthcountry, centralID
        case documentno, educationallevel, employmentstatus
        case nokFirstname = "nok_firstname"
        case nokLastname = "nok_lastname"
        case nokMiddlename = "nok_middlename"
        case nokAddress1 = "nok_address1"
        case nokAddress2 = "nok_address2"
        case nokLGA = "nok_lga"
        case nokState = "nok_state"
        case nokTown = "nok_town"
        case nokPostalcode = "nok_postalcode"
        case othername, pfirstname, photo, pmiddlename, psurname, nspokenlang, ospokenlang, religion
        case residenceTown = "residence_Town"
        case residenceLGA = "residence_lga"
        case residenceState = "residence_state"
        case residencestatus
        case residenceAddressLine1 = "residence_AddressLine1"
        case residenceAddressLine2 = "residence_AddressLine2"
        case selfOriginLGA = "self_origin_lga"
        case selfOriginPlace = "self_origin_place"
        case selfOriginState = "self_origin_state"
        case signature
        case trackingID = "trackingId"
        case addressCity, addressState, address, msisdn
        case phoneNumberMiddleName = "MiddleName"
        case uuid, licenseNo, issuedDate, expiryDate, stateOfIssue, birthDate
        case status
    }
    
    var phoneNumber: String? {
        phoneNumber1 ?? phoneNumber2
    }
}
