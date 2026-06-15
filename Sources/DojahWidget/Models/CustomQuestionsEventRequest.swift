//
//  CustomQuestionsEventRequest.swift
//  DojahWidget
//
//  Created by Sunday on 06/06/2026.
//

struct DJCustomQuestionEventRequest: Codable {
    let name: String
    let value: [CustomQuestionsResult.AnsweredQuestion]
    var services: [String]
    
    init(name: String = "questions", value: [CustomQuestionsResult.AnsweredQuestion], services: [String] = []) {
        self.name = name
        self.value = value
        self.services = services
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "event_type"
        case value = "event_value"
        case services
    }
}
