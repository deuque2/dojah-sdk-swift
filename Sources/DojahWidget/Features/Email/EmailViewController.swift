//
//  EmailViewController.swift
//  
//
//  Created by Isaac Iniongun on 02/05/2024.
//

import UIKit

final class EmailViewController: DJBaseViewController {
    
    private let viewModel: EmailViewModel
    
    init(viewModel: EmailViewModel = EmailViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        kviewModel = viewModel
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let emailTextField = DJTextField(
        title: "Email address",
        placeholder: "Email address",
        validationType: .email,
        keyboardType: .emailAddress
    )
    private lazy var continueButton = DJButton(title: "Continue") { [weak self] in
        self?.didTapContinueButton()
    }
    
    private lazy var contentStackView = VStackView(
        subviews: [emailTextField, continueButton],
        spacing: 40
    )
    private lazy var contentScrollView = UIScrollView(children: [contentStackView])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        viewModel.viewProtocol = self
        viewModel.setupPreAuthEmailAddress()
        with(contentScrollView) {
            addSubview($0)
            
            $0.anchor(
                top: navView.bottomAnchor,
                leading: safeAreaLeadingAnchor,
                bottom: poweredView.topAnchor,
                trailing: safeAreaTrailingAnchor,
                padding: .kinit(leftRight: 20)
            )
            
            contentStackView.anchor(
                top: $0.ktopAnchor,
                leading: $0.kleadingAnchor,
                bottom: $0.kbottomAnchor,
                trailing: $0.ktrailingAnchor,
                padding: .kinit(top: 50, bottom: 20)
            )
        }
    }
    
    private func didTapContinueButton() {
        viewModel.didTapContinue(email: emailTextField.text)
    }

}

extension EmailViewController: EmailViewProtocol {
    func prefillEmail(email: String) {
        emailTextField.textField.text = email
        emailTextField.textField.isEnabled = false
    }

    func showVerifyController() {
        showOtpVerification()
    }
    
    func showErrorMessage(_ message: String) {
        navView.showErrorMessage(message)
    }
    
    func hideMessage() {
        navView.hideMessage()
    }
    
    func showEmailError(_ message: String) {
        emailTextField.showError(message)
    }
    
    func hideEmailError() {
        emailTextField.hideError()
    }
}
