//
//  BusinessDataViewProtocol.swift
//
//
//  Created by Isaac Iniongun on 13/02/2024.
//

import Foundation

protocol BusinessDataViewProtocol: BaseViewProtocol {
    func updateNumberTextfield()
    func showOrHideBusinessNameView(isHidden: Bool)
    func showOrhideCompanyTypeView(isHidden: Bool)
}
