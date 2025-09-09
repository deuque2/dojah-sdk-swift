//
//  GovtIDOptionsViewController.swift
//  
//
//  Created by Isaac Iniongun on 01/02/2024.
//

import UIKit

final public class GovtIDOptionsViewController: DJBaseViewController {
    
    private let viewModel: GovtIDOptionsViewModel
    
    init(viewModel: GovtIDOptionsViewModel = GovtIDOptionsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        kviewModel = viewModel
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var idTypeView = DJPickerView(
        title: "Please select your identification type",
        items: viewModel.identificationTypes.names,
        itemSelectionHandler: { [weak self] _, index in
            self?.continueButton.enable()
            self?.viewModel.didChooseIdentificationType(at: index)
        }
    )
    private lazy var continueButton = DJButton(title: "Continue", isEnabled: false) { [weak self] in
        self?.viewModel.didTapContinue()
    }
    private lazy var contentStackView = VStackView(
        subviews: [idTypeView, continueButton],
        spacing: 40
    )

    override public func viewDidLoad() {
        super.viewDidLoad()
        with(contentStackView) {
            addSubview($0)
            $0.anchor(
                top: navView.bottomAnchor,
                leading: safeAreaLeadingAnchor,
                trailing: safeAreaTrailingAnchor,
                padding: .kinit(topBottom: 40, leftRight: 20)
            )
        }
        let manualGovId = preference.DJExtraUserData?.govId
        if(manualGovId != nil && manualGovId!.isAnyDataAvailable()){
            let govId = manualGovId!.getNgIdType()
            let govIdTypes = viewModel.identificationTypes

            if let index = govIdTypes.firstIndex(where: {
                $0.idType?.rawValue == govId }
            ) {
                idTypeView.selectItem(item: govIdTypes[index].name ?? "", index: index)
                self.viewModel.didChooseIdentificationType(at: index)
                self.viewModel.didTapContinue()
            }
        }
    }

}
