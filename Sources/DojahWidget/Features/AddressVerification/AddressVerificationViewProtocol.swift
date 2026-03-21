//
//  AddressVerificationViewProtocol.swift
//
//
//  Created by Isaac Iniongun on 13/03/2024.
//

import Foundation
import GooglePlaces

protocol AddressVerificationViewProtocol: BaseViewProtocol {
    func showPlacesResults()
    func showProvincesResults()
    func enableContinueButton(_ enable: Bool)
    func captureUtilityBill()
}
