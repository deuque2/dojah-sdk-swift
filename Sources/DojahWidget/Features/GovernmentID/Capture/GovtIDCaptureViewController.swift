//
//  GovtIDCaptureViewController.swift
//
//
//  Created by Isaac Iniongun on 29/10/2023.
//

import UIKit
import AVFoundation
import MobileCoreServices

final class GovtIDCaptureViewController: DJBaseViewController {
    
    private let viewModel: GovtIDCaptureViewModel
    
    init(viewModel: GovtIDCaptureViewModel = GovtIDCaptureViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        kviewModel = viewModel
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var viewState: GovtIDCaptureViewState { viewModel.viewState }
    private let verificationMethod: GovtIDVerificationMethod = .govtID
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var idImageBlurEffectView: UIVisualEffectView?
    
    private lazy var titleLabel = UILabel(
        text: viewState.title,
        font: .medium(16),
        alignment: .center
    )
    private let uploadHintAttributedText = AttributedStringBuilder()
        .text("Click here to select ", attributes: [.textColor(.primary), .font(.light(14)), .alignment(.center)])
        .text("from ", attributes: [.textColor(.aLabel), .font(.light(14)), .alignment(.center)])
        .newline()
        .text("your device.", attributes: [.textColor(.aLabel), .font(.light(14)), .alignment(.center)])
        .attributedString
    private lazy var uploadHintLabel = UILabel(
        attributedText: uploadHintAttributedText,
        numberOfLines: 0,
        alignment: .center
    )
    private lazy var uploadView = UIView(
        subviews: [uploadHintLabel],
        height: 200,
        backgroundColor: .primaryGrey,
        radius: 5
    )
    private lazy var cameraHintView = PillTextView(
        text: "Loading camera...",
        textColor: .white,
        bgColor: .black
    )
    private lazy var cameraContainerWidth = min((view.width - 100), 400)
    private lazy var cameraViewWidth = cameraContainerWidth - 3
    private lazy var cameraContainerView = UIView(
        subviews: [cameraView, idImageView, cameraHintView],
        height: 300,
        width: cameraContainerWidth,
        radius: 5,
        clipsToBounds: false
    )
    private lazy var cameraView = UIView(
        backgroundColor: .djBorder.withAlphaComponent(0.3),
        radius: 3,
        clipsToBounds: true
    )
    private let idImageView = UIImageView(
        image: .res("driversLicense"),
        contentMode: .scaleAspectFill,
        cornerRadius: 3
    )
    private let disclaimerItemsView = DisclaimerItemsView(items: DJConstants.idCaptureDisclaimerItems)
    private lazy var hintView = PillIconTextView(
        text: "Make sure your \(viewModel.idName) is properly placed before you capture.",
        font: .light(13),
        icon: .res("greenInfoCircle"),
        iconSize: 18,
        textColor: .djGreen,
        bgColor: .djLightGreen,
        cornerRadius: 20
    )
    private lazy var primaryButton = DJButton(title: viewState.primaryButtonTitle) { [weak self] in
        self?.didTapPrimaryButton()
    }
    private lazy var secondaryButton = DJButton(
        title: viewState.secondaryButtonTitle,
        font: .medium(15),
        backgroundColor: .primaryGrey,
        textColor: .aLabel,
        borderWidth: 1,
        borderColor: .djBorder
    ) { [weak self] in
        self?.didTapSecondaryButton()
    }
    private lazy var contentStackView = VStackView(
        subviews: [titleLabel, uploadView, cameraContainerView, hintView, disclaimerItemsView, primaryButton, secondaryButton],
        spacing: 20
    )
    private lazy var contentScrollView = UIScrollView(children: [contentStackView])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewProtocol = self
        setupUI()
        autoUploadGovIdIfAvailable()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        runAfter { [weak self] in
            self?.uploadView.addDashedBorder(
                dashLength: 3,
                dashSpacing: 3,
                lineWidth: 1.5,
                strokeColor: .primary
            )
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
                padding: .kinit(top: 40, bottom: 20)
            )
        }
        
        [uploadView, disclaimerItemsView, idImageView].showViews(false)
        [uploadHintLabel, cameraHintView].centerInSuperview()
        cameraView.fillSuperview(padding: .kinit(allEdges: 3))
        idImageView.fillSuperview(padding: .kinit(allEdges: 3))
        primaryButton.enable(false)
        
        bindAttachmentManager()
        
        runAfter { [weak self] in
            self?.setupCameraView()
        }
    }

    private func autoUploadGovIdIfAvailable() {
        let manualGovId = preference.DJExtraUserData?.govId
        if(manualGovId != nil && manualGovId!.isAnyDataAvailable()){
            if(manualGovId!.others?.isNotEmpty == true){
                //handle other id
            }else{
                DispatchQueue.main.async {
                    let imageUrl = manualGovId!.getFirstData()
                    self.viewModel.downloadImageAndConvertToBase64(from: imageUrl) { base64String in
                        if let base64 = base64String {
                            print("Base64 String generated")
                            self.viewModel.autoUploadGovId(
                                imageBase64: base64, idType: manualGovId!.getNgIdType(), docType: imageUrl.hasSuffix(".pdf") ? "pdf" : "image"
                            )
                        } else {
                            //continue as normal
                        }
                    }
                    
                }
            }
        }
    }
    
    private func bindAttachmentManager() {
        attachmentManager.imagePickedHandler = { [weak self] uiimage, imageURL, sourceType in
            self?.didPickImage(uiimage, at: imageURL, using: sourceType)
        }

        attachmentManager.filePickedHandler = { [weak self] fileURL in
            self?.didPickFile(at: fileURL)
        }
    }

    private func setupCameraView() {
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            kprint("Front camera not available.")
            cameraHintView.text = "Camera loading error."
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: backCamera)

            if captureSession.canAddInput(input) && captureSession.canAddOutput(photoOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(photoOutput)

                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = .resizeAspectFill
                guard let previewLayer else { return }
                [primaryButton, secondaryButton].enable()
                cameraHintView.showView(false)
                cameraView.clearBackground()
                previewLayer.frame = cameraView.layer.bounds
                cameraView.layer.insertSublayer(previewLayer, at: 0)

                startCaptureSession()
            }
        } catch {
            kprint("Error setting up camera input: \(error.localizedDescription)")
        }
    }

    private func startCaptureSession(_ start: Bool = true) {
        cameraHintView.showView(!start)
        runOnBackgroundThread { [weak self] in
            start ? self?.captureSession.startRunning() : self?.captureSession.stopRunning()
        }
    }

    override func addTapGestures() {
        uploadView.didTap { [weak self] in
            guard let self else { return }
            self.attachmentManager.showOptions(
                on: self,
                attachmentTypes: [.photoLibrary, .files],
                docTypes: [String(kUTTypePDF), String(kUTTypePNG), String(kUTTypeJPEG), String(kUTTypeImage)]
            )
        }
    }

    private func didPickImage(
        _ uiimage: UIImage,
        at imageURL: URL?,
        using sourceType: UIImagePickerController.SourceType
    ) {
        guard let imageURL, let imageData = uiimage.pngData() else { return }
        uploadHintLabel.attributedText = AttributedStringBuilder()
            .text(imageURL.lastPathComponent, attributes: [.textColor(.aSecondaryLabel), .font(.regular(16)), .alignment(.center)])
            .attributedString
        viewModel.updateImageData(imageData)
    }

    private func didPickFile(at fileURL: URL) {
        uploadHintLabel.attributedText = AttributedStringBuilder()
            .text(fileURL.lastPathComponent, attributes: [.textColor(.aSecondaryLabel), .font(.regular(16)), .alignment(.center)])
            .attributedString
        viewModel.updateIDData(from: fileURL)
    }

    private func didTapPrimaryButton() {
        switch viewState {
        case .uploadFront, .uploadBack, .uploadCACDocument, .uploadDocument:
            viewModel.didTapContinue()
        case .captureFront, .captureBack, .captureCACDocument, .captureDocument:
            capturePhoto()
        case .previewFront, .previewBack, .previewCACDocument, .previewDocument:
            viewModel.didTapContinue()
        }
    }

    private func didTapSecondaryButton() {
        switch viewState {
        case .uploadFront:
            viewModel.viewState = .captureFront
        case .uploadBack:
            viewModel.viewState = .captureBack
        case .captureFront:
            viewModel.viewState = .uploadFront
        case .captureBack:
            viewModel.viewState = .uploadBack
        case .previewFront:
            viewModel.viewState = .captureFront
        case .previewBack:
            viewModel.viewState = .captureBack
        case .captureCACDocument:
            viewModel.viewState = .uploadCACDocument
        case .uploadCACDocument:
            viewModel.viewState = .captureCACDocument
        case .previewCACDocument:
            viewModel.viewState = .captureCACDocument
        case .captureDocument:
            viewModel.viewState = .uploadDocument
        case .uploadDocument:
            viewModel.viewState = .captureDocument
        case .previewDocument:
            viewModel.viewState = .captureDocument
        }
        updateUI()
    }

    override func showLoader(_ show: Bool) {
        [primaryButton, secondaryButton].enable(!show)
        guard !viewModel.isDocumentUpload else {
            super.showLoader(show)
            return
        }
        with(cameraHintView) {
            $0.showView(show)
            $0.backgroundColor = show ? .systemOrange : .black
            $0.textLabel.text = "Proccessing..."
        }
        if show {
            idImageBlurEffectView = idImageView.applyBlurEffect(alpha: 0.6)
        } else {
            idImageBlurEffectView?.removeFromSuperview()
            idImageBlurEffectView = nil
        }
    }

    private func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .off
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

}

extension GovtIDCaptureViewController: GovtIDCaptureViewProtocol {
    func showIDImageError(message: String) {
        with(cameraHintView) {
            $0.showView()
            $0.backgroundColor = .djRed
            $0.textLabel.text = message
        }
        [primaryButton, secondaryButton].enable()

        runAfter { [weak self] in
            self?.showLoader(false)
        }
    }

    func updateUI() {
        with(viewState) {
            titleLabel.text = $0.title
            primaryButton.title = $0.primaryButtonTitle
            secondaryButton.title = $0.secondaryButtonTitle

            switch $0 {
            case .uploadFront, .uploadCACDocument, .uploadDocument:
                startCaptureSession(false)
                [cameraContainerView, cameraView, cameraHintView, hintView, idImageView, disclaimerItemsView].showViews(false)
                uploadView.showView()
            case .uploadBack:
                uploadHintLabel.attributedText = uploadHintAttributedText
            case .captureFront, .captureBack, .captureCACDocument, .captureDocument:
                [cameraView, cameraHintView, hintView, cameraContainerView].showViews()
                [idImageView, disclaimerItemsView, uploadView].showViews(false)
                startCaptureSession()
            case .previewFront, .previewBack, .previewCACDocument, .previewDocument:
                startCaptureSession(false)
                [cameraView, cameraHintView, hintView].showViews(false)
                [idImageView, disclaimerItemsView].showViews()
            }
        }
    }

    func showErrorMessage(_ message: String) {
        navView.showErrorMessage(message)
    }

    func hideMessage() {
        navView.hideMessage()
    }
}

extension GovtIDCaptureViewController: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let uiImage = UIImage(data: imageData) {
            viewModel.updateImageData(imageData)
            didCaptureImage(uiImage)
        } else {
            kprint("Error capturing photo: \(error?.localizedDescription ?? "Unknown error")")
            showToast(message: "Error taking photo, please try again", type: .error)
        }
    }

    private func didCaptureImage(_ uiImage: UIImage) {
        runOnMainThread { [weak self] in
            self?.viewModel.updateViewState()
            self?.idImageView.image = uiImage
        }
    }
}
