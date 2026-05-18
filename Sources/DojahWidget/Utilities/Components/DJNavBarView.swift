//
//  DJNavBarView.swift
//
//
//  Created by Isaac Iniongun on 27/10/2023.
//

import UIKit

protocol DJNavBarViewDelegate: AnyObject {
    func didTapBack()
    func didDismiss()
}

final class DJNavBarView: BaseView {
    weak var delegate: DJNavBarViewDelegate?
    private let backImageView = UIImageView(image: .res("backTextIcon"), height: 24, width: 64)
    private let closeImageView = UIImageView(image: .res("xmarkFilledIcon"), size: 18)
    private let appImageView = UIImageView(image: .res("circleIcon"), contentMode: .scaleAspectFit)
    let hintIconTextView = PillIconTextView(
        text: "Fill the form as it appears on your valid ID",
        icon: .res("greenInfoCircle"),
        iconSize: 18,
        textColor: .djGreen,
        bgColor: .djLightGreen
    )
    private lazy var hintContainerView = hintIconTextView.withHStackCentering()
    private lazy var hintParentView = VStackView(subviews: [hintContainerView, UIView.vspacer(1)])

    override func setup() {
        addSubviews(backImageView, closeImageView, appImageView, hintParentView)
        with(appImageView) {
            $0.centerXInSuperview()
            $0.anchor(top: topAnchor)
            backImageView.centerVertically(to: $0.centerYAnchor)
            backImageView.anchor(leading: leadingAnchor)
            closeImageView.centerVertically(to: $0.centerYAnchor)
            closeImageView.anchor(trailing: trailingAnchor)
            hintParentView.anchor(
                top: $0.bottomAnchor,
                leading: leadingAnchor,
                bottom: bottomAnchor,
                trailing: trailingAnchor,
                padding: .kinit(top: 30, left: 10, right: 10)
            )
        }

        addTapGestures()
        setAppImage()
        hintContainerView.showView(false)
    }

    private func addTapGestures() {
        backImageView.didTap { [weak self] in
            self?.delegate?.didTapBack()
        }

        closeImageView.didTap { [weak self] in
            self?.delegate?.didDismiss()
        }
    }

    func showNavControls(_ show: Bool) {
        backImageView.showView(show)
        closeImageView.showView(show)
    }

    func showNavBackControl(_ show: Bool) {
        backImageView.showView(show)
    }

    func showNavCloseControl(_ show: Bool) {
        closeImageView.showView(show)
    }

    private func setAppImage() {
        if let appLogoURL = preference.DJAppConfig?.logo {
            appImageView.setImageFromURL(appLogoURL)
            appImageView.contentMode = .scaleAspectFit
        }
    }

    func showErrorMessage(_ message: String) {

            hintIconTextView.text = message
            hintIconTextView.backgroundColor = .djLightRed
            hintIconTextView.iconTextView.textColor = .djRed
            hintIconTextView.iconTextView.icon = .res("greenInfoCircle").withRenderingMode(.alwaysTemplate)
            hintIconTextView.iconTextView.icontTint = .djRed

        hintContainerView.showView()
    }

    func showSuccessMessage(_ message: String) {

            hintIconTextView.text = message
            hintIconTextView.backgroundColor = .djLightGreen
            hintIconTextView.iconTextView.textColor = .djGreen
            hintIconTextView.iconTextView.icon = .res("greenInfoCircle").withRenderingMode(.alwaysTemplate)
            hintIconTextView.iconTextView.icontTint = .djGreen

        hintContainerView.showView()
    }

    func hideMessage() {
        hintContainerView.showView(false)
    }

}
