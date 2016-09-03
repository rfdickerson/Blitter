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
    
    func fillIn(response: RouterResponse, next: () -> Void) {
        switch self {
        case .error(let error):
            response.error = error
            next()
        case .status(let status):
            response.status(status)
            next()
        case .json(let json):
            ResultOrError( catching: { try response.status(.OK).send(json: json).end() } )
                .ifFailure { response.error = $0 }
        }
    }
}

public typealias FutureRouterResponse = Future<FnRouterResponse>
public typealias FnRouterHandler = (RouterRequest) -> FutureRouterResponse

