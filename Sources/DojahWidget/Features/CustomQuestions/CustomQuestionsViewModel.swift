import Foundation

 protocol CustomQuestionsViewProtocol: AnyObject {
    func enableSubmitButton(_ enabled: Bool)
    func deliverResult(_ result: CustomQuestionsResult)
}

struct CustomQuestionsConfig: Codable, Equatable {
   public let questions: [Question]
   public let title: String
    
    public struct Question: Codable, Equatable {
        public let text: String
        public let type: QuestionType
        public let options: [String]?

        public init(text: String, type: QuestionType, options: [String]? = nil) {
            self.text = text
            self.type = type
            self.options = options
        }
    }

    public enum QuestionType: String, Codable, Equatable {
        case text
        case single
        case multiple
    }
}

final class CustomQuestionsViewModel: BaseViewModel {

    public weak var viewProtocol: CustomQuestionsViewProtocol?

    // Simplified config: only title and questions
    private(set) var questionsConfig: CustomQuestionsConfig = CustomQuestionsConfig(questions: [], title: "")

    // Local cache to support mapping and UI binding
    private var localQuestions: [CustomQuestionsConfig.Question] = []
    private var localTitle: String = ""

    init() {
        super.init()
        loadFromPreference()
    }

    private func loadFromPreference() {
        
        // First, try to find the config from the current auth step when it's customQuestions.
        if let config = findCustomQuestionsConfig() {
            if let cfg = config as? [String: Any] {
                let title = cfg["title"] as? String ?? ""
                let questionsArray = cfg["questions"] as? [[String: Any]] ?? []
                let questions: [CustomQuestionsConfig.Question] = questionsArray.compactMap { item in
                    guard let text = item["text"] as? String,
                          let typeRaw = item["type"] as? String,
                          let type = CustomQuestionsConfig.QuestionType(rawValue: typeRaw) else { return nil }
                    let options = item["options"] as? [String]
                    return CustomQuestionsConfig.Question(text: text, type: type, options: options)
                }
                let built = CustomQuestionsConfig(questions: questions, title: title)
                self.questionsConfig = built
                self.localQuestions = questions
                self.localTitle = title
            }
            return
        }
        // Fallback to previously stored config
        self.localQuestions = questionsConfig.questions
        self.localTitle = questionsConfig.title
    }

    public func updateSubmitAvailability(allAnswered: Bool) {
        viewProtocol?.enableSubmitButton(allAnswered)
    }

    public func submit(answered: [CustomQuestionsResult.AnsweredQuestion]) {
        let result = CustomQuestionsResult(event_type: "questions", event_value: answered)
        // Notify view
        viewProtocol?.deliverResult(result)
        // Broadcast for any coordinator/router to consume
        NotificationCenter.default.post(name: .djCustomQuestionsSubmitted, object: result)
        // Proceed to next step if available
        setNextAuthStep()
    }

    // Attempts to find the custom questions config from the current auth step.
    // Returns nil if not found or if the API doesn't expose it yet.
    private func findCustomQuestionsConfig() -> Any? {
        guard preference.DJAuthStep.name == .customQuestions else { return nil }
        return preference.DJAuthStep.config
    }

    func makeConfig() -> CustomQuestionsConfig {
        // Map from local question cache to CustomQuestionsConfig.Question
        let mapped: [CustomQuestionsConfig.Question] = self.localQuestions.map { q in
            let type: CustomQuestionsConfig.QuestionType
            switch q.type {
            case .text: type = .text
            case .single: type = .single
            case .multiple: type = .multiple
            }
            return CustomQuestionsConfig.Question(text: q.text, type: type, options: q.options)
        }
        return CustomQuestionsConfig(questions: mapped, title: self.localTitle)
    }
}

