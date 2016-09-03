//
//  fnKassandra.swift
//  Blitter
//
//  Created by David Ungar on 9/2/16.
//
//

import Foundation
import FunctionalProgramming
import Kassandra

public typealias KassandraResult = Result


public extension Kassandra {
    // TODO: factor this code
    public func connect(with keyspace: String? = nil) -> Future<KassandraResult> {
        let future = Future<KassandraResult>()
        do { try connect(with: keyspace, oncompletion: future.write) }
        catch { future.write( .error(error)) }
        return future
    }
    
    public func execute(_ query: String) -> Future<KassandraResult> {
        let future = Future<KassandraResult>()
        execute(query, oncompletion: future.write)
        return future
    }
    public func execute(_ query: Query) -> Future<KassandraResult> {
        let future = Future<KassandraResult>()
        execute(query, oncompletion: future.write)
        return future
    }
    public func execute(_ request: Request) -> Future<KassandraResult> {
        let future = Future<KassandraResult>()
        execute(request, oncompletion: future.write)
        return future
    }
}
