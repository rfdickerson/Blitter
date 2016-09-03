//
//  Blitter
//
//  Created by David Ungar on 9/2/16.
//
//

import Kitura
import Kassandra
import Foundation
import SwiftyJSON
import CredentialsFacebook
import LoggerAPI
import FunctionalProgramming

public struct FnBlitterController {
    let kassandra = Kassandra() 
    public let router = Router()
    
    public init() {
        router.all("/*", middleware: BodyParser())
        router.get("/",         handler: cvt( getMyFeed ) )
        router.get("/:user",    handler: cvt( getUserFeed ) )
        router.post("/",        handler: cvt( bleet ) )
        router.put("/:user",    handler: cvt( followAuthor ) )
    }
}

private func cvt(_ functionalHandler: @escaping FnRouterHandler ) -> RouterHandler {
    return {
        request, response, next in
        
        functionalHandler(request)
            .finally {
                switch $0 {
                case .error(let error):
                    response.error = error
                    next()
                case .status(let status):
                    response.status(status)
                    next()
                case .json(let json):
                    ResultOrError( catching: { try response.status(.OK).send(json: json).end() } )
                        .ifFailure { response.error = $0 }
                }
        }
    }
}


extension FnBlitterController: FnBlitterProtocol {

    public func bleet(request: RouterRequest) -> FutureRouterResponse {
        let userID = authenticate(request: request, defaultUser: "Robert")
        
        let jsonResult = request.json
        guard let json = jsonResult else {
            return Future(outcome: .status(.badRequest) )
        }
        
        let message = json[Bleet.FieldNames.message.rawValue].stringValue
        
        // TODO: functionalize kassandra
        return kassandra.connect(with: "blitter")
            .then {
                _ in
                "SELECT subscriber FROM subscription WHERE author='\(userID)'"
                    |> self.kassandra.execute
            }
            .then {
                result -> FnRouterResponse in
                result
                    .asRows!
                    .flatMap {  $0[Subscription.Field.subscriber.rawValue] as? String }
                    .map {
                        Bleet( id:          UUID(),
                               author:      userID,
                               subscriber:  $0,
                               message:     message,
                               postDate:    Date())
                    }
                    .forEach { $0.save() {_ in } }
                
                return .status(.OK)
        }
    }
    
    
    public func getMyFeed(request: RouterRequest) -> FutureRouterResponse {
        let userID = authenticate(request: request, defaultUser: "Jack")
        
        return kassandra.connect(with: "blitter")
            .then {
                _ in
                Bleet.fetch(predicate: Bleet.Field.subscriber.rawValue == userID, limit: 50)
            }
            .then ( FnRouterResponse.init(bleets:) )
    }
    
    
    public func getUserFeed(request: RouterRequest) -> FutureRouterResponse {
        guard let myUsername = request.parameters["user"] else {
            return Future(outcome: .status(.badRequest) )
        }
        return kassandra.connect(with: "blitter")
            .then {
                _ in
                Bleet.fetch(predicate: Bleet.Field.author.rawValue == myUsername, limit: 50)
            }
            .then ( FnRouterResponse.init(bleets:) )
    }
    
    
    public func followAuthor(request: RouterRequest) -> FutureRouterResponse {
        let myUsername = authenticate(request: request, defaultUser: "Jack")
        
        guard let author = request.parameters["user"] else {
            return Future(outcome: .status(.badRequest) )
        }
        return kassandra.connect(with: "blitter")
            .then {
                _ in
                Subscription.insert([.id: UUID(), .author: author, .subscriber: myUsername])
                    .execute()
            }
            .then {
                _ in
                FnRouterResponse.status(.OK)
        }
    }
}
