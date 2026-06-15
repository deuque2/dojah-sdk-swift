//
//  CustomQuestionsController.swift
//  DojahWidget
//
//  Created by Sunday on 25/05/2026.
//

import UIKit

private final class QuestionHeaderView: UIView {
   private let titleLabel = UILabel()

   init(text: String) {
       super.init(frame: .zero)
       translatesAutoresizingMaskIntoConstraints = false
       titleLabel.translatesAutoresizingMaskIntoConstraints = false
       titleLabel.text = text
       titleLabel.font = .semibold(12)
       titleLabel.textColor = .aLabel
       titleLabel.numberOfLines = 0
       addSubview(titleLabel)
       NSLayoutConstraint.activate([
           titleLabel.topAnchor.constraint(equalTo: topAnchor),
           titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
           titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
           titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
       ])
   }

   required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
 
private protocol QuestionAnswering: AnyObject {
    var onInputChanged: (() -> Void)? { get set }
    var isAnswered: Bool { get }
    func currentAnswer() -> CustomQuestionsResult.AnsweredQuestion.Answer?
}

private final class TextQuestionView: UIView, QuestionAnswering, UITextFieldDelegate {
    private let textField = UITextField()
    private let stack = UIStackView()

    var onInputChanged: (() -> Void)?
    var placeholder: String? { didSet { textField.placeholder = placeholder } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        textField.borderStyle = .none
        textField.backgroundColor = .primaryGrey
        textField.font = .regular(12)
        textField.textColor = .aLabel
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.djBorder.withAlphaComponent(0.45).cgColor
        textField.setPadding(left: 14, right: 14)
        textField.delegate = self
        textField.addTarget(self, action: #selector(onChange), for: .editingChanged)

        stack.addArrangedSubview(textField)
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func onChange() {
        onInputChanged?()
    }

    var isAnswered: Bool { !(textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    func currentAnswer() -> CustomQuestionsResult.AnsweredQuestion.Answer? {
        let v = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !v.isEmpty else { return nil }
        return .text(v)
    }
}

private final class SingleChoiceQuestionView: UIView, QuestionAnswering {
    private let stack = UIStackView()
    private var buttons: [UIButton] = []
    private(set) var selected: String? = nil
    var onInputChanged: (() -> Void)?

    init(options: [String]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        for option in options {
            let button = makeOptionButton(title: option)
            buttons.append(button)
            stack.addArrangedSubview(button)
        }

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.font = .regular(12)
        button.setTitleColor(.aLabel, for: .normal)
        button.setTitleColor(.aLabel, for: .selected)
        button.setTitleColor(.aLabel, for: .highlighted)
        button.setTitleColor(.aLabel, for: [.selected, .highlighted])
        button.setTitleColor(.aLabel, for: .disabled)
        button.backgroundColor = .primaryGrey
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.djBorder.withAlphaComponent(0.45).cgColor
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .selected)
        button.tintColor = .primary
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 8)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
        button.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        return button
    }

    @objc private func onTap(_ sender: UIButton) {
        for b in buttons { b.isSelected = (b === sender) }
        selected = sender.title(for: .normal)
        onInputChanged?()
    }

    var isAnswered: Bool { selected != nil }

    func currentAnswer() -> CustomQuestionsResult.AnsweredQuestion.Answer? {
        guard let s = selected else { return nil }
        return .single(s)
    }
}

private final class MultipleChoiceQuestionView: UIView, QuestionAnswering {
    private let stack = UIStackView()
    private var buttons: [UIButton] = []
    var onInputChanged: (() -> Void)?

    init(options: [String]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        for option in options {
            let button = makeOptionButton(title: option)
            buttons.append(button)
            stack.addArrangedSubview(button)
        }

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func makeOptionButton(title: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.titleLabel?.font = .regular(12)
        button.setTitleColor(.aLabel, for: .normal)
        button.setTitleColor(.aLabel, for: .selected)
        button.setTitleColor(.aLabel, for: .highlighted)
        button.setTitleColor(.aLabel, for: [.selected, .highlighted])
        button.setTitleColor(.aLabel, for: .disabled)
        button.backgroundColor = .primaryGrey
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.djBorder.withAlphaComponent(0.45).cgColor
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = .primary
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 8)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
        button.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        return button
    }

    @objc private func onTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        onInputChanged?()
    }

    var isAnswered: Bool { buttons.contains(where: { $0.isSelected }) }

    func currentAnswer() -> CustomQuestionsResult.AnsweredQuestion.Answer? {
        let selected = buttons.compactMap { $0.isSelected ? $0.title(for: .normal) : nil }
        guard !selected.isEmpty else { return nil }
        return .multiple(selected)
    }
}

final class CustomQuestionsViewController: DJBaseViewController {

    let viewModel: CustomQuestionsViewModel
    let config: CustomQuestionsConfig

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let titleLabel = UILabel()
    private let submitButton = UIButton(type: .system)
    public var onSubmit: ((CustomQuestionsResult) -> Void)?

    private struct Section {
        let question: CustomQuestionsConfig.Question
        let view: UIView & QuestionAnswering
    }
    private var sections: [Section] = []
    private var areAllQuestionSectionsSettled: Bool {
        !sections.isEmpty && sections.allSatisfy { $0.view.isAnswered }
    }

    init(viewModel: CustomQuestionsViewModel = CustomQuestionsViewModel()) {
        self.viewModel = viewModel
        self.config = viewModel.makeConfig()
        super.init(nibName: nil, bundle: nil)
        self.title = config.title
        kviewModel = viewModel
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewProtocol = self
        setupLayout()
        buildSections()
        updateSubmitState()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 24

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = config.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Compliance Questions" : config.title
        titleLabel.font = .medium(13)
        titleLabel.textColor = .aLabel
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Submit", for: .normal)
        submitButton.titleLabel?.font = .semibold(13)
        submitButton.backgroundColor = .primary
        submitButton.tintColor = .white
        submitButton.layer.cornerRadius = 6
        submitButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        submitButton.addTarget(self, action: #selector(onSubmitTap), for: .touchUpInside)

        let bottomContainer = UIView()
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(submitButton)
        view.addSubview(bottomContainer)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            bottomContainer.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: poweredView.topAnchor, constant: -8),

            submitButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 8),
            submitButton.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -8),
            submitButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 48),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func buildSections() {
        contentStack.addArrangedSubview(titleLabel)
        contentStack.setCustomSpacing(28, after: titleLabel)

        let sourceQuestions: [CustomQuestionsConfig.Question] = config.questions
        for q in sourceQuestions {
            let header = QuestionHeaderView(text: q.text)
            let answerView: UIView & QuestionAnswering
            switch q.type {
            case .text:
                let v = TextQuestionView()
                v.placeholder = q.text
                answerView = v
            case .single:
                let v = SingleChoiceQuestionView(options: q.options ?? [])
                answerView = v
            case .multiple:
                let v = MultipleChoiceQuestionView(options: q.options ?? [])
                answerView = v
            }
            answerView.onInputChanged = { [weak self] in
                self?.updateSubmitState()
            }

            let questionStack = UIStackView()
            questionStack.translatesAutoresizingMaskIntoConstraints = false
            questionStack.axis = .vertical
            questionStack.spacing = 8

            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(answerView)
            NSLayoutConstraint.activate([
                answerView.topAnchor.constraint(equalTo: container.topAnchor),
                answerView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                answerView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                answerView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])

            questionStack.addArrangedSubview(header)
            questionStack.addArrangedSubview(container)
            contentStack.addArrangedSubview(questionStack)
            sections.append(.init(question: q, view: answerView))
        }
    }

    private func updateSubmitState() {
        setSubmitButtonEnabled(areAllQuestionSectionsSettled)
    }

    private func setSubmitButtonEnabled(_ enabled: Bool) {
        submitButton.isEnabled = enabled
        submitButton.alpha = enabled ? 1.0 : 0.55
        submitButton.backgroundColor = enabled ? .primary : .djBorder
    }

    @objc private func onSubmitTap() {
        guard areAllQuestionSectionsSettled else {
            setSubmitButtonEnabled(false)
            return
        }

        var answered: [CustomQuestionsResult.AnsweredQuestion] = []
        for s in sections {
            guard let ans = s.view.currentAnswer() else { continue }
            let answeredItem = CustomQuestionsResult.AnsweredQuestion(
                text: s.question.text,
                type: s.question.type,
                options: s.question.options,
                answer: ans
            )
            answered.append(answeredItem)
        }

        viewModel.didTapPrimaryButton(answered: answered)
    }
}

extension CustomQuestionsViewController: CustomQuestionsViewProtocol {
    public func enableSubmitButton(_ enabled: Bool) {
        setSubmitButtonEnabled(enabled && areAllQuestionSectionsSettled)
    }
    public func deliverResult(_ result: CustomQuestionsResult) {
        // Return via closure
        onSubmit?(result)
    }
}

// MARK: - Helpers
private extension UIView {
    func subviewsRecursive<T: UIView>(of type: T.Type) -> [T] {
        var result: [T] = []
        for v in subviews {
            if let t = v as? T { result.append(t) }
            result.append(contentsOf: v.subviewsRecursive(of: type))
        }
        return result
    }
}
