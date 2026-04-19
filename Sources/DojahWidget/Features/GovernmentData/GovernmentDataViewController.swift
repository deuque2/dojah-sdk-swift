//
//  GovernmentDataViewController.swift
//
//
//  Created by Isaac Iniongun on 28/10/2023.
//

import UIKit

final class GovernmentDataViewController: DJBaseViewController {
    
    private let viewModel: DJGovernmentDataViewModel
    
    init(viewModel: DJGovernmentDataViewModel = DJGovernmentDataViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        kviewModel = viewModel
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*private let hintIconTextView = PillIconTextView(
        text: "Fill the form as it appears on your valid ID",
        icon: .res(.greenInfoCircle),
        iconSize: 18,
        textColor: .djGreen,
        bgColor: .djLightGreen
    )
    private lazy var hintContainerView = hintIconTextView.withHStackCentering()*/
    private lazy var govtIDView = DJPickerView(
        title: "Government Identification",
        items: viewModel.governmentIDs.names,
        itemSelectionHandler: { [weak self] _, index in
            self?.viewModel.didChooseGovernmentData(at: index, type: .id)
        }
    )
    private let govtIDNumberTextField = DJTextField(title: "Govt. ID Number")
    private lazy var verificationMethodView = DJPickerView(
        title: "Verify with",
        items: viewModel.governmentIDVerificationMethods.names,
        itemSelectionHandler: { [weak self] _, index in
            self?.viewModel.didChooseGovernmentData(at: index, type: .verificationMethod)
        }
    )
    private lazy var continueButton = DJButton(title: "Continue") { [weak self] in
        self?.viewModel.didTapContinue()
    }
    private lazy var contentStackView = VStackView(
        subviews: [govtIDView, govtIDNumberTextField, verificationMethodView, continueButton],
        spacing: 20
    )
    private lazy var contentScrollView = UIScrollView(children: [contentStackView])
    private var govtID: GovtID?
    private var govtIDVerificationMethod: GovtIDVerificationMethod?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        prefillDataIfAvailable()
    }
    
    private func setupUI() {
        viewModel.viewProtocol = self
        
        with(contentScrollView) {
            addSubview($0)
            
            $0.anchor(
                top: navView.bottomAnchor,
                leading: safeAreaLeadingAnchor,
                bottom: poweredView.topAnchor,
                trailing: safeAreaTrailingAnchor,
                padding: .kinit(leftRight: 20)
            )
            
            /*hintContainerView.anchor(
                top: $0.ktopAnchor,
                leading: $0.kleadingAnchor,
                trailing: $0.ktrailingAnchor,
                padding: .kinit(top: 40)
            )*/
            
            contentStackView.anchor(
                top: $0.ktopAnchor,
                leading: $0.kleadingAnchor,
                bottom: $0.kbottomAnchor,
                trailing: $0.ktrailingAnchor,
                padding: .kinit(top: 50, bottom: 20)
            )
            contentStackView.setCustomSpacing(40, after: verificationMethodView)
        }
        
        govtIDNumberTextField.showView(false)
        govtIDNumberTextField.textDidChange = { [weak self] text in
            self?.viewModel.idNumber = text
        }
        
        navView.showSuccessMessage("Fill the form as it appears on your valid ID")
    }
    
    private func prefillDataIfAvailable() {
        
        let manualSelectGovData = preference.DJExtraUserData?.govData
        
        if(manualSelectGovData != nil && manualSelectGovData!.isFilled()){
            let items = viewModel.governmentIDs.names
            let symbols = self.viewModel.governmentIDs.symbols
            
            var idNumber = ""
            
            if(manualSelectGovData?.bvn?.isNotEmpty == true){
                let index = symbols.firstIndex(of: "bvn") ?? 0
                self.govtIDView.selectItem(item: items[index],index:index)
                idNumber = manualSelectGovData?.bvn ?? ""
            }else  if(manualSelectGovData?.dl?.isNotEmpty == true){
                let index = symbols.firstIndex(of: "dl") ?? 0
                self.govtIDView.selectItem(item: items[index],index:index)
                idNumber = manualSelectGovData?.dl ?? ""
            }else  if(manualSelectGovData?.nin?.isNotEmpty == true){
                let index = symbols.firstIndex(of: "nin") ?? 0
                self.govtIDView.selectItem(item: items[index],index:index)
                idNumber = manualSelectGovData?.nin ?? ""
            }else  if(manualSelectGovData?.vnin?.isNotEmpty == true){
                let index = symbols.firstIndex(of: "vnin") ?? 0
                self.govtIDView.selectItem(item: items[index],index:index)
                idNumber = manualSelectGovData?.vnin ?? ""
            }
            
            self.govtIDNumberTextField.text = idNumber
            self.viewModel.idNumber = idNumber
            self.govtIDView.isUserInteractionEnabled = false
            self.govtIDNumberTextField.isUserInteractionEnabled = false
            govtIDNumberTextField.showView(true)
        }else{
            self.govtIDView.isUserInteractionEnabled = true
            self.govtIDNumberTextField.isUserInteractionEnabled = true
            govtIDNumberTextField.showView(false)
        }
    }
    
}

extension GovernmentDataViewController: GovernmentDataViewProtocol {
    func showGovtIDNumberTextField() {
        guard let governmentID = viewModel.selectedGovernmentID else { return }
        with(govtIDNumberTextField) {
            $0.textField.placeholder = governmentID.placeholder
            $0.title = governmentID.name ?? "ID Number"
            $0.textField.keyboardType = governmentID.inputType?.keyboardType ?? .default
            $0.maxLength = governmentID.maxLength?.int
            $0.showView()
        }
    }
    
    func errorAction() {
        kpop()
    }
    
    func updateVerificationMethods() {
        with(verificationMethodView) {
            $0.selectionItems = viewModel.governmentIDVerificationMethods.names
            $0.updateValue("")
        }
    }
    
    func showErrorMessage(_ message: String) {
        navView.showErrorMessage(message)
        /*with(hintIconTextView) {
            $0.text = message
            $0.backgroundColor = .djLightRed
            $0.iconTextView.textColor = .djRed
            $0.iconTextView.icon = .res(.greenInfoCircle).withRenderingMode(.alwaysTemplate)
            $0.iconTextView.icontTint = .djRed
        }*/
    }
    
    func removeErrorMessage() {
        /*with(hintIconTextView) {
            $0.text = "Fill the form as it appears on your valid ID"
            $0.backgroundColor = .djLightGreen
            $0.iconTextView.textColor = .djGreen
            $0.iconTextView.icon = .res(.greenInfoCircle).withRenderingMode(.alwaysTemplate)
            $0.iconTextView.icontTint = .djGreen
        }*/
    }
    
    func hideMessage() {
        navView.showSuccessMessage("Fill the form as it appears on your valid ID")
    }
}
