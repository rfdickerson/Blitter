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
import Kitura
import LoggerAPI
import SwiftyJSON

func authenticate(request: RouterRequest, defaultUser: String) -> String {
    return request.userProfile?.id ?? defaultUser
}

enum BlitterError : Error {
    case noJSON
}

enum Result<T> {
    case success(T)
    case error(Error)
    
    var value: T? {
        switch self {
        case .success (let value): return value
        case .error: return nil
        }
    }
    
    var error: Error? {
        switch self {
        case .success: return nil
        case .error(let error): return error
        }
    }
}

extension RouterRequest {
    
    var json: JSON? {
        
        guard let body = self.body else {
            Log.warning("No body in the message")
            return nil
        }
        
        guard case let .json(json) = body else {
            Log.warning("Body was not formed as JSON")
            return nil
        }
        
        return json
    }
}
