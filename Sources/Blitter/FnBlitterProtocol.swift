//
//  FnBlitterProtocol.swift
//  Blitter
//
//  Created by David Ungar on 9/2/16.
//
//

import Foundation
import Kitura

protocol FnBlitterProtocol {
    
    var router: Router { get }
    
    func bleet       (request: RouterRequest) -> FutureRouterResponse
    func getMyFeed   (request: RouterRequest) -> FutureRouterResponse
    func getUserFeed (request: RouterRequest) -> FutureRouterResponse
    func followAuthor(request: RouterRequest) -> FutureRouterResponse
}
