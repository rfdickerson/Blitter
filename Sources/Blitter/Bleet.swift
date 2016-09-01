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
        case message    = "message"
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




extension Bleet: StringValuePairConvertible {
    var stringValuePairs: StringValuePair {
        var result = StringValuePair()
        
        result["id"]          = "\(self.id!)"
        result["author"]      = self.author
        result["subscriber"]  = self.subscriber
        result["message"]     = self.message
        result["postdate"]    = "\(self.postDate)"
        
        return result
    }
}

