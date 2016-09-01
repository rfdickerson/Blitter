//
//  ResultOrError.swift
//  Blitter
//
//  Created by David Ungar on 8/31/16.
//
//

import Foundation

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
            return .failure(Errors.alreadyHandled)
        }
    }
}


