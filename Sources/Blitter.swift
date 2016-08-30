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

public func bleet(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    
    //let profile = request.userProfile
    let userID = "Chia"
    
    guard let body = request.body else {
        response.status(.badRequest)
        return
    }
    
    guard case let .json(json) = body else {
        response.status(.badRequest)
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

public func getMyFeed(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
    
    //let userID: String = request.userProfile?.name
    
    /*guard let userID = request.parameters["userID"] else {
     response.status(.badRequest)
     return
     }*/
    let user = "Robert"
    
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

public func getUserFeed(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
    
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


public func followAuthor(request: RouterRequest, response: RouterResponse, next: () -> Void) throws {
    
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

protocol DictionaryConvertible {
    func toDictionary() -> JSONDictionary
}

extension Array where Element : DictionaryConvertible {
    
    func toDictionary() -> [JSONDictionary] {
        
        return self.map { $0.toDictionary() }
        
    }
    
}

//create table bleetgroup(id uuid, followee text, follower text, bleet text, timestamp timestamp, primary key(id));

struct Bleet {
    
    var id          : UUID?
    let author      : String
    let subscriber  : String
    let message     : String
    let postDate    : Date
    
}

extension Bleet: Model {
    
    enum Field: String {
        case id         = "id"
        case author     = "author"
        case subscriber = "subscriber"
        case message    = "text"
        case postDate   = "postdate"
    }
    
    static let tableName = "bleet"
    
    static var primaryKey: Field {
        return Field.id
    }
    
    static var fieldTypes: [Field: DataType] {
        return [
            .id         : .uuid,
            .author     : .text,
            .subscriber : .text,
            .message    : .text,
            .postDate   : .timestamp
        ]
    }
    
    var key: UUID? {
        get {
            return self.id
        }
        set {
            self.id = newValue
        }
    }
    
    init(row: Row) {
        self.id         = row["id"]         as? UUID
        self.author     = row["author"]     as! String
        self.subscriber = row["subscriber"] as! String
        self.message    = row["message"]    as! String
        self.postDate   = row["postdate"]   as! Date
    }
}


typealias JSONDictionary = [String : Any]

extension Bleet: DictionaryConvertible {
    func toDictionary() -> JSONDictionary {
        var result = JSONDictionary()
        // var result = [String:Any]()
        
        result["id"]          = "\(self.id!)"
        result["author"]      = self.author
        result["subscriber"]  = self.subscriber
        result["message"]     = self.message
        result["postdate"]    = "\(self.postDate)"
        
        return result
    }
}

struct Subscription {
    var id: UUID?
    let author: String
    let subscriber: String
}

extension Subscription: Model {
    enum Field: String {
        case id         = "id"
        case author     = "author"
        case subscriber = "subscriber"
    }
    
    static let tableName = "subscription"
    
    static var primaryKey: Field {
        return Field.id
    }
    
    static var fieldTypes: [Field: DataType] {
        return [.id  : .uuid, .author: .text, .subscriber: .text]
    }
    
    var key: UUID? {
        get {
            return self.id
        }
        set {
            self.id = newValue
        }
    }
    
    init(row: Row) {
        self.id         = row["id"] as? UUID
        self.author     = row["author"] as! String
        self.subscriber   = row["subscriber"] as! String
    }
}
