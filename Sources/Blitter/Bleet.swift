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

import Foundation
import Kassandra

struct Bleet {
    enum FieldNames: String {
        case id, author, subscriber, message, postDate
    }

    
    var id          : UUID?
    let author      : String
    let subscriber  : String
    let message     : String
    let postDate    : Date
    
}

extension Bleet: Model {
    
    enum Field: String {
        case id, author, subscriber, message
        case postDate = "postdate" // Cassandra stores column names in lowercase
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
        self.id         = row[Field.id         .rawValue]  as? UUID
        self.author     = row[Field.author     .rawValue]  as! String
        self.subscriber = row[Field.subscriber .rawValue]  as! String
        self.message    = row[Field.message    .rawValue]  as! String
        self.postDate   = row[Field.postDate   .rawValue]  as! Date
    }
}


typealias JSONDictionary = [String : Any]

extension Bleet: DictionaryConvertible {
    func toDictionary() -> JSONDictionary {
        var result = JSONDictionary()
        // var result = [String:Any]()
        
        result[FieldNames.id         .rawValue]  = "\(self.id!)"
        result[FieldNames.author     .rawValue]  = self.author
        result[FieldNames.subscriber .rawValue]  = self.subscriber
        result[FieldNames.message    .rawValue]  = self.message
        result[FieldNames.postDate   .rawValue]  = "\(self.postDate)"
        
        return result
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
