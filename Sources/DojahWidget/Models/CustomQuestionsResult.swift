//
//  CustomQuestionsResult.swift
//  DojahWidget
//
//  Created by Sunday on 07/06/2026.
//

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
