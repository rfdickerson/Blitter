/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

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
                $0.fillIn(response: response, next: next)
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
