//
//  BusinessIDViewController.swift
//  
//
//  Created by Isaac Iniongun on 31/10/2023.
//

import UIKit

final class BusinessDataViewController: DJBaseViewController {
    
    private let viewModel: BusinessDataViewModel
    
    init(viewModel: BusinessDataViewModel = BusinessDataViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        kviewModel = viewModel
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var documentTypeView = DJPickerView(
        title: "Document Type",
        items: viewModel.documentTypes.names,
        itemSelectionHandler: { [weak self] _, index in
            self?.continueButton.enable()
            self?.viewModel.didChooseDocumentType(at: index)
        }
    )
    
    private let documentNumberTextField = DJTextField(
        title: "Document Number",
        validationType: .alphaNumeric
    )
    
    private lazy var companyTypeVIew = DJPickerView(
        title: "Company Type",
        items: CompanyType.titles,
        itemSelectionHandler: { [weak self] _, index in
            self?.continueButton.enable()
            self?.viewModel.didChooseCompanyType(at: index)
        }
    )
    
    private let businessNameTextField = DJTextField(
        title: "Business Name",
        placeholder: "Business name",
        validationType: .name
    )
    
    private lazy var continueButton = DJButton(title: "Continue", isEnabled: false) { [weak self] in
        self?.didTapContinueButton()
    }
    private lazy var contentStackView = VStackView(
        subviews: [documentTypeView, documentNumberTextField, businessNameTextField, companyTypeVIew, continueButton],
        spacing: 24
    )
    private lazy var contentScrollView = UIScrollView(children: [contentStackView])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        prefillDataIfAvailable()
    }
    
    
    private func setupUI() {
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
        
        [documentNumberTextField, businessNameTextField, companyTypeVIew].showViews(false)
        
        viewModel.viewProtocol = self
        
    }
    
    private func prefillDataIfAvailable() {
        let manualSelectBizData = preference.DJExtraUserData?.businessData
        
        if(manualSelectBizData != nil && manualSelectBizData!.isFilled()){
            let items = viewModel.documentTypes.names
            let symbols = self.viewModel.documentTypes.symbols
            
            if(manualSelectBizData?.cac?.isNotEmpty == true){
                let index = symbols.firstIndex(of: "cac") ?? 0
                self.documentTypeView.selectItem(item: items[index],index:index)
                self.documentNumberTextField.text = manualSelectBizData?.cac ?? ""
            }
            
            self.documentTypeView.isUserInteractionEnabled = false
            self.documentNumberTextField.isUserInteractionEnabled = false
            documentNumberTextField.showView(true)
        } else{
            self.documentTypeView.isUserInteractionEnabled = true
            self.documentNumberTextField.isUserInteractionEnabled = true
            documentNumberTextField.showView(false)
        }
    }
    
    private func didTapContinueButton() {
        if [documentNumberTextField].areValid {
            viewModel.verifyBusiness(
                name: businessNameTextField.text,
                number: documentNumberTextField.text
            )
        }
    }
    
}

extension BusinessDataViewController: BusinessDataViewProtocol {
    func showOrHideBusinessNameView(isHidden: Bool) {
        businessNameTextField.showView(!isHidden)
    }
    
    func showOrhideCompanyTypeView(isHidden: Bool) {
        companyTypeVIew.showView(!isHidden)
    }
    
    func updateNumberTextfield() {
        guard let selectedDocument = viewModel.selectedDocument else { return }
        continueButton.enable()
        documentTypeView.updateValue(selectedDocument.name.orEmpty)
        with(documentNumberTextField) {
            $0.textField.placeholder = selectedDocument.placeholder.orEmpty
            $0.title = selectedDocument.idEnum.orEmpty
            $0.showView()
        }
        companyTypeVIew.showView()
    }
    
    func showErrorMessage(_ message: String) {
        navView.showErrorMessage(message)
    }
    
    func hideMessage() {
        navView.hideMessage()
    }
}
