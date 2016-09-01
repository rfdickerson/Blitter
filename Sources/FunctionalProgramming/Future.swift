//
//  Future.swift
//  Blitter
//
//  Created by David Ungar on 8/31/16.
//
//

import Foundation

//: Simple Future implementation, no errors, no composition
//: Leaks memory, most likely


public class Future<Outcome> {
    private typealias Reader = (Outcome) -> Void
    private var outcomeIfKnown: Outcome?
    private var readerIfKnown: Reader?
    
    
    private let racePrevention = DispatchSemaphore(value: 1)
    private func oneAtATime(_ fn: () -> Void) {
        defer { racePrevention.signal() }
        racePrevention.wait()
        fn()
    }
    
    
    public init() {}
    
    
    public func write(_ outcome: Outcome) -> Void {
        oneAtATime {
            if let reader = self.readerIfKnown {
                DispatchQueue(label: "Future reader", qos: .userInitiated)
                .async {
                    reader(outcome)
                }
            }
            else {
                self.outcomeIfKnown = outcome
            }
        }
    }
    
    public func then<NewOutcome>(
        qos: FutureQOS = .userInitiated,
        _ fn: @escaping (Outcome) -> Future<NewOutcome>
        )
        -> Future<NewOutcome>
    {
        let future = Future<NewOutcome>()
        finally(qos: qos) {
            fn($0).finally(future.write)
        }
        return future
    }
    
    public func finally(
        qos: FutureQOS = .userInitiated,
        _ reader: @escaping (Outcome) -> Void
        )
    {
        oneAtATime {
            if let outcome = self.outcomeIfKnown {
                DispatchQueue(label: "Future reader", qos: .userInitiated)
                .async {
                    reader(outcome)
                }
            }
            else {
                self.readerIfKnown = reader
            }
        }
    }
}


public protocol ResultOrErrorProtocol {
    associatedtype Result
    var asResultOrError: ResultOrError<Result> { get }
}
extension ResultOrError: ResultOrErrorProtocol {
    public var asResultOrError: ResultOrError { return self }
}

public extension Future where Outcome: ResultOrErrorProtocol {
    
    // Consuming function produces a Future:
    public func thenIfSuccess<NewResult>( _ fn: @escaping (Outcome.Result) -> Future<ResultOrError<NewResult>>) -> Future<ResultOrError<NewResult>> {
        let future = Future<ResultOrError<NewResult>>()
        finally {
            switch $0.asResultOrError {
            case .success(let result):  fn(result).finally( future.write )
            case .failure(let error ):  future.write( .failure(error) )
            }
        }
        return future
    }
    
    // Consuming function produces a new result type:
    public func thenIfSuccess<NewResult>( _ fn: @escaping (Outcome.Result) -> NewResult) -> Future<ResultOrError<NewResult>> {
        let future = Future<ResultOrError<NewResult>>()
        finally {
            switch $0.asResultOrError {
            case .success(let result):  future.write( .success( fn(result) ) )
            case .failure(let error ):  future.write( .failure(error)        )
            }
        }
        return future
    }
    
    // Consuming function consumes error, produces nothing:
    public func thenIfFailure( _ fn: @escaping (Error) -> Void) -> Future<ResultOrError<Outcome.Result>> {
        let future = Future<ResultOrError<Outcome.Result>>()
        finally {
            switch $0.asResultOrError {
            case .success: future.write($0.asResultOrError)
            case .failure(let error):
                fn(error)
                future.write(.failure(AlreadyHandledError(error: error)))
            }
        }
        return future
    }
}
