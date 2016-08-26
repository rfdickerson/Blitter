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
//import CredentialsFacebook

public func tweet(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    
    guard let body = request.body else {
        response.status(.badRequest)
        return
    }
    
    guard case let .json(json) = body else {
        response.status(.badRequest)
        return
    }
    
    let user    = json["user"].stringValue
    let message = json["body"].stringValue
    let time    = DateFormatter().date(from: json["timestamp"].stringValue)!
    
    let post = Post(id: UUID(), user: user, body: message, timestamp: time)
    
    post.save() { _ in
        
        do {
            try response.status(.OK).end()
            
        } catch {
            print(error)
        }
    }
    
}

public func getAll(request: RouterRequest, response: RouterResponse, next: () -> Void) {
    
    //let userID: String = request.userProfile?.name
    
    guard let userID = request.parameters["userID"] else {
        response.status(.badRequest)
        return
    }
    
    Relationship.fetch(predicate: "user" == userID, limit: 50) { result, error in
        
        let friends = result!.map { $0.follower }
                
        Post.fetch(predicate: "user" > friends, limit: 50) { tweets, error in
            
            if let twts = tweets {
                do {
                    try response.status(.OK).send(json: JSON(twts.toDictionary())).end()
                    
                } catch {
                    print(error)
                }
            }
        }
        
    }
    
}

public func follow(request: RouterRequest, response: RouterResponse, next: () -> Void) {

    guard let body = request.body else {
        response.status(.badRequest)
        return
    }
    
    guard case let .json(json) = body else {
        response.status(.badRequest)
        return
    }
    
    let user1 = json["followee"].stringValue
    let user2 = json["follower"].stringValue
    
    Relationship.insert([.id: UUID(), .follower: user1, .followee: user2]).execute { _ in
        
        do {
            try response.status(.OK).end()

        } catch {
            print(error)
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

struct Post {
    var id: UUID?
    let user: String
    let body: String
    let timestamp: Date
}

extension Post: Model {
    enum Field: String {
        case id = "id"
        case user = "user"
        case body  = "message"
        case timestamp = "timestamp"
    }

    static let tableName = "Posts"
    
    static var primaryKey: Field {
        return Field.id
    }
    
    static var fieldTypes: [Field: DataType] {
        return [
                .id         : .uuid,
                .user       : .text,
                .body       : .text,
                .timestamp  : .timestamp
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
        self.id         = row["id"] as? UUID
        self.user       = row["user"] as! String
        self.body       = row["body"] as! String
        self.timestamp  = row["timestamp"] as! Date
    }
}
typealias JSONDictionary = [String : AnyObject]

extension Post: DictionaryConvertible {
    func toDictionary() -> JSONDictionary {
        var result = JSONDictionary()
        result["id"]        = self.id
        result["user"]      = self.user
        result["body"]      = self.body
        result["timestamp"] = self.timestamp

        return result
    }
}
struct Users {
    var id: UUID?
    let name: String
}

extension Users: Model {
    enum Field: String {
        case id = "id"
        case name = "name"
    }
    
    static let tableName = "Users"

    static var primaryKey: Field {
        return Field.id
    }
    
    static var fieldTypes: [Field: DataType] {
        return [.id  : .uuid, .name: .text]
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
        self.name       = row["name"] as! String
    }
}

struct Relationship {
    var id: UUID?
    let followee: String
    let follower: String
}

extension Relationship: Model {
    enum Field: String {
        case id         = "id"
        case followee   = "followee"
        case follower   = "follower"
    }
    
    static let tableName = "Relationship"
    
    static var primaryKey: Field {
        return Field.id
    }
    
    static var fieldTypes: [Field: DataType] {
        return [.id  : .uuid, .followee: .text, .follower: .text]
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
        self.follower   = row["follower"] as! String
        self.followee   = row["followee"] as! String
    }
}
//create keyspace twissandra with replication = {'class':'SimpleStrategy', 'replication_factor' : 1};
//create table post(id uuid primary key, user text, body text, timestamp timestamp) ;
//create table user(id uuid primary key, name text) ;
//create table relationship(id uuid primary key, followee text, follower text) ;
//CREATE INDEX ON twissandra.relationship (follower);
