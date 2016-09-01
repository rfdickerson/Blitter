//
//  Pipe.swift
//  Blitter
//
//  Created by David Ungar on 8/31/16.
//
//

import Foundation

public class Pipe<OutcomeParm> {
    public typealias Me = Pipe<OutcomeParm>
    public typealias Outcome = OutcomeParm
    
    fileprivate let internalSynchronizationQueue = DispatchQueue(label: "Pipe internalSynchronizationQueue")
    
    fileprivate var outcomes: [Outcome] = []
    
    fileprivate var readFn: ( (Outcome?) -> Void)?
    fileprivate let readerQueue: DispatchQueue
    
    fileprivate var areWritesPossible = true
    
    public init(readerQueue: DispatchQueue) {
        self.readerQueue = readerQueue
    }
    public convenience init(qos: AsynchronousOutcomeQOS) {
        self.init(readerQueue: qos.queue)
    }
    
    public func readEach(
        function: String = #function,
        file: String = #file,
        line: Int = #line,
        
        fn: @escaping (Outcome?) -> Void )
    {
        let loc = SourceLocation(function: function, file: file, line: line)
        let me = self
        
        internalSynchronizationQueue.sync {
            assert(me.areWritesPossible)
            me.readFn = fn
            for outcome in me.outcomes {
                me.dispatchAReadFrom(loc) { fn(outcome) }
            }
            me.outcomes.removeAll()
            if !me.areWritesPossible {
                me.dispatchAReadFrom(loc) { fn(nil) }
            }
        }
    }
    
    
    public func readForEach(
        function: String = #function,
        file: String = #file,
        line: Int = #line,
        
        eachFn: @escaping (Outcome) -> Void)
        -> Future<Outcome?>
    {
        
        var finalOutcome: Outcome?
        let output = Future<Outcome?>()
        
        readEach(function: function, file: file, line: line) {
            switch $0 {
            case let outcome?:
                finalOutcome = outcome
                eachFn(outcome)
            case nil:
                output.write(finalOutcome)
            }
        }
        return output
    }
    
    
    @discardableResult
    public func write(
        outcome: Outcome,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        )
        -> Should_be_Pipe_but_Swift_compiler_balks
    {
        let loc = SourceLocation(function: function, file: file, line: line)
        let me = self
        internalSynchronizationQueue.sync {
            assert(me.areWritesPossible)
            if let fn = me.readFn  {
                me.dispatchAReadFrom(loc) { fn(outcome) }
            }
            else {
                me.outcomes.append(outcome)
            }
        }
        return self
    }
    
    public func close(
        function: String = #function,
        file: String = #file,
        line: Int = #line
        )
    {
        let loc = SourceLocation(function: function, file: file, line: line)
        let me = self
        internalSynchronizationQueue.sync {
            me.areWritesPossible = false
            if let fn = me.readFn {
                me.dispatchAReadFrom(loc) { fn(nil) }
            }
        }
    }
    
    fileprivate func dispatchAReadFrom( _ loc: SourceLocation,  fn: @escaping () -> Void) {
        readerQueue.async(execute: fn)
    }
}

public func writeToPipeOnReaderQueue<T>(
    queue: DispatchQueue,
    outcome: T,
    function: String = #function,
    file: String = #file,
    line: Int = #line
    )
    -> Should_be_Pipe_but_Swift_compiler_balks<T>
{
    return Should_be_Pipe_but_Swift_compiler_balks<T>(readerQueue: queue).write(outcome: outcome, function: function, file: file, line: line)
}
