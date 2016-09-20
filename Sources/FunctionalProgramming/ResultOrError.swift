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

public typealias VoidOrError = ResultOrError<Void>

public enum ResultOrError<Result> {
    case failure(Error)
    case success(Result)
    
    // Success consumer might fail:
    @discardableResult // avoid a warning if result is not used
    public func ifSuccess<NewResult>(_ fn: (Result) -> ResultOrError<NewResult>) -> ResultOrError<NewResult> {
        switch self {
            // Because compiler infers types
        // you don't have to say "return ResultOrError<NewResult>.failure(e)" below.
        case .failure(let e): return .failure(e)
        case .success(let r): return fn(r)
        }
    }
    
    // Success consumer always succeeds:
    @discardableResult // avoid a warning if result is not used
    public func ifSuccess<NewResult>( _ fn: (Result) -> NewResult )  -> ResultOrError<NewResult>  {
        switch self {
        case .failure(let e): return .failure(e)
        case .success(let r): return ResultOrError<NewResult>.success( fn(r) )
        }
    }
    
    @discardableResult // avoid a warning if result is not used
    public func ifFailure(_ fn: (Error) -> Void) -> ResultOrError {
        switch self {
        case .success: return self
        case .failure(let e):
            fn(e)
            return .failure(AlreadyHandledError(error: e))
        }
    }
    
    // integration with synchronous errors
    
    public init( catching fn: () throws -> Result ) {
        do      { self = try .success(  fn()  ) }
        catch   { self = .failure(  error ) }
    }
    
}


