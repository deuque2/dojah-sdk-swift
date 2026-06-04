//
//  CustomQuestionsController.swift
//  DojahWidget
//
//  Created by Sunday on 25/05/2026.
//

import UIKit

// MARK: - Notifications
private extension Notification.Name {
    static let customQuestionsInputChanged = Notification.Name("CustomQuestionsInputChangedNotification")
}

 extension Notification.Name {
    static let djCustomQuestionsSubmitted = Notification.Name("DJCustomQuestionsSubmitted")
}

 struct CustomQuestionsResult: Codable, Equatable {
    public let event_type: String
    public let event_value: [AnsweredQuestion]

     struct AnsweredQuestion: Codable, Equatable {
         let text: String
         let type: CustomQuestionsConfig.QuestionType
         let options: [String]?
         let answer: Answer

         init(text: String, type: CustomQuestionsConfig.QuestionType, options: [String]?, answer: Answer) {
            self.text = text
            self.type = type
            self.options = options
            self.answer = answer
        }

        enum CodingKeys: String, CodingKey {
            case text
            case type
            case options
            case answer
        }

         init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.text = try container.decode(String.self, forKey: .text)
            self.type = try container.decode(CustomQuestionsConfig.QuestionType.self, forKey: .type)
            self.options = try container.decodeIfPresent([String].self, forKey: .options)
            self.answer = try container.decode(Answer.self, forKey: .answer)
        }

         func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(text, forKey: .text)
            try container.encode(type, forKey: .type)
            try container.encodeIfPresent(options, forKey: .options)
            try container.encode(answer, forKey: .answer)
        }

         enum Answer: Codable, Equatable {
            case text(String)
            case single(String)
            case multiple([String])

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let str = try? container.decode(String.self) {
                    self = .text(str)
                } else if let arr = try? container.decode([String].self) {
                    self = .multiple(arr)
                } else {
                    throw DecodingError.typeMismatch(Answer.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported answer type"))
                }
            }

             func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .text(let s):
                    try container.encode(s)
                case .single(let s):
                    try container.encode(s)
                case .multiple(let arr):
                    try container.encode(arr)
                }
            }

             static func == (lhs: Answer, rhs: Answer) -> Bool {
                switch (lhs, rhs) {
                case let (.text(a), .text(b)): return a == b
                case let (.single(a), .single(b)): return a == b
                case let (.multiple(a), .multiple(b)): return a == b
                default: return false
                }
            }
        }
    }
}

private final class QuestionHeaderView: UIView {
    private let titleLabel = UILabel()

    init(text: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = text
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
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

private protocol QuestionAnswering: UIView {
    var isAnswered: Bool { get }
    func currentAnswer() -> CustomQuestionsResult.AnsweredQuestion.Answer?
}

private final class TextQuestionView: UIView, QuestionAnswering, UITextFieldDelegate {
    private let textField = UITextField()
    private let stack = UIStackView()

    var placeholder: String? { didSet { textField.placeholder = placeholder } }

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.addTarget(self, action: #selector(onChange), for: .editingChanged)

        stack.addArrangedSubview(textField)
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func onChange() {
        NotificationCenter.default.post(name: .customQuestionsInputChanged, object: self)
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
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "largecircle.fill.circle"), for: .selected)
        button.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        return button
    }

    @objc private func onTap(_ sender: UIButton) {
        for b in buttons { b.isSelected = (b === sender) }
        selected = sender.title(for: .normal)
        NotificationCenter.default.post(name: .customQuestionsInputChanged, object: self)
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
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.contentHorizontalAlignment = .leading
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        button.tintColor = .systemBlue
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        button.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        return button
    }

    @objc private func onTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        NotificationCenter.default.post(name: .customQuestionsInputChanged, object: self)
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
    private let submitButton = UIButton(type: .system)
    public var onSubmit: ((CustomQuestionsResult) -> Void)?

    private struct Section {
        let question: CustomQuestionsConfig.Question
        let view: QuestionAnswering
    }
    private var sections: [Section] = []

    init(viewModel: CustomQuestionsViewModel = CustomQuestionsViewModel()) {
        self.viewModel = viewModel
        self.config = viewModel.makeConfig()
        super.init(nibName: nil, bundle: nil)
        self.title = config.title
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewProtocol = self
        setupLayout()
        buildSections()
        NotificationCenter.default.addObserver(self, selector: #selector(onAnyInputChanged), name: .customQuestionsInputChanged, object: nil)
        updateSubmitState()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .customQuestionsInputChanged, object: nil)
    }

    private func setupLayout() {
        // Added navView to view hierarchy and anchored it at the top like DJDisclaimerViewController
        view.addSubview(navView)
        navView.delegate = self
        navView.anchor(
            top: safeAreaTopAnchor,
            leading: safeAreaLeadingAnchor,
            trailing: safeAreaTrailingAnchor,
            padding: .init(top: 10, left: 5, bottom: 0, right: 16)
        )
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Continue", for: .normal)
        submitButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        submitButton.backgroundColor = .systemBlue
        submitButton.tintColor = .white
        submitButton.layer.cornerRadius = 10
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

            submitButton.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            submitButton.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 8),
            submitButton.bottomAnchor.constraint(equalTo: bottomContainer.bottomAnchor, constant: -8),
            submitButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func buildSections() {
        let sourceQuestions: [CustomQuestionsConfig.Question] = config.questions
        for q in sourceQuestions {
            let header = QuestionHeaderView(text: q.text)
            contentStack.addArrangedSubview(header)
            let answerView: QuestionAnswering
            switch q.type {
            case .text:
                let v = TextQuestionView()
                v.placeholder = "Enter answer"
                answerView = v
            case .single:
                let v = SingleChoiceQuestionView(options: q.options ?? [])
                answerView = v
            case .multiple:
                let v = MultipleChoiceQuestionView(options: q.options ?? [])
                answerView = v
            }

            let container = UIView()
            container.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(answerView)
            NSLayoutConstraint.activate([
                answerView.topAnchor.constraint(equalTo: container.topAnchor),
                answerView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                answerView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                answerView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])

            contentStack.addArrangedSubview(container)
            sections.append(.init(question: q, view: answerView))
        }
    }

    @objc private func onAnyInputChanged() {
        updateSubmitState()
    }

    private func updateSubmitState() {
        let allAnswered = sections.allSatisfy { $0.view.isAnswered }
        submitButton.isEnabled = allAnswered
        submitButton.alpha = allAnswered ? 1.0 : 0.5
    }

    @objc private func onSubmitTap() {
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

        let result = CustomQuestionsResult(event_type: "questions", event_value: answered)

        // Return via closure
        onSubmit?(result)

        // Broadcast for any coordinator/router to consume
        NotificationCenter.default.post(name: .djCustomQuestionsSubmitted, object: result)

        // Proceed to next step if available
        kviewModel?.setNextAuthStep()
    }
}

extension CustomQuestionsViewController: CustomQuestionsViewProtocol {
    public func enableSubmitButton(_ enabled: Bool) {
        submitButton.isEnabled = enabled
        submitButton.alpha = enabled ? 1.0 : 0.5
    }
    public func deliverResult(_ result: CustomQuestionsResult) {
        // Return via closure
        onSubmit?(result)
        // Broadcast
        NotificationCenter.default.post(name: .djCustomQuestionsSubmitted, object: result)
        // Proceed
        kviewModel?.setNextAuthStep()
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

