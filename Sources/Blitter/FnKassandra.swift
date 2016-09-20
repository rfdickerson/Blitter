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


public extension Model {
    public static func fetch(_ fields: [Field] = [], predicate: Predicate? = nil, limit: Int? = nil) -> Future<ResultOrError<[Self]>> {
        let future = Future<ResultOrError<[Self]>>()
        fetch(fields, predicate: predicate, limit: limit) {
            selves, error in
            ( error.map { .failure($0) } ?? .success( selves ?? [] ) )
            |> future.write
        }
        return future
    }
}


public extension Query {
    public func execute() -> Future<KassandraResult> {
        let future = Future<KassandraResult>()
        execute { future.write($0) }
        return future
    }
}
