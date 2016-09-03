//
//  FnKitura.swift
//  Blitter
//
//  Created by David Ungar on 9/2/16.
//
//

import Foundation
import FunctionalProgramming
import Kitura
import KituraNet
import SwiftyJSON


public enum FnRouterResponse {
    case error(Swift.Error)
    case status(HTTPStatusCode)
    case json(JSON)
    
    init(bleets: ResultOrError<[Bleet]>) {
        switch bleets {
        case .failure(let error): self = .error(error)
        case .success(let r):     self = .json( JSON(r.stringValuePairs) )
        }
    }
}

public typealias FutureRouterResponse = Future<FnRouterResponse>
public typealias FnRouterHandler = (RouterRequest) -> FutureRouterResponse

