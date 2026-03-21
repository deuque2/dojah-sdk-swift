//
//  AddressVerificationViewController.swift
//
//
//  Created by Isaac Iniongun on 31/10/2023.
//

import UIKit
import GooglePlaces
import CoreLocation

final class AddressVerificationViewController: DJBaseViewController {

    private let viewModel: AddressVerificationViewModel

    init(viewModel: AddressVerificationViewModel = AddressVerificationViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        kviewModel = viewModel
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let addressTextField = DJTextField(
        title: "Street",
        placeholder: "3-9 Olu Koleosho Street",
        rightIcon: .res("chevronDown")
    )
    
    private let addressLandmardTextField = DJTextField(
        title: "Landmark (Optional)",
        placeholder: "",
    )
    
    private lazy var resultsTableView = UITableView(
        cells: [UITableViewCell.self],
        delegate: self,
        datasource: self,
        scrollable: true
    )
    private lazy var searchResultsView = UIView(
        subviews: [resultsTableView],
        height: 300,
        backgroundColor: .white,
        borderWidth: 1,
        borderColor: .djBorder,
        radius: 5
    )
    
    private lazy var addressStateView = DJPickerView(
        title: "State",
        items: viewModel.states.map { $0.name },
        itemSelectionHandler: { [weak self] _, index in
            self?.selectedStateIndex = index
            self?.viewModel.onStateSelected(index)
            self?.lgaTextField.text = ""
            self?.viewModel.selectedProvince = nil
            self?.lgaResultsView.showView(false)
            self?.validateForm()
        }
    )
    
    private let lgaTextField = DJTextField(
        title: "Local Government Area (LGA)/ Province",
        placeholder: "Select or type LGA/Province",
        rightIcon: .res("chevronDown")
    )
    
    private lazy var lgaTableView = UITableView(
        cells: [UITableViewCell.self],
        delegate: self,
        datasource: self,
        scrollable: true
    )
    
    private lazy var lgaResultsView = UIView(
        subviews: [lgaTableView],
        height: 200,
        backgroundColor: .white,
        borderWidth: 1,
        borderColor: .djBorder,
        radius: 5
    )
    
    private lazy var continueButton = DJButton(title: "Continue", isEnabled: false) { [weak self] in
        self?.viewModel.didTapContinue(lga: self?.lgaTextField.text ?? "", landmark: self?.addressLandmardTextField.text)
    }
    private lazy var contentStackView = VStackView(
        subviews: [addressStateView, lgaTextField, lgaResultsView, addressTextField, searchResultsView, addressLandmardTextField, continueButton],
        spacing: 20
    )
    
    private lazy var contentScrollView = UIScrollView(children: [contentStackView])

    private var isManualAddressLaunched: Bool = false
    private var selectedStateIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewProtocol = self
        setupUI()
        //if manual address is already passed,
        //call the endpoints
        let address = preference.DJExtraUserData?.address
        if(address != nil){
            locationManager.didUpdateLocation = { [weak self] location in
                self?.viewModel.currentLocation = location
                if(self?.isManualAddressLaunched == false){
                    self?.viewModel.sendManualAddress(address:  address!, lga: "", landmark: "")
                    self?.isManualAddressLaunched = true

                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(preference.DJExtraUserData?.location?.isParamSet() != true){
            locationManager.stopUpdatingLocation()
        }
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

        with(searchResultsView) {
            $0.applyShadow(radius: 5)
            $0.showView(false)
        }
        
        with(resultsTableView) {
            $0.fillSuperview(padding: .kinit(topBottom: 10))
            $0.clearBackground()
        }
        
        with(lgaResultsView) {
            $0.applyShadow(radius: 5)
            $0.showView(false)
        }
        
        with(lgaTableView) {
            $0.fillSuperview(padding: .kinit(topBottom: 10))
            $0.clearBackground()
        }

        contentStackView.setCustomSpacing(5, after: addressTextField)
        contentStackView.setCustomSpacing(5, after: lgaTextField)
        contentStackView.setCustomSpacing(40, after: addressLandmardTextField)
        
        // Add tap gesture to dismiss dropdowns when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        if(preference.DJExtraUserData?.location?.isParamSet() != true){
            //if location is not manually passed
            //start updating location
            locationManager.didUpdateLocation = { [weak self] location in
                self?.viewModel.currentLocation = location
            }

            locationManager.startUpdatingLocation()
        }

        addressTextField.textField.addTarget(
            self,
            action: #selector(addressTextfieldDidChange),
            for: .editingChanged
        )
        
        lgaTextField.textField.addTarget(
            self,
            action: #selector(lgaTextfieldDidChange),
            for: .editingChanged
        )
        
        lgaTextField.textField.delegate = self
    }

    @objc private func addressTextfieldDidChange() {
        viewModel.findAddress(addressTextField.text)
    }
    
    @objc private func lgaTextfieldDidChange() {
        viewModel.filterProvinces(lgaTextField.text)
        validateForm()
    }
    
    private func validateForm() {
        let isAddressFilled = !addressTextField.text.isEmpty
        let isStateFilled = selectedStateIndex != nil
        let isLgaFilled = !lgaTextField.text.isEmpty
        
        let isFormValid = isAddressFilled && isStateFilled && isLgaFilled
        continueButton.enable(isFormValid)
    }
    
    @objc private func handleTapOutside(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        
        // Check if tap is outside lgaResultsView
        if !lgaResultsView.isHidden, !lgaResultsView.frame.contains(location), !lgaTextField.frame.contains(location) {
            lgaResultsView.showView(false)
            view.endEditing(true)
        }
        
        // Check if tap is outside searchResultsView
        if !searchResultsView.isHidden, !searchResultsView.frame.contains(location), !addressTextField.frame.contains(location) {
            searchResultsView.showView(false)
            view.endEditing(true)
        }
    }

    private func didChooseGooglePlace(_ place: GMSPlace?) {
        guard let place else {
            showToast(message: "Invalid place selected", type: .error)
            return
        }
        viewModel.selectedPlace = place
        addressTextField.text = place.formattedAddress ?? ""
        continueButton.enable()
    }

    private func didChoosePlacePrediction(_ prediction: GMSAutocompletePrediction) {
        addressTextField.text = prediction.attributedFullText.string
        viewModel.didChoosePlacePrediction(prediction)
        
        searchResultsView.showView(false)
        validateForm()
    }
    
    private func didChooseProvince(_ province: String) {
        lgaTextField.text = province
        viewModel.selectedProvince = province
        lgaResultsView.showView(false)
        validateForm()
    }

}

extension AddressVerificationViewController: AddressVerificationViewProtocol {
    func captureUtilityBill() {
        showUtilityBillCapture()
    }
    
    func showPlacesResults() {
        searchResultsView.showView(viewModel.placePredictions.isNotEmpty)
        resultsTableView.reloadData()
    }
    
    func showProvincesResults() {
        lgaResultsView.showView(viewModel.filteredProvinces.isNotEmpty)
        lgaTableView.reloadData()
    }

    func enableContinueButton(_ enable: Bool) {
        continueButton.enable(enable)
    }

    func showErrorMessage(_ message: String) {
        navView.showErrorMessage(message)
    }

    func hideMessage() {
        navView.hideMessage()
    }
}

extension AddressVerificationViewController: UITableViewConformable {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == lgaTableView {
            return viewModel.filteredProvinces.count
        }
        return viewModel.placePredictions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == lgaTableView {
            let province = viewModel.filteredProvinces[indexPath.row]
            return with(tableView.deque(cell: UITableViewCell.self, at: indexPath)) {
                $0.clearBackground()
                $0.textLabel?.numberOfLines = 0
                $0.textLabel?.text = province
                $0.didTap { [weak self] in
                    self?.didChooseProvince(province)
                }
            }
        }
        
        let prediction = viewModel.placePredictions[indexPath.row]
        return with(tableView.deque(cell: UITableViewCell.self, at: indexPath)) {
            $0.clearBackground()
            $0.textLabel?.numberOfLines = 0
            $0.textLabel?.attributedText = prediction.attributedFullText
            $0.didTap { [weak self] in
                self?.didChoosePlacePrediction(prediction)
                self?.validateForm()
            }
        }
    }
}
extension AddressVerificationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == lgaTextField.textField {
            // Show the dropdown if there are provinces available
            if viewModel.filteredProvinces.isNotEmpty {
                lgaResultsView.showView(true)
                lgaTableView.reloadData()
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == lgaTextField.textField {
            // Hide the dropdown when field loses focus
            lgaResultsView.showView(false)
        }
    }
}

