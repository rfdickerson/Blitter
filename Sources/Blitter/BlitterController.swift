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

public class BlitterController {
  
    let kassandra = Kassandra()
    public let router = Router()
    
    public init() {
        router.all("/*", middleware: BodyParser())
        router.get("/", handler: getMyFeed)
        router.get("/:user", handler: getUserFeed)
        router.post("/", handler: bleet)
        router.put("/:user", handler: followAuthor)
    }
}

extension BlitterController: BlitterProtocol {

public func bleet(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    
    //let profile = request.userProfile
    
    let kassandra = Kassandra()
    
    let userID = "Robert"
    
    guard let body = request.body else {
        response.status(.badRequest)
        Log.warning("No body in the message")
        return
    }
    
    guard case let .json(json) = body else {
        response.status(.badRequest)
        Log.warning("Body was not formed as JSON")
        return
    }
    
    let message = json["message"].stringValue
    
    try kassandra.connect(with: "blitter") { result in
        
        kassandra.execute("select subscriber from subscription where author='\(userID)'"){ result in
            let rows = result.asRows!
            
            let subscribers: [String] = rows.map {
                return $0["subscriber"] as! String
            }
            
            let newbleets: [Bleet] = subscribers.map {
                let bleet = Bleet( id:          UUID(),
                                   author:      userID,
                                   subscriber:  $0,
                                   message:     message,
                                   postDate:    Date())
                return bleet
            }
            
            newbleets.forEach { $0.save() { _ in } }
            
            response.status(.OK)
            next()
            
            
        }
        
    }
}

public func getMyFeed(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    
    //let userID: String = request.userProfile?.name
    
    /*guard let userID = request.parameters["userID"] else {
     response.status(.badRequest)
     return
     }*/
    let user = "Jack"
    
    try kassandra.connect(with: "blitter") { result in
        Bleet.fetch(predicate: "subscriber" == user, limit: 50) { bleets, error in
            if let twts = bleets {
                do {
                    try response.status(.OK).send(json: JSON(twts.toDictionary())).end()
                    
                } catch {
                    print(error)
                }
            }
        }
    }
}

public func getUserFeed(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    
    guard let myUsername = request.parameters["user"] else {
        response.status(.badRequest)
        return
    }
    
    try kassandra.connect(with: "blitter") { result in
        Bleet.fetch(predicate: "author" == myUsername, limit: 50) { bleets, error in
            
            if let twts = bleets {
                do {
                    try response.status(.OK).send(json: JSON(twts.toDictionary())).end()
                    
                } catch {
                    print(error)
                }
            }
        }
    }
}


public func followAuthor(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    
    let author = "Raymond"
    
    guard let myUsername = request.parameters["user"] else {
        response.status(.badRequest)
        return
    }
    try kassandra.connect(with: "blitter") { _ in
        Subscription.insert([.id: UUID(), .author: author, .subscriber: myUsername]).execute { result in
            do {
                try response.status(.OK).end()
                
            } catch {
                print(error)
            }
        }
    }
}


}



