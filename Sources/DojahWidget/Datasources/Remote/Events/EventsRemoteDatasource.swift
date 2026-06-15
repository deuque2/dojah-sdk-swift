//
//  EventsRemoteDatasource.swift
//
//
//  Created by Isaac Iniongun on 07/12/2023.
//

import Foundation

struct EventsRemoteDatasource: EventsRemoteDatasourceProtocol {
    
    private let service: NetworkServiceProtocol
    
    init(service: NetworkServiceProtocol = NetworkService()) {
        self.service = service
    }
    
    func postEvent(request: DJEventRequest, completion: @escaping DJResultAction<SuccessEntityResponse>) {
        service.makeRequest(
            responseType: SuccessEntityResponse.self,
            requestMethod: .post,
            remotePath: .events,
            parameters: request.dictionary,
            headers: nil,
            completion: completion
        )
    }
    
    func postCustomQuestionsEvent(
        request: DJCustomQuestionEventRequest,
        completion: @escaping DJResultAction<SuccessEntityResponse>) {
        service.makeRequest(
            responseType: SuccessEntityResponse.self,
            requestMethod: .post,
            remotePath: .events,
            parameters: request.dictionary,
            headers: nil,
            completion: completion
        )
    }
    
    func postEmailCollectedEvent(
        request: DJEventRequest,
        completion: @escaping DJResultAction<EntityResponse<EmailCollectedEventResponse>>
    ) {
        service.makeRequest(
            responseType: EntityResponse<EmailCollectedEventResponse>.self,
            requestMethod: .post,
            remotePath: .events,
            parameters: request.dictionary,
            headers: nil,
            completion: completion
        )
    }
}
