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
                case .error(let error): response.error = error
                case .status(let status): response.status(status)
                case .json(let json):
                    ResultOrError( catching: { try response.status(.OK).send(json: json).end() } )
                        .ifFailure { response.error = $0 }
                }
                next()
        }
    }
}
// TODO: FnBlitterProtocol
extension FnBlitterController {
    
    
    
    public func bleet(request: RouterRequest) -> FutureRouterResponse {
        let future = FutureRouterResponse()
        let userID = authenticate(request: request, defaultUser: "Robert")
        
        let jsonResult = request.json
        guard let json = jsonResult else {
            future.write( .status(.badRequest) )
            return future
        }
        
        let message = json[Bleet.FieldNames.message.rawValue].stringValue
        
        // TODO: functionalize kassandra
        do {try self.kassandra.connect(with: "blitter") { result in
            
            let sql = "SELECT subscriber FROM subscription WHERE author='\(userID)'"
            self.kassandra.execute(sql){ result in
                let rows = result.asRows!
                
                let subscribers: [String] = rows.flatMap {
                    $0[Subscription.Field.subscriber.rawValue] as? String
                }
                
                let newbleets: [Bleet] = subscribers.map {
                    Bleet( id:          UUID(),
                           author:      userID,
                           subscriber:  $0,
                           message:     message,
                           postDate:    Date())
                }
                
                newbleets.forEach { $0.save() { _ in } }
                
                future.write(.status(.OK))
            }
            
            }
        }
        catch { future.write(.error(error)) }
        return future
    }
    
    public func getMyFeed(request: RouterRequest) -> FutureRouterResponse {
        let future = FutureRouterResponse()
        
        let userID = authenticate(request: request, defaultUser: "Jack")
        
        do {
            try kassandra.connect(with: "blitter") { result in
                Bleet.fetch(predicate: Bleet.Field.subscriber.rawValue == userID, limit: 50) { bleets, error in
                    if let twts = bleets {
                        future.write( .json( JSON(twts.stringValuePairs) ) )
                    }
                }
            }
        }
        catch { future.write(.error(error)) }
        
        return future
    }
    
    
    public func getUserFeed(request: RouterRequest) -> FutureRouterResponse {
        let future = FutureRouterResponse()
        
        guard let myUsername = request.parameters["user"] else {
            future.write( .status(.badRequest) )
            return future
        }
        do {
            try kassandra.connect(with: "blitter") { result in
                Bleet.fetch(predicate: Bleet.Field.author.rawValue == myUsername, limit: 50) { bleets, error in
                    
                    if let twts = bleets {
                        future.write( .json( JSON(twts.stringValuePairs) ) )
                    }
                }
            }
        }
        catch { future.write(.error(error)) }
        
        return future
    }
    
    
    public func followAuthor(request: RouterRequest) -> FutureRouterResponse {
        let future = FutureRouterResponse()
        
        let myUsername = authenticate(request: request, defaultUser: "Jack")
        
        guard let author = request.parameters["user"] else {
            future.write( .status(.badRequest) )
            return future
        }
        do {
            try kassandra.connect(with: "blitter") { _ in
                Subscription.insert([.id: UUID(), .author: author, .subscriber: myUsername]).execute { result in
                    future.write( .status(.OK) )
                }
            }
        }
        catch { future.write(.error(error)) }
        
        return future
    }
    
    
}
