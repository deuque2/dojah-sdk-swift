//
//  SignatureViewController.swift
//
//
//  Created by Isaac Iniongun on 13/02/2024.
//

import PencilKit
import UIKit

final class SignatureViewController: DJBaseViewController {

    private let viewModel: SignatureViewModel

    init(viewModel: SignatureViewModel = SignatureViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        kviewModel = viewModel
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let titleLabel = UILabel(
        text: "",
        font: .regular(18),
        color: .aLabel,
        alignment: .center
    )
    private let informationLabel = UILabel(
        text: "",
        font: .regular(16),
        numberOfLines: 0,
        color: .aSecondaryLabel,
        alignment: .left
    )
    private let nameTextField = DJTextField(
        title: "Enter your full name",
        placeholder: "Enter your full name",
        validationType: .name
    )
    private let signaturePromptLabel = UILabel(
        text: "Add your signature and confirm below",
        font: .regular(13),
        color: .aLabel,
        alignment: .left
    )
    private let signatureCanvasView = PKCanvasView()
    private let clearSignatureButton = UIButton(type: .system)
    private lazy var confirmButton = DJButton(
        title: "I sign and confirm",
        height: 48
    ) { [weak self] in
        self?.didTapConfirmButton()
    }
    private lazy var contentStackView = UIStackView(arrangedSubviews: [
        titleLabel,
        informationLabel,
        nameTextField,
        signaturePromptLabel,
        signatureCanvasView,
        clearSignatureButton
    ])
    private let contentScrollView = UIScrollView()

    private var hasSignature: Bool {
        if #available(iOS 14.0, *) {
            return !signatureCanvasView.drawing.strokes.isEmpty
        }
        return !signatureCanvasView.drawing.bounds.isEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindInputs()
        updateConfirmButtonState()
    }

    private func setupUI() {
        titleLabel.text = viewModel.signatureTitle
        informationLabel.text = viewModel.signatureInformation
        informationLabel.setLineHeight(spacing: 4)
        nameTextField.textField.autocapitalizationType = .words

        contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 24

        signatureCanvasView.translatesAutoresizingMaskIntoConstraints = false
        signatureCanvasView.backgroundColor = .primaryGrey
        signatureCanvasView.layer.cornerRadius = 5
        signatureCanvasView.clipsToBounds = true
        signatureCanvasView.delegate = self
        signatureCanvasView.drawingPolicy = .anyInput
        signatureCanvasView.tool = PKInkingTool(.pen, color: .aLabel, width: 3)

        clearSignatureButton.titleLabel?.font = .regular(13)
        clearSignatureButton.setAttributedTitle(
            NSAttributedString(
                string: "Clear Signature",
                attributes: [
                    .font: UIFont.regular(13),
                    .foregroundColor: UIColor.aSecondaryLabel,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            ),
            for: .normal
        )
        clearSignatureButton.addTarget(self, action: #selector(didTapClearSignature), for: .touchUpInside)

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentStackView)
        view.addSubview(confirmButton)

        NSLayoutConstraint.activate([
            contentScrollView.topAnchor.constraint(equalTo: navView.bottomAnchor),
            contentScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            contentScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            contentScrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20),

            contentStackView.topAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.topAnchor, constant: 26),
            contentStackView.leadingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.bottomAnchor, constant: -12),
            contentStackView.widthAnchor.constraint(equalTo: contentScrollView.frameLayoutGuide.widthAnchor),

            signatureCanvasView.heightAnchor.constraint(equalToConstant: 142),

            confirmButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: poweredView.topAnchor, constant: -12)
        ])

        contentStackView.setCustomSpacing(40, after: titleLabel)
        contentStackView.setCustomSpacing(34, after: informationLabel)
        contentStackView.setCustomSpacing(18, after: nameTextField)
        contentStackView.setCustomSpacing(12, after: signaturePromptLabel)
        contentStackView.setCustomSpacing(16, after: signatureCanvasView)
    }

    private func bindInputs() {
        nameTextField.textDidChange = { [weak self] _ in
            self?.updateConfirmButtonState()
        }
    }

    private func updateConfirmButtonState() {
        let isEnabled = nameTextField.text.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty && hasSignature
        confirmButton.enable(isEnabled)
        confirmButton.backgroundColor = isEnabled ? .primary : .djBorder
    }

    @objc private func didTapClearSignature() {
        signatureCanvasView.drawing = PKDrawing()
        updateConfirmButtonState()
    }

    private func didTapConfirmButton() {
        guard nameTextField.isValid, hasSignature, let signatureData = signatureImageData() else {
            updateConfirmButtonState()
            return
        }
        viewModel.didTapPrimaryButton(name: nameTextField.text, signatureData: signatureData)
    }

    private func signatureImageData() -> Data? {
        let bounds = signatureCanvasView.bounds
        guard !bounds.isEmpty else { return nil }
        let image = signatureCanvasView.drawing.image(from: bounds, scale: UIScreen.main.scale)
        return image.pngData()
    }
}

extension SignatureViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        updateConfirmButtonState()
    }
}
