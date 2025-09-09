//
//  EmailViewProtocol.swift
//
//
//  Created by Isaac Iniongun on 02/05/2024.
//

import Foundation

protocol EmailViewProtocol: BaseViewProtocol {
    func showEmailError(_ message: String)
    func hideEmailError()
    func showVerifyController()
    func prefillEmail(email: String)
}
